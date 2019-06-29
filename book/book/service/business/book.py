from typing import Optional, List

from injector import inject, singleton

from book.constants.messages import Messages
from book.utils.flask import NotFoundException

from book.domain.models.utils import ID

from book.service.book import BookService
from book.domain.models.book import Book


@singleton
class BookAdminService:
    @inject
    def __init__(
        self,
        book_service: BookService,
    ):
        self._book_service = book_service

    def create(self, book: Book) -> Optional[Book]:
        return self._book_service.create(book)

    def get(self, book_id: ID) -> Optional[Book]:
        model = self._book_service.get(book_id)
        if model is None:
            raise NotFoundException(Messages.ENTITY_NOT_FOUND.format("Book", id))
        return model

    def get_all(self) -> List[Book]:
        return self._book_service.get_all()

    def get_by_name(self, name: str) -> List[Book]:
        return self._book_service.get_by_name(name)

    def update(self, model: Book) -> Book:
        return self._book_service.update(model)

    def patch(self, model: Book) -> Book:
        old_model = self._book_service.get(model.id)
        if old_model is None:
            raise NotFoundException(Messages.ENTITY_NOT_FOUND.format("Book", id))

        if model.name is None:
            model.name = old_model.name
        if model.isbn is None:
            model.isbn = old_model.isbn
        if model.authors is None:
            model.authors = old_model.authors
        if model.release_date is None:
            model.release_date = old_model.release_date
        if model.country is None:
            model.country = old_model.country
        if model.number_of_pages is None:
            model.number_of_pages = old_model.number_of_pages
        if model.publisher is None:
            model.publisher = old_model.publisher
        return self.update(model)

    def delete(self, id: ID):
        return self._book_service.delete(id)
