#!/bin/bash
# Script to setup keys for fence as well as ssl credentials 

if [[ -e ./Secrets ]]; then
  echo "ERROR: Secrets/ folder already exists - bailing out"
  exit 1
fi

if [[ ! -d ./apis_configs ]]; then
  echo "ERROR: ./apis_configs not found - run in compose-services folder"
  exit 1
fi

cp -r ./apis_configs ./Secrets
cd Secrets

# make directories for temporary credentials
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir -p TLS
mkdir -p fenceJwtKeys
mkdir -p fenceJwtKeys/${timestamp}

# generate private and public key for fence
openssl genpkey -algorithm RSA -out fenceJwtKeys/${timestamp}/jwt_private_key.pem \
    -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in fenceJwtKeys/${timestamp}/jwt_private_key.pem \
    -out fenceJwtKeys/${timestamp}/jwt_public_key.pem

OS=$(uname)
OPTS=""
if [[ $OS == "Darwin" ]]; then
    cp /etc/ssl/openssl.cnf openssl-with-ca.cnf

    __v3_ca="
[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always
"

    echo "$__v3_ca" >> openssl-with-ca.cnf
    OPTS=" -extensions v3_ca -config openssl-with-ca.cnf"
fi

# generate certs for nginx ssl
commonName=${1:-localhost}
SUBJ="/countryName=US/stateOrProvinceName=IL/localityName=Chicago/organizationName=CDIS/organizationalUnitName=PlanX/commonName=$commonName/emailAddress=cdis@uchicago.edu"
openssl req -new -x509 -nodes -extensions v3_ca -keyout TLS/ca-key.pem \
    -out TLS/ca.pem -days 365 -subj $SUBJ $OPTS
if [[ $? -eq 1 ]]; then    
    echo "problem with creds_setup.sh script, refer to compose-services wiki"
    rm -rf temp*
    exit 1
fi


(
    cd TLS
    mkdir -p CA/newcerts
    touch CA/index.txt
    echo 1000 > CA/serial
    cat > openssl.cnf <<EOM
[ ca ]
# man ca
default_ca = CA_default
[ CA_default ]
# Directory and file locations.
dir             = TLS              # Where everything is kept
new_certs_dir   = \$dir/CA/newcerts
database        = \$dir/CA/index.txt     # database index file.
certificate     = \$dir/ca.pem           # The CA certificate
serial          = \$dir/CA/serial        # The current serial number
private_key     = \$dir/ca-key.pem       # The private key
# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
preserve          = no
policy            = policy_strict
[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of 'man ca'.
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ server_cert ]
# Extensions for server certificates ('man x509v3_config').
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
[ crl_ext ]
# Extension for CRLs ('man x509v3_config').
authorityKeyIdentifier=keyid:always
EOM

  )
openssl genrsa -out "TLS/service.key" 2048
openssl req -new -key "TLS/service.key" \
    -out "TLS/service.csr" -subj $SUBJ
openssl ca -batch -in "TLS/service.csr" -config TLS/openssl.cnf \
    -extensions server_cert -days 365 -notext -out "TLS/service.crt" 
