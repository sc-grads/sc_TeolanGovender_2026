from flask.views import MethodView
from flask_jwt_extended import get_jwt, jwt_required
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError
from utils.employee_required import employee_required

from db import db
from models import ProductModel
from schemas import ProductSchema, UpdateProductSchema

blp = Blueprint("products", __name__, description="Operations on products")


@blp.route("/product/<string:product_id>")
#@blp.route("/product")
class product(MethodView):
    @blp.response(200, ProductSchema)
    def get(self, product_id):
        employee_required() 
        prod = ProductModel.query.get_or_404(product_id)
        return prod

    @jwt_required()
    def delete(self, product_id):
        #jwt = get_jwt()
        #if not jwt.get("is_admin"):
            #abort(401, message="Admin privilege required.")

        product = ProductModel.query.get_or_404(product_id)
        db.session.delete(product)
        db.session.commit()
        return {"message": "product deleted."}

    '''
    @jwt_required()
    @blp.arguments(ProductSchema)
    @blp.response(201, ProductSchema)
    def patch(self, product_data, product_id):
        item = ProductModel(**product_data)

        product[product_id].update(product_data)
        return product
    '''

    @blp.arguments(ProductSchema)
    @blp.response(200, ProductSchema)
    def put(self, product_data, product_id):
        employee_required()
        """Update an existing item from a dictionary."""
        # item_data is automatically parsed, validated, and passed as a python dict
        product = ProductModel.query.get_or_404(product_id)
            
        # Update dictionary data
        for key, value in product_data.items():
            setattr(product, key, value)

        db.session.commit()
        return product

    """
    @jwt_required()
    @blp.arguments(ProductSchema)
    @blp.response(201, ProductSchema)
    def post(self, product_data, product_id):
        product = ProductModel(id=product_id, **product_data)

        try:
            db.session.add(product)
            db.session.commit()
        except SQLAlchemyError as e:
            print("ITEM INSERT ERROR:", e)
            db.session.rollback()
            abort(500, message="An error occurred while inserting the item.")

        return product
    """


@blp.route("/product")
class ProductList(MethodView):
    @blp.response(200, ProductSchema(many=True))
    def get(self):
        return ProductModel.query.all()

    @jwt_required()
    @blp.arguments(ProductSchema)
    @blp.response(201, ProductSchema)
    def post(self, product_data):
        employee_required()
        product = ProductModel(**product_data)

        try:
            db.session.add(product)
            db.session.commit()
        except SQLAlchemyError:
            abort(500, message="An error occurred while inserting the product.")

        return product