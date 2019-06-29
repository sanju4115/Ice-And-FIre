from injector import inject, singleton
from typing import List, Optional

from book.constants.messages import Messages
from book.store import db
from book.store.entities.base import Book as BookEntity
from book.domain.models.book import Book as BookModel
from book.domain.models.utils import ID
from book.utils.flask import NotFoundException


@singleton
class BookRepo:
    @inject
    def __init__(self, default_limit: int = 1000):
        self._db = db
        self.limit = default_limit

    def create(self, model: BookModel) -> BookModel:
        entity = self._to_entity(model)
        self._db.session.add(entity)
        self._db.session.flush()
        self._db.session.commit()
        return self.get(entity.id)

    def delete(self, id: ID) -> Optional[BookModel]:
        entity = self._db.session.query(BookEntity).filter_by(id=id).first()
        if entity is None:
            raise NotFoundException(Messages.ENTITY_NOT_FOUND.format("Books", id))
        self._db.session.delete(entity)
        self._db.session.flush()
        self._db.session.commit()
        return self._hydrate(entity)

    def get(self, id: ID) -> Optional[BookModel]:
        entity = self._db.session.query(BookEntity).filter_by(id=id).first()
        if entity is None:
            return None
        return self._hydrate(entity)

    def get_by_name(self, name: str) -> List[BookModel]:
        entities = self._db.session.query(BookEntity).filter_by(name=name).all()
        return self._hydrate_multi(entities)

    def get_all(self) -> List[BookModel]:
        entities = self._db.session.query(BookEntity).all()
        return self._hydrate_multi(entities)

    @staticmethod
    def _to_entity(model: BookModel) -> BookEntity:
        return BookEntity(
            name=model.name,
            number_of_pages=model.number_of_pages,
            country=model.country,
            authors=model.authors,
            isbn=model.isbn,
            publisher=model.publisher,
            release_date=model.release_date,
            id=model.id,
        )

    @staticmethod
    def _to_entity_multi(models: List[BookModel]) -> List[BookEntity]:
        def do(model):
            return BookRepo._to_entity(model)

        return [do(model) for model in models]

    @staticmethod
    def _hydrate(entity: BookEntity) -> BookModel:
        return BookModel(
            name=entity.name,
            number_of_pages=entity.number_of_pages,
            country=entity.country,
            authors=entity.authors,
            id=entity.id,
            publisher=entity.publisher,
            isbn=entity.isbn,
            release_date=entity.release_date
        )

    @staticmethod
    def _hydrate_multi(entities: List[BookEntity]) -> List[BookModel]:
        def do(model):
            return BookRepo._hydrate(model)

        return [do(entity) for entity in entities]

    def update(self, model: BookModel) -> BookModel:
        entity = self._db.session.query(BookEntity).filter_by(id=model.id).first()
        if entity is None:
            entity = BookEntity()
        entity.name = model.name
        entity.number_of_pages = model.number_of_pages
        entity.country = model.country
        entity.authors = model.authors
        entity.publisher = model.publisher
        entity.isbn = model.isbn
        entity.release_date = model.release_date
        entity.id = model.id
        self._db.session.add(entity)
        self._db.session.flush()
        self._db.session.commit()
        return self._hydrate(entity)
