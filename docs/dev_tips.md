# Dev Tips

You can quickly find commonly used commands for compose services in our [cheat sheet](https://github.com/uc-cdis/compose-services/docs/cheat_sheet.md).

When developing, you can have local repositories of the services you are working on and use volumes to mount your local repository files onto the containers to override the containers' code (which is built from GitHub using quay.io). Then, you can restart a single container with
```
docker-compose restart [CONTAINER_NAME]
```
after you update some code in order to see changes without having to rebuild all the microservices. Keep in mind that running `docker-compose restart` does not apply changes you make in the docker-compose file. Look up the Docker documentation for more information about [volumes](https://docs.docker.com/storage/).

## Spark service hdfs reformatting issue

The `spark-service` starts up runs `hdfs namenode -format` formatting, which is a compute intensive operation. If your `spark-service` fails to start due to being killed by docker daemon, e.g. the container status is `Exited (255)`, then tail the last lines of log as follows:

```
docker logs spark-service --tail=5
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at 3b8d38960f74/172.20.0.2
************************************************************/
2021-04-07 02:30:55,414 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
safemode: Your endpoint configuration is wrong; For more details see:  http://wiki.apache.org/hadoop/UnsetHostnameOrPort
```

Before attempting to (re)start the `spark-service`, make sure to delete the exited/failed container first.

```
docker rm spark-service
docker-compose up -d
```

Otherwise, you may encounter the following looping in the container log:

```
docker logs spark-service --tail=5
  Re-format filesystem in Storage Directory root= /hadoop/hdfs/data/dfs/namenode; location= null ? (Y or N) Invalid input:
  Re-format filesystem in Storage Directory root= /hadoop/hdfs/data/dfs/namenode; location= null ? (Y or N) Invalid input:
  Re-format filesystem in Storage Directory root= /hadoop/hdfs/data/dfs/namenode; location= null ? (Y or N) Invalid input:
  Re-format filesystem in Storage Directory root= /hadoop/hdfs/data/dfs/namenode; location= null ? (Y or N) Invalid input:
  Re-format filesystem in Storage Directory root= /hadoop/hdfs/data/dfs/namenode; location= null ? (Y or N) Invalid input:
```

## Running Docker Compose on a Remote Machine

To run Docker Compose on a remote machine, modify the `BASE_URL` field in `fence-config.yaml`, and the `hostname` field in `peregrine_creds.json` and `sheepdog_creds.json` in the `Secrets` directory.

## Dumping config files and logs (MacOS/Linux)

If you are encountering difficulties while setting up Docker Compose and need help from the Gen3 team, you can use the `dump.sh` script to create a zip file of your configuration and current logs, which you can share to get help.
```
bash dump.sh
```
Note that if docker-compose is not running, the logs will be empty.

The following configuration files will be included:
* docker-compose.yml
* user.yaml
* any file ending with "settings" or "config"

Credentials files are NOT included and lines containing "password", "secret" or "key" are removed from other files.
If your files contain other kinds of sensitive credentials, make sure to remove them before running the script.

## Environment Details

The sandbox ecosystem deployed thus architecturally looks as shown below:
![Sandbox](https://github.com/uc-cdis/compose-services/blob/master/SandboxContainers.jpg)


All the microservices communicate with the Postgres Container based on the configuration specified above. Once the services are up and running, the environment can be visualized using the windmill microservice running on port 80 by typing the URL of the machine on which the containers are deployed. Please see example screenshot below as an example:

![Launch Portal](https://github.com/uc-cdis/compose-services/blob/master/LaunchPortal.jpg)

Upon clicking 'Login from Google' and providing Google Credentials (if the same Google Account is used where the developer credentials came from), the system redirects the user to their landing page as shown below:


![Logged Into Portal](https://github.com/uc-cdis/compose-services/blob/master/LoggedInScreenshot.jpg)


## Revproxy-service cannot start

If revproxy-service cannot start an error will occur. It may be useful to
```
docker-compose down
docker-compose up -d
```
If the error still occurs, make sure that apache2 and revproxy-service do not share the same port. You can change the port for revproxy-service and any other service in the `docker-compose.yaml` [file](https://github.com/uc-cdis/compose-services/blob/bf1dbc0f43519c1d6bc25d9cb331b78c3b35ecca/docker-compose.yml#L215). For revproxy you would also need to change the port in the `nginx.conf` [here](https://github.com/uc-cdis/compose-services/blob/bf1dbc0f43519c1d6bc25d9cb331b78c3b35ecca/nginx.conf#L29).
