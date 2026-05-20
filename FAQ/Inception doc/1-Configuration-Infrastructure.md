# 1. Configuration & Infrastructure

Guide complet pour configurer l'infrastructure Docker avec les bonnes images et configurations.

---

## Table des matières

1. [Choix de l'image de base](#choix-de-limage-de-base)
2. [Configuration NGINX](#configuration-nginx)
3. [Configuration PHP-FPM](#configuration-php-fpm)
4. [Configuration des volumes](#configuration-des-volumes)
5. [Réseaux Docker](#réseaux-docker)

---

## Choix de l'image de base

### Architecture cible

```text
Service           Conteneur     Image recommandée
─────────────────────────────────────────────────
WordPress (PHP)   conteneur     alpine ou debian
MariaDB (DB)      conteneur     mariadb:11.4-debian
Nginx (Web)       conteneur     nginx:alpine
```

---

### Comparaison Alpine vs Debian

| Critère | Alpine | Debian (slim) |
|---------|--------|---------------|
| Taille de l'image | ~5 Mo | ~80-200 Mo |
| Libc | musl | glibc |
| Outils shell | BusyBox (minimal) | GNU (complets) |
| Compatibilité extensions PHP | ⚠️ Parfois limitée | ✅ Excellente |
| Démarrage | Très rapide | Normal |
| Surface d'attaque | Très faible | Faible |
| Documentation WP | Peu abondante | Très abondante |
| Debugging | Plus complexe | Aisé |

---

### Recommandations par service

#### MariaDB → **Debian**

```yaml
image: mariadb:11.4-debian
```

**Pourquoi :**
- Stabilité des transactions ACID garantie
- Pas de régression sur `fsync` et les verrous
- Collations et jeux de caractères parfaitement compatibles
- La base de données doit être fiable avant tout

#### Nginx → **Alpine**

```yaml
image: nginx:stable-alpine
```

**Pourquoi :**
- Aucune dépendance exotique
- Fonctionne parfaitement avec musl
- Gain en taille et en sécurité
- Démarrage instantané

#### WordPress (PHP-FPM) → **Selon vos besoins**

**Option Alpine (recommandée par défaut) :**
```yaml
image: wordpress:php8.3-fpm-alpine
```

Convient si :
- Pas d'extensions PHP tierces exotiques (ionCube, SourceGuardian)
- Pas de binaires précompilés spécifiques à glibc
- Vous voulez un conteneur léger

**Option Debian (sécurité maximale) :**
```yaml
image: wordpress:php8.3-fpm-debian
```

Convient si :
- Vous utilisez des plugins/thèmes obscurs
- Besoin d'extensions spécifiques (imagick, gnupg, ssh2)
- Vous débutez et voulez déboguer facilement
- Environnement de production critique

---

### État des versions (Mai 2026)

#### Alpine Linux

| Statut | Version | Date de Sortie | EOL |
| :--- | :--- | :--- | :--- |
| **Dernière Stable** | **3.23** | Décembre 2025 | Décembre 2027 |
| **Avant-dernière** | **3.22** | Mai 2025 | Mai 2027 |

**✅ À utiliser : Alpine 3.22 (avant-dernière)**

#### Debian

| Statut | Version | Nom de code | Sortie | Fin de Support |
| :--- | :--- | :--- | :--- | :--- |
| **Dernière Stable** | **13** | **Trixie** | Août 2025 | ~Août 2030 |
| **Avant-dernière** | **12** | **Bookworm** | Juin 2023 | Juin 2028 |

**✅ À utiliser : Debian 12 (Bookworm, avant-dernière)**

---

## Configuration NGINX

### Vue d'ensemble

NGINX est le **seul point d'entrée** (port 443 HTTPS). Il agit comme reverse proxy vers PHP-FPM.

### Exigences obligatoires

| Exigence | Détail |
|----------|--------|
| **Conteneur dédié** | NGINX seul, pas de PHP/MariaDB |
| **Port exposé** | 443 uniquement (HTTPS) |
| **TLS** | v1.2 ou v1.3 obligatoire |
| **Dockerfile** | Maison (pas d'image `latest` de DockerHub) |
| **Redémarrage** | `restart: unless-stopped` |
| **Domaine** | `login.42.fr` (remplacez `login`) |
| **Reverse proxy** | Vers `wordpress:9000` (PHP-FPM) |

---

### Configuration de sécurité TLS

Exemple `nginx.conf` :

```nginx
server {
    listen 443 ssl;
    server_name login.42.fr;
    
    # Certificats (générés avec OpenSSL)
    ssl_certificate     /etc/nginx/ssl/login.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/login.42.fr.key;
    
    # Seulement TLS v1.2 et v1.3
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Reverse proxy vers PHP-FPM
    location ~ \.php$ {
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Servir les fichiers statiques
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.php?$args;
    }
}
```

---

### Dockerfile NGINX recommandé

```dockerfile
# Alpine (avant-dernière version stable)
FROM alpine:3.22

RUN apk update && apk add --no-cache \
    nginx \
    openssl

# Créer le répertoire SSL
RUN mkdir -p /etc/nginx/ssl

# Générer certificat auto-signé
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/login.42.fr.key \
    -out /etc/nginx/ssl/login.42.fr.crt \
    -subj "/C=FR/ST=State/L=City/O=42/CN=login.42.fr"

# Copier config NGINX
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Lancer NGINX en foreground (pas de boucle infinie)
CMD ["nginx", "-g", "daemon off;"]
```

---

### Checklist NGINX

| Critère | Statut |
|---------|--------|
| Conteneur dédié | ☐ |
| Port 443 uniquement | ☐ |
| TLS v1.2/v1.3 | ☐ |
| Dockerfile maison | ☐ |
| Certificats SSL générés | ☐ |
| Domaine configuré | ☐ |
| Reverse proxy vers port 9000 | ☐ |

---

## Configuration PHP-FPM

### Qu'est-ce que PHP-FPM ?

```text
PHP-FPM = PHP FastCGI Process Manager
```

C'est le service qui **exécute les fichiers PHP**.

Flux de requête :
```text
Navigateur → Nginx → PHP-FPM → WordPress → Réponse HTML
```

---

### Configuration `www.conf` (à créer)

Fichier : `srcs/requirements/wordpress/conf/www.conf`

```ini
[www]

; Utilisateur exécutant PHP-FPM (jamais root pour sécurité)
user = www-data
group = www-data

; Socket d'écoute (pour Nginx)
listen = 9000

; Permissions du socket
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Gestion dynamique des processus
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

; Logs d'erreur
php_admin_flag[log_errors] = on
php_admin_value[error_log] = /proc/self/fd/2

; Sécurité
php_admin_flag[expose_php] = off

; Répertoire courant
chdir = /

; Garder les variables d'environnement Docker
clear_env = no
```

---

### Dockerfile WordPress recommandé

```dockerfile
FROM wordpress:php8.3-fpm-alpine

# Copier la configuration PHP-FPM
COPY conf/www.conf /usr/local/etc/php-fpm.d/www.conf

# Script d'initialisation (préparation DB, etc.)
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Lancer le script d'init puis PHP-FPM
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm"]
```

---

### Explications des paramètres PHP-FPM

| Paramètre | Rôle |
|-----------|------|
| `user` | Utilisateur Linux exécutant PHP (jamais root) |
| `listen` | Port où PHP-FPM écoute (9000 = port TCP) |
| `pm` | Mode de gestion des processus (dynamic = flexible) |
| `pm.max_children` | Processus max simultanees |
| `pm.start_servers` | Processus au démarrage |
| `expose_php` | off = cache la version PHP dans les headers |
| `clear_env` | no = garde les variables d'environnement |

---

## Configuration des volumes

### Volumes requis

Vous devez créer **exactement 2 volumes nommés** :

```yaml
volumes:
  wordpress_db:
    driver: local
    driver_opts:
      type: none
      device: /home/login/data/wordpress_db
      o: bind
  
  wordpress_files:
    driver: local
    driver_opts:
      type: none
      device: /home/login/data/wordpress_files
      o: bind
```

---

### Rôle de chaque volume

| Volume | Montage dans | Chemin conteneur | Contenu |
|--------|--------------|------------------|---------|
| **wordpress_db** | MariaDB | `/var/lib/mysql` | Base de données (tables, utilisateurs, articles) |
| **wordpress_files** | WordPress | `/var/www/html` | Fichiers WordPress (code, plugins, uploads) |

---

### Structure attendue sur l'hôte

```
/home/login/data/
├── wordpress_db/
│   ├── mysql/
│   └── (fichiers MariaDB)
└── wordpress_files/
    ├── index.php
    ├── wp-config.php
    ├── wp-content/
    │   ├── themes/
    │   ├── plugins/
    │   └── uploads/
    └── (code WordPress)
```

---

### Commandes de gestion des volumes

```bash
# Lister tous les volumes
docker volume ls

# Inspecter un volume (voir l'emplacement)
docker volume inspect wordpress_db

# Supprimer un volume (⚠️ supprime les données)
docker volume rm wordpress_db
```

---

## Réseaux Docker

### Configuration Docker Compose

```yaml
networks:
  inception-network:
    driver: bridge
```

---

### Qu'est-ce qu'un réseau bridge ?

```text
Réseau bridge = switch virtuel privé sur une machine
```

Bénéfices :
- ✅ Communication entre conteneurs par nom (DNS automatique)
- ✅ Isolation du réseau hôte
- ✅ Les services se découvrent mutuellement
- ✅ Multi-conteneurs peuvent partager le même réseau

---

### Configuration des services

```yaml
services:
  nginx:
    networks:
      - inception-network
  
  wordpress:
    networks:
      - inception-network
    depends_on:
      - mariadb
  
  mariadb:
    networks:
      - inception-network

networks:
  inception-network:
    driver: bridge
```

---

### Découverte DNS automatique

Dans ce réseau, les conteneurs se trouvent par nom :

```text
Nginx peut contacter PHP-FPM via : wordpress:9000
WordPress peut contacter DB via : mariadb:3306
```

Pas besoin d'adresses IP hardcodées !

---

## Docker Compose complet (exemple)

```yaml
version: '3.8'

services:
  mariadb:
    build: ./requirements/mariadb
    image: mariadb
    container_name: mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - wordpress_db:/var/lib/mysql
    networks:
      - inception-network

  wordpress:
    build: ./requirements/wordpress
    image: wordpress
    container_name: wordpress
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - wordpress_files:/var/www/html
    depends_on:
      - mariadb
    networks:
      - inception-network

  nginx:
    build: ./requirements/nginx
    image: nginx
    container_name: nginx
    restart: unless-stopped
    ports:
      - "443:443"
    volumes:
      - wordpress_files:/var/www/html:ro
    depends_on:
      - wordpress
    networks:
      - inception-network

volumes:
  wordpress_db:
    driver: local
    driver_opts:
      type: none
      device: /home/login/data/wordpress_db
      o: bind
  wordpress_files:
    driver: local
    driver_opts:
      type: none
      device: /home/login/data/wordpress_files
      o: bind

networks:
  inception-network:
    driver: bridge
```

---

## Checklist Configuration Globale

| Élément | Statut |
|---------|--------|
| Images Alpine/Debian (avant-dernière) | ☐ |
| Volumes nommés (pas de bind mounts) | ☐ |
| NGINX port 443 TLS uniquement | ☐ |
| PHP-FPM port 9000 | ☐ |
| MariaDB port 3306 (interne) | ☐ |
| Réseau bridge personnalisé | ☐ |
| Variables d'environnement (.env) | ☐ |
| Domaine local configuré (/etc/hosts) | ☐ |
| Répertoire /home/login/data/ créé | ☐ |

---

**Section suivante** : [Services & Dépendances](2-Services-Dependances.md)
