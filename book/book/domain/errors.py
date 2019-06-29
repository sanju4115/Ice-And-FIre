class ClientError(Exception):
    pass


class EntityNotFound(ClientError):
    pass


class ServerError(Exception):
    pass
