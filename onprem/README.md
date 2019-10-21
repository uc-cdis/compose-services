# On Premises

A collection of extensions to enable gen3 to work in a non aws environment.

![image](https://user-images.githubusercontent.com/47808/67230733-b113a280-f3f2-11e9-882b-cdf109472ba7.png)

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

Additional bucket attributes can be set to support indexing `extramural` buckets, buckets populated by external processes outside of gen3-client/fence/indexd.  

  * extramural_bucket
  * extramural_uploader_s3owner
  * extramural_uploader_manifest

In Secrets/fence-config.yaml:

```

AWS_CREDENTIALS:
  'CEPH_CREDS':
    aws_access_key_id: 'XXX'
    aws_secret_access_key: 'YYY'
    endpoint_url: 'https://some.ceph/' # see https://boto3.amazonaws.com/v1/documentation/api/latest/reference/core/session.html?highlight=endpoint_url

  'EXTERNAL_CREDS':
    aws_access_key_id: 'AAA'
    aws_secret_access_key: 'BBB'
    endpoint_url: 'https://some.external/'


S3_BUCKETS:
  gen3-dev:
    cred: 'CEPH_CREDS'
    region: default
    signature_version: s3    # defaults to v4, set to 's3' to use version2 url signing
    server_side_encryption: false  # defaults to true, used in combination with signature_version
  external-dev:
    cred: 'EXTERNAL_CREDS'
    extramural_bucket: true  # If set to true, the uploader for all newly indexed objects is set to the S3 bucket owner.
    extramural_uploader: foo@bar.edu  # If set, the uploader for all newly indexed objects is set to the string value.
    # extramural_uploader_s3owner:bool  # If set to true, the uploader for all newly indexed objects is set to the S3 bucket owner.
    # extramural_uploader_manifest:string  # Object path (key) should map to a uploader stored in a CSV file. The first column is the object path (key), the second column is the uploader.


# `DATA_UPLOAD_BUCKET` specifies an S3 bucket to which data files are uploaded,
# using the `/data/upload` endpoint. This must be one of the first keys under
# `S3_BUCKETS` (since these are the buckets fence has credentials for).
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
