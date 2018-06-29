Compose-Services
===

Docker-compose setup for local development of the Gen3 stack. Production use should use [cloud-automation](https://github.com/uc-cdis/cloud-automation).


added creds.json file as well as apis_configs files from cloud-automation
modified creds.json fields
modified apis_configs files in order to composeify them rather than kubeify them
modified docker-compose.yaml to mount files similarly to cloud-automation
manually went on postgres container and added databases and users, peregrine has to be superuser (this doesn't get erased when the container gets removed because of the persistent volume) 
USER STEP: update creds.json fence area with google API client secret and client ID
USER STEP: run sudo bash creds_setup.sh
NOTE: You can have a local repo of the service you are developing, and use 
volumes to mount that repo and override image's code. Then, you can restart a 
single container with docker-compose restart [CONTAINER_NAME] after you update 
some code in order to see changes without having to rebuild (does not apply 
changes in docker-compose file)



TODO: automate the script setup processes and make api_configs folder hardcoding more of an automated process

TODO: override uwsgi.ini files in sheepdog and peregrine to make intial database 
setup proceed in one go without error (change workers from 2 to 1, should get rid
of race condition)



userdatamodel-init to initialize databases beforehand, run it off of fence, stagger peregrine and sheepdog




## Installation

This setup uses Docker containers for postgres, indexd, fence, peregrine, sheepdog, data-portal and nginx. Images for the cdis microservices will be pulled from quay.io, while postgres (9.5) and nginx (latest) images will be pulled from Docker Hub. Nginx will be used as a reverse proxy to each of the services. 

### Dependencies

  - Python 2.7
  - Docker

### Initial Setup - Docker

#### Database Setup

Three postgres databases are recommended:
  1. The data model that stores the values as determined by the dictionary, used by gdcapi
  2. The user data model that stores information about the user
  3. The index data model that stores the digital IDs for indexd  


After the initial setup, all docker compose features should be available.

When running at the beginning, using the attached mode of `docker-compose up` can be useful for debugging errors. To run in backgrounded mode `docker-compose up -d`. The logs for each service can be accessed using `docker logs`.

To stop the services use?
```
docker-compose down
```
