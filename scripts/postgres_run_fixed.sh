#!/bin/bash

# Always run the postgres init script
postgres_always.sh

# Run postgres
exec postgres "$@"
