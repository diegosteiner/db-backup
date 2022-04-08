#!/bin/bash
set -e

#export MC_HOST_backup=$S3_URI
#mc mb backup/${S3_BUCK} --insecure
[[ "$DATABASE_URL" =~ "([\w-_]+):\/\/([\w-_]+):([\w-_]+)@([\w\._]+):?(\d*)\/([\w-_]+)" ]]
export DATABASE_ADAPTER="${BASH_REMATCH[0]}"
export DATABASE_USER="${BASH_REMATCH[1]}"
export DATABASE_PASSWORD="${BASH_REMATCH[2]}"
export DATABASE_HOST="${BASH_REMATCH[3]}"
export DATABASE_PORT="${BASH_REMATCH[4]}"
export DATABASE_NAME="${BASH_REMATCH[5]}"

mc find backup/${S3_BUCKET}/ --name "${BACKUP_NAME_PREFIX}*.sql.gz.enc" \ 
  | tail -n 1 \
  | xargs mc cat \
  | openssl enc -aes-256-cbc -salt -d -pass pass:$CRYPT_PASSPHRASE \
  | gunzip -9 > backup.sql

read -p "Press any key to continue... " -n1 -s

cat backup.sql \
  | mysql -h ${DATABASE_HOST} \
    -P ${DATABASE_PORT} \
    -u ${DATABASE_USER} \
    --password=${DATABASE_PASSWORD} \
    --skip-add-locks \
    --allow-keywords \
    ${DATABASE_NAME}
