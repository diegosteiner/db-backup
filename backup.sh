#!/bin/bash
set -e

export MC_HOST_backup=$S3_URI

#mc mb backup/${S3_BUCK} --insecure

mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} --skip-add-locks --allow-keywords ${MYSQL_DATABASE} \
 	|  gzip -9 > backup.tar.gz
	&& openssl enc -aes-256-cbc -salt -in backup.tar.gz -out backup.tar.gz.enc -k $CRYPT_PASSPHRASE
  && mc ./backup.tar.gz.env backup/${S3_BUCKET}/${BACKUP_NAME_PREFIX}-`date +%Y-%m-%dT%H-%M-%S`.sql.gz.enc
