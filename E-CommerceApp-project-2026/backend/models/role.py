from models.user import UserModel
from db import db

class CustomerModel(UserModel):
    __tablename__ = 'customers'

    user_id = db.Column(
        db.Integer,
        db.ForeignKey('users.user_id', ondelete='CASCADE'),
        primary_key=True,
    )

    phone_number = db.Column(db.String(20), nullable=False)

    addresses = db.relationship(
        "AddressModel",
        back_populates="customer",
        cascade="all, delete-orphan"
    )

    __mapper_args__ = {
        'polymorphic_identity': 'customer',
    }

class EmployeeModel(UserModel):
  __tablename__ = 'employee'

  user_id = db.Column(
      db.Integer,
      db.ForeignKey('users.user_id', ondelete='CASCADE'),
      primary_key=True,
  )
  department = db.Column(db.String(80), nullable=False)

  __mapper_args__ = {
      'polymorphic_identity': 'employee',
  }