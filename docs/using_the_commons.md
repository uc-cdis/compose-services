# Using the Data Commons

For some general information about Gen3 Data Commons and how they work (such as how to access and submit data), visit the [official site](https://gen3.org/). The section below will go over some useful technical aspects of Gen3.

## Smoke test

The `smoke_test.sh` script queries the health-check endpoints of each service
launched by `docker-compose.yml`.
```
bash smoke_test.sh localhost
```

## Programs and Projects

In a Gen3 Data Commons, programs and projects are two administrative nodes in the graph database that serve as the most upstream nodes. A program must be created first, followed by a project. Any subsequent data submission and data access, along with control of access to data, is done through the project scope.

Before you create a program and a project or submit any data, you need to grant yourself permissions. First, you will need to grant yourself access to **create** a program and second, you need to grant yourself access to *see* the program. You can **create** the program before or after having access to *see* it.
For this, you will need to edit the `Secrets/user.yaml` file following the docs shown [here](https://github.com/uc-cdis/fence/blob/master/docs/user.yaml_guide.md#programs-and-projects-crud-access).

Make sure to update user privileges:
```
docker exec -it fence-service fence-create sync --arborist http://arborist-service --yaml user.yaml
```

To create a program, visit the URL where your Gen3 Commons is hosted and append `/_root`. If you are running the Docker Compose setup locally, then this will be `localhost/_root`. Otherwise, this will be whatever you set the `hostname` field to in the creds files for the services with `/_root` added to the end. Here, you can choose to either use form submission or upload a file.  I will go through the process of using form submission here, as it will show you what your file would need to look like if you were using file upload. Choose form submission, search for "program" in the drop-down list and then fill in the "dbgap_accession_number" and "name" fields. As an example, you can use "123" as "dbgap accession number" and "Program1" as "name". Click 'Upload submission json from form' and then 'Submit'. If the message is green ("succeeded:200"), that indicates success, while a grey message indicates failure. More details can be viewed by clicking on the "DETAILS" button. If you don't see the green message, you can control the sheepdog logs for possible errors and check the Sheepdog database (`/datadictionary`), where programs and projects are stored. If you see your program in the data dictionary, neglect the fact that at this time the green message does not appear and continue to create a project.

To create a project, visit the URL where your Gen3 Commons is hosted and append the name of the program you want to create the project under. For example, if you are running the Docker Compose setup locally and would like to create a project under the program "Program1", the URL you will visit will be `localhost/Program1`. You will see the same options to use form submission or upload a file. This time, search for "project" in the drop-down list and then fill in the fields. As an example, you can use "P1" as "code", "phs1" as "dbgap_accession_number", and "project1" as "name". If you use different entries, make a note of the dbgap_accession_number for later. Click 'Upload submission json from form' and then 'Submit'. Again, a green message indicates success while a grey message indicates failure, and more details can be viewed by clicking on the "DETAILS" button. You can control in the `/datadictionary` whether the program and project have been correctly stored.

After that, you're ready to start submitting data for that project! Please note that Data Submission refers to metadata regarding the file(s) (Image, Sequencing files, etc.) that are to be uploaded. Please refer to the [Gen3 website](https://gen3.org/resources/user/submit-data/) for additional details.


## Controlling access to data

Access to data and admin privileges in Gen3 is controlled using Fence through the `user.yaml` file found in the `Secrets` directory. We use `users.policies` for individual access and `groups` for group access. Please refer to the [user.yaml guide](https://github.com/uc-cdis/fence/blob/master/docs/user.yaml_guide.md) to add/subtract users and policies. Make sure to update user privileges with
```
docker exec -it fence-service fence-create sync --arborist http://arborist-service --yaml user.yaml
```
or review how to apply the changes made in the `user.yaml` file to the database in the section [Setting up Users](https://github.com/uc-cdis/compose-services/docs/setup.md#Setting-Up-Users).

## Generating Test Metadata

The `gen3` stack requires metadata submitted to the system to conform
to a schema defined by the system's dictionary.  The `gen3` developers
use a tool to generate test data that conforms to a particular dictionary.
For example - the following commands generate data files suitable to submit
to a `gen3` stack running the default genomic dictionary at https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json

```
export TEST_DATA_PATH="$(pwd)/testData"
mkdir -p "$TEST_DATA_PATH"

docker run -it -v "${TEST_DATA_PATH}:/mnt/data" --rm --name=dsim --entrypoint=data-simulator quay.io/cdis/data-simulator:master simulate --url https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json --path /mnt/data --program jnkns --project jenkins --max_samples 10
```

## Changing the data dictionary

For an introduction to the data model and some essential information for modifying a data dictionary, please read [this](https://gen3.org/resources/user/dictionary/) before proceeding.

The data dictionary the commons uses is dictated by either the `DICTIONARY_URL` or the `PATH_TO_SCHEMA_DIR` environment variable in both Sheepdog and Peregrine. The default value for `DICTIONARY_URL` are set to `https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json` and the default value for `PATH_TO_SCHEMA_DIR` is set to the `datadictionary/gdcdictionary/schemas` directory which is downloaded as part of the compose-services repo (from [here](https://github.com/uc-cdis/datadictionary/tree/develop/gdcdictionary/schemas)). Both correspond to the developer test data dictionary, as one is on AWS and one is a local data dictionary setup. To override this default, edit the `environment` fields in the `peregrine-service` section of the `docker-compose.yml` file. This will change the value of the environment variable in both Sheepdog and Peregrine. An example, where the `DICTIONARY_URL` and `PATH_TO_SCHEMA_DIR` environment variables is set to the default values, is provided in the docker-compose.yml.

**NOTE**: Only one of the two environment variables can be active at a time. The data commons will prefer `DICTIONARY_URL` over `PATH_TO_SCHEMA_DIR`. To reduce confusion, keep the variable you're not using commented out.

There are 3 nodes that are required for the dev (default) portal--`case`, `experiment`, and `aliquot`. If you remove any one of these, then you will also need to [change](https://github.com/uc-cdis/compose-services/blob/master/docs/cheat_sheet.md) the `APP` environment variable in `portal-service`, in addition to changing the `DICTIONARY_URL` or `PATH_TO_SCHEMA` field.

As this is a change to the Docker Compose configuration, you will need to restart the Docker Compose (`docker-compose restart`) to apply the changes.

## Configuring guppy for exploration page

In order to enable guppy for exploration page, the `gitops.json`, `etlMapping.yaml` and `guppy_config.json` need to be configured. There are some examples of configurations located at `https://github.com/uc-cdis/cdis-manifest`. It is worth to mentioning that the index and type in `guppy_config.json` need to be matched with the index in `etlMapping.json`.
> NOTE:  The ETL [Tube](https://github.com/uc-cdis/tube) job creates required ElasticSearch indices for the Exploration page.
 When the data dictionary is changed, those files are also configured accordingly so that the exploration page can work.

Install `datadictionary` Python dependency
```
docker exec -it tube-service bash -c "cd /tmp/datadictionary && pip install ."
```

Run `bash ./guppy_setup.sh` to create/re-create ES indices


## Enabling data upload to s3

The `templates/user.yaml` file has been configured to grant `data_upload` privileges to the `username1@gmail.com` user.  Connect it to your s3 bucket by configuring access keys and bucket name in `fence-config.yaml`.

```
289,290c289,290
<     aws_access_key_id: 'your-key'
<     aws_secret_access_key: 'your-key'
---
>     aws_access_key_id: ''
>     aws_secret_access_key: ''
296c296
<   your-bucket:
---
>   bucket1:
309c309
< DATA_UPLOAD_BUCKET: 'your-bucket'
---
> DATA_UPLOAD_BUCKET: 'bucket1'
```

> 🟢 Note: Any upload bucket, including local machine storage, are currently not supported out of the box unless they are S3 compliant. Google Storage Buckets are supported with additional configuration (more info [here](https://github.com/uc-cdis/cirrus#cirrus)). 

## Uploaded data file in "Generating..." status
It is important to note that Gen3 Compose-Services use AWS Simple Notification System (SNS) to get notifications when objects are uploaded to a bucket. These notifications are then stored in an AWS Simple Queue System (SQS). The Gen3 [job dispatcher service](https://github.com/uc-cdis/ssjdispatcher) watches the SQS and spins up an [indexing job](https://github.com/uc-cdis/indexs3client) to update indexd with the file information (size, hash). During this process, the UI shows the file status as "Generating..." until indexd is updated.

If one or multiple data files have been submitted to an S3 bucket and you do not want to set up automation through an SNS and SQS, a simple alternative is to index the data files manually after the upload. The upload command creates a "blank" record in indexd, which should be then updated by adding the file's size and hash. This can be done with a PUT request to [index](http://petstore.swagger.io/?url=https://raw.githubusercontent.com/uc-cdis/Indexd/master/openapis/swagger.yaml#/index/updateBlankEntry), where the base URL is `https://your-commons.org/index/index/blank/{GUID}`. A list of URLS to reach other services from the Gen3 Framework is shown [here](https://gen3.org/resources/developer/microservice/#microservice-nginx-route-table).
Only once the uploaded data file is indexed, graph metadata can be submitted to it.

# Persistent Store

The `postgres` RDBMS and the document store `esproxy-service` persistent stores are backed by [docker volumes](https://docs.docker.com/storage/volumes/) as follows:

```
docker volume ls | grep psqldata
local     compose-services_psqldata

docker volume ls | grep esdata
local     compose-services_esdata
```

If you would like to re-spin everything and/or start from scratch, you can/must delete these volumes prior bringing up the stack again.

> 🛑️ **WARNING**: This will **PERMANENTLY DELETE ALL DATA** stored on the persistent services.

```
docker volume rm compose-services_esdata
docker volume rm compose-services_psqldata
```
