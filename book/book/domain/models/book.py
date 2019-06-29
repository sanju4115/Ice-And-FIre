import datetime
from dataclasses import dataclass

from typing import List


@dataclass
class Book:
    name: str
    isbn: str
    authors: List
    country: str
    number_of_pages: int
    publisher: str
    release_date: datetime
    id: int = None
