#!/bin/bash
# entrypoint script for fence to sync user.yaml before running

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"

update-ca-certificates 

fence-create sync --yaml user.yaml

rm -f /var/run/apache2/apache2.pid && /usr/sbin/apache2ctl -D FOREGROUND