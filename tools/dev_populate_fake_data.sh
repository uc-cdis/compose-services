#!/bin/bash
#
# Script:  dev_populate_fake_data.sh
#
# Usage:  dev_populate_fake_data.sh 
#               -t,--token <github_token> 
#               -r,--recreate-env
#               OR 
#               create a .env file, see the README.md for detals
#
# BEFORE attempting to run this script, visit the local Gen3 instance
#
#   CREDENTIALS.JSON:
#     login via Google and visit the profile page,
#     https://locahost/identity
#     Add API key to your profile and download the credentials.json file to 
#     configuration-files/populate_fake_data directory
#
#   PYTHON:  
#     Requires v3.6+; 'python' should be aliased to python3
#
# A Gen3 script to automate the process of getting the 
#    Gen3 dev environment up and running efficiently.
#
# Run:  - dev_setup.sh
#       - dev_populate_fake_data.sh
#
# By:  dvenckus@uchicago.edu (PCDC/Peds-BSD).
# 

echo "Begin dev_populate_fake_data.sh"

GITHUB_TOKEN=
RECREATE_ENV=

USAGE="Usage:  dev_populate_fake_data.sh -t <github_token>"

#------------------------------------------------------
# Get Args
#------------------------------------------------------

# If settings are imported from the .env file, great
# if not, check commandline arguments
source ./.env

# extract options and their arguments into variables.
while (( "$#" )); do
  var=$1

  case "$var" in
    -t|--token)
        if [ -z "$GITHUB_TOKEN" ]; then
          # use the parameters if it's not in the .env file
          GITHUB_TOKEN=$2 
        fi
        shift 2 ;;

    -r|--recreate-env)
        RECREATE_ENV=1 ; shift 1 ;;
  esac
  # shift
done


if [ -z "$GITHUB_TOKEN" ]; then
  echo "Missing paramters: "
  echo "  github_token:     $GITHUB_TOKEN"
  echo "$USAGE"
fi


#------------------------------------------------------
# CONSTANTS
#------------------------------------------------------

CWD=$(cd $(dirname "$0") && pwd)
GEN3_ROOT="$CWD/../.."
COMPOSE_SVCS_DIR="$CWD/.."
GEN3_SCRIPTS_DIR="$GEN3_ROOT/gen3_scripts"

CREDENTIALS_FILE="$GEN3_SCRIPTS_DIR/populate_fake_data/credentials.json"
# xargs is trimming whitespace
PYTHON3_LATEST_VERSION=$(pyenv install --list | grep -E '\s3\.([6-9]|\d{2,})\.\d+$' | tail -n1 | xargs)
PYTHON3_MIN_VERSION='^3\.([6-9]|\d{2,})\.\d+$'
NGINX_CONF="$COMPOSE_SVCS_DIR/nginx.conf"
NGINX_CONF_TMP="$COMPOSE_SVCS_DIR/nginx.conf.tmp"


#------------------------------------------------------
# Setup the Python Virtual Env
#------------------------------------------------------
echo "Check for the credentials file"

if [ ! -e "$CREDENTIALS_FILE" ]; then
  echo "ERROR:  $CREDENTIALS_FILE not found"
  echo "Login to http://localhost/login and visit http://localhost/identity to 'Create API key' and download credentials.json file into the populate_fake_data directory."
  exit 1
fi 

#------------------------------------------------------
# Setup the Python Environment
#------------------------------------------------------
cd $GEN3_SCRIPTS_DIR/populate_fake_data

# Is pyenv installed?
echo "Is pyenv installed?"
PYENV_INSTALLED=$(command -v pyenv)
if [ -z "$PYENV_INSTALLED" ]; then
  echo "ERROR:  pyenv not found."
  exit 1
else 
  echo "Found pyenv"
fi

# Check for the minimum required python version
echo "Is the Python minimum required version installed?"
cd $GEN3_SCRIPTS_DIR
# Is the current python version acceptable?
PYTHON3_VERSION=$(pyenv version | awk '{print $1}')
USING_PYTHON3_MIN_VERSION=$(echo "$PYTHON3_VERSION" | grep -E "$PYTHON3_MIN_VERSION")
echo "Python version: $PYTHON3_VERSION"
if [ -z "$USING_PYTHON3_MIN_VERSION" ]; then
  # Not currently using python min version
  # We need to do something about this!

  # Is an acceptable python version already installed?  Get latest from pyenv versions
  MIN_VERSION_ALREADY_INSTALLED=$(pyenv versions| awk '{print $1}' | grep -E "^3\.([6-9]|\d{2,})\.\d+$" | tail -n1)

  if [ -z "$MIN_VERSION_ALREADY_INSTALLED" ]; then
    # Python min version not detected, install if it's not there
    echo "Pyenv python minimum version not detected. Verifying installation or will install $PYTHON3_LATEST_VERSION"
    pyenv install --skip-existing $PYTHON3_LATEST_VERSION
    
    # setup the required version for this project (creates a .python-version file)  
    cd $GEN3_SCRIPTS_DIR
    echo "Setting: 'pyenv local $PYTHON3_LATEST_VERSION' for gen3_scripts"
    pyenv local $PYTHON3_LATEST_VERSION
  else 
    # Found one!  Activate it
    echo "Setting: 'pyenv local $MIN_VERSION_ALREADY_INSTALLED' for gen3_scripts"
    pyenv local $MIN_VERSION_ALREADY_INSTALLED
  fi
else
  echo "Found python3 minimum verion."
fi

echo "Checking for Python Virtual Env"
cd $GEN3_SCRIPTS_DIR/populate_fake_data
if [ ! -d "./env" ] || [ ! -e "./env/bin/activate" ] || [ ! -z "$RECREATE_ENV" ]; then
  # if env not found, not populated or needs to be recreated
  if [ -e "./env" ]; then 
    rm -rf "./env"
  fi
  echo "Python Virtual Env not found or being recreated, creating new env."
  python -m venv env 
  echo "Activating python env"
  source env/bin/activate
  echo "Install Python packages with requirements.txt"
  echo "This will take a while.  Grab some coffee while you wait."
  pip install -r requirements.txt
else
  echo "Activating python env"
  source env/bin/activate
fi

#------------------------------------------------------
# Modify the etl.py script to include your GITHUB TOKEN
#------------------------------------------------------
cd ./operations

echo "Edit etl.py so it includes your GITHUB_TOKEN"
perl -i -pe "s/token = \"[0-9a-zA-Z_]*\"/token =\"${GITHUB_TOKEN}\"/" etl.py

#------------------------------------------------------
# Run:  etl.py load, Load data into postgres db
#------------------------------------------------------
echo "Run: python etl.py load"
python ./etl.py load

deactivate  # exit python venv

#------------------------------------------------------
# Run:  Load data into elasticsearch
#------------------------------------------------------
cd ../../es_etl_patch

echo "Checking for ES ETL Python Virtual Env"
if [ ! -d "./env" ] || [ ! -e "./env/bin/activate" ] || [ ! -z "$RECREATE_ENV" ]; then
  # if env not found, not populated or needs to be recreated
  if [ -e "./env" ]; then 
    rm -rf "./env"
  fi
  echo "Python Virtual Env not found or being recreated, creating new env."
  python -m venv env 
  echo "Activating python env"
  source env/bin/activate
  echo "Install Python packages with requirements.txt"
  echo "This will take a while.  Grab some coffee while you wait."
  pip install -r requirements.txt
else
  echo "Activating python env"
  source env/bin/activate
fi

#-------------------------------------------------------------
# Modify the build_json.py script to include your GITHUB TOKEN
#-------------------------------------------------------------
cd ./etl

echo "Edit ES etl/build_json.py so it includes your GITHUB_TOKEN"
perl -i -pe "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" build_json.py


#------------------------------------------------------
# Load ES data
#------------------------------------------------------
echo "Load ES Data, python create_index.py"
python create_index.py

deactivate  # exit python venv

#--------------------------------------------------------------
# Replace nginx.conf (current one has guppy location commented)
#--------------------------------------------------------------
if [ -e "$NGINX_CONF_TMP" ]; then
  echo "Copy: nginx.conf... AGAIN!  This time with more oomfph."
  # nginx.conf.tmp should exist after the dev_setup.sh script run
  cp -f $NGINX_CONF_TMP $NGINX_CONF
  echo "Docker restart revproxy-service"
  docker restart revproxy-service
  sleep 10s
fi

#------------------------------------------------------
# Services Restart
#------------------------------------------------------

echo "Docker restart guppy-service"
docker restart guppy-service

echo 'Docker restart revproxy-service (last time)'
docker restart revproxy-service

# Back to where we started
cd $CWD

echo "Gen3 dev environment ready.  Login to http://localhost"
echo "Done!"
