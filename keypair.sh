#!bin/bash

# Startup script for local docker-compose dev setup to create a keypair for 
# fence to use. Runs the last line of the Dockerfile to start up fence.

# Create directory for keys
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cd /fence/keys
mkdir ${timestamp}
cd ${timestamp}

# Generate keys
openssl genpkey -algorithm RSA -out jwt_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in jwt_private_key.pem -out jwt_public_key.pem

# Run last line of Dockerfile
rm -f /var/run/apache2/apache2.pid && /usr/sbin/apache2ctl -D FOREGROUND