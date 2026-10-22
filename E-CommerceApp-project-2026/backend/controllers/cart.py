from flask import request
from flask.views import MethodView
from flask_jwt_extended import (
    get_jwt_identity,
    jwt_required,
    verify_jwt_in_request
)
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError

from db import db
from models import ProductModel
from models.cart import CartModel
from models.product_cart import ProductCartModel
from schemas import AddToCartSchema, CartSchema, UpdateCartSchema


blp = Blueprint("cart", __name__, description="Operations on products")


@blp.route("/cart")
class UserCart(MethodView):

    @blp.response(200, CartSchema)
    def get(self):

        verify_jwt_in_request(optional=True)

        user_id = get_jwt_identity()

        # Logged-in user
        if user_id:
            user_id = int(user_id)

            cart = CartModel.query.filter_by(
                user_id=user_id
            ).first()

        # Guest user
        else:
            guest_token = request.headers.get("X-Guest-Token")

            if not guest_token:
                abort(400, message="Guest token is required.")

            cart = CartModel.query.filter_by(
                guest_token=guest_token
            ).first()

        if not cart:
            abort(404, message="Cart not found.")

        return cart

    @blp.arguments(AddToCartSchema)
    @blp.response(201, CartSchema)
    def post(self, cart_data):

        verify_jwt_in_request(optional=True)

        user_id = get_jwt_identity()

        # Logged-in user
        if user_id:
            user_id = int(user_id)

            cart = CartModel.query.filter_by(
                user_id=user_id
            ).first()

            if not cart:
                cart = CartModel(user_id=user_id)
                db.session.add(cart)
                db.session.flush()

        # Guest user
        else:
            guest_token = request.headers.get("X-Guest-Token")

            if not guest_token:
                abort(400, message="Guest token is required.")

            cart = CartModel.query.filter_by(
                guest_token=guest_token
            ).first()

            if not cart:
                cart = CartModel(
                    guest_token=guest_token
                )

                db.session.add(cart)
                db.session.flush()

        product = ProductModel.query.get_or_404(
            cart_data["product_id"],
            description="Product not found"
        )

        cart_item = ProductCartModel.query.filter_by(
            cart_id=cart.cart_id,
            product_id=product.product_id
        ).first()

        if cart_item:
            cart_item.quantity += cart_data["quantity"]

        else:
            cart_item = ProductCartModel(
                cart_id=cart.cart_id,
                product_id=product.product_id,
                quantity=cart_data["quantity"]
            )

            db.session.add(cart_item)

        try:
            db.session.commit()

        except SQLAlchemyError:
            db.session.rollback()
            abort(
                500,
                message="An error occurred while updating the cart."
            )

        return cart
    

    @blp.arguments(UpdateCartSchema)
    @blp.response(200, CartSchema)
    def patch(self, cart_data):

        verify_jwt_in_request(optional=True)

        user_id = get_jwt_identity()

        # Logged-in user
        if user_id:
            user_id = int(user_id)

            cart = CartModel.query.filter_by(
                user_id=user_id
            ).first()

        # Guest user
        else:
            guest_token = request.headers.get("X-Guest-Token")

            if not guest_token:
                abort(400, message="Guest token is required.")

            cart = CartModel.query.filter_by(
                guest_token=guest_token
            ).first()

        if not cart:
            abort(404, message="Cart not found.")

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
            abort(
                500,
                message="An error occurred while updating the cart."
            )

        return cart

    @blp.arguments(UpdateCartSchema)
    @blp.response(200, CartSchema)
    def delete(self, cart_data):

        verify_jwt_in_request(optional=True)

        user_id = get_jwt_identity()

        # Logged-in user
        if user_id:
            user_id = int(user_id)

            cart = CartModel.query.filter_by(
                user_id=user_id
            ).first()

        # Guest user
        else:
            guest_token = request.headers.get("X-Guest-Token")

            if not guest_token:
                abort(400, message="Guest token is required.")

            cart = CartModel.query.filter_by(
                guest_token=guest_token
            ).first()

        if not cart:
            abort(404, message="Cart not found.")

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
            abort(
                500,
                message="An error occurred while removing the item."
            )

        return cart

@blp.route("/cart/merge")
class MergeCart(MethodView):

    @jwt_required()
    def post(self):
        user_id = int(get_jwt_identity())

        guest_token = request.headers.get("X-Guest-Token")

        if not guest_token:
            return {"message": "No guest cart found."}, 200

        guest_cart = CartModel.query.filter_by(
            guest_token=guest_token
        ).first()

        # Nothing to merge
        if not guest_cart:
            return {"message": "No guest cart found."}, 200

        # Find the user's existing cart
        user_cart = CartModel.query.filter_by(
            user_id=user_id
        ).first()

        # Create one if they don't have one
        if not user_cart:
            user_cart = CartModel(user_id=user_id)
            db.session.add(user_cart)
            db.session.flush()

        # Move each guest item into the user's cart
        for guest_item in guest_cart.items:

            user_item = ProductCartModel.query.filter_by(
                cart_id=user_cart.cart_id,
                product_id=guest_item.product_id
            ).first()

            if user_item:
                # Same product already exists
                user_item.quantity += guest_item.quantity
            else:
                # Add guest product to user's cart
                user_item = ProductCartModel(
                    cart_id=user_cart.cart_id,
                    product_id=guest_item.product_id,
                    quantity=guest_item.quantity
                )
                db.session.add(user_item)

        # Delete the guest cart
        db.session.delete(guest_cart)

        try:
            db.session.commit()
        except SQLAlchemyError:
            db.session.rollback()
            abort(500, message="An error occurred while merging the cart.")

        return {"message": "Cart merged successfully."}, 200