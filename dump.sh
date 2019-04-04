#!/bin/bash
# Copies config and logs into a zip file

dirname=compose-services_dump_`date '+%Y-%m-%d_%H:%M:%S'`
mkdir -p $dirname
mkdir -p $dirname/config/
mkdir -p $dirname/logs/

echo "Copying config files"
cp docker-compose.yml $dirname/
cp Secrets/user.yaml $dirname/
cp Secrets/*config.* $dirname/config/
cp Secrets/*settings.* $dirname/config/

echo "Dumping logs"
cat docker-compose.yml | grep "container_name" | while read -r line ; do
    name=$(expr "$line" : ".* \([a-z]*-service\)")
    docker-compose logs $name > $dirname/logs/logs-$name.txt
done

echo "Getting environment details"
# pip freeze > $dirname/pip-freeze.txt
# env > $dirname/env-vars.txt
git rev-parse HEAD > $dirname/latest-commit.txt

echo "Saving as zip file $dirname.zip"
zip -r $dirname.zip $dirname

echo "Cleaning up"
rm -r $dirname

echo "Done"
