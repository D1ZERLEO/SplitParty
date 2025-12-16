from sqlalchemy import Column, Integer, String, Boolean, TIMESTAMP, Text, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(Text, unique=True, nullable=False, index=True)
    nickname = Column(Text, unique=True, nullable=False, index=True)
    password_hash = Column(Text, nullable=False)
    verified = Column(Boolean, default=False)
    verification_token = Column(String(128), nullable=True)
    token_expires = Column(TIMESTAMP, nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.now())



class Gathering(Base):
    __tablename__ = "gatherings"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    admin_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

    admin = relationship("User", backref="owned_gatherings")

class GatheringParticipant(Base):
    __tablename__ = "gathering_participants"
    gathering_id = Column(Integer, ForeignKey("gatherings.id", ondelete="CASCADE"), primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    joined_at = Column(TIMESTAMP, server_default=func.now())

class Receipt(Base):
    __tablename__ = "receipts"
    id = Column(Integer, primary_key=True, index=True)
    gathering_id = Column(Integer, ForeignKey("gatherings.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(100))
    total_amount = Column(Numeric(12, 2), nullable=False)
    currency = Column(String(3), default="RUB")
    created_by = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"))
    created_at = Column(TIMESTAMP, server_default=func.now())

class ReceiptItem(Base):
    __tablename__ = "receipt_items"
    id = Column(Integer, primary_key=True, index=True)
    receipt_id = Column(Integer, ForeignKey("receipts.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(150), nullable=False)
    price = Column(Numeric(12, 2), nullable=False)

class UserReceiptItem(Base):
    __tablename__ = "user_receipt_items"
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    receipt_item_id = Column(Integer, ForeignKey("receipt_items.id", ondelete="CASCADE"), primary_key=True)