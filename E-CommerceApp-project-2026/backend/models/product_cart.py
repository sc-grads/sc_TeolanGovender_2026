from db import db

class ProductCartModel(db.Model):
  __tablename__ = "product_cart"

  product_id = db.Column(db.Integer, db.ForeignKey("product.product_id"), primary_key=True, nullable=False)
  cart_id = db.Column(db.Integer, db.ForeignKey("cart.cart_id"), primary_key=True, nullable=False,)
  quantity = db.Column(db.Integer, nullable=False, default=1)

  cart = db.relationship("CartModel", back_populates="items")
  product = db.relationship("ProductModel", uselist=False)