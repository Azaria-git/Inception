# Configuration NGINX - Projet Inception

## Vue d'ensemble

Ce document détaille l'ensemble des exigences obligatoires pour le conteneur **NGINX** dans le cadre du projet Inception. Le respect de ces règles est impératif pour la validation de la partie obligatoire.

---

## 1. Conteneur dédié

- Un conteneur Docker distinct doit être créé spécifiquement pour NGINX.
- NGINX ne doit **pas** être installé dans les conteneurs WordPress ou MariaDB.
- Chaque service a son propre conteneur (un par service).

```yaml
# Extrait docker-compose.yml (exemple)
services:
  nginx:
    build: ./requirements/nginx
    container_name: nginx
    # ...
```

---

## 2. Version TLS uniquement

- Le serveur NGINX doit être configuré pour accepter **uniquement** les protocoles TLS v1.2 **ou** TLS v1.3.
- Les versions antérieures (SSLv2, SSLv3, TLSv1.0, TLSv1.1) sont **interdites**.

**Exemple de configuration (nginx.conf) :**
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
```

---

## 3. Point d'entrée unique (Port 443)

- NGINX est le **seul point d'entrée** de l'infrastructure.
- Toute communication externe doit passer par NGINX, exclusivement via le **port 443** (HTTPS).
- Aucun autre conteneur (WordPress, MariaDB, etc.) ne doit exposer directement de port à l'hôte.

```yaml
ports:
  - "443:443"
```

---

## 4. Séparation des responsabilités

- Le conteneur NGINX ne doit **pas** contenir WordPress, PHP-FPM ou MariaDB.
- Son rôle est uniquement de servir de reverse proxy vers le conteneur WordPress (PHP-FPM).
- La communication entre NGINX et WordPress doit se faire via le réseau interne Docker.

---

## 5. Image de base autorisée

- L'image doit être construite à partir de **Alpine** ou **Debian** (dernière version stable moins une).
- L'utilisation d'images pré-construites de NGINX (ex: `nginx:latest`, `nginx:alpine`) est **interdite**.
- Vous devez écrire vous-même le Dockerfile.

```dockerfile
# Exemple Dockerfile (Alpine)
FROM alpine:3.18   # pénultième version stable

RUN apk update && apk add nginx openssl

# ... configuration personnalisée
```

---

## 6. Dockerfile personnel

- Un Dockerfile dédié doit être écrit pour NGINX.
- Il doit se trouver dans le dossier `srcs/requirements/nginx/` (ou structure équivalente selon le sujet).
- Le `Makefile` doit appeler `docker-compose.yml`, qui lui-même utilise le Dockerfile.

---

## 7. Réseau Docker

- NGINX doit être connecté à un **réseau Docker personnalisé**.
- Ce réseau permet la communication avec le conteneur WordPress.
- L'utilisation de `network: host`, `--link` ou `links:` est **interdite**.

```yaml
networks:
  - inception-network
```

---

## 8. Politique de redémarrage

- Le conteneur NGINX doit être configuré pour redémarrer automatiquement en cas de crash.
- Utiliser `restart: always` ou `restart: unless-stopped` dans `docker-compose.yml`.

```yaml
restart: unless-stopped
```

---

## 9. Interdiction des hacks d'initialisation

- **Interdiction formelle** d'utiliser des commandes en boucle infinie pour maintenir le conteneur actif.
- Commandes prohibées : `tail -f`, `bash`, `sleep infinity`, `while true`, etc.
- NGINX doit être lancé normalement en tant que processus principal (PID 1) avec `nginx -g "daemon off;"`.

**Exemple correct :**
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

**À ne PAS faire :**
```dockerfile
CMD ["tail", "-f", "/dev/null"]
```

---

## 10. Nom de domaine et résolution locale

- NGINX doit répondre au nom de domaine : **`login.42.fr`** (remplacez `login` par votre identifiant 42).
- Ce nom doit pointer vers l'adresse IP locale (`127.0.0.1` ou IP de la VM).
- Configuration à ajouter dans le fichier `hosts` de la machine hôte :

```
127.0.0.1   login.42.fr
```

- Le `server_name` dans la configuration NGINX doit correspondre à ce domaine :

```nginx
server_name login.42.fr;
```

---

## 11. Gestion des certificats SSL/TLS

- Des certificats SSL valides (même auto-signés) sont nécessaires pour le TLS.
- Les chemins des certificats doivent être spécifiés dans la configuration NGINX :

```nginx
ssl_certificate     /etc/nginx/ssl/login.42.fr.crt;
ssl_certificate_key /etc/nginx/ssl/login.42.fr.key;
```

- La génération des certificats peut se faire dans le Dockerfile (via OpenSSL).

---

## 12. Proxy vers WordPress

- NGINX doit être configuré comme reverse proxy vers le conteneur WordPress (PHP-FPM).
- WordPress écoute typiquement sur le port 9000 (PHP-FPM) dans son propre conteneur.

```nginx
location / {
    fastcgi_pass wordpress:9000;
    # ... autres directives fastcgi
}
```

---

## Récapitulatif des vérifications à faire avant évaluation

| Critère | Statut |
|---------|--------|
| Conteneur dédié (uniquement NGINX) | ☐ |
| TLS v1.2 ou v1.3 uniquement | ☐ |
| Port exposé : 443 uniquement | ☐ |
| Pas de WordPress/php-fpm dans NGINX | ☐ |
| Image Alpine ou Debian (penultième stable) | ☐ |
| Dockerfile maison (pas d'image toute faite) | ☐ |
| Réseau Docker personnalisé (pas host/ --link) | ☐ |
| Restart automatique activé | ☐ |
| Pas de commande infinie (tail -f, etc.) | ☐ |
| Nom de domaine `login.42.fr` configuré | ☐ |
| Certificats SSL générés et configurés | ☐ |
| Proxy correctement dirigé vers WordPress | ☐ |

---

## Commandes utiles pour tester

```bash
# Vérifier que NGINX écoute uniquement sur le port 443
docker exec nginx netstat -tulpn | grep nginx

# Tester la version TLS (via openssl)
openssl s_client -connect login.42.fr:443 -tls1_2

# Vérifier que le conteneur redémarre après un kill
docker kill nginx
docker ps -a  # Vérifier le statut

# Tester la configuration NGINX
docker exec nginx nginx -t
```

---

*Document basé sur le sujet Inception version 5.2 - Partie obligatoire*