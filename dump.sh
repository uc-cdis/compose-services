#!/bin/bash
# Copies config and logs into a zip file

help="$(basename "$0") [help] [--logs-only]
where:
	help		show this help text
	--logs-only do not copy configuration files"

if [[ "$OSTYPE" != "linux-gnu" && "$OSTYPE" != "darwin"* ]]; then
	echo "This script only works on MacOS/Linux"
	exit 1
fi

get_config=true
while [ -n "$1" ]; do
	case "$1" in
	--logs-only)
		get_config=false
		;;
	help)
		echo "$help"
		exit 0
		;;
	*)
		echo "ignoring unknown option $1"
		;;
	esac
	shift
done

dirname=compose-services_dump_`date '+%Y-%m-%d_%H:%M:%S'`
mkdir -p $dirname
mkdir -p $dirname/logs/
if $get_config; then
	mkdir -p $dirname/config/
fi

if $get_config; then
	echo "Copying config files"
	cp docker-compose.yml $dirname/config/
	cp Secrets/etlMapping.yaml $dirname/config/
	cp Secrets/gitops.json $dirname/config/
	cp Secrets/user.yaml $dirname/config/
	cp Secrets/*config.* $dirname/config/
	cp Secrets/*settings.* $dirname/config/

	# remove lines containing creds
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		sed -i "/key/Id" $dirname/config/*
		sed -i "/secret/Id" $dirname/config/*
		sed -i "/password/Id" $dirname/config/*
	elif [[ "$OSTYPE" == "darwin"* ]]; then # MacOS
		sed -i "" "/[Kk][Ee][Yy]/d" $dirname/config/*
		sed -i "" "/[Ss][Ee][Cc][Rr][Ee][Tt]/d" $dirname/config/*
		sed -i "" "/[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]/d" $dirname/config/*
	else
		echo "WARNING: did not remove lines with creds (unknown OS $OSTYPE)"
	fi
fi

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
