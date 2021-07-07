# Release History and Migration Instructions

# 2019/03 release

The `2019/03` release includes changes necessary for running the latest versions of the `gen3` services as of March 2019.
This release may fail to run earlier versions of `gen3`.

* Changes
  - add `arborist` and `pidgin` services
  - move secrets to `Secrets/` folder which git ignores (via the `.gitignore` file), `apis_configs/` is renamed to a `templates/` folder
  - bump to Postgres `9.6`
  - do not publish Postgres port to host by default - to avoid port conflicts on the host

* Migrate an existing commons to the new setup
    - move the current secrets to `./Secrets`: `mv ./apis_configs Secrets`
    - `git pull`
    - `docker-compose pull` - pull the latest `gen3` Docker images
    - `bash ./creds_setup.sh`
    - edit the `postgres` service in `docker-compose.yaml` to stay on version `9.5` - a `9.6` server cannot read data saved by a `9.5` server.  If you want to erase the data currently in the commons, and proceed with Postgres `9.6`, then `docker-compose down -v` clears the old data.
    - Set the settings in `Secrets/fence-config.yaml` - be sure to set the `client_secret` and `client_id` fields under `OPENID_CONNECT`.
    - ready to go: `docker-compose up -d`
