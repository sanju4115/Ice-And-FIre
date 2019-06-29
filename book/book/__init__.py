from werkzeug.utils import find_modules, import_string

# local imports
from book.utils.flask import (
    APIFlask,
    ValidationException,
    NotFoundException,
)
from book.utils.config import Config
from book.store import configure_db_with_app
from book.inject import injector
from flask_injector import FlaskInjector

from book.api.book import blueprint


def create_app() -> APIFlask:

    # init flask app and configuration
    app = APIFlask(__name__, instance_relative_config=True)
    app.config.from_object(Config)

    configure_db_with_app(app)
    _register_all_blueprints(app)
    _inject_deps(app)

    _register_error_handler(app)

    return app


def _register_all_blueprints(app: APIFlask):
    # app.register_blueprint(blueprint)
    for name in find_modules("book.api"):
        mod = import_string(name)
        if hasattr(mod, "blueprint"):
            app.register_blueprint(mod.blueprint)


def _register_error_handler(app: APIFlask):
    app.register_error_handler(ValidationException, lambda err: err.to_json())
    app.register_error_handler(NotFoundException, lambda err: err.to_json())


def _inject_deps(app):
    FlaskInjector(app=app, injector=injector)