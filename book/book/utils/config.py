from os import environ


def _create_sql_alchemy_url(db_url, db_user, db_pass, db_name):
    return "postgresql+psycopg2://%(user)s:%(pass)s@%(url)s/%(name)s" % {
        "user": db_user,
        "pass": db_pass,
        "name": db_name,
        "url": db_url,
    }


class Config:
    """
    Common configurations
    """

    SQLALCHEMY_ECHO = environ.get("SUPPLY_SQLALCHEMY_ECHO", "false") == "true"

    db_url = environ.get("BOOK_DB_URL")
    db_user = environ.get("BOOK_DB_USER")
    db_pass = environ.get("BOOK_DB_PASS")
    db_name = environ.get("BOOK_DB_NAME")

    SQLALCHEMY_DATABASE_URI = _create_sql_alchemy_url(db_url, db_user, db_pass, db_name)