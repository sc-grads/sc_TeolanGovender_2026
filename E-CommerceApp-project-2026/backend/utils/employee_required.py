from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from flask_smorest import abort

from models import UserModel


def employee_required():
    verify_jwt_in_request()

    user_id = int(get_jwt_identity())

    user = UserModel.query.get(user_id)

    if not user or user.role != "employee":
        abort(403, message="Employee access required.")