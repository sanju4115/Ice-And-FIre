#!/usr/bin/env bash
# use this script to truncate tables of a db
cmdname=$(basename $0)

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname host:port:db_name:table_name or $cmdname host:port:db_name
    -h  HOST       | --host=HOST          db host    | default - 0.0.0.0
    -p  PORT       | --port=PORT          db port    | default - 9221
    -db DB_NAME    | --db_name=DB_NAME    db name
    -t  TABLE_NAME | --t_name=TABLE_NAME  table name | default - ALL
USAGE
    exit 1
}

HOST="0.0.0.0"
PORT="9221"
TABLE_NAME="ALL"

truncate_all()
{
psql postgresql://shuttl_user:shuttl_user@"$HOST":"$PORT"/"$DB_NAME" << EOF
      do
      \$\$
      declare
         l_stmt text;
      begin
          select 'truncate ' || string_agg(format('%I.%I', schemaname, tablename), ',')
          from pg_tables into l_stmt
          where schemaname in ('public');
          execute l_stmt;
      end;
      \$\$
EOF
}

truncate_table()
{
psql postgresql://shuttl_user:shuttl_user@"$HOST":"$PORT"/"$DB_NAME" << EOF
      truncate "$TABLE_NAME"
EOF
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        *:*:*:* )
        host_port_db=(${1//:/ })
        HOST=${host_port_db[0]}
        PORT=${host_port_db[1]}
        DB_NAME=${host_port_db[2]}
        TABLE_NAME=${host_port_db[3]}
        shift 1
        ;;
        *:*:* )
        host_port_db=(${1//:/ })
        HOST=${host_port_db[0]}
        PORT=${host_port_db[1]}
        DB_NAME=${host_port_db[2]}
        shift 1
        ;;
        -h)
        HOST="$2"
        if [[ $HOST == "" ]]; then break; fi
        shift 2
        ;;
        --host=*)
        HOST="${1#*=}"
        shift 1
        ;;
        -p)
        PORT="$2"
        if [[ $PORT == "" ]]; then break; fi
        shift 2
        ;;
        --port=*)
        PORT="${1#*=}"
        shift 1
        ;;
        -db)
        DB_NAME="$2"
        if [[ $DB_NAME == "" ]]; then break; fi
        shift 2
        ;;
        --db_name=*)
        DB_NAME="${1#*=}"
        shift 1
        ;;
        -t)
        TABLE_NAME="$2"
        if [[ TABLE_NAME == "" ]]; then break; fi
        shift 2
        ;;
        --t_name=*)
        TABLE_NAME="${1#*=}"
        shift 1
        ;;
        --help)
        usage
        ;;
        *)
        echo "Unknown argument: $1"
        usage
        ;;
    esac
done

if [[ "$HOST" == "" || "$PORT" == "" || "$DB_NAME" == "" ]]; then
    echo "Error: you need to provide host, port and db name"
    usage
fi

if "$TABLE_NAME" == ""; then
   echo "Please provide table name"
   usage
fi

echo "Cleaning data from $HOST:$PORT $DB_NAME"

if [ "$TABLE_NAME" == "ALL" ]
then
    echo 'Truncating all tables in db:' "$DB_NAME"
    truncate_all
else
    echo 'Truncating table:' "$TABLE_NAME"
    truncate_table
fi

echo "Done Cleaning data from $HOST:$PORT $DB_NAME"