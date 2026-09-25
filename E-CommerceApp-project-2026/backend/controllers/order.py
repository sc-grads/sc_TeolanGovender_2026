from flask.views import MethodView
from flask_jwt_extended import get_jwt_identity, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import desc
import os
import stripe
from services.email_service import send_order_confirmation

from db import db
from models import CartModel, OrderModel, ProductOrderModel, ProductModel, AddressModel, UserModel
from schemas import OrderSchema, UpdateOrderStatusSchema

blp = Blueprint("orders", __name__, description="Operations on orders")

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")


#payment-intent endpoint for stripe
#payment-intent is the object returned from stripe to allow progression of the checkout - or something like that
@blp.route("/create-payment-intent")
class CreatePaymentIntent(MethodView):

    @jwt_required()
    def post(self):
        user_id = int(get_jwt_identity())
        cart = CartModel.query.filter_by(user_id=user_id).first()

        if not cart or not cart.items:
            abort(400, message="Cart is empty.")

        total_amount = sum(float(item.product.price) * item.quantity for item in cart.items)

        try:
            payment_intent = stripe.PaymentIntent.create(
                amount=round(total_amount * 100),
                currency="zar",
                automatic_payment_methods={"enabled": True}
            )
            return {"clientSecret": payment_intent.client_secret}

        except stripe.error.StripeError as e:
            abort(500, message=f"Stripe error: {str(e)}")


#checkout endpoint for orders
@blp.route("/checkout")
class Checkout(MethodView):

    @jwt_required()
    @blp.arguments(OrderSchema)
    @blp.response(201, OrderSchema)
    def post(self, order_data):

        user_id = int(get_jwt_identity())
        address_id = order_data["address_id"]
        payment_intent_id = order_data["payment_intent_id"]

        cart = CartModel.query.filter_by(
            user_id=user_id
        ).first()

        if not cart or not cart.items:
            abort(400, message="Cart is empty.")

        # Make sure this address belongs to the logged-in user
        address = AddressModel.query.filter_by(
            address_id=address_id,
            user_id=user_id
        ).first()

        if not address:
            abort(
                400,
                message="Invalid address selected."
            )

        total_amount = sum(
            float(item.product.price) * item.quantity
            for item in cart.items
        )
        #handle invalid payment_intent exceptions
        try:
            payment_intent = stripe.PaymentIntent.retrieve(
                payment_intent_id
            )

        except stripe.error.StripeError:
            abort(
                400,
                message="Unable to verify payment."
            )

        if payment_intent.status != "succeeded":
            abort(
                400,
                message="Payment was not successful."
            )

        expected_amount = round(total_amount * 100)

        if payment_intent.amount != expected_amount:
            abort(
                400,
                message="Payment amount does not match the order total."
            )

        if payment_intent.currency.lower() != "zar":
            abort(
                400,
                message="Invalid payment currency."
            )

        user = UserModel.query.get(user_id)

        try:

            # Create the order
            order = OrderModel(
                user_id=user_id,
                address_id=address_id,
                order_amount=total_amount,
                status="Paid"
            )

            db.session.add(order)
            db.session.flush()

            # Check stock and create order items
            for cart_item in cart.items:

                product = cart_item.product

                if product.quantity == 0:
                    raise ValueError(
                        f"{product.name} is out of stock."
                    )

                if cart_item.quantity > product.quantity:
                    raise ValueError(
                        f"Only {product.quantity} units of "
                        f"{product.name} are available."
                    )

                order_item = ProductOrderModel(
                    order_id=order.order_id,
                    product_id=cart_item.product_id,
                    order_price=product.price,
                    quantity=cart_item.quantity
                )

                db.session.add(order_item)

                product.quantity -= cart_item.quantity

            for cart_item in list(cart.items):
                db.session.delete(cart_item)

            db.session.commit()

        except ValueError as e:
            db.session.rollback()

            #simulate transaction rollback - refund
            try:
                stripe.Refund.create(
                    payment_intent=payment_intent_id
                )
            except stripe.error.StripeError as refund_error:
                print(
                    f"Refund failed: {refund_error}"
                )

            abort(
                400,
                message=str(e)
            )

        except SQLAlchemyError:
            db.session.rollback()

            try:
                stripe.Refund.create(
                    payment_intent=payment_intent_id
                )
            except stripe.error.StripeError as refund_error:
                print(
                    f"Refund failed: {refund_error}"
                )

            abort(
                500,
                message="An error occurred while processing the order."
            )

        #calls resend function for confirmation email
        try:
            send_order_confirmation(order, user)
        except Exception as email_error:
            print(
                f"Order confirmation email failed: {email_error}"
            )

        return order
    

#get orders by token
@blp.route("/orders")
class UserOrders(MethodView):
  @jwt_required()
  @blp.response(200, OrderSchema(many=True))
  def get(self):
    user_id = int(get_jwt_identity())
    orders = OrderModel.query.filter_by(user_id=user_id).order_by(desc(OrderModel.order_date)).all()
    return orders

#get all orders for admin
@blp.route("/admin/orders")
class AdminOrders(MethodView):
    @jwt_required()
    @blp.response(200, OrderSchema(many=True))
    def get(self):
        orders = OrderModel.query.order_by(
            desc(OrderModel.order_date)
            ).all()
        return orders

#edit orders
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