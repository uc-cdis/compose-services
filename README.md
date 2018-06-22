Compose-Services
===

Docker-compose setup for local development of the Gen3 stack. Production use should use [cloud-automation](https://github.com/uc-cdis/cloud-automation).


added creds.json file as well as apis_configs files from cloud-automation
modified creds.json fields 
modified docker-compose.yaml to mount files similarly to cloud-automation
manually went on postgres container and added databases and users 
wrote keypair.sh script and manually went on fence to run it to generate keypairs

TODO: figure out how to make a proper workflow for editing, currently have to docker-compose down and docker-compose up again to fully rebuild to make sure everything is running updated files.




  







## Installation

This setup uses Docker containers for postgres, indexd, fence, peregrine, sheepdog, data-portal and nginx. Images for the cdis microservices will be pulled from quay.io, while postgres and nginx images will be pulled from Docker Hub. Nginx will be used as a reverse proxy to each of the services. 

It enables a test user that can use OAuth2 locally.

### Dependencies

  - Python 2.7
  - Docker

### Initial Setup

#### Database Setup

Three postgres databases are recommended:
  1. The data model that stores the values as determined by the dictionary, used by gdcapi
  2. The user data model that stores information about the user
  3. The index data model that stores the digital IDs for indexd  

However, as currently there isn't table name overlap, it would be fine to compress it all into one database.

#### User Setup

To create the test user:
```
userapi-create create ua.yaml
```

Signpost user setup


#### Local OAuth2


On the user-api Docker:
```
userapi-create client-create --client gdcapi --urls http://localhost/api/v0/oauth2/authorize --username test
```

Returns a keypair tuple, the first value should be set as `client_id` and the second as `client_secret` in the gdcapi OAUTH2 config.

### Usage

After the initial setup, all docker compose features should be available.

When running at the beginning, using the attached mode of `docker-compose up` can be useful for debugging errors. To run in backgrounded mode `docker-compose up -d`. The logs for each service can be accessed using `docker logs`.


Services will be available on the ports defined in docker-compose.yml, to test the default settings:

```
$ curl http://localhost:8080/index/
$ curl http://localhost:8081/user/
$ curl http://localhost:8082/v0/submission
```

To stop the services use?
```
docker-compose down
```
