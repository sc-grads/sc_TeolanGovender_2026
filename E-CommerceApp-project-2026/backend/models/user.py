from db import db

class UserModel(db.Model):
  __tablename__="users"

  user_id = db.Column(db.Integer, primary_key=True)
  first_name = db.Column(db.String(80), unique=True, nullable=False)
  last_name = db.Column(db.String(80), unique=True, nullable=False)
  email = db.Column(db.String(80), unique=True, nullable=False)
  password = db.Column(db.String(80), nullable=False)
  role = db.Column(db.String(80), nullable=False)

  cart = db.relationship("CartModel", back_populates="user", uselist=False)
  orders = db.relationship("OrderModel", back_populates="user")

  __mapper_args__ = {
    'polymorphic_on': role,
    'polymorphic_identity': 'user',
  }