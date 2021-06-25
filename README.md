Compose-Services
===

Docker-compose setup for experimental commons, small commons, or local development of the Gen3 stack. Production use should use [cloud-automation](https://github.com/uc-cdis/cloud-automation).

This setup uses Docker containers for Postgres, IndexD, Fence, Peregrine, Sheepdog, Windmill (data-portal), and nginx. Images for the [CDIS microservices](https://github.com/uc-cdis/) and nginx will be pulled from quay.io (master), while Postgres (9.5) images will be pulled from Docker Hub. Nginx will be used as a reverse proxy to each of the services. Below you will find information about [migrating existing](docs/release_history) and [setting up](docs/setup) new compose services, some [tips](docs/dev_tips), basic information about [using](docs/using_the_commons) data commons, and [useful links](#useful-links). You can quickly find commonly used commands in our [cheat sheet](./docs/cheat_sheet.md). Config file formats were copied from [cloud-automation](https://github.com/uc-cdis/cloud-automation) and stored in the `Secrets` directory and modified for local use with Docker Compose. Setup scripts for some of the containers are kept in the `scripts` directory.


# Key Documentation

* [Database Information](docs/database_information)
* [Release History and Migration Instructions](docs/release_history)
* [Setup](docs/setup)
* [Dev Tips](docs/dev_tips)
* [Using the Data Commons](docs/using_the_commons)
* [Useful links](docs/useful_links)