#!/usr/bin/env bash

set -e

NOW=$(date "+%Y-%m-%d_%H-%M-%S")

# Setup pgdump
touch /root/.pgpass

# Build placeholder string
STRING="*:*:*:"
STRING+=${DB_USERNAME}
STRING+=":"
STRING+="@@DB_PASSWORD@@"

# Overwrite placeholder string
echo "${STRING}" > /root/.pgpass

# Overwrite unclean db password
echo ${DB_PASSWORD} > unclean.txt

# Cleanup db password colon and & operator
sed -i -e 's/:/\\\\:/g' unclean.txt
sed -i -e 's/&/\\&/g' unclean.txt

# Find and replace db password placeholder with real cleaned db password
sed -i -E "s|@@DB_PASSWORD@@|$(cat unclean.txt)|g" /root/.pgpass

# Setting permission
chmod 600 /root/.pgpass

# Dump scheme
pg_dump -U ${DB_USERNAME} -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} -w -f ${APP_NAME}_${NOW}.sql

# Init for upload dump
mkdir -p tmp
mv *.sql tmp/

# Uploading dump
aws s3 sync ./tmp s3://${BACKUP_BUCKET_NAME}