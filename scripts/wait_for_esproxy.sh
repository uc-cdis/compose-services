#!/usr/bin/env bash

until curl -f -s http://esproxy-service:9200/_cluster/health | python3 -c "import sys, json; sys.exit(0 if json.load(sys.stdin)['status'] == 'green' else 1)" 2>/dev/null;
do
  echo "esproxy not ready, waiting..."
  sleep 5
done

echo "esproxy status is green"

exec "$@"