#!/usr/bin/env bash

# Setup pgdump
touch /root/.pgpass
bash -c \"echo '*:*:*:${DB_USERNAME}:${DB_PASSWORD}' > /root/.pgpass \"
chmod 600 /root/.pgpass

# Dump scheme
pg_dump -U ${DB_USERNAME} -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -w -f ${APP_NAME}_${NOW_CACHED}.sql

# Init for upload dump
mkdir -p tmp
mv *.sql tmp/

# Uploading dump
AWS_ACCESS_KEY_ID=${SINDRIA_AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${SINDRIA_AWS_SECRET_ACCESS_KEY} aws s3 sync ./tmp s3://${BACKUP_BUCKET_NAME}
