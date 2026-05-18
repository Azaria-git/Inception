# Configuration des Volumes - Projet Inception

## Vue d'ensemble

Ce document détaille l'ensemble des exigences obligatoires concernant les **volumes Docker** dans le cadre du projet Inception. Les volumes sont utilisés pour la persistance des données (base de données MariaDB et fichiers du site WordPress).

---

## 1. Nombre et type de volumes requis

Vous devez configurer **exactement deux volumes Docker nommés** :

| Volume | Contenu stocké |
|--------|----------------|
| Volume 1 | Base de données WordPress (MariaDB) |
| Volume 2 | Fichiers du site WordPress (wp-content, thèmes, plugins, médias) |

```yaml
# Extrait docker-compose.yml (exemple)
volumes:
  wordpress_db:
  wordpress_files:
```

---

## 2. Interdiction des bind mounts pour ces volumes

- Les **bind mounts** (montage de répertoire local direct) sont **interdits** pour ces deux volumes.
- Vous devez impérativement utiliser des **Docker named volumes**.

**❌ À ne PAS faire :**
```yaml
volumes:
  - ./data/wordpress:/var/www/html  # Bind mount - INTERDIT
```

**✅ À faire :**
```yaml
volumes:
  - wordpress_files:/var/www/html   # Named volume - OBLIGATOIRE
```

---

## 3. Emplacement de stockage sur l'hôte

- Les données des deux volumes nommés doivent être stockées dans le chemin suivant sur la machine hôte :

```
/home/login/data/
```

- Remplacez `login` par votre identifiant utilisateur 42 (exemple : `wil`, `mabrie`, etc.)

**Structure finale attendue :**
```
/home/login/
└── data/
    ├── wordpress_db/      # Données MariaDB
    └── wordpress_files/   # Fichiers WordPress
```

- Docker doit être configuré pour que les named volumes pointent vers ces répertoires.
- Ceci se fait généralement via le driver `local` avec l'option `device`.

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

> ⚠️ **Note** : Cette configuration utilise techniquement un bind mount au niveau du driver, mais reste conforme car le sujet exige des **named volumes** et c'est la méthode standard pour contrôler l'emplacement physique.

---

## 4. Rôle de chaque volume

### Volume 1 - Base de données
- Monté dans le conteneur **MariaDB** (uniquement)
- Emplacement typique dans le conteneur : `/var/lib/mysql`
- Contient toutes les données des bases de données WordPress (tables, utilisateurs, articles, commentaires, etc.)

### Volume 2 - Fichiers WordPress
- Monté dans le conteneur **WordPress** (uniquement)
- Emplacement typique dans le conteneur : `/var/www/html`
- Contient :
  - Fichiers core WordPress
  - Thèmes installés (`/wp-content/themes/`)
  - Plugins installés (`/wp-content/plugins/`)
  - Médias téléchargés (`/wp-content/uploads/`)
  - Fichiers de configuration (`wp-config.php`)

---

## 5. Règles de montage

- Chaque volume ne doit être monté que dans **un seul conteneur** (le conteneur qui en a besoin) :
  - Volume MariaDB → uniquement dans le conteneur MariaDB
  - Volume WordPress → uniquement dans le conteneur WordPress
- NGINX n'a pas besoin de volume (ne stocke pas de données persistantes)

```yaml
services:
  mariadb:
    volumes:
      - wordpress_db:/var/lib/mysql
    # PAS de wordpress_files ici

  wordpress:
    volumes:
      - wordpress_files:/var/www/html
    # PAS de wordpress_db ici
```

---

## 6. Persistance des données

- Les volumes garantissent que les données survivent :
  - À l'arrêt des conteneurs
  - Au redémarrage des conteneurs
  - À la suppression des conteneurs
- Les données persistent même après `docker-compose down` (sauf avec `-v`)

---

## 7. Commandes utiles pour gérer les volumes

### Afficher la liste des volumes
```bash
docker volume ls
```

### Inspecter un volume (voir son emplacement réel)
```bash
docker volume inspect wordpress_db
docker volume inspect wordpress_files
```

### Supprimer les volumes (attention : perte de données)
```bash
docker volume rm wordpress_db wordpress_files
```

### Nettoyage complet (conteneurs + volumes)
```bash
docker-compose down -v
```

### Vérifier que les données sont bien au bon endroit
```bash
ls -la /home/login/data/wordpress_db/
ls -la /home/login/data/wordpress_files/
```

---

## 8. Permissions et propriété

- Les fichiers dans les volumes doivent avoir les bonnes permissions.
- MariaDB nécessite souvent l'utilisateur `mysql:mysql`
- WordPress nécessite souvent `www-data:www-data`
- Assurez-vous que les Dockerfiles configurent correctement les utilisateurs et permissions.

---

## 9. Récapitulatif des vérifications

| Critère | Statut |
|---------|--------|
| Deux volumes nommés (pas de bind mounts directs) | ☐ |
| Volume pour base de données MariaDB | ☐ |
| Volume pour fichiers WordPress | ☐ |
| Stockage physique dans `/home/login/data/` | ☐ |
| Volume DB monté uniquement dans MariaDB | ☐ |
| Volume WP monté uniquement dans WordPress | ☐ |
| Les données persistent après arrêt/redémarrage | ☐ |
| Permissions correctement configurées | ☐ |

---

## 10. Erreurs fréquentes à éviter

| Erreur | Pourquoi c'est interdit |
|--------|------------------------|
| `./data:/var/www/html` | Bind mount direct, pas un named volume |
| Un seul volume pour tout | Deux volumes requis (DB + fichiers) |
| Volume monté dans NGINX | NGINX n'a pas besoin de stockage persistant |
| Oubli de configurer `/home/login/data/` | Emplacement imposé par le sujet |
| Mauvais identifiant (login incorrect) | Doit correspondre à votre login 42 |

---

## 11. Exemple complet de configuration

```yaml
# docker-compose.yml
volumes:
  wordpress_db:
    driver: local
    driver_opts:
      type: none
      device: /home/wil/data/wordpress_db
      o: bind

  wordpress_files:
    driver: local
    driver_opts:
      type: none
      device: /home/wil/data/wordpress_files
      o: bind

services:
  mariadb:
    image: mariadb:custom
    volumes:
      - wordpress_db:/var/lib/mysql
    # ... autres configs

  wordpress:
    image: wordpress:custom
    volumes:
      - wordpress_files:/var/www/html
    # ... autres configs
```

---

*Document basé sur le sujet Inception version 5.2 - Partie obligatoire*