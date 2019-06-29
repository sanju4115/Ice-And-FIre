from sqlalchemy import JSON
from .. import db


class Book(db.Model):
    __tablename__ = "books"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    isbn = db.Column(db.String(14), nullable=False)
    authors = db.Column(JSON, nullable=False)
    country = db.Column(db.String(50), nullable=False)
    number_of_pages = db.Column(db.Integer, nullable=False)
    publisher = db.Column(db.String(255), nullable=False)
    release_date = db.Column(db.DateTime, nullable=False)
