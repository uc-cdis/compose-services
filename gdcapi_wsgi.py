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
    'user': "test",
    'password': "test",
    'database': "bpareplicate",
}

config["OAUTH2"] = {
    'client_id': "MkyDcVzGJ2w2eJYmksf2rNZ44lFn49I4iKwCWCuC",
    'client_secret': "mQPax6tyRO2KlSnNcChwD93bhPqN03lwv9kVruAhWJfe9t30Wr4qtsN",
    'internal_oauth_provider': 'http://user-api/oauth2/',
    'oauth_provider': 'http://localhost/user/oauth2/',
    'redirect_uri': 'http://localhost/api/v0/oauth2/authorize'
}

config["USER_API"] = 'http://user-api/'

config['HMAC_ENCRYPTION_KEY'] = 'shared_encryption_key_with_userapi'
config['PSQL_USER_DB_CONNECTION'] = 'postgresql://test:test@postgres:5432/userapi'
app_init(app)
application = app
