import functools
from typing import Any, Callable

from flask_sqlalchemy import SQLAlchemy
from injector import Module, singleton, provider, Injector, inject
from book.store import db

# from user import get_user_service, UserService
# from utils.config import Config


class Provider(Module):
    @provider
    @singleton
    def provide_db(self) -> SQLAlchemy:
        return db

    # @provider
    # @singleton
    # def provide_user_service(self) -> UserService:
    #     return get_user_service(Config)


injector = Injector([Provider])


def f_inject(fun) -> Callable:
    @functools.wraps(fun)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return injector.call_with_injection(
            callable=inject(fun), args=args, kwargs=kwargs
        )

    return wrapper
