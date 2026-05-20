#!/bin/sh

set -e

SSL_DIR="/etc/nginx/ssl"
CERT_FILE="$SSL_DIR/nginx.crt"
KEY_FILE="$SSL_DIR/nginx.key"

mkdir -p "$SSL_DIR"

# Generate certificate only if it doesn't exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=MG/ST=Analamanga/L=Antananarivo/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi
