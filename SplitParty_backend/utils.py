from uuid import uuid4
from datetime import datetime, timedelta, timezone
import os

VERIF_EXP_MIN = int(os.getenv("VERIFICATION_TOKEN_EXPIRE_MINUTES", "60"))

def generate_verification_token() -> str:
    return uuid4().hex

def token_expiration_time():
    return datetime.now(timezone.utc) + timedelta(minutes=VERIF_EXP_MIN)