#!/bin/bash
###### DEPRECATED --> see creds_setup_services.sh  #########

# Script to setup keys for fence as well as ssl credentials

if [[ ! -d ./Secrets ]]; then
  echo "ERROR: ./Secrets not found"
  exit 1
fi
cd Secrets

#change to analysis-jwt-keys

# make directories for temporary credentials
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# generate private and public key for fence
yearMonth="$(date +%Y-%m)"
if [[ ! -d ./analysisJwtKeys ]] || ! (ls ./analysisJwtKeys | grep "$yearMonth" > /dev/null 2>&1); then
    echo "Generating analysis OAUTH key pairs under Secrets/analysisJwtKeys"
    mkdir -p analysisJwtKeys
    mkdir -p analysisJwtKeys/${timestamp}

    openssl genpkey -algorithm RSA -out analysisJwtKeys/${timestamp}/jwt_private_key.pem \
        -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in analysisJwtKeys/${timestamp}/jwt_private_key.pem \
        -out analysisJwtKeys/${timestamp}/jwt_public_key.pem
    chmod -R a+rx analysisJwtKeys

    cp analysisJwtKeys/${timestamp}/jwt_private_key.pem analysisJwtKeys/jwt_private_key.pem
    cp analysisJwtKeys/${timestamp}/jwt_public_key.pem analysisJwtKeys/jwt_public_key.pem 
fi


