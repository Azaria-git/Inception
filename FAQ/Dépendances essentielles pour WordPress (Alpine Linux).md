# 🐘 PHP 8.2 – Dépendances essentielles pour WordPress (Alpine Linux)

Ce document explique le rôle de chaque module PHP utilisé dans un environnement WordPress.

---

# ⚙️ Core PHP

## php82
👉 Le cœur de PHP 8.2

- Interpréteur PHP principal
- Permet d’exécuter WordPress
- Sans lui → rien ne fonctionne ❌

---

## php82-fpm
👉 PHP FastCGI Process Manager

- Permet à PHP de fonctionner avec Nginx
- Gère les requêtes HTTP de manière performante
- Transforme PHP en service serveur (daemon)

📌 Indispensable pour architecture Nginx + PHP

---

# 🗄️ Base de données

## php82-mysqli
👉 Extension MySQL améliorée

- Connexion entre WordPress et MySQL/MariaDB
- Permet requêtes SQL sécurisées et rapides
- Utilisé pour :
  - utilisateurs
  - articles
  - paramètres WordPress

📌 Sans ça → WordPress ne peut pas se connecter à la base

---

# 🔐 Sécurité & HTTPS

## php82-openssl
👉 Support cryptographie SSL/TLS

- HTTPS (certificats SSL)
- Connexions sécurisées API
- Chiffrement de données

📌 Important pour login sécurisé + API externes

---

# 🌐 Réseau / HTTP

## php82-curl
👉 Client HTTP intégré à PHP

- Appels API externes
- Téléchargement de plugins/thèmes
- Requêtes HTTP/HTTPS

📌 Utilisé par WordPress pour :
- plugins
- updates
- services externes

---

# 📦 Archives PHP

## php82-phar
👉 PHP Archive handler

- Gestion des fichiers `.phar`
- Format d’archive PHP exécutable
- Utilisé par certains outils/plugins

---

# 🧵 Traitement texte

## php82-mbstring
👉 Multi Byte String

- Gestion des caractères UTF-8
- Support langues internationales 🌍
- Manipulation texte (emails, titres, contenu)

📌 CRUCIAL pour WordPress multilingue

---

# 🖼️ Images

## php82-gd
👉 Bibliothèque de traitement d’images

- Redimensionnement images
- Génération thumbnails
- Compression images uploadées

📌 Utilisé pour :
- médias WordPress
- miniatures articles

---

# 🔤 Encodage

## php82-iconv
👉 Conversion d’encodage texte

- UTF-8 ↔ ISO-8859-1
- Nettoyage caractères
- Compatibilité anciens systèmes

---

# 🔑 Sessions utilisateur

## php82-session
👉 Gestion des sessions PHP

- Login utilisateur WordPress
- Cookies de session
- Authentification

📌 Sans ça → login impossible ou instable

---

# 📌 Résumé global (WordPress)

| Module | Rôle |
|--------|------|
| php82 | moteur PHP |
| php82-fpm | serveur PHP pour Nginx |
| mysqli | base de données |
| openssl | sécurité HTTPS |
| curl | requêtes HTTP/API |
| phar | archives PHP |
| mbstring | UTF-8 / texte |
| gd | images |
| iconv | encodage |
| session | login utilisateur |

---

# 🧠 Conclusion

👉 WordPress n’est pas juste PHP  
👉 C’est un **écosystème complet** :

- 🗄️ base de données (mysqli)
- 🌐 réseau (curl)
- 🔐 sécurité (openssl)
- 🖼️ médias (gd)
- 🧵 texte (mbstring)
- 👤 sessions (session)

Sans ces modules → WordPress devient incomplet ou instable ⚠️