#!/bin/bash
# entrypoint script for peregrine to update CA certificates before running

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"

update-ca-certificates 

/peregrine/dockerrun.sh