FROM alpine:3.22

# PHP + dépendances WordPress
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-openssl \
    php82-curl \
    php82-phar \
    php82-mbstring \
    php82-gd \
    php82-iconv \
    php82-session \
    wget \
    unzip \
    curl

# Création dossier web
RUN mkdir -p /var/www/html

# Téléchargement WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz && \
    tar -xzf /tmp/wp.tar.gz -C /var/www/html --strip-components=1 && \
    rm -rf /tmp/wp.tar.gz

# Permissions
RUN chown -R nobody:nobody /var/www/html

# PHP-FPM config minimale
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

# Script de lancement
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

CMD ["/setup.sh"]