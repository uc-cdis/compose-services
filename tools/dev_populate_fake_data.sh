#!/bin/bash
#
# Script:  dev_populate_fake_data.sh
#
# Usage:  dev_populate_fake_data.sh 
#               -t,--token <github_token> 
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

USAGE="Usage:  dev_populate_fake_data.sh -t <github_token>"

#------------------------------------------------------
# Get Args
#------------------------------------------------------

# If settings are imported from the .env file, great
# if not, check commandline arguments
source ./.env

if [ -z "$GITHUB_TOKEN" ]; then

  # extract options and their arguments into variables.
  while (( "$#" )); do
    var=$1

    case "$var" in
      -t|--token)
          GITHUB_TOKEN=$2 ; shift 2 ;;
    esac
    # shift
  done
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Missing paramters: "
  echo "  github_token:     $GITHUB_TOKEN"
  echo "$USAGE"
fi

#------------------------------------------------------
# CONSTANTS
#------------------------------------------------------

CWD=$(cd $(dirname "$0") && pwd)
COMPOSE_SVCS_DIR="$CWD/.."
GEN3_SCRIPTS_DIR="$CWD/../../gen3_scripts"
GEN3_SCRIPTS_REPO="https://github.com/chicagopcdc/gen3_scripts.git"
GEN3_SCRIPTS_REPO_BRANCH="origin/pcdc_dev"

CREDENTIALS_FILE="$GEN3_SCRIPTS_DIR/populate_fake_data/credentials.json"
PYTHON_REQD_VERSION=$(pyenv install --list | grep -e '\s3\.9\.\d$' | tail -n1)
NGINX_CONF="$COMPOSE_SVCS_DIR/nginx.conf"
NGINX_CONF_TMP="$COMPOSE_SVCS_DIR/nginx.conf.tmp"

#------------------------------------------------------
# Setup the Python Virtual Env
#------------------------------------------------------
echo "Check for the credentials file and the correct version of Python"

if [ ! -e "$CREDENTIALS_FILE" ]; then
  echo "ERROR:  $CREDENTIALS_FILE not found"
  echo "Login to http://localhost/login and visit http://localhost/identity to 'Create API key' and download credentials.json file into the populate_fake_data directory."
  exit 1
fi 

#------------------------------------------------------
# Clone or Update chicagopcdc/gen3_scripts repo
#------------------------------------------------------

# Swtiched to using chicagopcdc/gen3_scripts repo (pcdc_dev branch)

echo "Clone or Update chicagopcdc/gen3_scripts repo from github"

# Does compose-services repo exist?  If not, go get it!
if [ ! -d "$GEN3_SCRIPTS_DIR" ]; then
  cd ../..
  git clone $GEN3_SCRIPTS_REPO

  cd $GEN3_SCRIPTS_DIR

  git checkout -t $GEN3_SCRIPTS_REPO_BRANCH
  git pull
  git reset --hard $GEN3_SCRIPTS_REPO_BRANCH
  git pull 
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

# Check for required python version
echo "Does the current version of python match the required version $PYTHON_REQD_VERSION ?"
PYTHON_CURRENT_VERSION=$(python --version)
if [[ ! $PYTHON_CURRENT_VERSION =~ "Python $PYTHON_REQD_VERSION" ]]; then
  # Use pyenv to setup required python local version
  IS_REQD_VERSION_INSTALLED=$(pyenv versions | grep "$PYTHON_REQD_VERSION")
  if [ -z "$IS_REQD_VERSION_INSTALLED" ]; then
    # not installed, let's do that now
    echo "pyenv python $PYTHON_REQD_VERSION not detected. Verifying installation."
    pyenv install --skip-existing $PYTHON_REQD_VERSION
  else
    echo "pyenv python $PYTHON_REQD_VERSION found"
  fi
  # setup the required version for this project (creates a .python-version file)
  echo "Setting: 'pyenv local $PYTHON_REQD_VERSION' for this project"
  pyenv local $PYTHON_REQD_VERSION
else
  echo "Found $PYTHON_REQD_VERSION"
fi

echo "Setup Python Virtual Env"
cd $GEN3_SCRIPTS_DIR/populate_fake_data
if [ ! -d "./env" ] || [ ! -e "./env/bin/activate" ]; then
  # if env found but not populated
  rm -f "./env"
  echo "Python Virtual Env not found, creating it."
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

# handle different versions of sed that require different parameters
echo "Edit the etl.py so it includes your GITHUB_TOKEN"
WHICH_SED=$(command -v sed)
if [[ "$WHICH_SED" == "/usr/bin/sed" ]]; then
  # default mac developer tools version of sed
  sed -i ' ' -e "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" etl.py
else 
  # gnu-sed, /usr/local/opt/gnu-sed/libexec/gnubin/sed
  # or an undetermined sed
  sed -i "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" etl.py
fi

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

echo "Setup ES ETL Python Virtual Env"
if [ ! -d "./env" ] || [ ! -e "./env/bin/activate" ]; then
  # if env found but not populated
  rm -f "./env"
  echo "Python Virtual Env not found, creating it."
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

echo "Edit the ES etl/build_json.py so it includes your GITHUB_TOKEN"
if [[ "$WHICH_SED" == "/usr/bin/sed" ]]; then
  # default mac developer tools version of sed
  sed -i ' ' -e "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" build_json.py
else 
  # gnu-sed, /usr/local/opt/gnu-sed/libexec/gnubin/sed
  # or an undetermined sed
  sed -i "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" build_json.py
fi

#------------------------------------------------------
# Load ES data
#------------------------------------------------------
echo "Load ES Data, python create_index.py"
python create_index.py

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
# Guppy Setup
#------------------------------------------------------
echo "Run: guppy_setup.sh"
bash $COMPOSE_SVCS_DIR/guppy_setup.sh

echo "Docker restart revproxy-service (last time)"
docker restart revproxy-service

# Back to where we started
cd $CWD

echo "Gen3 dev environment ready.  Login to http://localhost"
echo "Done!"