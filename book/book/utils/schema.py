from functools import wraps

from stringcase import snakecase
from flask import request
from voluptuous import Invalid

from book.utils.flask import ValidationException


def dataschema(schema):
    def decorator(f):
        @wraps(f)
        def new_func(*args, **kwargs):
            try:
                parsed_json = request.get_json()
                if parsed_json is None:
                    if request.mimetype == "application/x-www-form-urlencoded":
                        parsed_json = {}
                        for k, v in request.form.items():
                            parsed_json[k] = v
                valid_dict = schema(parsed_json)
                snaked_kwargs = {snakecase(k): v for k, v in valid_dict.items()}
                kwargs.update(snaked_kwargs)
            except Invalid as e:
                message = 'Invalid data: %s (path "%s")' % (
                    str(e.msg),
                    ".".join([str(k) for k in e.path]),
                )
                raise ValidationException(message)
            return f(*args, **kwargs)

        return new_func

    return decorator
