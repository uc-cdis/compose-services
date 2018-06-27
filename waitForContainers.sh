#!bin/bash

sleep 10

until curl -f -s -o /dev/null http://nginx/api/v0/submission/getschema ; do
    echo "peregrine not ready, waiting..."
    sleep 10
done

until curl -f -s -o /dev/null http://nginx/api/v0/submission/_dictionary/_all; do
    echo "sheepdog not ready, waiting..."
    sleep 10
done

echo "both services are ready"
bash ./dockerStart.sh