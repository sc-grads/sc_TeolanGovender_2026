from flask.views import MethodView
from flask_jwt_extended import get_jwt, get_jwt_identity, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError

from db import db
from models import ProductModel
from models.cart import CartModel
from models.product_cart import ProductCartModel
from schemas import AddToCartSchema, CartSchema , UpdateCartSchema

blp = Blueprint("cart", __name__, description="Operations on products")


@blp.route("/cart")
class UserCart(MethodView):
    @jwt_required()
    @blp.response(200, CartSchema)
    def get(self):
        user_id = int(get_jwt_identity())
        cart = CartModel.query.filter_by(user_id=user_id).first_or_404(
            description="Cart not found for this user."
        )
        return cart

    @jwt_required()
    @blp.arguments(AddToCartSchema)
    @blp.response(201, CartSchema)
    def post(self, cart_data):
        user_id = int(get_jwt_identity())

        cart = CartModel.query.filter_by(user_id=user_id).first()
        if not cart:
            cart = CartModel(user_id=user_id)
            db.session.add(cart)
            db.session.flush()

        product = ProductModel.query.get_or_404(
        cart_data["product_id"], description="Product not found"
        )

        # Check if item is already in cart; increment quantity if it is
        cart_item = ProductCartModel.query.filter_by(
        cart_id=cart.cart_id, product_id=product.product_id
        ).first()

        if cart_item:
            cart_item.quantity += cart_data["quantity"]
        else:
            cart_item = ProductCartModel(
            cart_id=cart.cart_id,
            product_id=product.product_id,
            quantity=cart_data["quantity"],
        )
        db.session.add(cart_item)

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(500, message="An error occurred while updating the cart.")

        return cart


    @jwt_required()
    @blp.arguments(UpdateCartSchema)
    @blp.response(200, CartSchema)
    def patch(self, cart_data):
        user_id = int(get_jwt_identity())

        cart = CartModel.query.filter_by(user_id=user_id).first_or_404(
            description="Cart not found for this user."
        )

        cart_item = ProductCartModel.query.filter_by(
            cart_id=cart.cart_id,
            product_id=cart_data["product_id"]
        ).first_or_404(
            description="Product not found in cart."
        )

        # Decrease quantity by 1
        if cart_item.quantity > 1:
            cart_item.quantity -= 1

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(500, message="An error occurred while updating the cart.")

        return cart



    @jwt_required()
    @blp.arguments(UpdateCartSchema)
    @blp.response(200, CartSchema)
    def delete(self, cart_data):
        user_id = int(get_jwt_identity())

        cart = CartModel.query.filter_by(user_id=user_id).first_or_404(
            description="Cart not found for this user."
        )

        cart_item = ProductCartModel.query.filter_by(
            cart_id=cart.cart_id,
            product_id=cart_data["product_id"]
        ).first_or_404(
            description="Product not found in cart."
        )

        db.session.delete(cart_item)

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(500, message="An error occurred while removing the item.")

        return cart