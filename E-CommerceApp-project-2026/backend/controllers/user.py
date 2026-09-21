from flask.views import MethodView
from flask import abort
from passlib.hash import pbkdf2_sha256
from flask_smorest import Blueprint
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    get_jwt_identity,
    get_jwt,
    jwt_required,
)
from blocklist import BLOCKLIST
from db import db
from schemas import CustomerSchema, UserRegisterSchema
from schemas import UserLoginSchema, ProfileSchema, UpdateProfileSchema, ChangePasswordSchema
from models import CustomerModel, EmployeeModel, UserModel

blp = Blueprint("Users", "users", description="Operations on users")


@blp.route("/register")
class UserRegister(MethodView):

  @blp.arguments(UserRegisterSchema)
  def post(self, user_data):
    if UserModel.query.filter(UserModel.email == user_data["email"]).first():
      abort(409, message="A user with that email already exists.")

    hashed_password = pbkdf2_sha256.hash(user_data["password"])
    role = user_data["role"].lower()

    if role == "customer":
      user = CustomerModel(
          first_name=user_data["first_name"],
          last_name=user_data["last_name"],
          email=user_data["email"],
          password=hashed_password,
          phone_number=user_data["phone_number"],
          address=user_data["address"],
      )
    elif role == "employee":
      user = EmployeeModel(
          first_name=user_data["first_name"],
          last_name=user_data["last_name"],
          email=user_data["email"],
          password=hashed_password,
          department=user_data["department"],
      )
    else:
      abort(400, message="Invalid role provided.")

    db.session.add(user)
    db.session.commit()

    return {
        "message": f"{role.capitalize()} created successfully.",
        "user_id": user.user_id,
    }, 201

@blp.route("/users/<string:user_id>")
class GetUsers(MethodView):
    
    @blp.response(200, UserRegisterSchema)
    def get(self, user_id):
        user = UserModel.query.get_or_404(user_id)
        return user



""""
@blp.route("/register")
class UserRegister(MethodView):
    @blp.arguments(UserRegisterSchema)
    def post(self, user_data):
        if UserModel.query.filter(
            UserModel.email == user_data["email"]
        ).first():
            abort(409, message="A user with that email already exists.")

        user = UserModel(
            name=user_data["name"],
            email=user_data["email"],
            password=pbkdf2_sha256.hash(user_data["password"]),
            role=user_data["role"],
        )

        db.session.add(user)
        db.session.commit()

        return {"message": "User created successfully."}, 201
"""

@blp.route("/login")
class UserLogin(MethodView):
    @blp.arguments(UserLoginSchema)
    def post(self, user_data):
        user = UserModel.query.filter(
            UserModel.email == user_data["email"]
        ).first()

        if user and pbkdf2_sha256.verify(
            user_data["password"], user.password
        ):
            # Convert user.id to a string because the JWT "sub"
            # (subject) claim must be a string.
            access_token = create_access_token(
                identity=str(user.user_id),
                fresh=True,
            )

            refresh_token = create_refresh_token(
                identity=str(user.user_id)
            )

            return {
                "access_token": access_token,
                "refresh_token": refresh_token,
                "user": {
                    "user_id": user.user_id,
                    "first_name": user.first_name,
                    "last_name": user.last_name,
                    "email": user.email,
                    "role": user.role,
            },
}, 200
            return {
    "access_token": access_token,
    "refresh_token": refresh_token,
    "user": {
        "user_id": user.user_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "role": user.role,
    },
}, 200
            return {
    "access_token": access_token,
    "refresh_token": refresh_token,
    "user": {
        "user_id": user.user_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "role": user.role,
    },
}, 200
            return {
    "access_token": access_token,
    "refresh_token": refresh_token,
    "user": {
        "user_id": user.user_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "role": user.role,
    },
}, 200

        abort(401, message="Invalid credentials.")

@blp.route("/logout")
class UserLogout(MethodView):
    @jwt_required()
    def post(self):
        jti = get_jwt()["jti"]

        BLOCKLIST.add(jti)

        return {"message": "Successfully logged out"}, 200


@blp.route("/user/<int:user_id>")
class User(MethodView):
    """
    This resource can be useful when testing our Flask app.
    We may not want to expose it to public users, but for the
    sake of demonstration in this course, it can be useful
    when we are manipulating data regarding the users.
    """

    @blp.response(200, CustomerSchema)
    def get(self, user_id):
        user = UserModel.query.get_or_404(user_id)

        return user

    def delete(self, user_id):
        user = UserModel.query.get_or_404(user_id)

        db.session.delete(user)
        db.session.commit()

        return {"message": "User deleted."}, 200


@blp.route("/refresh")
class TokenRefresh(MethodView):
    @jwt_required(refresh=True)
    def post(self):
        current_user = get_jwt_identity()

        # current_user is already a string because the identity
        # was stored as a string in the refresh token.
        new_token = create_access_token(
            identity=current_user,
            fresh=False,
        )

        # Add the refresh token's JTI to the blocklist.
        # This means this refresh token cannot be reused.
        jti = get_jwt()["jti"]
        BLOCKLIST.add(jti)

        return {"access_token": new_token}, 200


@blp.route("/profile")
class Profile(MethodView):

    @jwt_required()
    @blp.response(200, ProfileSchema)
    def get(self):
        user_id = int(get_jwt_identity())

        user = UserModel.query.get_or_404(user_id)

        return user

    @jwt_required()
    @blp.arguments(UpdateProfileSchema)
    @blp.response(200, ProfileSchema)
    def patch(self, user_data):
        user_id = int(get_jwt_identity())

        user = UserModel.query.get_or_404(user_id)

        if "email" in user_data:
            existing_user = UserModel.query.filter(
                UserModel.email == user_data["email"],
                UserModel.user_id != user_id
            ).first()

            if existing_user:
                abort(409, message="That email is already in use.")

        for key, value in user_data.items():
            setattr(user, key, value)

        db.session.commit()

        return user

    @jwt_required()
    def delete(self):
        user_id = int(get_jwt_identity())
        user = UserModel.query.get_or_404(user_id)
        db.session.delete(user)
        db.session.commit()
        return {"message": "Account deleted successfully."}, 200


@blp.route("/profile/password")
class ChangePassword(MethodView):

    @jwt_required()
    @blp.arguments(ChangePasswordSchema)
    def patch(self, password_data):
        user_id = int(get_jwt_identity())

        user = UserModel.query.get_or_404(user_id)

        if not pbkdf2_sha256.verify(
            password_data["current_password"],
            user.password
        ):
            abort(401, message="Current password is incorrect.")

        user.password = pbkdf2_sha256.hash(
            password_data["new_password"]
        )

        db.session.commit()

        return {"message": "Password changed successfully."}, 200