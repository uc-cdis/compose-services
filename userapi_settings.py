from boto.s3.connection import OrdinaryCallingFormat
DB = 'postgresql://username:password@host:5432/db_name'

MOCK_AUTH = True 

EMAIL_SERVER = 'localhost'

SEND_FROM = 'phillis.tt@gmail.com'

SEND_TO = 'phillis.tt@gmail.com'

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

HMAC_ENCRYPTION_KEY = 'shared_encryption_key_with_userapi'
