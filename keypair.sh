#!bin/bash

# Create directory for keys
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cd /fence/keys
mkdir ${timestamp}
cd ${timestamp}

# Generate keys
openssl genpkey -algorithm RSA -out jwt_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in jwt_private_key.pem -out jwt_public_key.pem