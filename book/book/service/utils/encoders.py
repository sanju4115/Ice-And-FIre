import datetime
import enum
import json
from uuid import UUID


class JsonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, UUID):
            return str(obj)
        if isinstance(obj, datetime.datetime):
            return str(obj)
        if isinstance(obj, enum.Enum):
            return str(obj)
        return json.JSONEncoder.default(self, obj)
