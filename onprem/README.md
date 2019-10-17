# On Premises

A collection of extensions to enable gen3 to work in a non aws environment.

![image](https://user-images.githubusercontent.com/47808/67042087-f75bbf80-f0db-11e9-8181-ec4b036de8f3.png)

## Build

Build our extensions for on premises gen3. From the compose-services directory:

```
cd onprem
make
```

## Configure

### Fence

Our fork supports non-aws s3 object stores (ceph, minio, swift). Extensions to bucket configuration include:

  * signature_version
  * server_side_encryption
  * endpoint_url

In Secrets/fence-config.yaml

```

AWS_CREDENTIALS:
  'CRED1':
    aws_access_key_id: ''
    aws_secret_access_key: ''
    endpoint_url: 'https://your.host/' # see https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html?highlight=endpoint_url


S3_BUCKETS:
  gen3-dev:
    cred: 'CRED1'
    region: default
    signature_version: s3    # defaults to v4, set to 's3' to use version2 url signing
    server_side_encryption: false  # defaults to true, used in combination with signature_version

DATA_UPLOAD_BUCKET: 'gen3-dev'

```


### s3indexer

Replacement for [SQS S3 Job Dispatcher](https://github.com/uc-cdis/ssjdispatcher)

* polls indexd database
* calls our fork of indexs3client


### indexs3client

Our fork of [indexs3client](https://github.com/ohsu-comp-bio/indexs3client)

* called by s3indexer
* support extra parameter `AWS_ENDPOINT`


## Deploy

Extend by overriding docker compose.  From the compose-services directory:

```
docker-compose -f docker-compose.yml -f onprem/docker-compose.yml
```

You may wish to shorthand this as:

```
alias dc='docker-compose -f docker-compose.yml -f onprem/docker-compose.yml'
```
