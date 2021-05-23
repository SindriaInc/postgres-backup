#!/usr/bin/env bash

set -e

NOW=$(date "+%Y-%m-%d_%H-%M-%S")

env
echo "Chi sono?"
whoami

# Setup pgdump
touch /root/.pgpass

STRING="*:*:*:"
STRING+=${DB_USERNAME}
STRING+=":"
STRING+=${DB_PASSWORD}
#STRING+="@@DB_PASSWORD@@"

echo "${STRING}" > /root/.pgpass

cat /root/.pgpass

#sed -i -E "s|@@DB_PASSWORD@@|${DB_PASSWORD}|g" /root/.pgpass
#cat /root/.pgpass

chmod 600 /root/.pgpass

ls -la /root/.pgpass

# Dump scheme
pg_dump -U ${DB_USERNAME} -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -w -f ${APP_NAME}_${NOW}.sql

# Init for upload dump
mkdir -p tmp
mv *.sql tmp/

# Uploading dump
aws s3 sync ./tmp s3://${BACKUP_BUCKET_NAME}