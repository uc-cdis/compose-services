# Setup

## Dependencies

  - OpenSSL
  - Docker and Docker Compose

## Docker and Docker Compose Setup

If you've never used Docker before, it may be helpful to read some of the Docker documentation to familiarize yourself with containers. You can also read an overview of what Docker Compose is [here](https://docs.docker.com/compose/overview/) if you want some extra background information.

The official *Docker* installation page can be found [here](https://docs.docker.com/install/#supported-platforms). The official *Docker Compose* installation page can be found [here](https://docs.docker.com/compose/install/#prerequisites). For Windows and Mac, Docker Compose is included into Docker Desktop. If you are using Linux, then the official Docker installation does not come with Docker Compose; you will need to install Docker Engine before installing Docker Compose.
Go through the steps of installing Docker Compose for your platform, then proceed to set up credentials. Note, that Docker Desktop is set to use 2 GB runtime memory by default. 

> **NOTE:**
> 
> 🛑 As a minimum, make sure to increase the size of the **memory to 6 GB** (or more) as described [here](https://docs.docker.com/docker-for-mac/#resources).

> ElasticSearch and ETL/Spark jobs through tube/guppy/spark-service are particularly resource intensive. If you are running Compose-Services on your laptop, we recommend minimizing/stopping background jobs/services during running ETL jobs or hdfs formatting phase during `spark-service` startup, etc. Please do observe with `docker stats` and `top` / `htop`.

## Docker ElasticSearch

If you are running on AWS EC2 instance (Amazon Linux), consider setup [Docker ElasticSearch prerequisites](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-prod-prerequisites). The following are known to be required to set on Docker host:
```
grep vm.max_map_count /etc/sysctl.conf
vm.max_map_count=262144
```

## Setting up Credentials

Setup credentials for Fence, a custom root CA  and SSL certs with the provided script by running either:
```
bash ./creds_setup.sh
OR
bash ./creds_setup.sh YOUR-CUSTOM-DOMAIN
```
This script will create a `Secrets` folder that holds various secrets and configuration files.
The script by default generates an SSL certificate to access the gen3 stack at `https://localhost`.
If you are running this in a remote server with an actual domain, you can run `bash creds_setup.sh YOUR_DOMAIN`.  This will create SSL cert signed by the custom CA so that the microservices can talk to each other without bypassing SSL verification. If you are setting this up on AWS, ensure that you use an Elastic IP address BEFORE you set up and use that as your domain. On an EC2 instance, for example, this would be your ec2-YOUR-Elastic-IP-Addr.us-region-number.compute.amazonaws.com. This will save a lot of time and avoid [editing the individual files](https://github.com/uc-cdis/compose-services/blob/master/docs/dev_tips.md#Running-Docker-Compose-on-a-Remote-Machine) to set up the hostname(`fence-config.yaml`, `peregrine_creds.json`, and `sheepdog_creds.json`) when the machine is rebooted. This is because each of the microservices can be configured to run on separate machines and thus have their respective configuration files. You will still need to bypass SSL verification when you hit the services from the browser. If you have real certs for your domain, you can copy to `Secrets/TLS/service.key` and `Secrets/TLS/service.crt` to overwrite our dev certs.

If you are using MacOS, you may run into an error with the default MacOS OpenSSL config not including the configuration for v3_ca certificate generation. OpenSSL should create the `jwt_private_key.pem` and `jwt_public_key.pem` in the `Secrets/fenceJwtKeys/{dateTtimeZ}` folder. If you do not see them, control whether your version of OpenSSL is correct.  You can refer to the solution on [this Github issue](https://github.com/jetstack/cert-manager/issues/279) on a related issue on Jetstack's cert-manager.

Support for multi-tenant fence (configure another fence as an IDP for this fence) is available and can be edited in the `fence-config.yaml`. If this is not the case, we recommend removing the [relevant section](https://github.com/uc-cdis/compose-services/blob/fa3dcc95a4244805c7a02f315cd330447e189945/templates/fence-config.yaml#L81).

## Setting up Google OAuth Client-Id for Fence

This Docker Compose setup requires Google API Credentials in order for Fence microservice to complete its authentication.
To set up Google API Credentials, go to [the Credentials page of the Google Developer Console](https://console.developers.google.com/apis/credentials) and click the 'Create Credentials' button. Follow the prompts to create a new OAuth Client ID for a Web Application. Add  `https://localhost/user/login/google/login/` OR `https://YOUR_REMOTE_MACHINE_DOMAIN/user/login/google/login/` to your Authorized redirect URIs in the Credentials and click 'Create'. Then copy your client ID and client secret and use them to fill in the 'google.client_secret' and 'google.client_id' fields in the `Secrets/fence-config.yaml` file.
See image below for an example on a sample Google account.

![Redirection Set up](https://github.com/uc-cdis/compose-services/blob/master/Authorization_URL_2020.jpg)

If you have Google API credentials set up already that you would like to use with the local gen3 Docker Compose setup, simply add `https://localhost/user/login/google/login/` OR `https://YOUR_REMOTE_MACHINE_DOMAIN/user/login/google/login/` to your Authorized redirect URIs in your credentials and copy your client ID and client secret from your credentials to the 'client_secret' and 'client_id' fields in the `Secrets/fence-config.yaml` under `OPENID_CONNECT` and `google`.

## Setting up Users

To set up user privileges for the services, please edit the `Secrets/user.yaml` file, following [this guide](https://github.com/uc-cdis/fence/blob/master/docs/user.yaml_guide.md). In particular, you should change all occurrences of `username1@gmail.com` to the email you intend to log in with, so that you can create administrative nodes later on.

Fence container will automatically sync this file to the `fence_db` database on startup. If you wish to update user privileges while the containers are running (without restarting the container), just edit the `Secrets/user.yaml` file and then run
```
docker exec -it fence-service fence-create sync --arborist http://arborist-service --yaml user.yaml
```
This command will enter Fence container to run the fence-create sync command, which will update your user privileges. If you are logged in to your commons on a browser, you may need to log out and log back in again or clear your cookies in order to see the changes.


## Start running your local Gen3 Docker Compose environment

> **NOTE**:
> 
> 🛑 If your Gen3 Data Commons does not host any data, yet, we recommend commenting out the [kibana-service section](https://github.com/uc-cdis/compose-services/blob/454d06358a49b4455097e34ddc060e76903e1aa3/docker-compose.yml#L309-L320) in the `docker-compose.yaml` and the [guppy section](https://github.com/uc-cdis/compose-services/blob/454d06358a49b4455097e34ddc060e76903e1aa3/nginx.conf#L140-L142) in the `nginx.conf` file. After having setup the first program/project and uploaded the first data, we recommend enabling these sections. Precisely, re-enable both services after you completed the following two steps: 
> 1. [Generate Test Metadata](https://github.com/uc-cdis/compose-services/blob/master/docs/using_the_commons.md#generating-test-metadata)
> 2. Upload the simulated test metadata to the Data Portal UI. Follow [gen3.org](https://gen3.org/resources/user/submit-data/) and [Useful links](https://github.com/uc-cdis/compose-services/blob/master/docs/useful_links.md) for how-to guides and tutorials. 

> 🟢 Finally, re-enable kibana and guppy services before continuing with the section [Configuring guppy for exploration page](https://github.com/uc-cdis/compose-services/blob/master/docs/using_the_commons.md#configuring-guppy-for-exploration-page). 

Now that you are done with the setup, all Docker Compose features should be available. If you are a non-root user you may need to add yourself to the 'docker' group: `sudo usermod -aG docker your-user`, and the log out and log back in.
Here are some useful commands:

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
Sheepdog and Peregrine services download the dictionary schema at startup, and the
portal service runs a series of pre-launch compilations that depend on Sheepdog and Peregrine,
so it may take several minutes for the portal to finally come up at https://localhost

Following the portal logs is one way to monitor its startup progress:
```
docker logs -f portal-service
```
When you see that `bundle.js` and `index.html` were successfully built in the logs, you should be able to log into https://localhost and see the data commons. You are now ready to setup the [first program and project](https://github.com/uc-cdis/compose-services/blob/master/docs/using_the_commons.md#programs-and-projects).


## Update tips

You should of course `git pull` compose-services if you have not done so for a while. You also need to `docker-compose pull` new images from Quay--this will not happen automatically. If your git pull pulled new commits, and you already have a `Secrets` folder, you may also need to delete your old `Secrets` and rerun `creds_setup.sh` (see [Setting up Credentials](https://github.com/uc-cdis/compose-services/blob/master/docs/setup.md#Setting-up-Credentials)) to recreate it.
