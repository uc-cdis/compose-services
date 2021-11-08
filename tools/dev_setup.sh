#!/bin/bash
#
# Script:  dev_setup.sh
#
# Usage:  dev_setup.sh 
#               -i,--id <client_id> 
#               -s,--secret <client_secret> 
#               OR 
#               create a .env file, see the README.md for detals
#
# A Gen3 script to automate the process of getting the 
#    Gen3 dev environment up and running efficiently.
# Run:  - dev_setup.sh
#       - dev_populate_fake_data.sh
#
# By:  dvenckus@uchicago.edu (PCDC/Peds-BSD).
# 

#------------------------------------------------------
# Get Args
#------------------------------------------------------
CLIENT_ID=
CLIENT_SECRET=

USAGE="Usage:  dev_setup.sh -i <client_id> -s <client_secret>"

echo "Begin Gen3 dev_setup.sh..."

# If settings are imported from the .env file, great
# if not, check commandline arguments
source ./.env

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then

  # extract options and their arguments into variables.
  while (( "$#" )); do
    var=$1

    case "$var" in
      -i|--id)
          CLIENT_ID=$2 ; shift 2 ;;
      -s|--secret)
          CLIENT_SECRET=$2 ; shift 2 ;;
    esac

    # shift
  done
fi


if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing paramters: "
  echo "  client_id:     $CLIENT_ID"
  echo "  client_secret: $CLIENT_SECRET"
  echo "$USAGE"
fi


#------------------------------------------------------
# CONSTANTS
#------------------------------------------------------

# CWD=$(dirname "$0")
CWD=$(cd $(dirname "$0") && pwd)
COMPOSE_SVCS_DIR="$CWD/.."

# Swtiched to using chicagopcdc/gen3_scripts repo (pcdc_dev branch)
GEN3_ROOT="$CWD/../.."
GEN3_SCRIPTS_DIR="$GEN3_ROOT/gen3_scripts"
GEN3_SCRIPTS_REPO="https://github.com/chicagopcdc/gen3_scripts.git"
GEN3_SCRIPTS_REPO_BRANCH="origin/pcdc_dev"

#------------------------------------------------------
# Clone or Update chicagopcdc/gen3_scripts repo
#------------------------------------------------------

echo "Clone or Update chicagopcdc/gen3_scripts repo from github"

# Does compose-services repo exist?  If not, go get it!
if [ ! -d "$GEN3_SCRIPTS_DIR" ]; then
  cd "$GEN3_ROOT"
  git clone $GEN3_SCRIPTS_REPO

  cd $GEN3_SCRIPTS_DIR

  git checkout -t $GEN3_SCRIPTS_REPO_BRANCH
  git pull
  cd ..
fi

cd $COMPOSE_SVCS_DIR

#------------------------------------------------------
# Destroy any Docker Hanging Volumes
#------------------------------------------------------
DANGLING=$(docker volume ls -qf dangling=true)
if [ ! -z "$DANGLING" ]; then 
  docker volume rm ${DANGLING}
fi

#------------------------------------------------------
# Credentials Setup
#------------------------------------------------------
echo "Running: creds_setup.sh"
bash ./creds_setup.sh


#------------------------------------------------------
# Add Google oAuth client_id and client_secret settings
#------------------------------------------------------
echo "Update fence-config.yaml Google oAuth credentials"
FENCE_CONFIG="$COMPOSE_SVCS_DIR/Secrets/fence-config.yaml"
perl -i -pe "s/GOOGLE_CLIENT_ID/${CLIENT_ID}/" $FENCE_CONFIG
perl -i -pe "s/GOOGLE_CLIENT_SECRET/${CLIENT_SECRET}/" $FENCE_CONFIG


#------------------------------------------------------
# nginx.conf - Disable guppy-service block
#------------------------------------------------------
NGINX_CONF="$COMPOSE_SVCS_DIR/nginx.conf"
NGINX_CONF_TMP="$COMPOSE_SVCS_DIR/nginx.conf.tmp"

echo "Nginx.conf:  Disable guppy-service block"

# remove old tmp file if it exists
rm -fr $NGINX_CONF_TMP

# rename the nginx.conf
cp -f $NGINX_CONF $NGINX_CONF_TMP
rm -f $NGINX_CONF

# start the new nginx.conf file
touch $NGINX_CONF
DONE=
# This method with IFS preserves whitespace in files
OLD_IFS="$IFS"
IFS=
while read -r line; do
  if [[ $line != *"#"* ]] && [ -z $DONE ]; then
    if [[ $line =~ "location /guppy/ {" ]] ; then
      echo "# $line" >> $NGINX_CONF
      read -r line
      echo "# $line" >> $NGINX_CONF
      read -r line
      echo "# $line" >> $NGINX_CONF
      DONE="1"
      continue
    fi
  fi
  echo "$line" >> $NGINX_CONF
done < $NGINX_CONF_TMP
IFS="$OLD_IFS"

# Don't remove yet, keep for after the next step
# rm -f $NGINX_CONF_TMP

#------------------------------------------------------
# Credentials Setup for Gen3 Services
#------------------------------------------------------
echo "Running: creds_setup_services.sh"
bash ./creds_setup_services.sh

#------------------------------------------------------
# Docker
#------------------------------------------------------
echo "Running:  docker-compose up -d"
docker-compose up -d 
sleep 30s

# Due to an order of events problem, restart some services
# If we attempt restart too soon, this won't work
echo "Restarting: portal-service revproxy-service"
docker restart portal-service revproxy-service 

# Return to where we started.
cd $CWD

echo "Done!"
