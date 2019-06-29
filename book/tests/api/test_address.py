from http import HTTPStatus
from uuid import uuid4

import pytest

from tests.factories import create_state, create_district


@pytest.fixture(autouse=True)
def _(fake_auth):
    # Ensures that the fake_auth fixture is added to all methods below
    yield


@pytest.mark.integration
def test_create_and_get_state(app):
    with app.test_client() as client:
        response = client.post(
            "/api/v1/states",
            json={"state_name": "dummy", "gst_code": "DUMMY", "state_code": "DUMMY"},
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.OK == response.status_code
        id = response.get_json()["data"]["id"]
        response = client.get("/api/v1/states/%s" % id)
        assert HTTPStatus.OK == response.status_code
        name = response.get_json()["data"]["state_name"]
        assert name == "dummy"


@pytest.mark.integration
def test_update_state(app):
    state = create_state()
    with app.test_client() as client:
        response = client.put(
            "/api/v1/states/%s" % state.id,
            json={"state_name": "dummy2", "gst_code": "DUMMY", "state_code": "DUMMY"},
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.OK == response.status_code
        response = client.get("/api/v1/states/%s" % state.id)
        assert HTTPStatus.OK == response.status_code
        name = response.get_json()["data"]["state_name"]
        assert name == "dummy2"


@pytest.mark.integration
def test_create_and_get_district(app):
    state = create_state()
    with app.test_client() as client:
        response = client.post(
            "/api/v1/districts",
            json={"state_id": str(state.id), "district_name": "DUMMY"},
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.OK == response.status_code
        response = client.get("/api/v1/districts?state-id=%s" % state.id)
        assert HTTPStatus.OK == response.status_code
        district_name = response.get_json()["data"][0]["district_name"]
        assert "DUMMY" == district_name


@pytest.mark.integration
def test_update_district(app):
    state = create_state()
    district = create_district(state)
    with app.test_client() as client:
        response = client.put(
            "/api/v1/districts/%s" % district.id,
            json={"state_id": str(state.id), "district_name": "DUMMY2"},
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.OK == response.status_code
        response = client.get("/api/v1/districts?state-id=%s" % state.id)
        assert HTTPStatus.OK == response.status_code
        district_name = response.get_json()["data"][0]["district_name"]
        assert "DUMMY2" == district_name


@pytest.mark.integration
def test_get_all_state(app):
    create_state()
    with app.test_client() as client:
        response = client.get("/api/v1/states")
        assert HTTPStatus.OK == response.status_code


@pytest.mark.integration
def test_create_and_get_address(app):
    state = create_state()
    district = create_district(state)
    with app.test_client() as client:
        response = client.post(
            "/api/v1/address",
            json={
                "formatted_address": "dummy",
                "state_id": state.id,
                "pincode": "800024",
                "district_id": district.id,
            },
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.OK == response.status_code
        id = response.get_json()["data"]["id"]
        response = client.get("/api/v1/address/%s" % id)
        assert HTTPStatus.OK == response.status_code
        formatted_address = response.get_json()["data"]["formatted_address"]
        assert formatted_address == "dummy"


@pytest.mark.integration
def test_create_address_when_invalid_state(app):
    with app.test_client() as client:
        response = client.post(
            "/api/v1/address",
            json={
                "formatted_address": "dummy",
                "state_id": uuid4(),
                "pincode": "800024",
                "district_id": uuid4(),
            },
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.BAD_REQUEST == response.status_code


@pytest.mark.integration
def test_create_address_when_invalid_district(app):
    state = create_state()
    with app.test_client() as client:
        response = client.post(
            "/api/v1/address",
            json={
                "formatted_address": "dummy",
                "state_id": state.id,
                "pincode": "800024",
                "district_id": uuid4(),
            },
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.BAD_REQUEST == response.status_code


@pytest.mark.integration
def test_create_address_when_invalid_pincode(app):
    state = create_state()
    district = create_district(state)
    with app.test_client() as client:
        response = client.post(
            "/api/v1/address",
            json={
                "formatted_address": "dummy",
                "state_id": state.id,
                "pincode": "80",
                "district_id": district.id,
            },
            headers={"X-USER-TOKEN": "dummy"},
        )
        assert HTTPStatus.BAD_REQUEST == response.status_code
