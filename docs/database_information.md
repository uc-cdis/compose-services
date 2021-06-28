# Database Information

Database setup only has to occur the very first time you set up your local gen3 Docker Compose environment, as this docker-compose environment is configured to create a persistent volume for Postgres. The environment configuration is set up to automatically run setup scripts for the postgres container and set up the following:
  1. 5 databases
      - `metadata` (Used by `metadata-service`)
      - `metadata_db` (Used by `sheepdog` and `peregrine`)
      - `fence_db`
      - `indexd_db`
      - `arborist_db`
  2. 6 users with passwords and superuser access
      - `metadata_user`
      - `fence_user`
      - `peregrine_user`
      - `sheepdog_user`
      - `indexd_user`
      - `arborist_user`

> **NOTE**: You can use docker compose override to configure the Postgres database container and publish the db service port to the host machine by changing the `ports` block under the `postgres` service in `docker-compose.override.yml`, then run `docker-compose up -d postgres`:
```
cp docker-compose.override.sample.yml docker-compose.override.yml
```
The container host can connect to the database after the port is published - ex:
```
psql -h localhost -U fence_user -d fence_db
```

> **Heads-up**: Similarly, you can add/override your custom docker compose config parameters/values in `docker-compose.override.yml` and keep the base config clean. See [docker compose documentation](https://docs.docker.com/compose/extends/) for more.

