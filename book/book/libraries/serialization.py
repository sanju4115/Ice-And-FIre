from datetime import datetime
from enum import Enum
from uuid import UUID

primitive = (int, float, str, bool)


def is_primitive(thing):
    return isinstance(thing, primitive)


def serialize(obj):
    if obj is None:
        return None
    if is_primitive(obj):
        return obj
    if isinstance(obj, Enum):
        return obj.name
    if isinstance(obj, datetime):
        return obj.isoformat()
    if isinstance(obj, UUID):
        return str(obj)
    if isinstance(obj, list):
        return [serialize(v) for v in obj]
    if isinstance(obj, dict):
        return {k: serialize(v) for k, v in obj.items()}

    return {k: serialize(v) for k, v in obj.__dict__.items()}
