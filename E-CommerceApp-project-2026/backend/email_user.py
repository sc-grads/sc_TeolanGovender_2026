from app import create_app
from models import UserModel, OrderModel
from services.email_service import send_order_confirmation

app = create_app()

with app.app_context():

    order = OrderModel.query.order_by(
        OrderModel.order_id.desc()
    ).first()

    if not order:
        print("No orders found in the database.")
    else:
        user = UserModel.query.get(order.user_id)

        print(f"Testing order #{order.order_id}")
        print(f"Customer: {user.email}")
        print(f"Items: {len(order.items)}")

        send_order_confirmation(order, user)

        print("Email sent successfully.")