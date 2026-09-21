from flask.views import MethodView
from flask_jwt_extended import get_jwt, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError

from db import db
from models import ProductModel
from schemas import CustomerSchema

blp = Blueprint("user", __name__, description="Operations on users")


@blp.route("/customer/<string:product_id>")
class Customer(MethodView):
    @blp.response(200, CustomerSchema)
    def get(self, user_id):
        user = ProductModel.query.get_or_404(user_id)
        return user