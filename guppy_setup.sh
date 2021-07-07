#!/bin/bash
# Script to create and re-create es indices and setup guppy

sleep 2
# docker exec esproxy-service curl -X DELETE http://localhost:9200/etl_0
# sleep 2
# docker exec esproxy-service curl -X DELETE http://localhost:9200/cancer_inrg_0
# sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_1_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_person_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_survival_characteristic_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_1-array-config_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_person-array-config_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_survival_characteristic-config_0
sleep 2



docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_clinical_event_0
sleep 2
docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_clinical_event-array-config_0
sleep 2

# docker exec esproxy-service curl -X DELETE http://localhost:9200/cancer_inrg-array-config_0
# sleep 2
# docker exec esproxy-service curl -X DELETE http://localhost:9200/pcdc_1-array-config_0
# sleep 2
docker exec tube-service bash -c "python run_config.py && python run_etl.py"

docker container stop guppy-service
docker container start guppy-service