# Guide Complet du Projet Inception

Table des matières pour la mise en place d'une infrastructure WordPress en Docker (3 conteneurs).

---

## 📋 Structure de ce guide

Ce guide est organisé en 4 sections principales :

### 1. **[Configuration & Infrastructure](1-Configuration-Infrastructure.md)**
   - Choix de l'image de base (Alpine vs Debian)
   - Configuration NGINX (TLS, reverse proxy)
   - Configuration PHP-FPM (www.conf)
   - Configuration des volumes Docker
   - Réseaux Docker (bridge driver)

### 2. **[Services & Dépendances](2-Services-Dependances.md)**
   - Extensions PHP essentielles pour WordPress
   - Configuration de chaque module PHP
   - Règles des Dockerfiles (bonnes pratiques)
   - Dépendances pour chaque service (Nginx, PHP-FPM, MariaDB)

### 3. **[Sécurité & Protocoles](3-Securite.md)**
   - Protocole TLS (v1.2, v1.3)
   - OpenSSL : générer certificats et clés
   - Authentification et chiffrement
   - Bonnes pratiques de sécurité

### 4. **[Références & Ressources](Appendix-References.md)**
   - État des versions Alpine Linux
   - État des versions Debian
   - Installation de Docker
   - Liens utiles (OpenSSL, Docker Compose)

---

## 🎯 Architecture cible

```
┌─────────────────────────────────────────────────┐
│  Hôte (127.0.0.1 / login.42.fr)               │
│  Port 443 (HTTPS uniquement)                   │
└────────────────┬────────────────────────────────┘
                 │
    ┌────────────────────────────┐
    │   Réseau: inception-network │ (bridge driver)
    │                             │
    │  ┌─────────────┐  ┌──────────────────┐
    │  │  Nginx      │  │ WordPress (PHP-  │
    │  │  (Alpine)   │──│   FPM) (Alpine/  │
    │  │  Port 443   │  │   Debian)        │
    │  │  TLS v1.2/3 │  │  Port 9000 (int) │
    │  └─────────────┘  │                  │
    │                   └─────────┬────────┘
    │                             │
    │                   ┌─────────▼────────┐
    │                   │  MariaDB (Debian)│
    │                   │  Port 3306 (int) │
    │                   │                  │
    │                   └──────────────────┘
    │
    │ Volumes nommés:
    │ - wordpress_db    (/var/lib/mysql)
    │ - wordpress_files (/var/www/html)
    └────────────────────────────────────────┘
```

---

## ✅ Checklist pré-déploiement

Avant de démarrer le projet, vérifiez que vous avez :

- [ ] Docker et Docker Compose installés
- [ ] Identifiant 42 récupéré (ex: `login`)
- [ ] Domaine local configuré (`/etc/hosts` : `127.0.0.1 login.42.fr`)
- [ ] Répertoire `/home/login/data/` créé
- [ ] Connaissances des 3 images de base : Alpine, Debian, MariaDB
- [ ] Compris les 3 sections principales de ce guide

---

## 🚀 Démarrage rapide

```bash
# Cloner / préparer le projet
cd ~/Inception
make build

# Démarrer les conteneurs
make up

# Vérifier les logs
docker-compose logs -f

# Tester
curl -k https://login.42.fr
```

---

## 📚 Comment utiliser ce guide

1. **Commencez par [Configuration & Infrastructure](1-Configuration-Infrastructure.md)** pour comprendre les choix architecturaux
2. **Puis [Services & Dépendances](2-Services-Dependances.md)** pour les détails de chaque service
3. **Consultez [Sécurité](3-Securite.md)** pour les aspects TLS et SSL
4. **Référez-vous à [Appendix](Appendix-References.md)** pour les versions et ressources

---

## 🔑 Concepts clés

| Concept | Explication rapide |
|---------|-------------------|
| **Alpine** | Image très légère (~5 Mo), idéale pour Nginx, possible pour PHP/WordPress |
| **Debian** | Image plus grande (~80-200 Mo), recommandée pour MariaDB, plus compatible |
| **TLS** | Protocole de sécurité pour HTTPS (v1.2 ou v1.3 obligatoire) |
| **PHP-FPM** | Gestionnaire de processus FastCGI pour exécuter PHP avec Nginx |
| **Named Volumes** | Volumes Docker nommés pour la persistance (obligatoire, pas de bind mounts) |
| **Bridge Network** | Réseau virtuel privé pour la communication entre conteneurs |

---

## ⚠️ Pièges courants

- ❌ Utiliser l'image `latest` → ✅ Spécifier une version exacte
- ❌ Mettre des mots de passe en dur dans Dockerfile → ✅ Utiliser variables d'environnement
- ❌ Garder d'anciennes versions Alpine/Debian → ✅ Utiliser avant-dernière version stable
- ❌ Utiliser des commandes infinies (`tail -f`, `sleep infinity`) → ✅ Laisser le service s'exécuter normalement
- ❌ Exposer MariaDB et WordPress directement → ✅ Passer uniquement par Nginx

---

## 📞 Support et dépannage

Pour chaque problème :

1. **Vérifiez les logs** : `docker-compose logs <service>`
2. **Consultez la section pertinente** de ce guide
3. **Testez manuellement** : `docker exec -it <container> sh/bash`

---

**Dernière mise à jour** : Mai 2026  
**État** : Documentation consolidée et complète
