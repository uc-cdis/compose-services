from gdcapi.api import app
from os import environ
# the below could be replaced with `from gcapi.api import app_init`,
# it's here only for extreme backwards compatibility and should
# someday be removed
try:
    from gdcapi.run import app_init
except:
    from gdcapi.api import db_init as app_init

config = app.config

config["AUTH"] = None 
config["AUTH_ADMIN_CREDS"] = None
config["INTERNAL_AUTH"] = None

# Signpost
config['SIGNPOST'] = {
    'host': environ.get('SIGNPOST_HOST', 'http://indexd'),
    'version': 'v0',
    'auth': ('username', 'password'),
}
config["PSQLGRAPH"] = {
    'host': "postgres",
    'user': "pguserenv",
    'password': "pgpass3",
    'database': "envdb",
}

config["OAUTH2"] = {
    'client_id': "",
    'client_secret': "",
    'oauth_provider': "",
    'redirect_uri': "",
}

config["USER_API"] = 'userapi'

config['HMAC_ENCRYPTION_KEY'] = 'shared_encryption_key_with_userapi'
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://pguserenv:pgpass3@postgres:5432/envdb'
app_init(app)
application = app
