from db import db

class CartModel(db.Model):
    __tablename__ = "cart"

    cart_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.user_id"), nullable=True, unique=True)
    guest_token = db.Column(db.String(100), nullable=True, unique=True)
    user = db.relationship("UserModel", back_populates="cart")
    items = db.relationship("ProductCartModel", back_populates="cart", cascade="all, delete-orphan")