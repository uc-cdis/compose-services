#!/bin/bash
# entrypoint script for sheepdog to run setup_transactionlogs.py before running

python /sheepdog/bin/setup_transactionlogs.py --host postgres --user sheepdog_user --password sheepdog_pass --database metadata_db
bash /sheepdog/dockerrun.bash