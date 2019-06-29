from uuid import UUID

from voluptuous import All, Coerce, Schema

uuid_validator = All(str, Coerce(UUID))

allow_extra = Schema({}, required=True, extra=1)
