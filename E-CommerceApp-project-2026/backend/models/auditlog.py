from datetime import datetime
from db import db

class AuditLogModel(db.Model):
    __tablename__ = "audit_log"

    audit_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    method = db.Column(db.String(10), nullable=False)
    endpoint = db.Column(db.String(255),nullable=False)
    status_code = db.Column(db.Integer,nullable=False)
    response_time_ms = db.Column(db.Integer,nullable=False)
    ip_address = db.Column(db.String(45),nullable=True)
    created_at = db.Column(db.DateTime,nullable=False,default=datetime.utcnow)