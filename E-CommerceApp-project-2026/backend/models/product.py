from db import db


class ProductModel(db.Model):
    __tablename__ = "product"

    product_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=False, nullable=False)
    description = db.Column(db.String(500), unique=False, nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    image_url = db.Column(db.String(200), unique=False, nullable=False)
    quantity = db.Column(db.Integer, nullable=False, default=0)
    category_id = db.Column(db.Integer, db.ForeignKey("category.category_id"), unique=False, nullable=False)

    category = db.relationship("CategoryModel", back_populates="product")