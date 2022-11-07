# PCDC Instruction

## Set up Environment 
- change branch `git checkout -t origin/pcdc_dev`
- run `bash creds_setup.sh`
- run `bash ./analysis_service_cred_setup.sh`
- copy the Secrets folder from the configuration-files repo and add your google credentials in the fence-config.yaml file
- run `docker-compose up`

## Load fake data into Postgres DB
- Make sure the Secrets/user.yaml file conatins your user information and the correct authZ policy
- in a different directory run `git clone https://github.com/chicagopcdc/gen3_scripts.git`
- run `cd gen3_scripts/`
- change branch `git checkout -t origin/pcdc_dev`
- run `cd populate_fake_data`
- run `python -m venv env`
- run `source env/bin/activate`
- run `pip install -r requirements.txt`
- open `http://localhost/identity`, click on `Create API key` and download the `credentials.json` file and place in the `populate_fake_data` dir
- In the file `operations/etl.py` replace `GITHUB_TOKEN` with your Github token
- run `cd operations`
- run `python etl.py load`


## Load fake data into ES 
- in a different directory run `git clone https://github.com/chicagopcdc/gen3_scripts.git` 
- run `cd gen3_scripts/`
- change branch `git checkout -t origin/pcdc_dev`
- run `cd es_etl_patch`
- run `python -m venv env`
- run `source env/bin/activate`
- run `pip install -r requirements.txt`
- run `cd etl`
- In the file `build_json.py` replace `GITHUB_TOKEN` with your Github token
- run `python create_index.py`
- run `docker restart guppy-service`
- run `docker restart revproxy-service`