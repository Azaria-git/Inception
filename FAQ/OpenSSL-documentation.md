# OpenSSL - Guide Simple pour Débutant

# 1. Qu'est-ce que OpenSSL ?

OpenSSL est un outil utilisé pour :

- créer des certificats SSL/TLS
- générer des clés privées
- sécuriser les connexions HTTPS
- chiffrer des données

Il est très utilisé avec :

- Nginx
- Apache
- Docker
- serveurs Linux
- HTTPS

---

# 2. SSL vs TLS

Avant :
- SSL = Secure Sockets Layer

Aujourd'hui :
- TLS = Transport Layer Security

Mais beaucoup de personnes disent encore "SSL".

HTTPS utilise TLS.

---

# 3. Pourquoi HTTPS ?

HTTP :
- données visibles
- non sécurisé

HTTPS :
- données chiffrées
- sécurisé

Exemple :

```txt
http://example.com
https://example.com
```

Le `s` signifie sécurisé.

---

# 4. Les fichiers importants

## Clé privée

```txt
server.key
```

Elle est secrète.

⚠️ Ne jamais partager ce fichier.

---

## Certificat

```txt
server.crt
```

Il contient :
- la clé publique
- le nom du serveur
- des informations d'identité

Le navigateur lit ce fichier.

---

# 5. Installation de OpenSSL

## Alpine Linux

```bash
apk add openssl
```

## Debian / Ubuntu

```bash
apt install openssl
```

---

# 6. Générer un certificat SSL auto-signé

## Commande simple

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout server.key \
  -out server.crt
```

---

# 7. Explication de la commande

## `req`

Crée une demande de certificat.

---

## `-x509`

Crée un certificat auto-signé.

---

## `-nodes`

Ne protège pas la clé par mot de passe.

Utile pour Nginx.

---

## `-days 365`

Le certificat expire après 365 jours.

---

## `-newkey rsa:2048`

Crée :
- une nouvelle clé
- RSA
- taille 2048 bits

---

## `-keyout`

Nom du fichier clé privée.

---

## `-out`

Nom du certificat.

---

# 8. Génération automatique sans questions

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout server.key \
  -out server.crt \
  -subj "/C=MG/ST=Analamanga/L=Antananarivo/O=42/OU=Inception/CN=localhost"
```

---

# 9. Comprendre `-subj`

## Exemple

```txt
/C=MG
```

Pays.

---

```txt
/ST=Analamanga
```

Région.

---

```txt
/L=Antananarivo
```

Ville.

---

```txt
/O=42
```

Organisation.

---

```txt
/OU=Inception
```

Département.

---

```txt
/CN=localhost
```

Nom du serveur.

Très important.

---

# 10. Le Common Name (CN)

## Exemple

```txt
CN=localhost
```

Le certificat sera valide pour :

```txt
https://localhost
```

Mais pas pour :

```txt
https://127.0.0.1
```

---

# 11. Utilisation avec Nginx

## Configuration HTTPS

```nginx
server {
    listen 443 ssl;

    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
        root /var/www/html;
        index index.html;
    }
}
```

---

# 12. Port HTTPS

| Port | Usage |
|---|---|
| 80 | HTTP |
| 443 | HTTPS |

---

# 13. Vérifier un certificat

## Voir les informations

```bash
openssl x509 -in server.crt -text -noout
```

---

# 14. Vérifier une clé privée

```bash
openssl rsa -in server.key -text -noout
```

⚠️ Utiliser seulement en local.

---

# 15. Vérifier la date d'expiration

```bash
openssl x509 -enddate -noout -in server.crt
```

---

# 16. Permissions importantes

## Protéger la clé privée

```bash
chmod 600 server.key
```

---

# 17. Certificat auto-signé

## Avantages

- gratuit
- simple
- parfait pour développement

## Inconvénients

- warning navigateur
- non reconnu officiellement

---

# 18. Certificat officiel

En production on utilise :

- Let's Encrypt
- Cloudflare
- DigiCert

---

# 19. Tester HTTPS localement

## Docker

```bash
docker build -t nginx-ssl .
docker run -p 443:443 nginx-ssl
```

---

## Navigateur

```txt
https://localhost
```

Le warning est normal avec un certificat auto-signé.

---

# 20. Structure classique d'un projet

```txt
project/
├── Dockerfile
├── conf/
│   ├── nginx.conf
│   └── default.conf
├── tools/
│   └── generate_ssl.sh
└── ssl/
    ├── server.crt
    └── server.key
```

---

# 21. Exemple de script SSL

```sh
#!/bin/sh

set -e

SSL_DIR="/etc/nginx/ssl"

CERT_FILE="$SSL_DIR/nginx.crt"
KEY_FILE="$SSL_DIR/nginx.key"

mkdir -p "$SSL_DIR"

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=MG/ST=Analamanga/L=Antananarivo/O=42/OU=Inception/CN=localhost"

chmod 600 "$KEY_FILE"

echo "SSL certificate generated."
```

---

# 22. Résumé

## OpenSSL sert à :

- générer des certificats
- créer des clés privées
- sécuriser HTTPS

---

## Fichiers importants

| Fichier | Rôle |
|---|---|
| `.key` | clé privée |
| `.crt` | certificat public |

---

## HTTPS utilise

- TLS
- chiffrement
- port 443

---

# 23. Commandes utiles

## Générer certificat

```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout server.key \
-out server.crt
```

---

## Lire certificat

```bash
openssl x509 -in server.crt -text -noout
```

---

## Vérifier expiration

```bash
openssl x509 -enddate -noout -in server.crt
```

---

# 24. À apprendre ensuite

- TLS Handshake
- RSA vs ECC
- Let's Encrypt
- Certbot
- TLS 1.3
- Reverse Proxy HTTPS
- Docker + HTTPS
- Perfect Forward Secrecy
- HTTP/2 et HTTPS