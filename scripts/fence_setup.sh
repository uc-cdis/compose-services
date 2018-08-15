#!/bin/bash
# entrypoint script for fence to sync user.yaml before running

fence-create sync --yaml user.yaml

rm -f /var/run/apache2/apache2.pid && /usr/sbin/apache2ctl -D FOREGROUND