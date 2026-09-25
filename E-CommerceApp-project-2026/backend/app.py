from flask import Flask, jsonify, request, g
from flask_smorest import Api
from flask_jwt_extended import JWTManager
from blocklist import BLOCKLIST
from flask_cors import CORS
from datetime import timedelta

from db import db
import models
import time

from controllers.category import blp as CategoryBlueprint
from controllers.product import blp as ProductBlueprint
from controllers.user import blp as UserBlueprint
from controllers.cart import blp as CartBlueprint
from controllers.order import blp as OrderBlueprint
from controllers.address import blp as AddressBlueprint
from models.auditlog import AuditLogModel


def create_app(db_url=None):
    app = Flask(__name__)
    CORS(app)

    app.config["API_TITLE"] = "E-Commerce API"
    app.config["API_VERSION"] = "v1"
    app.config["OPENAPI_VERSION"] = "3.0.3"
    app.config["OPENAPI_URL_PREFIX"] = "/"
    app.config["OPENAPI_SWAGGER_UI_PATH"] = "/swagger-ui"
    app.config["OPENAPI_SWAGGER_UI_URL"] = "https://cdn.jsdelivr.net/npm/swagger-ui-dist/"

    app.config["SQLALCHEMY_DATABASE_URI"] = db_url or "sqlite:///data.db"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["PROPAGATE_EXCEPTIONS"] = True
    app.config["SQLALCHEMY_DATABASE_URI"] = (
    "mssql+pyodbc://@LAPTOP-4KISL5TR\\MSSQLSERVERDEVEL/TechTraders_tgdb"
    "?driver=ODBC+Driver+18+for+SQL+Server"
    "&trusted_connection=yes"
    "&TrustServerCertificate=yes"
    )

    @app.before_request
    def start_request_timer():
        g.start_time = time.perf_counter()


    @app.after_request
    def log_request(response):

        if request.method == "OPTIONS":
            return response

        try:
            duration = (
                time.perf_counter() - g.start_time
            ) * 1000

            audit = AuditLogModel(
                method=request.method,
                endpoint=request.path,
                status_code=response.status_code,
                response_time_ms=round(duration),
                ip_address=request.remote_addr
            )

            db.session.add(audit)
            db.session.commit()

        except Exception as error:
            print(f"Audit logging failed: {error}")
            db.session.rollback()

        return response
    

    db.init_app(app)
    api = Api(app)

    app.config["JWT_SECRET_KEY"] = "flask-api-2026-this-is-a-long-secret-key"

    app.config["JWT_ACCESS_TOKEN_EXPIRES"] = False
    app.config["JWT_REFRESH_TOKEN_EXPIRES"] = False

    jwt = JWTManager(app)

    @jwt.token_in_blocklist_loader
    def check_if_token_in_blocklist(jwt_header, jwt_payload):
        print("JWT VERIFIED SUCCESSFULLY")
        print("JWT PAYLOAD:", jwt_payload)
        return jwt_payload["jti"] in BLOCKLIST

    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return (
            jsonify({"message": "The token has expired.", "error": "token_expired"}),
            401,
        )

    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        print("JWT INVALID ERROR:", error)
        return (
            jsonify(
                {"message": "Signature verification failed.", "error": "invalid_token"}
            ),
            401,
        )

    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return (
            jsonify(
                {
                    "description": "Request does not contain an access token.",
                    "error": "authorization_required",
                }
            ),
            401,
        )

    @jwt.needs_fresh_token_loader
    def token_not_fresh_callback(jwt_header, jwt_payload):
        return (
            jsonify(
                {
                    "description": "The token is not fresh.",
                    "error": "fresh_token_required",
                }
            ),
            401,
        )

    @jwt.revoked_token_loader
    def revoked_token_callback(jwt_header, jwt_payload):
        return (
            jsonify(
                {"description": "The token has been revoked.", "error": "token_revoked"}
            ),
            401,
        )


    with app.app_context():
        db.create_all()

    api.register_blueprint(CategoryBlueprint)
    api.register_blueprint(ProductBlueprint)
    api.register_blueprint(UserBlueprint)
    api.register_blueprint(CartBlueprint)
    api.register_blueprint(OrderBlueprint)
    api.register_blueprint(AddressBlueprint)
    

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)