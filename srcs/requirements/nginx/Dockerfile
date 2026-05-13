FROM alpine:3.22

RUN apk add --no-cache nginx openssl && \
    mkdir -p /run/nginx /var/www/html /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY website/ /var/www/html/

COPY --chmod=755 tools/generate_ssl.sh /tmp/generate_ssl.sh

RUN /tmp/generate_ssl.sh && \
    rm -f /tmp/generate_ssl.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]