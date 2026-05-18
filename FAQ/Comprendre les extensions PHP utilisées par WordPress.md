# Comprendre les extensions PHP utilisées par WordPress

WordPress est développé en PHP.  
Pour fonctionner correctement, il a besoin de plusieurs extensions PHP qui ajoutent différentes fonctionnalités.

---

# 1. php82

## Rôle

C’est le moteur principal PHP 8.2.

Sans lui :
- WordPress ne peut pas exécuter les fichiers `.php`
- aucune page dynamique ne fonctionne

## Exemple

```text
index.php -> exécuté par PHP
````

---

# 2. php82-fpm

## Signification

FPM = FastCGI Process Manager

## Rôle

Permet à Nginx de communiquer avec PHP.

Nginx ne sait pas exécuter PHP directement.
Il transmet les fichiers `.php` à PHP-FPM.

## Architecture

```text
Navigateur
    ↓
Nginx
    ↓
PHP-FPM
    ↓
WordPress
```

## Sans lui

Nginx affiche le code PHP au lieu de l’exécuter.

---

# 3. php82-mysqli

## Rôle

Permet à PHP de communiquer avec MySQL/MariaDB.

WordPress stocke dans la base de données :

* utilisateurs
* articles
* pages
* réglages
* plugins

## Sans lui

Erreur classique :

```text
Error establishing a database connection
```

---

# 4. php82-json

## Rôle

Permet de lire et créer du JSON.

WordPress utilise JSON pour :

* l’API REST
* Gutenberg
* AJAX
* échanges frontend/backend

## Exemple

```json
{
  "title": "Bonjour"
}
```

## Sans lui

Certaines fonctionnalités modernes de WordPress cassent.

---

# 5. php82-openssl

## Rôle

Ajoute le support SSL/TLS.

Utilisé pour :

* HTTPS
* connexions sécurisées
* téléchargement des plugins
* mises à jour WordPress

## Sans lui

* problèmes HTTPS
* échec des mises à jour
* API externes cassées

---

# 6. php82-curl

## Rôle

Permet d’envoyer des requêtes HTTP.

WordPress l’utilise pour :

* télécharger des plugins
* appeler des API
* mises à jour automatiques
* webhooks

## Exemple

```text
WordPress -> wordpress.org
```

## Sans lui

Certaines connexions réseau échouent.

---

# 7. php82-phar

## Signification

PHAR = PHP Archive

## Rôle

Permet de gérer des archives PHP.

Utilisé par :

* Composer
* certains plugins
* outils PHP

## Remarque

Pas toujours indispensable pour WordPress de base.

---

# 8. php82-mbstring

## Signification

MB = MultiByte String

## Rôle

Gère correctement les caractères UTF-8 :

* accents
* emojis
* langues asiatiques

## Important pour

* internationalisation
* sécurité
* manipulation de texte

## Sans lui

* caractères cassés
* problèmes d’encodage

---

# 9. php82-gd

## Rôle

Bibliothèque de traitement d’images.

WordPress l’utilise pour :

* créer des miniatures
* redimensionner les images
* recadrer les images

## Exemple

```text
photo.jpg -> thumbnail.jpg
```

## Sans lui

Les images et miniatures ne fonctionnent pas correctement.

---

# 10. php82-iconv

## Rôle

Convertit les encodages de texte.

Exemples :

* UTF-8
* ISO-8859-1

## Utilisé pour

* emails
* imports/export
* compatibilité fichiers

---

# 11. php82-session

## Rôle

Permet de stocker des données temporaires utilisateur.

Utilisé par :

* connexions utilisateur
* plugins
* paniers e-commerce
* formulaires

## Exemple

```text
Utilisateur connecté -> session active
```

## Sans lui

Certains plugins ne fonctionnent plus correctement.

---

# Extensions indispensables

## Minimum recommandé

```bash
php82
php82-fpm
php82-mysqli
php82-json
php82-curl
php82-openssl
php82-mbstring
```

---

# Extensions très utiles

```bash
php82-gd
php82-iconv
php82-session
```

---

# Extensions parfois optionnelles

```bash
php82-phar
```

---

# Exemple Alpine Linux pour WordPress

```dockerfile
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-openssl \
    php82-curl \
    php82-phar \
    php82-mbstring \
    php82-gd \
    php82-iconv \
    php82-session
```

---

# Résumé rapide

| Extension      | Utilité principale        |
| -------------- | ------------------------- |
| php82          | moteur PHP                |
| php82-fpm      | communication Nginx ↔ PHP |
| php82-mysqli   | base de données MySQL     |
| php82-json     | API et échanges JSON      |
| php82-openssl  | HTTPS / SSL               |
| php82-curl     | requêtes HTTP             |
| php82-phar     | archives PHP              |
| php82-mbstring | UTF-8 / accents           |
| php82-gd       | traitement d’images       |
| php82-iconv    | conversion encodage       |
| php82-session  | sessions utilisateur      |

---

# Extensions souvent ajoutées en plus

| Extension       | Utilité              |
| --------------- | -------------------- |
| php82-zip       | gestion ZIP          |
| php82-xml       | XML                  |
| php82-dom       | HTML/XML             |
| php82-fileinfo  | détection fichiers   |
| php82-simplexml | parsing XML          |
| php82-exif      | métadonnées images   |
| php82-intl      | internationalisation |