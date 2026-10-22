from db import db


class AIProductCache(db.Model):
    __tablename__ = "ai_product_cache"

    id = db.Column(db.Integer, primary_key=True)

    product_id = db.Column(
        db.Integer,
        db.ForeignKey("product.product_id"),
        unique=True,
        nullable=False
    )

    competitor_data = db.Column(db.Text, nullable=True)
    review_data = db.Column(db.Text, nullable=True)

    updated_at = db.Column(
        db.DateTime,
        nullable=False,
        default=db.func.now()
    )