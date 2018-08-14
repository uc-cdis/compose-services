Compose-Services
===

Docker-compose setup for experimental commons, small commons, or local development of the Gen3 stack. Production use should use [cloud-automation](https://github.com/uc-cdis/cloud-automation). 

## Introduction
This setup uses Docker containers for postgres, indexd, fence, peregrine, sheepdog, data-portal and nginx. Images for the cdis microservices will be pulled from quay.io, while postgres (9.5) and nginx (latest) images will be pulled from Docker Hub. Nginx will be used as a reverse proxy to each of the services. Config file formats were copied from [cloud-automation](https://github.com/uc-cdis/cloud-automation) and stored in the `api_configs` directory and modified for local use with Docker Compose. Setup scripts for some of the containers are kept in the `scripts` directory.

### Some Database Info
Database setup only has to occur the very first time you setup your local gen3 Docker Compose environment, as this docker-compose environment is configured to create a persistent volume for postgres. The environment configuration is set up to automatically run setup scripts for the postgres container and set up the following:
  1. 3 databases  
      - `metadata_db`
      - `fence_db`
      - `indexd_db`
  2. 4 users with passwords and superuser access
      - `fence_user`
      - `peregrine_user`
      - `sheepdog_user`
      - `indexd_user`

## Setup
### Dependencies
  - openssl
  - Docker and Docker Compose

### Docker Setup
The official Docker installation page can be found [here](https://docs.docker.com/install/#supported-platforms). If you've never used Docker before, it may be helpful to read some of the Docker documentation to familiarize yourself with containers. 

### Docker Compose Setup
If you are using Linux, then the official Docker installation does not come with Docker Compose. The official Docker Compose installation page can be found [here](https://docs.docker.com/compose/install/#prerequisites). You can also read an overview of what Docker Compose is [here](https://docs.docker.com/compose/overview/) if you want some extra background information. Go through the steps of installing Docker Compose for your platform, then proceed to setting up credentials.

### Setting up Credentials
Setup the credentials with the provided script by running:
```
bash creds_setup.sh
```
This script will create `temp_creds` and `temp_keys` directories with the credential files in it. 

If you are using MacOS, you may run into an error with the default MacOS OpenSSL config not including the configuration for v3_ca certificate generation. You can refer to the solution on [this Github issue](https://github.com/jetstack/cert-manager/issues/279) on a related issue on Jetstack's cert-manager.

This Docker Compose setup also requires Google API Credentials in order for the fence microservice to complete its authentication. If you have Google API credentials set up already that you would like to use with the local gen3 Docker Compose setup, simply add `https://localhost/user/login/google/login/` to your Authorized redirect URIs. If you do not already have Google API Credentials, follow the steps below to set them up.

### Setting up Google+ API and Google API Credentials for Fence
Fence uses the Google+ API to log users in using their Google Accounts. In order for fence to work properly, the Google+ API must be enabled for the Google Account your are creating Google API Credentials with. To enable the Google+ API, go [the library page of the Google Developer Console](https://console.developers.google.com/apis/library) and search for Google+ API. Click on the card and follow the instructions to enable it.

To set up Google API Credentials, go to [the credentials page of the Google Developer Console](https://console.developers.google.com/apis/credentials) and click the 'Create Credentials' button. Follow the prompts to create a new OAuth Client ID for a Web Application, and then copy your client ID and client secret and use them to fill in the 'google_client_secret' and 'google_client_id' fields in the `api_configs/fence_creds.json` JSON file. 

### Setting up Users
To set up user privileges for the services, please edit the `apis_configs/user.yaml` file, following the example format shown in the file. The fence container will automatically sync this file to the `fence_db` database on startup. If you wish to update user privileges while the containers are running (without restarting the container), just edit the `apis_configs/user.yaml` file and then run
```
docker exec -it compose-services_fence_1 fence-create sync --yaml user.yaml
```
This command will enter the fence container to run the fence-create sync command, which will update your user privileges.

### Start running your local gen3 Docker Compose environment
Now that you are done with the setup, all Docker Compose features should be available. Here are some useful commands:

The basic command of Docker Compose is
```
docker-compose up
``` 
which can be useful for debugging errors. To detach output from the containers, run 
```
docker-compose up -d
``` 
When doing this, the logs for each service can be accessed using
```
docker logs
```
To stop the services use
```
docker-compose down
```
As the Docker images are pulled from quay.io, they do not update automatically. To update your Docker images, run
```
docker-compose pull
docker image prune -f
```
These commands may take a while, and they also may fail. If they do fail, simply rerun them, or just update/remove images one at a time manually.

## Dev Tips
When developing, you can have local repositories of the services you are working on and use volumes to mount your local repository files onto the containers to override the containers' code (which is built from GitHub using quay.io). Then, you can restart a single container with
```
docker-compose restart [CONTAINER_NAME]
```
after you update some code in order to see changes without having to rebuild all the microservices. Keep in mind that running `docker-compose restart` does not apply changes you make in the docker-compose file. Look up the Docker documentation for more information about [volumes](https://docs.docker.com/storage/).

## Running Docker Compose