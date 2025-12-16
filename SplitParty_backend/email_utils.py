import os
import smtplib
from email.message import EmailMessage

SMTP_HOST = os.getenv("SMTP_HOST")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER = os.getenv("SMTP_USER")
SMTP_PASS = os.getenv("SMTP_PASS")
FROM_EMAIL = os.getenv("FROM_EMAIL", "noreply@example.com")

def send_verification_email(to_email: str, code: str):
    msg = EmailMessage()
    msg["Subject"] = "Your verification code"
    msg["From"] = FROM_EMAIL
    msg["To"] = to_email
    body = f"Your verification code: {code}\n\nOr click: https://your-app/verify?token={code}"
    msg.set_content(body)

    if not (SMTP_HOST and SMTP_USER and SMTP_PASS):
        print("SMTP not configured — verification code:", code)
        return

    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USER, SMTP_PASS)
        server.send_message(msg)