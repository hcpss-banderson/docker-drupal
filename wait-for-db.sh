#!/usr/bin/env bash

set -e

# Wait for MySQL
while ! mysqladmin ping -h"$MYSQL_HOSTNAME" --silent; do
    echo "Waiting for database connection..."
    sleep 5
done

exec "$@"
