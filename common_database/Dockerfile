FROM mdillon/postgis:9.6

ARG POSTGRES_MULTIPLE_DATABASES
ARG POSTGRES_PASSWORD
ARG POSTGRES_USER

ENV POSTGRES_MULTIPLE_DATABASES ${POSTGRES_MULTIPLE_DATABASES}
ENV POSTGRES_USER ${POSTGRES_USER}
ENV POSTGRES_PASSWORD ${POSTGRES_PASSWORD}

# Change default data dir as docker would discard everything in the intermediate steps
ENV PGDATA /var/lib/postgresql/shuttl_data

ADD . /app

RUN chmod +x /app/create_db.sh

# Run the entrypoint script as a step prior to actual container spawn.
# This will run create_db and this being a step in Dockerfile will be locally
# cached and subsequent runs should run quickly
# First part of the command just comments the postgres server start which is the
# last line of the file making the script non interactive and able to run
# as a step in Dockerfile. Second step copies the create db script to source dir where it will be
# picked up by the entrypoint script and lastly we uncomment the line for normal execution during
# container runs/spawns
RUN sed -i 's|exec "$@"|#exec "$@"|' /docker-entrypoint.sh && cp /app/create_db.sh /docker-entrypoint-initdb.d/ && \
    /docker-entrypoint.sh postgres && rm -f /docker-entrypoint-initdb.d/create_db.sh && \
    sed -i 's|#exec "$@"|exec "$@"|' /docker-entrypoint.sh

WORKDIR /app
