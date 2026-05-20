# 2. Services & Dépendances

Détail des dépendances, extensions PHP, et règles pour construire les Dockerfiles.

---

## Table des matières

1. [Extensions PHP pour WordPress](#extensions-php-pour-wordpress)
2. [Dépendances par service](#dépendances-par-service)
3. [Règles des Dockerfiles](#règles-des-dockerfiles)
4. [Bonnes pratiques](#bonnes-pratiques)

---

## Extensions PHP pour WordPress

### Vue d'ensemble

WordPress nécessite plusieurs extensions PHP pour fonctionner correctement.

### Core PHP

#### **php82** (ou php8.3)
- **Rôle** : Moteur PHP principal
- **Sans lui** : WordPress ne peut pas exécuter de PHP → rien ne fonctionne
- **Indispensable** : ✅ OUI

#### **php82-fpm**
- **Rôle** : FastCGI Process Manager pour fonctionner avec Nginx
- **Permet** : Communication Nginx ↔ PHP via socket (port 9000)
- **Sans lui** : Nginx affiche le code PHP en clair
- **Indispensable** : ✅ OUI

---

### Base de données

#### **php82-mysqli**
- **Rôle** : Extension MySQL améliorée pour PHP
- **Utilisée pour** : Connexion WordPress ↔ MariaDB
- **Permet** : Requêtes SQL sécurisées et performantes
- **Sans lui** : Erreur "Error establishing a database connection"
- **Indispensable** : ✅ OUI

---

### Sécurité & HTTPS

#### **php82-openssl**
- **Rôle** : Support cryptographie SSL/TLS
- **Utilisée pour** : HTTPS, certificats, connexions sécurisées
- **Permet** : API externes, téléchargement de plugins
- **Sans lui** : Échec des mises à jour, API cassées
- **Indispensable** : ✅ OUI

---

### Réseau & HTTP

#### **php82-curl**
- **Rôle** : Client HTTP intégré à PHP
- **Utilisée pour** : Appels API externes, requêtes HTTP
- **Permet** : Téléchargement de plugins/thèmes, webhooks
- **Sans lui** : Certaines connexions réseau échouent
- **Indispensable** : ✅ OUI

---

### Archives PHP

#### **php82-phar**
- **Rôle** : PHP Archive handler (.phar)
- **Utilisée pour** : Composer, certains plugins
- **Indispensable** : ⚠️ PARFOIS (rarement utilisé)

---

### Traitement texte

#### **php82-mbstring**
- **Rôle** : Multi Byte String (encodage UTF-8)
- **Utilisée pour** : Caractères spéciaux, accents, emojis
- **Permet** : Internationalisation, manipulation de contenu
- **Sans lui** : Caractères cassés, problèmes d'encodage
- **Indispensable** : ✅ OUI

---

### Images

#### **php82-gd**
- **Rôle** : Bibliothèque de traitement d'images
- **Utilisée pour** : Redimensionnement, thumbnails, compression
- **Utilisé par** : Médias WordPress, miniatures
- **Sans lui** : Gestion d'images dégradée
- **Indispensable** : ✅ OUI

---

### Encodage

#### **php82-iconv**
- **Rôle** : Conversion d'encodage texte
- **Utilisée pour** : UTF-8 ↔ ISO-8859-1
- **Permet** : Compatibilité anciens systèmes
- **Indispensable** : ⚠️ PARFOIS

---

### Sessions utilisateur

#### **php82-session**
- **Rôle** : Gestion des sessions PHP
- **Utilisée pour** : Login utilisateur, cookies de session
- **Authentification** : WordPress authentification
- **Sans lui** : Login impossible ou instable
- **Indispensable** : ✅ OUI

---

## Configuration des extensions PHP

Les extensions se configurent dans `php.ini` ou fichiers `/usr/local/etc/php/conf.d/`.

### Exemple Dockerfile WordPress

```dockerfile
FROM wordpress:php8.3-fpm-alpine

# Installer les extensions PHP manquantes (Alpine utilise apk)
RUN apk add --no-cache \
    php83-gd \
    php83-iconv \
    php83-session \
    php83-mbstring

# Ou sur Debian : RUN apt install -y php8.3-gd php8.3-iconv etc.

COPY conf/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm"]
```

---

### Vérifier les extensions installées

```bash
# Dans le conteneur WordPress
docker exec wordpress php -m

# Vous devriez voir :
# - mysqli
# - openssl
# - curl
# - phar
# - mbstring
# - gd
# - iconv
# - session
```

---

## Dépendances par service

### Nginx (Alpine)

```dockerfile
FROM nginx:stable-alpine

# Dépendances Nginx sur Alpine
RUN apk add --no-cache \
    openssl

# Config + certificats SSL
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate_ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_ssl.sh

# Générer les certificats au démarrage
CMD ["sh", "-c", "/usr/local/bin/generate_ssl.sh && nginx -g 'daemon off;'"]
```

**Extensions Nginx** : Aucune (staticité, reverse proxy simple)

---

### WordPress + PHP-FPM (Alpine ou Debian)

```dockerfile
# Alpine
FROM wordpress:php8.3-fpm-alpine

# Dépendances Alpine pour WordPress
RUN apk add --no-cache \
    php83-gd \
    php83-iconv \
    php83-session \
    php83-mbstring

# Debian alternative
FROM wordpress:php8.3-fpm-debian

RUN apt update && apt install -y \
    php8.3-gd \
    php8.3-iconv \
    php8.3-session \
    php8.3-mbstring
```

**Extensions PHP** : Voir section précédente

---

### MariaDB (Debian obligatoire)

```dockerfile
FROM mariadb:11.4-debian

# Dépendances MariaDB sur Debian
RUN apt update && apt install -y \
    openssl

# Scripts d'initialisation
COPY conf/50-server.cnf /etc/mysql/conf.d/
COPY tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

# MariaDB démarre automatiquement
CMD ["--default-authentication-plugin=mysql_native_password"]
```

**Extensions** : Aucune (MariaDB gère tout)

---

## Résumé des dépendances

| Service | Image | Dépendances clés |
|---------|-------|------------------|
| **Nginx** | nginx:stable-alpine | openssl |
| **WordPress** | wordpress:php8.3-fpm-alpine | php-gd, php-mbstring, php-session, php-iconv |
| **MariaDB** | mariadb:11.4-debian | openssl (pour SSL) |

---

## Règles des Dockerfiles

### Règle 1 : Nommage des images

```yaml
# ✅ BON : Image nommée comme le service
services:
  nginx:
    build: ./requirements/nginx
    image: nginx

  wordpress:
    build: ./requirements/wordpress
    image: wordpress

  mariadb:
    build: ./requirements/mariadb
    image: mariadb
```

**Avantage** : Clarté, identification facile lors du débogage

---

### Règle 2 : Versions explicites (pas de `latest`)

```dockerfile
# ❌ MAUVAIS
FROM nginx:latest
FROM alpine:latest
FROM debian:latest

# ✅ BON : Versions explicites
FROM alpine:3.22
FROM debian:12-slim
FROM nginx:stable-alpine
```

**Avantage** : Reproductibilité, builds identiques à 6 mois d'intervalle

---

### Règle 3 : Avant-dernière version stable obligatoire

**Alpine** :
```dockerfile
# ✅ BON (avant-dernière)
FROM alpine:3.22

# ❌ MAUVAIS (dernière)
FROM alpine:3.23
```

**Debian** :
```dockerfile
# ✅ BON (avant-dernière)
FROM debian:12-slim

# ❌ MAUVAIS (dernière)
FROM debian:13-slim
```

**Avantage** : Équilibre sécurité/stabilité (les dernières versions peuvent avoir des bugs non détectés)

---

### Règle 4 : Pas de mots de passe en dur

```dockerfile
# ❌ MAUVAIS
ENV MYSQL_ROOT_PASSWORD=password123
RUN mysql -u root -ppassword123 < init.sql

# ✅ BON : Utiliser des variables d'environnement
ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
```

**Raison** : Sécurité
- Les mots de passe en dur restent en clair dans `docker history`
- Ils peuvent être versionés dans Git
- Faille de sécurité critique

---

### Règle 5 : Pas de boucles infinies

```dockerfile
# ❌ MAUVAIS : Processus fictif
CMD ["tail", "-f", "/dev/null"]
CMD ["sleep", "infinity"]
CMD ["while true; do sleep 10; done"]

# ✅ BON : Laisser le service s'exécuter
CMD ["nginx", "-g", "daemon off;"]
CMD ["php-fpm"]
CMD ["mariadbd"]
```

**Raison** :
- Le conteneur doit exécuter le service réel (PID 1)
- Les signaux d'arrêt (SIGTERM) ne sont pas propagés
- Le redémarrage automatique ne fonctionne pas

---

### Règle 6 : Optimisation des couches

```dockerfile
# ❌ MAUVAIS : Trop de couches
RUN apt update
RUN apt install openssl
RUN apt install nginx

# ✅ BON : Chaîner les commandes
RUN apt update && apt install -y \
    openssl \
    nginx
```

**Avantage** : Images plus petites, moins de couches

---

### Règle 7 : Nettoyage des caches

```dockerfile
# ✅ BON : Nettoyer après installation (Alpine)
RUN apk add --no-cache openssl nginx

# ✅ BON : Nettoyer après installation (Debian)
RUN apt update && apt install -y \
    openssl \
    nginx \
    && rm -rf /var/lib/apt/lists/*
```

**Avantage** : Réduit la taille de l'image

---

### Checklist Dockerfile

| Aspect | Vérification |
|--------|------------|
| Pas de `latest` | ☐ |
| Version explicite (alpine:3.22, debian:12) | ☐ |
| Image nommée comme service | ☐ |
| Pas de mots de passe en dur | ☐ |
| Service s'exécute normalement (pas de boucle) | ☐ |
| Commandes chaînées (`&&`) | ☐ |
| Caches nettoyés | ☐ |
| CMD/ENTRYPOINT clairement défini | ☐ |

---

## Bonnes pratiques

### ENTRYPOINT vs CMD

```dockerfile
# ENTRYPOINT = ce qui s'exécute toujours
# CMD = arguments par défaut à ENTRYPOINT

ENTRYPOINT ["php-fpm"]
# ou
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm"]
```

---

### Scripts d'initialisation

Exemple `tools/setup.sh` :

```bash
#!/bin/bash
set -e

# Attendre que MariaDB soit prête
while ! nc -z mariadb 3306; do
    sleep 1
done

# Initialiser WordPress si nécessaire
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Configuration WordPress..."
    wp config create \
        --dbhost=mariadb \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --allow-root
fi

# Lancer PHP-FPM
exec "$@"
```

---

### Gestion des permissions

```dockerfile
# Créer l'utilisateur www-data s'il n'existe pas
RUN addgroup -g 33 www-data || true && \
    adduser -D -u 33 -G www-data www-data || true
```

---

## Résumé Services & Dépendances

| Service | Image | Ext. PHP | Dépendances |
|---------|-------|----------|------------|
| **Nginx** | alpine:3.22 | - | openssl |
| **WordPress** | wordpress:php8.3-fpm-alpine | gd, mbstring, session, iconv | curl, mysqli, openssl |
| **MariaDB** | mariadb:11.4-debian | - | mariadb-server |

---

**Section suivante** : [Sécurité & Protocoles](3-Securite.md)
