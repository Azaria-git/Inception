# Appendix - Références & Ressources

Versions officielles, ressources externes, et scripts d'installation.

---

## Table des matières

1. [État des versions](#état-des-versions)
2. [Installation de Docker](#installation-de-docker)
3. [Ressources externes](#ressources-externes)
4. [Commandes utiles](#commandes-utiles-docker)
5. [Variables d'environnement (.env)](#variables-denvironnement)

---

## État des versions

### Alpine Linux (Mai 2026)

**Cycle de vie** : 2 versions par an (mai et décembre)

| Statut | Version | Date de sortie | Fin de support (EOL) |
|--------|---------|---|---|
| **Dernière Stable** | **3.23** | Décembre 2025 | Décembre 2027 |
| **Avant-dernière Stable** | **3.22** | Mai 2025 | Mai 2027 |
| **Old Stable** | **3.21** | Décembre 2024 | Décembre 2026 |

**✅ Recommandé pour le projet** : `alpine:3.22` (avant-dernière)

**Source** : [alpinelinux.org/downloads](https://alpinelinux.org/downloads)

---

### Debian (Mai 2026)

**Cycle de vie** : Une version tous les 2 ans environ

| Statut | Version | Nom de code | Sortie | Fin de support LTS |
|--------|---------|---|---|---|
| **Dernière Stable** | **13** | **Trixie** | Août 2025 | ~Août 2030 |
| **Avant-dernière (Oldstable)** | **12** | **Bookworm** | Juin 2023 | Juin 2028 |
| **Oldoldstable** | **11** | **Bullseye** | Août 2021 | Août 2026 |

**✅ Recommandé pour le projet** : `debian:12-slim` ou `debian:12` (avant-dernière)

**Source** : [debian.org/releases](https://www.debian.org/releases/index.fr.html)

---

## Installation de Docker

### Prérequis

- Distribution Debian 10+
- Accès root ou sudo
- Connexion Internet

---

### Script d'installation (Debian)

```bash
#!/bin/bash
###############################################################################
# Script d'installation de Docker sur Debian
#
# Description:
#   Installe Docker Engine, Docker CLI, containerd, et les plugins
#   Docker Buildx et Docker Compose
#
# Usage:
#   sudo bash install_docker.sh
###############################################################################

# 1️⃣ Mettre à jour le système
sudo apt update
sudo apt upgrade -y

# 2️⃣ Installer les dépendances nécessaires
sudo apt install -y ca-certificates curl gnupg

# 3️⃣ Créer le dossier /etc/apt/keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# 4️⃣ Télécharger la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo tee /etc/apt/keyrings/docker.asc > /dev/null

# 5️⃣ Modifier les permissions de la clé
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 6️⃣ Récupérer l'architecture et le nom de code
ARCH=$(dpkg --print-architecture)
. /etc/os-release
DISTRO=$VERSION_CODENAME

# 7️⃣ Ajouter le dépôt Docker
DOCKER_REPO="deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $DISTRO stable"
echo "$DOCKER_REPO" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 8️⃣ Mettre à jour la liste des paquets
sudo apt update

# 9️⃣ Installer Docker et composants
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 🔟 Vérifier l'installation
docker --version
docker-compose --version
```

**Sauvegarder** : `install_docker.sh`  
**Exécuter** : `sudo bash install_docker.sh`

---

### Vérifier l'installation

```bash
# Vérifier Docker
docker --version
# Output: Docker version 24.x.x, ...

# Vérifier Docker Compose
docker-compose --version
# Output: Docker Compose version 2.x.x, ...

# Vérifier le daemon Docker
sudo systemctl status docker
```

---

### Configuration post-installation (optionnel)

Pour utiliser Docker sans `sudo` :

```bash
# Créer le groupe docker
sudo groupadd docker

# Ajouter votre utilisateur
sudo usermod -aG docker $USER

# Activer les changements
newgrp docker

# Vérifier
docker run hello-world
```

---

## Ressources externes

### Documentation Docker

| Ressource | URL |
|-----------|-----|
| Docker Compose | https://docs.docker.com/reference/compose-file/ |
| Services (compose) | https://docs.docker.com/reference/compose-file/services/ |
| Dockerfile | https://docs.docker.com/engine/reference/builder/ |
| Docker CLI | https://docs.docker.com/engine/reference/commandline/ |

---

### Documentation OpenSSL

| Ressource | URL |
|-----------|-----|
| OpenSSL Documentation | https://docs.openssl.org/master/ |
| OpenSSL Wiki | https://wiki.openssl.org/index.php/Main_Page |
| OpenSSL Manual | https://www.openssl.org/docs/ |

---

### Documentation des images

| Image | URL |
|-------|-----|
| Nginx (Docker Hub) | https://hub.docker.com/_/nginx |
| WordPress (Docker Hub) | https://hub.docker.com/_/wordpress |
| MariaDB (Docker Hub) | https://hub.docker.com/_/mariadb |
| Alpine (Docker Hub) | https://hub.docker.com/_/alpine |
| Debian (Docker Hub) | https://hub.docker.com/_/debian |

---

### Linux & Conteneurs

| Sujet | URL |
|-------|-----|
| Alpine Linux | https://alpinelinux.org/ |
| Debian | https://www.debian.org/ |
| Docker Best Practices | https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ |

---

## Commandes utiles Docker

### Gestion des conteneurs

```bash
# Lister les conteneurs en cours
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a

# Démarrer un conteneur
docker start <container_id|name>

# Arrêter un conteneur
docker stop <container_id|name>

# Redémarrer un conteneur
docker restart <container_id|name>

# Supprimer un conteneur (doit être arrêté)
docker rm <container_id|name>

# Afficher les logs
docker logs <container_id|name>

# Afficher les logs en direct
docker logs -f <container_id|name>

# Exécuter une commande dans un conteneur
docker exec -it <container_id|name> /bin/sh
docker exec -it <container_id|name> /bin/bash
```

---

### Gestion des images

```bash
# Lister les images
docker images

# Construire une image
docker build -t <image_name>:<tag> .

# Construire avec dockerfile personnalisé
docker build -f Dockerfile -t <image_name> .

# Supprimer une image
docker rmi <image_id|name>

# Afficher les détails d'une image
docker history <image_id|name>
```

---

### Docker Compose

```bash
# Démarrer les services (build + run)
docker-compose up

# Démarrer en arrière-plan
docker-compose up -d

# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Afficher les logs
docker-compose logs

# Afficher les logs d'un service spécifique
docker-compose logs wordpress

# Logs en direct
docker-compose logs -f

# Construire les images
docker-compose build

# Démarrer les services sans rebuild
docker-compose start

# Arrêter sans supprimer
docker-compose stop

# Recréer les conteneurs
docker-compose up --force-recreate

# Afficher le statut
docker-compose ps
```

---

### Gestion des volumes

```bash
# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect <volume_name>

# Supprimer un volume
docker volume rm <volume_name>

# Supprimer tous les volumes non utilisés
docker volume prune

# Voir le contenu d'un volume
docker run --rm -v <volume_name>:/data -it alpine:3.22 sh
# Puis: ls /data
```

---

### Dépannage

```bash
# Vérifier les erreurs
docker ps -a
docker logs <container>

# Inspecter un conteneur
docker inspect <container>

# Accéder au shell d'un conteneur
docker exec -it <container> sh
docker exec -it <container> bash

# Vérifier les ports exposés
docker port <container>

# Vérifier les connexions réseau
docker network ls
docker network inspect <network_name>

# Tester la connectivité entre conteneurs
docker exec <container1> ping <container2>

# Afficher les statistiques en temps réel
docker stats
```

---

## Variables d'environnement

### Fichier `.env` (exemple)

À créer à la racine du projet :

```bash
# .env

# Identifiant 42 (à remplacer)
USER_ID=login

# MariaDB
MYSQL_ROOT_PASSWORD=secure_password_root
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=secure_password_wp

# WordPress
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=${MYSQL_DATABASE}
WORDPRESS_DB_USER=${MYSQL_USER}
WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
WORDPRESS_SITE_URL=https://login.42.fr
WORDPRESS_SITE_TITLE=My WordPress Site
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=admin_password
WORDPRESS_ADMIN_EMAIL=admin@login.42.fr

# Nginx
DOMAIN=login.42.fr
```

### Utilisation dans Docker Compose

```yaml
services:
  mariadb:
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
  
  wordpress:
    environment:
      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
```

**Note** : Docker Compose lit automatiquement le fichier `.env`

---

## Checklist de déploiement

Avant de déployer en production :

| Élément | Vérification |
|---------|------------|
| Docker installé | ☐ |
| Docker Compose v2+ | ☐ |
| Dossier `/home/login/data/` créé | ☐ |
| Fichier `.env` configuré | ☐ |
| `/etc/hosts` : `127.0.0.1 login.42.fr` | ☐ |
| Images Alpine 3.22, Debian 12 | ☐ |
| Certificats SSL générés | ☐ |
| NGINX TLS v1.2/v1.3 | ☐ |
| PHP-FPM port 9000 (interne) | ☐ |
| MariaDB port 3306 (interne) | ☐ |
| Volumes nommés (pas de bind) | ☐ |
| Réseau bridge personnalisé | ☐ |
| Makefile opérationnel | ☐ |

---

## Dépannage courant

### Conteneur plante au démarrage

```bash
docker logs <container>
# Lire le message d'erreur pour identifier le problème
```

### Port déjà utilisé

```bash
# Trouver le processus occupant le port 443
sudo lsof -i :443

# Arrêter le processus
sudo kill -9 <PID>

# Ou utiliser un autre port dans docker-compose.yml
ports:
  - "8443:443"
```

### Certificate verification failed

```bash
# Vérifier le certificat
openssl x509 -in login.42.fr.crt -text -noout

# Régénérer si expiré ou invalide
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout login.42.fr.key \
    -out login.42.fr.crt \
    -subj "/C=FR/ST=State/L=City/O=42/CN=login.42.fr"
```

### PHP-FPM ne communique pas avec Nginx

```bash
# Vérifier la connectivité
docker exec nginx ping wordpress

# Vérifier le socket
docker exec wordpress ls -la /run/php-fpm.sock
```

### Base de données non accessible

```bash
# Vérifier que MariaDB est démarrée
docker ps | grep mariadb

# Vérifier les logs MariaDB
docker logs mariadb

# Tester la connexion
docker exec wordpress mysql -h mariadb -u user -p
```

---

**Fin de la documentation**  
**Dernière mise à jour** : Mai 2026  
**État** : Complète et consolidée
