import functools
from typing import Any, Callable

from flask_sqlalchemy import SQLAlchemy
from injector import Module, singleton, provider, Injector, inject
from book.store import db


class Provider(Module):
    @provider
    @singleton
    def provide_db(self) -> SQLAlchemy:
        return db


injector = Injector([Provider])


def f_inject(fun) -> Callable:
    @functools.wraps(fun)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return injector.call_with_injection(
            callable=inject(fun), args=args, kwargs=kwargs
        )

    return wrapper
