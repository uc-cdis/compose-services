#!/bin/bash
# entrypoint script for sheepdog to run setup_transactionlogs.py before running

sleep 2
until (echo > /dev/tcp/postgres/5432) >/dev/null 2>&1; do
  echo "Postgres is unavailable - sleeping"
  sleep 2
done

echo "postgres is ready"

update-ca-certificates

python /sheepdog/bin/setup_transactionlogs.py --host postgres --user sheepdog_user --password sheepdog_pass --database metadata_db
bash /sheepdog/dockerrun.bash
