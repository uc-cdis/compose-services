#!bin/bash

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"
rm -f /var/run/apache2/apache2.pid && /indexd/dockerrun.bash