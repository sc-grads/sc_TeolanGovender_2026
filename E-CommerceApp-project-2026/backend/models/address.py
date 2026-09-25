from db import db


class AddressModel(db.Model):
    __tablename__ = "address"

    address_id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(
        db.Integer,
        db.ForeignKey("customers.user_id", ondelete="CASCADE"),
        nullable=False
    )

    address_line_1 = db.Column(db.String(50), nullable=False)
    address_line_2 = db.Column(db.String(50), nullable=True)
    city = db.Column(db.String(80), nullable=False)
    province = db.Column(db.String(80), nullable=False)
    postal_code = db.Column(db.String(10), nullable=False)

    customer = db.relationship("CustomerModel", back_populates="addresses")
    orders = db.relationship("OrderModel", back_populates="address")