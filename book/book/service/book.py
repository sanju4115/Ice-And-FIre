from injector import singleton, inject
from typing import List

from book.store.repos.books import BookRepo
from book.domain.models.book import Book as BookModel


@singleton
class BookService:

    @inject
    def __init__(
            self,
            book_repo: BookRepo,
    ):
        self._book_repo = book_repo

    def create(self, model: BookModel) -> BookModel:
        return self._book_repo.create(model)

    def create_all(self, models: List[BookModel]) -> List[BookModel]:
        return self._book_repo.create_all(models)

    def delete(self, id: int) -> BookModel:
        return self._book_repo.delete(id)

    def get(self, id: int) -> BookModel:
        return self._book_repo.get(id)

    def get_all(self) -> List[BookModel]:
        return self._book_repo.get_all()

    def get_by_name(self, name: str) -> List[BookModel]:
        return self._book_repo.get_by_name(name)

    def update(self, model: BookModel) -> BookModel:
        return self._book_repo.update(model)
