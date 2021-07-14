# Automated Gen3 Dev Setup

Create a .env file in the [configuration-files]:/tools subdirectory with the following values:

- CLIENT_ID='[google oauth client id]'
- CLIENT_SECRET='[google oauth client secret]'
- GITHUB_TOKEN='[github personal authorization token]'

The .env file will be ignored by Git.

Make sure your test gmail account is included in [configuration-files]:/compose-service/Secrets/user.yaml with correct permissions

### PREREQUISITES
- pyenv

### Install with Homebrew on MAC OS
brew update
brew install pyenv

### Upgrade pyenv
brew update
brew upgrade
```
OR

Visit https://github.com/pyenv/pyenv for other ways to install

Visit https://realpython.com/intro-to-pyenv/ for info on pyenv

### RECOMMENDED DOCKER RESOURCES SETTINGS
These settings are recommended, not required
- 6 CPUs
- 7-8 GB RAM

### IMAGE CLEANUP (Optional)
If you have stale Quay.io Gen3 docker images, you may want to destroy those and start fresh

```
# Destroy all Gen 3 Quay.io images
docker images -a | grep quay | awk '{print $3}' | xargs docker rmi
```

### GEN3 SETUP

In compose-services:
```
cd ./tools
./dev_setup.sh
```

NOTE:  Once the script completes, it may take a few minutes for the site to be available in the browser at https://localhost.  You may see an HTTP 502 screen, but this should last for only a few minutes.


### LOAD DATA

1. Visit Gen3 in the browser & login at https://localhost/login
2. Visit https://localhost/identity
3. Click 'Create API key'
4. Download and save credentials.json file into the ```/populate_fake_data``` directory of configuration-files repo.

NOTE:  pyenv should be installed on the host machine at this point.

In compose-services:
```
cd ./tools
./dev_populate_fake_data.sh
```

### DONE
Gen3 should now be accessible at https://localhost