#!/bin/bash

# We use this script in docker-compose.yml to setup a common database container
# for all apps. It accepts database names via the `POSTGRES_MULTIPLE_DATABASES`
# environment variable.

# Compared to one DB container per app: this increases boot times, but ends up
# saving resources when multiple DB-backed services are running at the same time.

set -e
set -u
set -x

function create_user_and_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $database;
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
EOSQL

    psql -v ON_ERROR_STOP=1 --dbname="$database" --username "$POSTGRES_USER" <<-EOSQL
	    CREATE EXTENSION  postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		create_user_and_database $db
	done
	echo "Multiple databases created"
fi
