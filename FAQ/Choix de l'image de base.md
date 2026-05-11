# Choix de l'image de base pour WordPress, MariaDB et Nginx en conteneurs séparés

## Architecture cible
- **WordPress** (PHP-FPM) dans un conteneur
- **MariaDB** dans un conteneur
- **Nginx** (serveur web) dans un conteneur

Chaque service utilise une image de base différente selon ses besoins.

---

## Comparaison Alpine vs Debian

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

## Recommandations par service

### MariaDB → **Debian**
```yaml
image: mariadb:11.4-debian
# ou image: mariadb:lts-debian
```
**Pourquoi :**
- Stabilité des transactions ACID
- Pas de régression sur `fsync` et les verrous
- Collations et jeux de caractères parfaitement compatibles
- La base de données doit être fiable avant tout

### Nginx → **Alpine**
```yaml
image: nginx:stable-alpine
# ou image: nginx:alpine
```
**Pourquoi :**
- Aucune dépendance exotique
- Fonctionne parfaitement avec musl
- Gain en taille et en sécurité
- Démarrage instantané

### WordPress (PHP-FPM) → **Selon vos besoins**

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
- Vous utilisez des plugins/ thèmes obscurs
- Besoin de `imagick`, `gnupg`, `ssh2` spécifiques
- Vous débutez et voulez déboguer facilement
- Environnement de production critique

---

## Architecture finale recommandée (docker-compose.yml)

```yaml
version: '3.8'

services:
  mariadb:
    image: mariadb:11.4-debian     # ✅ Debian pour la base
    container_name: wp-mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - wp-network

  nginx:
    image: nginx:alpine             # ✅ Alpine pour Nginx
    container_name: wp-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html
      - ./nginx-conf:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - wordpress
    networks:
      - wp-network

  wordpress:
    image: wordpress:php8.3-fpm-alpine  # ✅ Alpine (ou -debian)
    container_name: wp-phpfpm
    restart: unless-stopped
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - mariadb
    networks:
      - wp-network

volumes:
  mariadb_data:
  wordpress_data:

networks:
  wp-network:
    driver: bridge
```

---

## Pourquoi ce mélange est cohérent

| Service  | Image choisie      | Raison |
|----------|--------------------|--------|
| MariaDB  | Debian             | Stabilité, fiabilité des données |
| Nginx    | Alpine             | Légèreté, sécurité, performance |
| WordPress| Alpine (ou Debian) | Performance, sauf besoin exceptionnel |

Chaque composant utilise la base la plus adaptée à sa fonction critique.

---

## Vérification après déploiement

```bash
# Taille des images
docker images | grep -E "mariadb|nginx|wordpress"

# Connexion à WordPress (Alpine)
docker exec -it wp-phpfpm sh
# vs Debian
docker exec -it wp-phpfpm bash

# Test d'une extension PHP exotique
docker exec wp-phpfpm php -m | grep imagick
```

---

## Résumé décisionnel

**Choisissez Alpine si :**
- Vous maîtrisez Docker et les différences musl/glibc
- Objectif : petite empreinte sur VPS limité
- Pas d'extensions PHP tierces exotiques
- Vous aimez la philosophie minimaliste

**Choisissez Debian si :**
- Vous débutez en conteneurs WordPress
- Vous voulez une compatibilité à 100%
- Vous avez besoin d'outils GNU complets dans les shells
- Environnement de production critique

---

## Notes importantes

- Les images `alpine` officielles pour WordPress et Nginx sont très matures
- Le principal risque Alpine reste les **extensions PHP non officielles**
- MariaDB en Alpine n'est **pas recommandé en production**
- Vous pouvez mixer : Alpine pour Nginx, Debian pour le reste

## Références

- [Images officielles WordPress - Docker Hub](https://hub.docker.com/_/wordpress)
- [Images officielles Nginx - Docker Hub](https://hub.docker.com/_/nginx)
- [Images officielles MariaDB - Docker Hub](https://hub.docker.com/_/mariadb)
- [Alpine vs Debian pour PHP](https://docs.docker.com/develop/develop-images/baseimages/)
