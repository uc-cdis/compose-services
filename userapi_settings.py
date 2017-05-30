from boto.s3.connection import OrdinaryCallingFormat
DB = 'postgresql://pguserenv:pgpass3@postgres:5432/envdb'

MOCK_AUTH = True
MOCK_STORAGE = True

HOSTNAME = 'https://play.opensciencedatacloud.org/user/'
APPLICATION_ROOT = '/user'

EMAIL_SERVER = 'localhost'

SEND_FROM = 'phillis.tt@gmail.com'

SEND_TO = 'phillis.tt@gmail.com'

STORAGE_CREDENTIALS = {
}

CEPH = {
    'aws_access_key_id': '',
    'aws_secret_access_key': '',
    'host': '',
    'port': 443,
    'is_secure': True,
    "calling_format": OrdinaryCallingFormat()
}

AWS = {
    'aws_access_key_id': '',
    'aws_secret_access_key': '',
}

OPENID_CONNECT = {
    'google': {
        'client_id': '',
        'client_secret': '',
        'redirect_url': ''
    }
}

'''
If the api is behind firewall that need to set http proxy:
    HTTP_PROXY = {'host': 'cloud-proxy', 'port': 3128}
'''
HTTP_PROXY = None

STORAGES = []
ITRUST_GLOBAL_LOGOUT = 'https://itrusteauth.nih.gov/siteminderagent/smlogout.asp?mode=nih&AppReturnUrl='

HMAC_ENCRYPTION_KEY = 'shared_encryption_key_with_userapi'
