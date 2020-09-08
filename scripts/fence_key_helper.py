import base64
import os
key = base64.urlsafe_b64encode(os.urandom(32))
print(key.decode('UTF-8'))
