from flask.views import MethodView
from flask_jwt_extended import get_jwt_identity, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError

from db import db
from models import AddressModel
from schemas import AddressSchema


blp = Blueprint(
    "address",
    __name__,
    description="Operations on addresses"
)


@blp.route("/address")
class AddressList(MethodView):

    @jwt_required()
    @blp.response(200, AddressSchema(many=True))
    def get(self):
        user_id = int(get_jwt_identity())

        addresses = AddressModel.query.filter_by(
            user_id=user_id
        ).all()

        return addresses

    @jwt_required()
    @blp.arguments(AddressSchema)
    @blp.response(201, AddressSchema)
    def post(self, address_data):
        user_id = int(get_jwt_identity())

        address = AddressModel(
            user_id=user_id,
            **address_data
        )

        try:
            db.session.add(address)
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(
                500,
                message="An error occurred while creating the address."
            )

        return address


@blp.route("/address/<int:address_id>")
class Address(MethodView):

    @jwt_required()
    @blp.arguments(AddressSchema)
    @blp.response(200, AddressSchema)
    def patch(self, address_data, address_id):
        user_id = int(get_jwt_identity())

        address = AddressModel.query.filter_by(
            address_id=address_id,
            user_id=user_id
        ).first_or_404(
            description="Address not found."
        )

        for key, value in address_data.items():
            setattr(address, key, value)

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(
                500,
                message="An error occurred while updating the address."
            )

        return address

    @jwt_required()
    def delete(self, address_id):
        user_id = int(get_jwt_identity())

        address = AddressModel.query.filter_by(
            address_id=address_id,
            user_id=user_id
        ).first_or_404(
            description="Address not found."
        )

        db.session.delete(address)

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(
                500,
                message="An error occurred while deleting the address."
            )

        return {"message": "Address deleted successfully."}, 200