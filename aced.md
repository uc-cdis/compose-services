# ACED specific changes


## Fence

  ## Authentication

  * Let's turn off auth: Secrets/fence-config.yaml#L48-L49

        ```
        # if true, will automatically login a user with username "test"
        MOCK_AUTH: true
        ```

        * Then adjust the user mapping to make the "test" user admin. In Secrets/user.yaml, change all occurances of `username1@gmail.com` to `test`


        * Then restart fence.

        ```
        docker-compose stop fence-service ; docker-compose rm  -f fence-service ; docker-compose up fence-service ;
        ```

## Data

    * Per instructions, disable guppy and kibana

    * Create a program and project.  See https://github.com/uc-cdis/compose-services/blob/master/docs/using_the_commons.md#programs-and-projects


    * Let's generate some data

        ```
        export TEST_DATA_PATH="$(pwd)/testData"
        mkdir -p "$TEST_DATA_PATH"

        docker run -it -v "${TEST_DATA_PATH}:/mnt/data" --rm --name=dsim --entrypoint=data-simulator quay.io/cdis/data-simulator:master simulate --url https://s3.amazonaws.com/dictionary-artifacts/datadictionary/develop/schema.json --path /mnt/data --program MyFirstProgram --project MyFirstProject --max_samples 10
        ```

    * Load the data manually by following the instructions in 
        https://gen3.org/resources/user/submit-data/#begin-metadata-tsv-submissions  (Note that the data we will be using is in JSON form.) This will be a good opportunity to discover data dependency order. Navigate to the "Submit Data" page. Load the data, following the hierarchy displayed in the "Toogle View"


    * Re-Enable guppy

## Let's setup discovery

```
   metadata-service:
-    image: "quay.io/cdis/metadata-service:2021.03"
+    image: "quay.io/cdis/metadata-service:1.8.0"
     container_name: metadata-service
     depends_on:
       - postgres
+    volumes:
+      # /env/bin/python /src/src/mds/populate.py --config /var/local/metadata-service/aggregate_config.json
+      - ./Secrets/metadata/aggregate_config.json:/var/local/metadata-service/aggregate_config.json
     environment:
       - DB_HOST=postgres
       - DB_USER=metadata_user
       - DB_PASSWORD=metadata_pass
       - DB_DATABASE=metadata
+      - USE_AGG_MDS=true
+      - GEN3_ES_ENDPOINT=http://esproxy-service:9200
     command: >
```




