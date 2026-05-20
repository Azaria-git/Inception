FROM debian:12.13-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        mariadb-server \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
        && chown -R mysql:mysql /var/run/mysqld \
        && chown -R mysql:mysql /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init-db.sh /init-db.sh

RUN chmod +x /init-db.sh

CMD ["/init-db.sh"]