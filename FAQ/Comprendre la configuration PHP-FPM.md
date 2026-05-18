# Comprendre la configuration PHP-FPM (`www.conf`)

Cette documentation explique en détail une configuration typique de PHP-FPM utilisée avec Docker, Nginx et WordPress.

---

# Qu’est-ce que PHP-FPM ?

PHP-FPM signifie :

```text
PHP FastCGI Process Manager
```

C’est le service qui exécute les fichiers PHP.

Quand un utilisateur visite un site WordPress :

```text
Navigateur → Nginx → PHP-FPM → PHP → WordPress
```

- Nginx reçoit la requête HTTP
- Nginx transmet les fichiers `.php` à PHP-FPM
- PHP-FPM exécute le code PHP
- WordPress génère la page
- Nginx renvoie la réponse au navigateur

---

# Configuration complète

```ini
[www]

; Utilisateur exécutant PHP-FPM
user = nobody
group = nobody

; Socket d'écoute
listen = 9000

; Permissions du socket
listen.owner = nobody
listen.group = nobody
listen.mode = 0660

; Mode de gestion des processus
pm = dynamic

; Nombre max de processus PHP
pm.max_children = 5

; Processus au démarrage
pm.start_servers = 2

; Processus minimum en attente
pm.min_spare_servers = 1

; Processus maximum en attente
pm.max_spare_servers = 3

; Logs des erreurs PHP
php_admin_flag[log_errors] = on

; Fichier log
php_admin_value[error_log] = /proc/self/fd/2

; Empêche l'exposition de la version PHP
php_admin_flag[expose_php] = off

; Répertoire courant
chdir = /

; Variables d’environnement Docker
clear_env = no
```

---

# `[www]`

```ini
[www]
```

Cette section définit un **pool PHP-FPM**.

Un pool est :

```text
Un groupe de processus PHP avec sa propre configuration
```

---

# Pourquoi utiliser des pools ?

Les pools permettent :

- d’isoler des applications
- d’avoir plusieurs configurations PHP
- de limiter les ressources
- de sécuriser différents sites

Exemple :

```ini
[wordpress]
[api]
[admin]
```

Chaque pool peut avoir :

- son utilisateur
- sa mémoire
- son port
- ses limites

Ici :

```ini
[www]
```

correspond au pool par défaut.

---

# `user` et `group`

```ini
user = nobody
group = nobody
```

Définit sous quel utilisateur Linux PHP-FPM fonctionne.

---

# Pourquoi ne pas utiliser `root` ?

Très important pour la sécurité.

Si PHP tourne en `root` :

```text
Le code PHP pourrait contrôler tout le système
```

Un attaquant pourrait :

- supprimer des fichiers
- modifier le système
- accéder aux secrets
- prendre le contrôle du conteneur

---

# Pourquoi `nobody` ?

`nobody` est :

```text
Un utilisateur Linux très limité
```

Il possède peu de permissions.

Donc :

```text
Même si PHP est compromis → dégâts limités
```

---

# `listen`

```ini
listen = 9000
```

Définit où PHP-FPM écoute les requêtes FastCGI.

Ici :

```text
Port TCP 9000
```

---

# Comment Nginx communique avec PHP-FPM

Exemple Nginx :

```nginx
location ~ \.php$ {
    fastcgi_pass wordpress:9000;
}
```

Nginx envoie les requêtes PHP vers :

```text
wordpress:9000
```

---

# Deux méthodes possibles

## 1. TCP (ici)

```ini
listen = 9000
```

Communication réseau.

Très utilisé avec Docker.

---

## 2. Socket Unix

```ini
listen = /run/php/php-fpm.sock
```

Communication via fichier Linux spécial.

Plus rapide localement.

---

# Pourquoi utiliser TCP avec Docker ?

Dans Docker :

- les conteneurs communiquent via réseau
- TCP est plus simple
- pas besoin de partager un fichier socket

Donc :

```ini
listen = 9000
```

est souvent préféré.

---

# `listen.owner`

```ini
listen.owner = nobody
listen.group = nobody
listen.mode = 0660
```

Ces paramètres servent principalement avec un socket Unix.

Exemple :

```ini
listen = /run/php/php-fpm.sock
```

---

# `listen.owner`

```ini
listen.owner = nobody
```

Propriétaire du socket.

---

# `listen.group`

```ini
listen.group = nobody
```

Groupe du socket.

---

# `listen.mode`

```ini
listen.mode = 0660
```

Permissions Linux du socket.

---

# Comprendre `0660`

Permissions Linux :

```text
rw-rw----
```

Découpage :

```text
0 6 6 0
  │ │ └─ autres
  │ └── groupe
  └──── propriétaire
```

---

# Valeurs Linux

| Valeur | Permission |
|---|---|
| 4 | lecture |
| 2 | écriture |
| 1 | exécution |

---

# Exemple

```text
6 = 4 + 2
```

Donc :

```text
lecture + écriture
```

---

# Résultat final

```text
rw-rw----
```

| Utilisateur | Accès |
|---|---|
| propriétaire | lecture/écriture |
| groupe | lecture/écriture |
| autres | aucun |

---

# `pm`

```ini
pm = dynamic
```

`pm` signifie :

```text
Process Manager
```

Définit comment PHP-FPM gère les processus PHP.

---

# Les modes disponibles

---

# 1. `static`

```ini
pm = static
```

Toujours le même nombre de processus.

Exemple :

```ini
pm.max_children = 10
```

→ 10 processus toujours actifs.

---

# Avantages

- performances stables
- prévisible

---

# Inconvénients

- consomme beaucoup de RAM

---

# 2. `dynamic` (utilisé ici)

```ini
pm = dynamic
```

PHP-FPM adapte le nombre de processus selon la charge.

---

# Fonctionnement

Quand il y a plus de trafic :

```text
PHP crée de nouveaux processus
```

Quand le trafic diminue :

```text
PHP détruit les processus inutiles
```

---

# Avantages

- bon équilibre
- flexible
- idéal pour petits serveurs

---

# 3. `ondemand`

```ini
pm = ondemand
```

Les processus sont créés uniquement lorsqu’une requête arrive.

---

# Avantages

- économise beaucoup de RAM

---

# Inconvénients

- première requête plus lente

---

# `pm.max_children`

```ini
pm.max_children = 5
```

Nombre maximum de processus PHP simultanés.

---

# Cela signifie

```text
5 requêtes PHP maximum en même temps
```

---

# Exemple

Si :

- 5 utilisateurs chargent WordPress
- chaque requête utilise un processus

alors :

```text
Le serveur est plein
```

Une 6ème requête devra attendre.

---

# Impact sur les performances

## Trop bas

```text
Le site ralentit
```

---

## Trop haut

```text
Le serveur manque de RAM
```

---

# Comment choisir ?

Dépend :

- de la RAM disponible
- du poids WordPress
- des plugins
- du trafic

---

# `pm.start_servers`

```ini
pm.start_servers = 2
```

Nombre de processus créés au démarrage.

---

# Pourquoi ?

Pour éviter :

```text
Une attente lors de la première requête
```

---

# `pm.min_spare_servers`

```ini
pm.min_spare_servers = 1
```

Nombre minimum de processus libres.

---

# Signification

PHP garde toujours :

```text
Au moins 1 processus prêt
```

---

# `pm.max_spare_servers`

```ini
pm.max_spare_servers = 3
```

Nombre maximum de processus inutilisés.

---

# Pourquoi ?

Si trop de processus sont inactifs :

```text
PHP-FPM les supprime
```

pour économiser la RAM.

---

# `php_admin_flag[log_errors]`

```ini
php_admin_flag[log_errors] = on
```

Active les logs d’erreurs PHP.

Très important.

---

# Sans logs

Tu ne vois pas :

- erreurs PHP
- erreurs WordPress
- problèmes plugins
- bugs

---

# Avec logs

Tu peux déboguer facilement.

---

# `php_admin_value[error_log]`

```ini
php_admin_value[error_log] = /proc/self/fd/2
```

Très important dans Docker.

---

# Comprendre `/proc/self/fd/2`

Sous Linux :

| Fichier | Signification |
|---|---|
| `/proc/self/fd/0` | stdin |
| `/proc/self/fd/1` | stdout |
| `/proc/self/fd/2` | stderr |

---

# `stderr`

Correspond à :

```text
La sortie d’erreur du conteneur
```

---

# Résultat

Les erreurs PHP apparaissent avec :

```bash
docker logs mon_container
```

---

# Pourquoi c’est important ?

Docker fonctionne mieux quand :

```text
Les logs sont envoyés vers stdout/stderr
```

Pas dans des fichiers classiques.

---

# `php_admin_flag[expose_php]`

```ini
php_admin_flag[expose_php] = off
```

Empêche PHP d’exposer sa version.

---

# Sans cette option

Le serveur peut envoyer :

```http
X-Powered-By: PHP/8.2.0
```

---

# Pourquoi c’est dangereux ?

Un attaquant peut :

- identifier la version PHP
- chercher des vulnérabilités connues

---

# Avec `off`

L’en-tête disparaît.

Plus sécurisé.

---

# `chdir`

```ini
chdir = /
```

Définit le dossier courant des processus PHP.

---

# Ici

```text
/
```

correspond à :

```text
La racine Linux
```

---

# Pourquoi ?

Évite certains problèmes de chemins relatifs.

Souvent utilisé dans Docker.

---

# `clear_env`

```ini
clear_env = no
```

Très important dans Docker.

---

# Par défaut

PHP-FPM supprime les variables d’environnement :

```ini
clear_env = yes
```

---

# Problème

Les variables Docker deviennent invisibles :

```bash
MYSQL_HOST
MYSQL_USER
WORDPRESS_DB_PASSWORD
```

---

# Avec `clear_env = no`

PHP peut lire les variables Docker.

---

# Exemple Docker

```yaml
environment:
  MYSQL_HOST: mariadb
```

---

# Exemple PHP

```php
echo getenv("MYSQL_HOST");
```

Résultat :

```text
mariadb
```

---

# Pourquoi c’est utile ?

Très utilisé pour :

- WordPress
- Laravel
- Symfony
- configuration Docker
- secrets
- mots de passe

---

# Architecture complète

```text
                ┌──────────────┐
                │ Navigateur   │
                └──────┬───────┘
                       │ HTTP/HTTPS
                       ▼
                ┌──────────────┐
                │ Nginx        │
                └──────┬───────┘
                       │ FastCGI
                       ▼
                ┌──────────────┐
                │ PHP-FPM      │
                └──────┬───────┘
                       │ PHP
                       ▼
                ┌──────────────┐
                │ WordPress    │
                └──────┬───────┘
                       │ SQL
                       ▼
                ┌──────────────┐
                │ MariaDB      │
                └──────────────┘
```

---

# Résumé rapide

| Configuration | Rôle |
|---|---|
| `user/group` | utilisateur Linux PHP |
| `listen` | port FastCGI |
| `pm` | gestion des processus |
| `pm.max_children` | limite des processus |
| `log_errors` | active les logs |
| `error_log` | logs Docker |
| `expose_php` | cache version PHP |
| `clear_env` | variables Docker |

---

# Conclusion

Cette configuration PHP-FPM est :

- légère
- adaptée à Docker
- sécurisée
- simple à comprendre
- parfaite pour WordPress
- bonne pour apprendre l’architecture web moderne
