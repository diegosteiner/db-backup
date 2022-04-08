#!/bin/bash
set -e

# export MC_HOST_backup=$S3_URI
#mc mb backup/${S3_BUCK} --insecure
REGEX="^([a-zA-Z0-9\._=-]+):\/\/([a-zA-Z0-9\/\._=-]+):([a-zA-Z0-9\._=-]+)@([a-zA-Z0-9\.-]+):?([0-9]*)\/([a-zA-Z0-9\/\._=-]+)$"
if [[ "$DATABASE_URL" =~ $REGEX ]]; then
  export DATABASE_ADAPTER="${BASH_REMATCH[1]:-mysql2}"
  export DATABASE_USER="${BASH_REMATCH[2]}"
  export DATABASE_PASSWORD="${BASH_REMATCH[3]}"
  export DATABASE_HOST="${BASH_REMATCH[4]:-localhost}"
  export DATABASE_PORT="${BASH_REMATCH[5]:-3306}"
  export DATABASE_NAME="${BASH_REMATCH[6]}"
fi

mysqldump \
  -h ${DATABASE_HOST} \
  -P ${DATABASE_PORT} \
  -u ${DATABASE_USER} \
  --password=${DATABASE_PASSWORD} \
  --skip-add-locks \
  --allow-keywords ${DATABASE_NAME} \
 	| gzip -9 \
  | openssl enc -aes-256-cbc -salt -e -pass pass:$CRYPT_PASSPHRASE \
  | mc pipe backup/${S3_BUCKET}/${BACKUP_NAME_PREFIX}-`date +%Y-%m-%dT%H-%M-%S`.sql.gz.enc
