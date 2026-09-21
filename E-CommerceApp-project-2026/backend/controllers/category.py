from flask import app, jsonify, Blueprint, abort
from flask.views import MethodView
from sqlalchemy.exc import SQLAlchemyError

from db import db
from models import CategoryModel

from flask.views import MethodView
from flask_smorest import Blueprint, abort
from sqlalchemy.exc import SQLAlchemyError, IntegrityError

from db import db
from models import CategoryModel
from schemas import CategorySchema, PlainCategorySchema, ProductSchema

blp = Blueprint("Categories", __name__, description="Operations on categories")


@blp.route("/category/<string:category_id>")
class Category(MethodView):
    @blp.response(200, CategorySchema)
    def get(self, category_id):
        cat = CategoryModel.query.get_or_404(category_id)
        return cat

    def delete(self, category_id):
        raise NotImplementedError("Deleting a category is not implemented.")


@blp.route("/category")
class CategoryList(MethodView):

    @blp.response(200, PlainCategorySchema(many=True))
    def get(self):
        return CategoryModel.query.all()

    @blp.arguments(PlainCategorySchema)
    @blp.response(201, PlainCategorySchema)
    def post(self, category_data):
        category = CategoryModel(**category_data)

        try:
            db.session.add(category)
            db.session.commit()
        except IntegrityError:
            abort(400, message="A category with that name already exists.")
        except SQLAlchemyError:
            abort(500, message="An error occurred creating the category.")

        return category

    @blp.arguments(CategorySchema)
    @blp.response(201, CategorySchema)
    def post(self, category_data):
        category = CategoryModel(**category_data)
        try:
            db.session.add(category)
            db.session.commit()
        except IntegrityError:
            abort(
                400,
                message="A category with that name already exists.",
            )
        except SQLAlchemyError:
            abort(500, message="An error occurred creating the category.")

        return category