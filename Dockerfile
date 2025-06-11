FROM debian:12-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends wget openssl mariadb-client postgresql-client \
  && wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc \
  && chmod +x /usr/local/bin/mc /usr/local/bin/backup.sh /usr/local/bin/restore.sh \
  && apt-get remove -y wget \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY backup.sh /usr/local/bin/backup.sh
COPY restore.sh /usr/local/bin/restore.sh
