#!/usr/bin/env bash

create_db_idempotent() {
  # Creating a DB similar to the "IF NOT EXISTS" syntax is a bit challenging in
  # Postgres.
  psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${1}'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE ${1}"
}

create_user_idempotent() {
  psql -U postgres << EOF
DO \$\$
BEGIN
  IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='${1}') THEN
    CREATE USER ${1};
  END IF;
END
\$\$;
EOF
}

create_db_idempotent "metadata"
create_user_idempotent "metadata_user"

psql -U postgres <<EOF
ALTER USER metadata_user WITH PASSWORD 'metadata_pass';
ALTER USER metadata_user WITH SUPERUSER;
EOF