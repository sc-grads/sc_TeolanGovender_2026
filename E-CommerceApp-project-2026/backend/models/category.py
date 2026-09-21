from db import db

class CategoryModel(db.Model):
    __tablename__ = "category"

    category_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=False, nullable=False)

    product = db.relationship("ProductModel", back_populates="category", lazy="dynamic")
