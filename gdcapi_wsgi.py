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
    'host': None,
    'user': None,
    'password': None,
    'database': None,
}

config['HMAC_ENCRYPTION_KEY'] = 'shared_encryption_key_with_userapi'
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://username:password@host:5432/db_name'
app_init(app)
application = app
