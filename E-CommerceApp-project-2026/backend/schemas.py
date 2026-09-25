from marshmallow import Schema, fields, validate

#------  schema for item inside a cart  --------
class PlainProductSchema(Schema):
    product_id = fields.Int(dump_only=True)
    name = fields.Str(required=True)
    description = fields.Str(required=True)
    price = fields.Float(required=True)
    image_url = fields.Str(required=True)
    quantity = fields.Int(required=True)

class PlainCategorySchema(Schema):
    category_id = fields.Int(dump_only=True)
    name = fields.Str(required=True)

class ProductSchema(PlainProductSchema):
    category_id = fields.Int(required=True)
    category = fields.Nested(PlainCategorySchema(), dump_only=True)

class CategorySchema(PlainProductSchema):
    Product_id = fields.List(fields.Nested(PlainCategorySchema()), dump_only=True)

class UserRegisterSchema(Schema):
    first_name = fields.Str(required=True)
    last_name = fields.Str(required=True)
    email = fields.Email(required=True)
    password = fields.Str(required=True, load_only=True)
    role = fields.Str(required=True, validate=validate.OneOf(["customer", "employee"]))

    phone_number = fields.Str()

    address_line_1 = fields.Str()
    address_line_2 = fields.Str()
    city = fields.Str()
    province = fields.Str()
    postal_code = fields.Str()

    department = fields.Str()

class UserLoginSchema(Schema):
    user_id = fields.Int(dump_only=True)
    email = fields.Str(required=True)
    password = fields.Str(required=True, load_only=True)
    #role = fields.Str(required=True)
    
class AddressSchema(Schema):
    address_id = fields.Int(dump_only=True)
    address_line_1 = fields.Str(required=True)
    address_line_2 = fields.Str(allow_none=True)
    city = fields.Str(required=True)
    province = fields.Str(required=True)
    postal_code = fields.Str(required=True)

class CustomerSchema(Schema):
    user_id = fields.Int(dump_only=True)
    phone_number = fields.Str(required=True)
    addresses = fields.List(fields.Nested(AddressSchema()),dump_only=True)

class ProfileSchema(Schema):
    user_id = fields.Int(dump_only=True)
    first_name = fields.Str(required=True)
    last_name = fields.Str(required=True)
    email = fields.Email(required=True)
    phone_number = fields.Str()
    addresses = fields.List(fields.Nested(AddressSchema()), dump_only=True)


class UpdateProfileSchema(Schema):
    first_name = fields.Str()
    last_name = fields.Str()
    email = fields.Email()
    phone_number = fields.Str()

class ChangePasswordSchema(Schema):
    current_password = fields.Str(required=True, load_only=True)
    new_password = fields.Str(required=True, load_only=True)

#------  schema for item inside a cart  --------
class CartItemSchema(Schema):
    product_cart_id = fields.Int(dump_only=True)
    quantity = fields.Int(required=True)
    product_id = fields.Int(required=True, load_only=True)
    product = fields.Nested(PlainProductSchema(), dump_only=True)

#------  Schema for POSTing a product into a cart  ------
class AddToCartSchema(Schema):
    product_id = fields.Int(required=True)
    quantity = fields.Int(required=True)

#------  http://127.0.0.1:5000/cart  ------
class CartSchema(Schema):
    cart_id = fields.Int(dump_only=True)
    user_id = fields.Int(dump_only=True)
    first_name = fields.Str(attribute="user.first_name")
    last_name = fields.Str(attribute="user.last_name")
    items = fields.List(fields.Nested(CartItemSchema()), dump_only=True)

class UpdateCartSchema(Schema):
    product_id = fields.Int(required=True)

class UpdateProductSchema(Schema):
    product_id = fields.Int(required=True)


class OrderItemSchema(Schema):
    product_id = fields.Int(dump_only=True)
    order_price = fields.Float(dump_only=True)
    quantity = fields.Int(dump_only=True)
    product = fields.Nested(PlainProductSchema(), dump_only=True)


class OrderSchema(Schema):
    order_id = fields.Int(dump_only=True)
    order_date = fields.DateTime(dump_only=True)
    address_id = fields.Int(required=True, load_only=True)
    order_amount = fields.Float(dump_only=True)
    status = fields.Str(dump_only=True)
    items = fields.List(fields.Nested(OrderItemSchema()), dump_only=True)
    first_name = fields.Str(attribute="user.first_name")
    last_name = fields.Str(attribute="user.last_name")
    address_line_1 = fields.Str(attribute="address.address_line_1")
    address_line_2 = fields.Str(attribute="address.address_line_2")
    payment_intent_id = fields.Str(required=True, load_only=True)


class UpdateOrderStatusSchema(Schema):
    status = fields.Str(
        required=True,
        validate=validate.OneOf(["Pending", "Processing", "Shipped", "Delivered", "Cancelled", "Refunded"])
    )