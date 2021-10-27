#!/bin/bash
# Script to setup keys for Gen3 services (except fence)

# optional argument
service_arg=

# ADD ADDT'L SERVICES to the 'services' array
# service keys (aside from fence) are stored in [service]-jwt-keys, mirroring production
services_list=( "analysis" "amanuensis" )

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# If valid service name provided as $1, only create keys for that service
if [[ ! -z $1 ]] && [[ " ${services[*]} " =~ " ${1} " ]]; then
    # echo "Will generate keys for $1"
    service_arg=$1
fi

# Check for the Secrets dir.  Exit if not found
if [[ ! -d ./Secrets ]]; then
  echo "ERROR: ./Secrets not found"
  exit 1
fi
cd Secrets


# Function:  create_keys()
create_keys() {
    service_name=$1
    service_key_dir="${service_name}-jwt-keys"

    # generate private and public key for service
    yearMonth="$(date +%Y-%m)"
    if [[ ! -d ./$service_key_dir ]] || ! (ls ./$service_key_dir | grep "$yearMonth" > /dev/null 2>&1); then
        echo "Generating ${service_name} OAUTH key pairs under Secrets/${service_key_dir}"
        mkdir -p ${service_key_dir}/${timestamp}

        openssl genpkey -algorithm RSA -out ${service_key_dir}/${timestamp}/jwt_private_key.pem \
            -pkeyopt rsa_keygen_bits:2048
        openssl rsa -pubout -in ${service_key_dir}/${timestamp}/jwt_private_key.pem \
            -out ${service_key_dir}/${timestamp}/jwt_public_key.pem
        chmod -R a+rx ${service_key_dir}

        cp ${service_key_dir}/${timestamp}/jwt_private_key.pem ${service_key_dir}/jwt_private_key.pem
        cp ${service_key_dir}/${timestamp}/jwt_public_key.pem ${service_key_dir}/jwt_public_key.pem 
    else
        echo "Keys already exist for ${service_name}.  Nothing to do."
    fi
}

# Create keys for one or more services
if [[ ! -z $service_arg ]]; then
    # Service name provided, generate keys for that service only
    # in the event we want to target a single service
    # echo "Calling create_keys for $service_arg"
    create_keys ${service_arg}
else
    # Create keys for each named service
    for service in "${services_list[@]}"; do
        # echo "Calling create_keys for $service"
        create_keys ${service}
    done
fi






