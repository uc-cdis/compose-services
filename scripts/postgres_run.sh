#!/usr/bin/env bash

# Thing shim around the normal Docker postgres entrypoint that allows us to run
# non-application migrations. Things like DB and user creations that would be
# done by cloud-automation tasks in a normal env.

set -e

# Initialize the DB, but don't allow outside connections yet.
docker-entrypoint.sh postgres -c listen_addresses='127.0.0.1' &
# Wait until the server is out of initialization mode and online.
while ! psql -U postgres -h localhost -c 'SELECT 1;' 2>/dev/null; do echo "waiting for postgres init..."; sleep 1; done
# Stop the server.
gosu postgres pg_ctl stop

echo "[postgres] run migrations"

# Run migrations/scripts that should run on every start. This is handy for data
# we want to backfill or otherwise migrate for users.
gosu postgres bash -c "(
  source /usr/local/bin/docker-entrypoint.sh
  docker_setup_env
  docker_temp_server_start

  bash /postgres_always.sh

  docker_temp_server_stop
)"

echo "[postgres] migrations complete"

# Start postgres "normally" allowing all network clients to connect.
docker-entrypoint.sh postgres
