from flask.views import MethodView
from flask_jwt_extended import get_jwt_identity, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import desc
import os
import stripe

from db import db
from models import CartModel, OrderModel, ProductOrderModel
from schemas import OrderSchema, UpdateOrderStatusSchema

blp = Blueprint("orders", __name__, description="Operations on orders")

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")


@blp.route("/create-payment-intent")
class CreatePaymentIntent(MethodView):

    @jwt_required()
    def post(self):
        user_id = int(get_jwt_identity())
        cart = CartModel.query.filter_by(user_id=user_id).first()

        if not cart or not cart.items:
            abort(400, message="Cart is empty.")

        total_amount = sum(
            float(item.product.price) * item.quantity
            for item in cart.items
        )

        try:
            payment_intent = stripe.PaymentIntent.create(
                amount=round(total_amount * 100),
                currency="zar",
                automatic_payment_methods={
                    "enabled": True
                }
            )

            return {
                "clientSecret": payment_intent.client_secret
            }

        except stripe.error.StripeError as e:
            abort(
                500,
                message=f"Stripe error: {str(e)}"
            )

@blp.route("/checkout")
class Checkout(MethodView):

    @jwt_required()
    @blp.response(201, OrderSchema)
    def post(self):

        """Convert the user's current cart into an order."""
        user_id = int(get_jwt_identity())
        cart = CartModel.query.filter_by(
            user_id=user_id
        ).first()

        # Make sure the cart exists and contains items
        if not cart or not cart.items:
            abort(400, message="Cart is empty.")

        try:
            total_amount = sum(
                float(item.product.price) * item.quantity
                for item in cart.items)

            # Create order
            order = OrderModel(
                user_id=user_id,
                order_amount=total_amount,
                status="Pending"
            )

            db.session.add(order)
            db.session.flush()

            # Copy cart items into the order
            for cart_item in cart.items:
                order_item = ProductOrderModel(
                    order_id=order.order_id,
                    product_id=cart_item.product_id,
                    order_price=cart_item.product.price,
                    quantity=cart_item.quantity
                )

                db.session.add(order_item)

            # Remove items from cart
            for cart_item in list(cart.items):
                db.session.delete(cart_item)

            db.session.commit()

        except SQLAlchemyError:
            db.session.rollback()
            abort(
                500,
                message="An error occurred while processing the order."
            )

        return order


@blp.route("/orders")
class UserOrders(MethodView):

  @jwt_required()
  @blp.response(200, OrderSchema(many=True))
  def get(self):
    user_id = int(get_jwt_identity())
    orders = OrderModel.query.filter_by(user_id=user_id).order_by(desc(OrderModel.order_date)).all()
    return orders

@blp.route("/admin/orders")
class AdminOrders(MethodView):

    @jwt_required()
    @blp.response(200, OrderSchema(many=True))
    def get(self):
        orders = OrderModel.query.order_by(
            desc(OrderModel.order_date)
        ).all()

        return orders

@blp.route("/admin/orders/<int:order_id>")
class AdminOrder(MethodView):

    @jwt_required()
    @blp.arguments(UpdateOrderStatusSchema)
    @blp.response(200, OrderSchema)
    def patch(self, status_data, order_id):
        order = OrderModel.query.get_or_404(order_id)

        order.status = status_data["status"]
        db.session.commit()

        return order