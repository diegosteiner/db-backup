#!/bin/bash
set -e

# export MC_HOST_backup=$S3_URI
#mc mb backup/${S3_BUCK} --insecure
[[ "$DATABASE_URL" =~ "([\w-_]+):\/\/([\w-_]+):([\w-_]+)@([\w\._]+):?(\d*)\/([\w-_]+)" ]]
export DATABASE_ADAPTER="${BASH_REMATCH[0]}"
export DATABASE_USER="${BASH_REMATCH[1]}"
export DATABASE_PASSWORD="${BASH_REMATCH[2]}"
export DATABASE_HOST="${BASH_REMATCH[3]}"
export DATABASE_PORT="${BASH_REMATCH[4]}"
export DATABASE_NAME="${BASH_REMATCH[5]}"

mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --skip-add-locks --allow-keywords ${MYSQL_DATABASE} \
 	| gzip -9 \
  | openssl enc -aes-256-cbc -salt -e -pass pass:$CRYPT_PASSPHRASE \
  | mc pipe backup/${S3_BUCKET}/${BACKUP_NAME_PREFIX}-`date +%Y-%m-%dT%H-%M-%S`.sql.gz.enc
