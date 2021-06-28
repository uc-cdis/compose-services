Compose-Services
===

Docker-compose setup for experimental commons, small commons, or local development of the Gen3 stack. Production use should use [cloud-automation](https://github.com/uc-cdis/cloud-automation).

This setup uses Docker containers for the [Gen3 microservices](https://github.com/uc-cdis/) and nginx. The microservices and nginx images are pulled from quay.io (master), while Postgres (9.5) images are pulled from Docker Hub. Nginx is used as a reverse proxy to each of the services. 

In the following pages you will find information about [migrating existing](docs/release_history.md) and [setting up](docs/setup.md) new compose services, [dev tips](docs/dev_tips.md), basic information about [using the data commons](docs/using_the_commons.md), and [useful links](docs/useful_links.md) contributed by our community. 

You can quickly find commonly used commands in our [cheat sheet](./docs/cheat_sheet.md). Config file formats were copied from [cloud-automation](https://github.com/uc-cdis/cloud-automation) and stored in the `Secrets` directory and modified for local use with Docker Compose. Setup scripts for some of the containers are kept in the `scripts` directory.


# Key Documentation

* [Database Information](docs/database_information.md)
* [Release History and Migration Instructions](docs/release_history.md)
* [Setup](docs/setup.md)
* [Dev Tips](docs/dev_tips.md)
* [Using the Data Commons](docs/using_the_commons.md)
* [Useful links](docs/useful_links.md)
