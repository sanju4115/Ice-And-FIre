from http import HTTPStatus

import pytest

from tests.factories import create_book


@pytest.mark.integration
def test_create_and_get_book(app):
    with app.test_client() as client:
        response = client.post(
            "/api/v1/books",
            json={
                "name": "dummy",
                "isbn": "DUMMY",
                "authors": ["test1"],
                "country": "India",
                "number_of_pages": 20,
                "publisher": "dummy_publisher",
                "release_date": "2019-08-01"
            }
        )
        assert HTTPStatus.CREATED == response.status_code
        id = response.get_json()["data"][0]["book"]["id"]
        response = client.get("/api/v1/books/%s" % id)
        assert HTTPStatus.OK == response.status_code
        name = response.get_json()["data"]["name"]
        assert name == "dummy"


@pytest.mark.integration
def test_update_book(app):
    book = create_book()
    with app.test_client() as client:
        response = client.patch(
            "/api/v1/books/%s" % book.id,
            json={"name": "dummy2"}
        )
        assert HTTPStatus.OK == response.status_code
        response = client.get("/api/v1/books/%s" % book.id)
        assert HTTPStatus.OK == response.status_code
        name = response.get_json()["data"]["name"]
        assert name == "dummy2"


@pytest.mark.integration
def test_get_all_book(app):
    create_book()
    with app.test_client() as client:
        response = client.get(
            "/api/v1/books"
        )
        assert HTTPStatus.OK == response.status_code
        data = response.get_json()["data"]
        assert len(data) == 1


@pytest.mark.integration
def test_delete_book(app):
    book = create_book()
    with app.test_client() as client:
        response = client.delete(
            "/api/v1/books/%s" % book.id
        )
        assert HTTPStatus.OK == response.status_code

@pytest.mark.integration
def test_get_all_book(app):
    book = create_book("my book")
    with app.test_client() as client:
        response = client.get(
            "/api/external-books?name=%s" % book.name
        )
        assert HTTPStatus.OK == response.status_code
        data = response.get_json()["data"][0]
        print(data)
        assert data["name"] == "my book"