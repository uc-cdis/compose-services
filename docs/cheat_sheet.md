# Docker compose services cheat sheet

**Quick start**

* bash ./creds_setup.sh (setup secrets)
* docker-compose up (start with logs)
* docker-compose up -d (start without logs)
* docker-compose down (stop)
* docker-compose down -v (stop and wipe existing data)

**Useful commands**

* docker ps
* docker logs [-f] xxx-service
* docker-compose restart xxx-service
* docker exec -it fence-service fence-create xxx

**Update images**

* docker-compose pull
* docker image prune -f (optional - to free up some space…)

**Access DB**

* docker exec -it compose-services_postgres_1 psql -U postgres
* \c DB_name

**Sync users**

* docker exec -it fence-service fence-create sync --arborist http://arborist-service --yaml user.yaml

**Change dictionary**

Update in docker-compose.yml:
* DICTIONARY_URL
* APP (to get the [corresponding portal setup](https://github.com/uc-cdis/data-portal/tree/master/data/config)), for example:
  * dev (goes to "default" config -> Dev data commons)
  * edc (Environmental data commons)

**Use local code (example with fence)**

Update in docker-compose.yml:
```
fence-service:
    image: "my-fence:latest"
```
Rerun the following commands after changing the code:
* cd fence; docker build . -t my-fence -f Dockerfile
* docker stop fence-service
* docker-compose up -d fence-service

**Dump logs and config in a zip file**

* bash dump.sh
