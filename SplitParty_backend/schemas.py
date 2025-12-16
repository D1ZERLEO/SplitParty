from pydantic import BaseModel, EmailStr, validator
import re
from typing import Optional

NICK_RE = re.compile(r'^[A-Za-z0-9_]{3,30}$')

class RegisterIn(BaseModel):
    email: EmailStr
    nickname: str
    password: str

    @validator('nickname')
    def valid_nick(cls, v):
        if not NICK_RE.match(v):
            raise ValueError('Nickname: 3-30 characters, letters, digits, underscore only')
        return v

    @validator('password')
    def valid_password(cls, v):
        # Минимум 8 символов; можно добавить сложности
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

class LoginIn(BaseModel):
    email_or_nick: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserOut(BaseModel):
    id: int
    email: EmailStr
    nickname: str
    verified: bool

    class Config:
        orm_mode = True


from typing import List, Optional

# --- Gatherings ---
class GatheringCreate(BaseModel):
    name: str
    description: Optional[str] = None

class GatheringOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    admin_id: int

    class Config:
        orm_mode = True

# --- Receipts ---
class ReceiptItemCreate(BaseModel):
    name: str
    price: float

class ReceiptCreate(BaseModel):
    name: Optional[str] = None
    items: List[ReceiptItemCreate]

class ReceiptItemOut(BaseModel):
    id: int
    name: str
    price: float

    class Config:
        orm_mode = True

class ReceiptOut(BaseModel):
    id: int
    name: Optional[str]
    total_amount: float
    currency: str
    created_by: int
    items: List[ReceiptItemOut]

    class Config:
        orm_mode = True

# --- Assignments ---
class AssignItemsRequest(BaseModel):
    item_ids: List[int]  # IDs позиций, за которые заплатил

class ReceiptStatusResponse(BaseModel):
    status: str  # "completed" или "pending"

class ReceiptSummaryUser(BaseModel):
    user_id: int
    nickname: str
    total_paid: float

class ReceiptSummaryResponse(BaseModel):
    items: List[ReceiptItemOut]
    total_paid_by_user: List[ReceiptSummaryUser]