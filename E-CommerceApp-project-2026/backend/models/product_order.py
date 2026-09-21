from db import db

class ProductOrderModel(db.Model):
  __tablename__ = "product_order"

  product_id = db.Column(db.Integer, db.ForeignKey("product.product_id", ondelete="CASCADE"), primary_key=True)
  order_id = db.Column(db.Integer, db.ForeignKey("orders.order_id", ondelete="CASCADE"), primary_key=True)
  order_price = db.Column(db.Numeric(10, 2), nullable=False)
  quantity = db.Column(db.Integer, nullable=False)


  order = db.relationship("OrderModel", back_populates="items")
  product = db.relationship("ProductModel")