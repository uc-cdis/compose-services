#!/bin/bash
# Script to setup keys for fence as well as ssl credentials

if [[ ! -d ./templates ]]; then
  echo "ERROR: ./templates not found - run in compose-services folder"
  exit 1
fi
if [[ -d Secrets ]]; then
  # make a backup
  bak="Secrets$(date +%Y%m%d%H%M%S).bak"
  if [[ -e "$bak" ]]; then
    echo "ERROR: ./Secrets and $bak already exist"
    exit 1
  fi
  echo "Backing up ./Secrets/ to ./$bak/"
  cp -r ./Secrets "./$bak"
fi

mkdir -p Secrets

for path in templates/*; do
  target="Secrets/$(basename "$path")"
  if [[ "$path" =~ \.py$ ]]; then # update python files
    echo "Copying $path to $target"
    cp "$path" "$target"
  elif [[ ! -e "$target" ]]; then
    echo "Copying $path to $target"
    cp -r "$path" "$target"
  else
    echo "$target already exists"
  fi
done

tempFile="gen3scratch.tmp"
if [ ! -z $1 ]; then
  customHost="$1"
  shift
  # be careful with sed -i on Mac: https://stackoverflow.com/questions/19456518/invalid-command-code-despite-escaping-periods-using-sed
  for name in Secrets/fence-config.yaml Secrets/*_creds.json; do
    sed "s/localhost/$customHost/g" "$name" > "$tempFile" && \
      cp "$tempFile" "$name"
  done
fi

configFile=./Secrets/fence-config.yaml
if grep "^ENCRYPTION_KEY: ''" "$configFile" > /dev/null; then
  # be careful with sed on Mac: https://stackoverflow.com/questions/19456518/invalid-command-code-despite-escaping-periods-using-sed
  key="$(python ./scripts/fence_key_helper.py)" && \
     sed "s/^ENCRYPTION_KEY: ''/ENCRYPTION_KEY: '$key'/" "$configFile" > "$tempFile" && \
     cp "$tempFile" "$configFile"
fi
rm "$tempFile"

cd Secrets

# make directories for temporary credentials
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# generate private and public key for fence
yearMonth="$(date +%Y-%m)"
if [[ ! -d ./fenceJwtKeys ]] || ! (ls ./fenceJwtKeys | grep "$yearMonth" > /dev/null 2>&1); then
    echo "Generating fence OAUTH key pairs under Secrets/fenceJwtKeys"
    mkdir -p fenceJwtKeys
    mkdir -p fenceJwtKeys/${timestamp}

    openssl genpkey -algorithm RSA -out fenceJwtKeys/${timestamp}/jwt_private_key.pem \
        -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in fenceJwtKeys/${timestamp}/jwt_private_key.pem \
        -out fenceJwtKeys/${timestamp}/jwt_public_key.pem
    chmod -R a+rx fenceJwtKeys
fi

# generate certs for nginx ssl
(
    mkdir -p TLS
    cd TLS

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

    if ! [[ -f openssl.cnf && -f ca.pem && -f ca-key.pem ]]; then
      echo "Generating a local certificate authority, and TLS certificates under Secrets/TLS/"
      # erase old certs if they exist
      /bin/rm -rf service.key service.crt
      commonName=${1:-localhost}
      SUBJ="/countryName=US/stateOrProvinceName=IL/localityName=Chicago/organizationName=CDIS/organizationalUnitName=PlanX/commonName=$commonName/emailAddress=cdis@uchicago.edu"
      openssl req -new -x509 -nodes -extensions v3_ca -keyout ca-key.pem \
          -out ca.pem -days 365 -subj $SUBJ $OPTS
      if [[ $? -eq 1 ]]; then
          echo "problem with creds_setup.sh script, refer to compose-services wiki"
          rm -rf temp*
          exit 1
      fi

      mkdir -p CA/newcerts
      touch CA/index.txt
      touch CA/index.txt.attr
      echo 1000 > CA/serial
      cat > openssl.cnf <<EOM
[ ca ]
# man ca
default_ca = CA_default
[ CA_default ]
# Directory and file locations.
dir             = .                      # Where everything is kept
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
    else
      echo "Looks like Secrets/TLS/CA already exists"
    fi
    if [[ ! -f service.key || ! -f service.crt ]]; then
      openssl genrsa -out "service.key" 2048
      openssl req -new -key "service.key" \
          -out "service.csr" -subj $SUBJ
      openssl ca -batch -in "service.csr" -config openssl.cnf \
          -extensions server_cert -days 365 -notext -out "service.crt"
    else
      echo "Looks like Secrets/TLS/service.key and service.crt already exist"
    fi
)
