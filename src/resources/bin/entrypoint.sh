#!/usr/bin/env bash

set -e

NOW=$(date "+%Y-%m-%d_%H-%M-%S")

# Setup pgdump
touch /root/.pgpass
echo '*:*:*:${DB_USERNAME}:${DB_PASSWORD}' > /root/.pgpass
chmod 600 /root/.pgpass

# Dump scheme
pg_dump -U ${DB_USERNAME} -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -w -f ${APP_NAME}_${NOW}.sql

# Init for upload dump
mkdir -p tmp
mv *.sql tmp/

# Uploading dump
aws s3 sync ./tmp s3://${BACKUP_BUCKET_NAME}