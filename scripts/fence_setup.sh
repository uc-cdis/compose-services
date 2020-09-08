#!/bin/bash
# entrypoint script for fence to sync user.yaml before running

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"

update-ca-certificates

until curl -f -s -o /dev/null http://arborist-service/policy; do
    echo "arborist not ready, waiting..."
    sleep 10
done

fence-create sync --yaml user.yaml --arborist http://arborist-service

cd /fence
/dockerrun.sh