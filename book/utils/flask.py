from http import HTTPStatus

from flask import json, Response, Flask


class APIFlask(Flask):
    def make_response(self, rv):
        if isinstance(rv, APIResponse):
            return rv.to_json()
        if isinstance(rv, APIError):
            return rv.to_json()
        if isinstance(rv, GenericResponse):
            return rv.to_json()
        return super(APIFlask, self).make_response(rv)


class GenericResponse:
    def __init__(self, value=None, status=HTTPStatus.OK, meta=None, message=None):
        if meta:
            self.payload = {"data": value, "meta": meta}
        else:
            self.payload = {
                "data": value,
                "status": "success",
                "status_code": status,
            }
            if message:
                self.payload["message"] = message
        self.status = status

    def to_json(self):
        return Response(
            json.dumps(self.payload), status=self.status, mimetype="application/json"
        )


class APIError:
    def __init__(self, error=None, status=HTTPStatus.INTERNAL_SERVER_ERROR):
        self.payload = {"error": error}
        self.status = status

    def to_json(self):
        return Response(
            json.dumps(self.payload), status=self.status, mimetype="application/json"
        )


class NotFoundException(Exception):
    def __init__(self, message, status=HTTPStatus.NOT_FOUND):
        self.message = message
        self.status = status

    def to_json(self):
        payload = {"message": self.message, "type": "NOT_FOUND_EXCEPTION"}
        return APIError(payload, status=self.status)