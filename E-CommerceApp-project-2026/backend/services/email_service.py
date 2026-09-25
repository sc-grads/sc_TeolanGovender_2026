import os
import resend
from dotenv import load_dotenv

load_dotenv()

resend.api_key = os.getenv("RESEND_API_KEY")


def send_order_confirmation(order, user):

    with open(
        "email_templates/order_confirmation.html",
        "r",
        encoding="utf-8"
    ) as file:
        email_html = file.read()

    items_html = ""

    for item in order.items:

        items_html += f"""
        <tr>

            <td
                style="
                    padding: 15px 0;
                    border-bottom: 1px solid #e5e7eb;
                "
            >

                <img
                    src="{item.product.image_url}"
                    alt="{item.product.name}"
                    width="100"
                    height="100"
                    style="
                        display: block;
                        object-fit: contain;
                        border-radius: 8px;
                    "
                >

            </td>


            <td
                style="
                    padding: 15px;
                    border-bottom: 1px solid #e5e7eb;
                "
            >

                <strong style="font-size: 15px;">
                    {item.product.name}
                </strong>

                <p
                    style="
                        margin: 6px 0 0;
                        color: #6b7280;
                    "
                >
                    Quantity: {item.quantity}
                </p>

            </td>


            <td
                style="
                    padding: 15px 0;
                    border-bottom: 1px solid #e5e7eb;
                    text-align: right;
                    white-space: nowrap;
                "
            >

                <strong>
                    R {float(item.order_price * item.quantity):.2f}
                </strong>

            </td>

        </tr>
        """

    email_html = email_html.replace(
        "{{ first_name }}",
        user.first_name
    )

    email_html = email_html.replace(
        "{{ order_id }}",
        str(order.order_id)
    )

    email_html = email_html.replace(
        "{{ status }}",
        order.status
    )

    email_html = email_html.replace(
        "{{ items }}",
        items_html
    )

    email_html = email_html.replace(
        "{{ total }}",
        f"{float(order.order_amount):.2f}"
    )

    email_html = email_html.replace(
        "{{ address_line_1 }}",
        order.address.address_line_1
    )

    email_html = email_html.replace(
        "{{ address_line_2 }}",
        order.address.address_line_2
    )

    email_html = email_html.replace(
        "{{ city }}",
        order.address.city
    )

    email_html = email_html.replace(
        "{{ province }}",
        order.address.province
    )

    email_html = email_html.replace(
        "{{ postal_code }}",
        order.address.postal_code
    )

    resend.Emails.send({
        "from": "onboarding@resend.dev",
        "to": user.email,
        "subject": f"TechTraders Order #{order.order_id} Confirmation",
        "html": email_html
    })