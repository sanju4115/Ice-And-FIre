from flask import Blueprint, request

from book.libraries.serialization import serialize
from book.service.business.book import BookAdminService
from book.utils.flask import GenericResponse

blueprint = Blueprint("ex-book", __name__, url_prefix="/api")


@blueprint.route("/external-books", methods=["GET"])
def get_all_books_ex(service: BookAdminService) -> GenericResponse:
    params = request.args
    name = params.get("name")
    if name:
        return GenericResponse(
            value=serialize(service.get_by_name(name))
        )
    else:
        return GenericResponse(
            value=serialize(service.get_all())
        )
