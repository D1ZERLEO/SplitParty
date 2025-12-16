from fastapi import FastAPI, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from database import SessionLocal, engine, Base
from models import User
from schemas import RegisterIn, LoginIn, TokenResponse, UserOut
from auth import hash_password, verify_password, create_access_token, decode_token
from utils import generate_verification_token, token_expiration_time
from email_utils import send_verification_email
from datetime import datetime, timedelta
import os

# создаём таблицы, если ещё нет
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Auth API")

# dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/register", response_model=UserOut)
def register(data: RegisterIn, db: Session = Depends(get_db)):
    # email/nick uniqueness
    exists = db.query(User).filter((User.email == data.email) | (User.nickname == data.nickname)).first()
    if exists:
        if exists.email == data.email:
            raise HTTPException(status_code=400, detail="Email already registered")
        else:
            raise HTTPException(status_code=400, detail="Nickname already taken")

    pw_hash = hash_password(data.password)
    token = generate_verification_token()
    expires = token_expiration_time()

    user = User(
        email=data.email,
        nickname=data.nickname,
        password_hash=pw_hash,
        verified=False,
        verification_token=token,
        token_expires=expires
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    print(f"=== VERIFICATION TOKEN FOR {user.email}: {token} ===")
    print(f"=== Use this token in /verify endpoint ===")
    # send email (async would be nicer; for now sync)
    try:
        send_verification_email(user.email, token)
    except Exception as e:
        # логируем, но не откатываем создание пользователя
        print("Email send failed:", e)

    return user

@app.post("/verify")
def verify(token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.verification_token == token).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid token")
    if user.token_expires and user.token_expires < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Token expired")
    user.verified = True
    user.verification_token = None
    user.token_expires = None
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"detail": "Email verified"}

@app.post("/login", response_model=TokenResponse)
def login(data: LoginIn, db: Session = Depends(get_db)):
    # find by email or nickname
    user = db.query(User).filter((User.email == data.email_or_nick) | (User.nickname == data.email_or_nick)).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    if not user.verified:
        raise HTTPException(status_code=403, detail="Email not verified")

    access_token = create_access_token({"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}

from fastapi.security import HTTPBearer
bearer_scheme = HTTPBearer()
def get_current_user(token: str = Depends(bearer_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token.credentials)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token payload")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.get("/me", response_model=UserOut)
def me(current_user: User = Depends(get_current_user)):
    return current_user

from sqlalchemy.orm import Session
from sqlalchemy import and_
from models import Gathering, GatheringParticipant, Receipt, ReceiptItem, UserReceiptItem
from schemas import (
    GatheringCreate, GatheringOut,
    ReceiptCreate, ReceiptOut,
    AssignItemsRequest, ReceiptStatusResponse, ReceiptSummaryResponse, ReceiptSummaryUser
)

# --- Gatherings ---
@app.post("/gatherings", response_model=GatheringOut)
def create_gathering(
    data: GatheringCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    gathering = Gathering(name=data.name, description=data.description, admin_id=current_user.id)
    db.add(gathering)
    db.commit()
    db.refresh(gathering)
    # Автоматически добавить создателя как участника
    db.add(GatheringParticipant(gathering_id=gathering.id, user_id=current_user.id))
    db.commit()
    return gathering

@app.post("/gatherings/{gathering_id}/join")
def join_gathering(
    gathering_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Проверить, существует ли тусовка
    gathering = db.query(Gathering).filter(Gathering.id == gathering_id).first()
    if not gathering:
        raise HTTPException(status_code=404, detail="Gathering not found")
    # Проверить, не участник ли уже
    existing = db.query(GatheringParticipant).filter_by(
        gathering_id=gathering_id, user_id=current_user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already a participant")
    # Добавить
    db.add(GatheringParticipant(gathering_id=gathering_id, user_id=current_user.id))
    db.commit()
    return {"detail": "Joined successfully"}

# --- Receipts ---
@app.post("/gatherings/{gathering_id}/receipts", response_model=ReceiptOut)
def add_receipt(
    gathering_id: int,
    data: ReceiptCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Проверить, что пользователь — участник
    participant = db.query(GatheringParticipant).filter_by(
        gathering_id=gathering_id, user_id=current_user.id
    ).first()
    if not participant:
        raise HTTPException(status_code=403, detail="Not a participant of this gathering")

    total = sum(item.price for item in data.items)
    receipt = Receipt(
        gathering_id=gathering_id,
        name=data.name,
        total_amount=total,
        created_by=current_user.id
    )
    db.add(receipt)
    db.commit()
    db.refresh(receipt)

    # Добавить позиции
    items = []
    for item_data in data.items:
        item = ReceiptItem(
            receipt_id=receipt.id,
            name=item_data.name,
            price=item_data.price
        )
        db.add(item)
        items.append(item)
    db.commit()
    for item in items:
        db.refresh(item)

    return ReceiptOut(
        id=receipt.id,
        name=receipt.name,
        total_amount=float(receipt.total_amount),
        currency=receipt.currency,
        created_by=receipt.created_by,
        items=[ReceiptItemOut.from_orm(i) for i in items]
    )

# --- Assign items (плюсик) ---
@app.post("/receipts/{receipt_id}/assign")
def assign_items(
    receipt_id: int,
    request: AssignItemsRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Проверить, что чек существует и пользователь — участник тусовки
    receipt = db.query(Receipt).filter(Receipt.id == receipt_id).first()
    if not receipt:
        raise HTTPException(status_code=404, detail="Receipt not found")
    participant = db.query(GatheringParticipant).filter_by(
        gathering_id=receipt.gathering_id, user_id=current_user.id
    ).first()
    if not participant:
        raise HTTPException(status_code=403, detail="Not a participant")

    # Удалить старые отметки пользователя для этого чека
    db.query(UserReceiptItem).filter(
        UserReceiptItem.user_id == current_user.id,
        UserReceiptItem.receipt_item_id.in_(
            db.query(ReceiptItem.id).filter(ReceiptItem.receipt_id == receipt_id)
        )
    ).delete(synchronize_session=False)

    # Добавить новые отметки
    for item_id in request.item_ids:
        # Проверить, что item_id принадлежит этому чеку
        item = db.query(ReceiptItem).filter(
            ReceiptItem.id == item_id,
            ReceiptItem.receipt_id == receipt_id
        ).first()
        if not item:
            raise HTTPException(status_code=400, detail=f"Item {item_id} not in this receipt")
        db.add(UserReceiptItem(user_id=current_user.id, receipt_item_id=item_id))

    db.commit()
    return {"detail": "Assigned successfully"}

# --- Кнопка "Не участвовал" = вызов assign_items с пустым списком
@app.post("/receipts/{receipt_id}/not-participating")
def not_participating(
    receipt_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return assign_items(receipt_id, AssignItemsRequest(item_ids=[]), current_user, db)

# --- Статус чека для пользователя ---
@app.get("/receipts/{receipt_id}/status", response_model=ReceiptStatusResponse)
def receipt_status(
    receipt_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    count = db.query(UserReceiptItem).join(ReceiptItem).filter(
        UserReceiptItem.user_id == current_user.id,
        ReceiptItem.receipt_id == receipt_id
    ).count()
    status = "completed" if count > 0 else "pending"
    return ReceiptStatusResponse(status=status)

# --- Итог по чеку ---
@app.get("/receipts/{receipt_id}/summary", response_model=ReceiptSummaryResponse)
def receipt_summary(
    receipt_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Проверить доступ
    receipt = db.query(Receipt).filter(Receipt.id == receipt_id).first()
    if not receipt:
        raise HTTPException(status_code=404, detail="Receipt not found")
    participant = db.query(GatheringParticipant).filter_by(
        gathering_id=receipt.gathering_id, user_id=current_user.id
    ).first()
    if not participant:
        raise HTTPException(status_code=403, detail="Not a participant")

    # Все позиции чека
    items = db.query(ReceiptItem).filter(ReceiptItem.receipt_id == receipt_id).all()

    # Все участники тусовки
    participants = db.query(GatheringParticipant).filter(
        GatheringParticipant.gathering_id == receipt.gathering_id
    ).all()
    user_ids = [p.user_id for p in participants]
    users = {u.id: u for u in db.query(User).filter(User.id.in_(user_ids)).all()}

    # Сколько заплатил каждый
    paid_by_user = {}
    for user_id in user_ids:
        total = db.query(func.coalesce(func.sum(ReceiptItem.price), 0)).select_from(UserReceiptItem)\
            .join(ReceiptItem, UserReceiptItem.receipt_item_id == ReceiptItem.id)\
            .filter(UserReceiptItem.user_id == user_id, ReceiptItem.receipt_id == receipt_id)\
            .scalar()
        paid_by_user[user_id] = float(total)

    summary_users = [
        ReceiptSummaryUser(
            user_id=uid,
            nickname=users[uid].nickname,
            total_paid=paid_by_user[uid]
        )
        for uid in user_ids
    ]

    return ReceiptSummaryResponse(
        items=[ReceiptItemOut.from_orm(i) for i in items],
        total_paid_by_user=summary_users
    )
print()
