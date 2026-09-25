from datetime import datetime
from db import db


class OrderModel(db.Model):
    __tablename__ = "orders"
    
    order_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer,db.ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    address_id = db.Column(db.Integer,db.ForeignKey("address.address_id"), nullable=False)
    
    order_date = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    order_amount = db.Column(db.Numeric(10, 2), nullable=False)
    status = db.Column(db.String(30), nullable=False, default="Paid")
    
    user = db.relationship("UserModel", back_populates="orders")
    address = db.relationship("AddressModel", back_populates="orders")
    items = db.relationship("ProductOrderModel", back_populates="order", cascade="all, delete-orphan")