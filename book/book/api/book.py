from flask import Blueprint

from http import HTTPStatus

from book.domain.models.book import Book
from book.domain.models.utils import ID

from book.libraries.serialization import serialize
from book.service.business.book import BookAdminService
from book.utils.flask import GenericResponse
from book.utils.schema import dataschema
from voluptuous import Schema, Required, Optional, Coerce

blueprint = Blueprint("book", __name__, url_prefix="/api/v1")


@blueprint.route("/books", methods=["POST"])
@dataschema(
    Schema(
        {
            Required("name"): str,
            Required("isbn"): str,
            Required("authors"): list,
            Required("country"): str,
            Required("number_of_pages"): int,
            Required("publisher"): str,
            Required("release_date"): str
        }
    )
)
def create_books(
        service: BookAdminService,
        name,
        isbn,
        authors,
        country,
        number_of_pages,
        publisher,
        release_date
) -> GenericResponse:
    book = service.create(
        Book(
            name=name,
            isbn=isbn,
            country=country,
            number_of_pages=number_of_pages,
            authors=authors,
            publisher=publisher,
            release_date=release_date
        )
    )
    return GenericResponse(
        value=serialize([
            {
                "book": book
            }
        ]),
        status=HTTPStatus.CREATED.value
    )


@blueprint.route("/books", methods=["GET"])
def get_all_book(service: BookAdminService) -> GenericResponse:
    return GenericResponse(
        value=serialize(service.get_all())
    )


@blueprint.route("/books/<int:id>", methods=["PATCH"])
@dataschema(
    Schema(
        {
            Optional("name"): str,
            Optional("isbn"): str,
            Optional("authors"): Coerce(dict),
            Optional("country"): str,
            Optional("number_of_pages"): int,
            Optional("publisher"): str,
            Optional("release_date"): str
        },
        extra=1,
    )
)
def update_book(
        service: BookAdminService,
        id,
        name=None,
        isbn=None,
        authors=None,
        country=None,
        number_of_pages=None,
        publisher=None,
        release_date=None
) -> GenericResponse:
    book = service.patch(
        Book(
            name=name,
            isbn=isbn,
            country=country,
            number_of_pages=number_of_pages,
            authors=authors,
            publisher=publisher,
            release_date=release_date,
            id=id
        )
    )
    return GenericResponse(
        value=serialize(
            book
        ),
        message="The book %s was updated successfully" % book.name
    )


@blueprint.route("/books/<int:id>", methods=["GET"])
def get_book(service: BookAdminService, id: ID) -> GenericResponse:
    return GenericResponse(
        value=serialize(service.get(id))
    )


@blueprint.route("/books/<int:id>", methods=["DELETE"])
def delete_book(service: BookAdminService, id: ID) -> GenericResponse:
    book = service.delete(id)
    return GenericResponse(
        value=serialize([]),
        message="The book %s was deleted successfully" % book.name,
    )
