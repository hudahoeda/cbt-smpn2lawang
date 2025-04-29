#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- You can add any initial SQL commands here if needed before restoring
EOSQL

# Restore the database dump
echo "Restoring database from /docker-entrypoint-initdb.d/exo-dump-master.sql..."
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < /docker-entrypoint-initdb.d/exo-dump-master.sql
echo "Database restore complete." 