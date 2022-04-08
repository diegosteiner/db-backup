FROM debian:11-slim

CMD ["backup.sh"]

RUN apt update && apt install -y wget openssl mariadb-client postgresql-client \
  && wget https://dl.minio.io/client/mc/release/linux-amd64/mc -O /sbin/mc && chmod +x /sbin/mc \
  && apt remove -y wget && apt autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY backup.sh .
COPY restore.sh .
