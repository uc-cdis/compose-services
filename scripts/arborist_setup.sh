!/usr/bin/env bash#!/bin/bash
# entrypoint script for arborist to setup db

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"

update-ca-certificates

psql -U postgres -H postgres -c "CREATE ROLE $PGUSER SUPERUSER LOGIN";

createdb
./migrations/latest
./bin/arborist
