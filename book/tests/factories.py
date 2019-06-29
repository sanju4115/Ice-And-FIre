import datetime

from book.store.repos.books import BookRepo
from book.domain.models.book import Book


def create_book(name="dummy-book"):
    return BookRepo().create(
        Book(
            name=name,
            isbn="978-0553103540",
            country="United States",
            number_of_pages=120,
            authors=["dummy_author"],
            publisher="dummy_publisher",
            release_date=datetime.datetime.now(),
        ))
