# 3. Sécurité & Protocoles

Guide complet sur TLS, OpenSSL, et les certificats SSL pour l'infrastructure WordPress.

---

## Table des matières

1. [Protocole TLS](#protocole-tls)
2. [OpenSSL : Générer certificats et clés](#openssl--générer-certificats-et-clés)
3. [Configuration TLS dans Nginx](#configuration-tls-dans-nginx)
4. [Authentification et chiffrement](#authentification-et-chiffrement)
5. [Bonnes pratiques](#bonnes-pratiques)

---

## Protocole TLS

### Qu'est-ce que TLS ?

**TLS** = Transport Layer Security

C'est un protocole de sécurité utilisé pour protéger les communications sur Internet.

```text
Anciennement appelé SSL (Secure Sockets Layer)
Aujourd'hui : TLS v1.0, v1.1, v1.2, v1.3
```

---

### Rôles principaux de TLS

| Rôle | Explication |
|------|-----------|
| **Confidentialité** | Chiffrement des données (lettres illisibles) |
| **Authentification** | Vérification que le serveur est authentique |
| **Intégrité** | Garantit que les données ne sont pas modifiées |

---

### Pourquoi TLS est important ?

Quand des données circulent sur Internet :

```text
Ordinateur → Routeur → Fournisseur Internet → Serveurs → Site Web
```

**Sans TLS**, une personne malveillante pourrait :
- Lire les données (ex: mot de passe en clair)
- Modifier les informations en transit
- Espionner les communications
- Usurper l'identité du serveur (Man-In-The-Middle)

**Avec TLS**, tout est chiffré et vérifié.

---

### Versions TLS et conformité

| Version | État | Sécurité |
|---------|------|----------|
| **TLS 1.0** | ❌ Obsolète | Vulnérabilités connues |
| **TLS 1.1** | ❌ Obsolète | Vulnérabilités connues |
| **TLS 1.2** | ✅ Minimum | Acceptable en production |
| **TLS 1.3** | ✅ Recommandé | Meilleur choix (plus rapide et sécurisé) |

**Exigence du projet Inception** : `TLS v1.2 ou v1.3 uniquement`

```nginx
# Bon
ssl_protocols TLSv1.2 TLSv1.3;

# Mauvais
ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
```

---

## TLS Handshake (Poignée de main)

### Étapes simplifiées

```text
1. Client Hello
   "Bonjour, je supporte TLS 1.2 et 1.3"
   
2. Server Hello + Certificat
   "Je suis Google.com, utilisons TLS 1.3"
   
3. Key Exchange
   "Établissons une clé symétrique secrète"
   
4. Finished
   "Connecté ! Chiffrement activé"
```

---

### Ce qu'on échange

```text
AVANT TLS :
motdepasse=123456

APRÈS TLS (données chiffrées) :
A7F91B8C92D4E1F...3K2L9M0N
```

---

## OpenSSL : Générer certificats et clés

### Qu'est-ce qu'OpenSSL ?

OpenSSL est un outil pour :
- Créer des certificats SSL/TLS
- Générer des clés privées
- Signer des certificats
- Vérifier des certificats

### Installation

#### Alpine Linux
```bash
apk add --no-cache openssl
```

#### Debian / Ubuntu
```bash
apt update && apt install -y openssl
```

---

### Concepts clés

#### Clé privée (`server.key`)
```
server.key
```
- **Secret absolu** : Ne jamais partager
- Reste sur le serveur
- Utilisée pour déchiffrer les données

#### Certificat (`server.crt`)
```
server.crt
```
- **Public** : Envoyé au navigateur
- Contient la clé publique
- Contient l'identité du serveur
- Valide la connexion TLS

---

### Générer un certificat auto-signé

Commande complète :

```bash
openssl req -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/login.42.fr.key \
    -out /etc/nginx/ssl/login.42.fr.crt \
    -subj "/C=FR/ST=State/L=City/O=42/CN=login.42.fr"
```

**Explication des paramètres :**

| Paramètre | Signification |
|-----------|--------------|
| `req` | Créer une demande de certificat (CSR) |
| `-x509` | Format X.509 (certificat auto-signé) |
| `-nodes` | Ne pas chiffrer la clé privée (pour Docker) |
| `-days 365` | Certificat valide 1 an |
| `-newkey rsa:2048` | Nouvelle clé RSA 2048 bits |
| `-keyout` | Chemin de la clé privée |
| `-out` | Chemin du certificat |
| `-subj` | Informations du certificat (sujet) |

---

### Interprétation du sujet (`-subj`)

```
/C=FR/ST=State/L=City/O=42/CN=login.42.fr
```

| Code | Signification | Exemple |
|------|--------------|---------|
| **C** | Country (Pays) | FR |
| **ST** | State (Province) | State |
| **L** | Locality (Ville) | City |
| **O** | Organization (Org) | 42 |
| **CN** | Common Name (Domaine) | login.42.fr |

---

### Vérifier un certificat

```bash
# Afficher les détails du certificat
openssl x509 -in login.42.fr.crt -text -noout

# Vérifier la validité
openssl x509 -in login.42.fr.crt -noout -dates

# Vérifier la clé
openssl rsa -in login.42.fr.key -text -noout
```

---

### Générateur dans Dockerfile

Intégrer la génération au Dockerfile Nginx :

```dockerfile
FROM alpine:3.22

RUN apk add --no-cache nginx openssl

# Créer le répertoire SSL
RUN mkdir -p /etc/nginx/ssl

# Générer le certificat auto-signé au build
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/login.42.fr.key \
    -out /etc/nginx/ssl/login.42.fr.crt \
    -subj "/C=FR/ST=State/L=City/O=42/CN=login.42.fr"

# Config Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
```

**Avantage** : Certificat généré automatiquement à chaque build

---

### Alternative : Générer dans un script d'entrée

Fichier `tools/generate_ssl.sh` :

```bash
#!/bin/bash

DOMAIN="login.42.fr"
SSL_DIR="/etc/nginx/ssl"
CERT="$SSL_DIR/$DOMAIN.crt"
KEY="$SSL_DIR/$DOMAIN.key"

# Créer le répertoire s'il n'existe pas
mkdir -p "$SSL_DIR"

# Générer le certificat s'il n'existe pas
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "Génération du certificat SSL..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY" \
        -out "$CERT" \
        -subj "/C=FR/ST=State/L=City/O=42/CN=$DOMAIN"
    echo "Certificat SSL généré avec succès"
else
    echo "Certificat SSL trouvé"
fi
```

Dans le Dockerfile :
```dockerfile
COPY tools/generate_ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_ssl.sh

CMD ["sh", "-c", "/usr/local/bin/generate_ssl.sh && nginx -g 'daemon off;'"]
```

---

## Configuration TLS dans Nginx

### Configuration minimale

```nginx
server {
    # Écouter sur port 443 (HTTPS)
    listen 443 ssl http2;
    server_name login.42.fr;
    
    # Chemins des certificats
    ssl_certificate     /etc/nginx/ssl/login.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/login.42.fr.key;
    
    # Versions TLS autorisées
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Force HTTPS pour tout
    return 301 https://$server_name$request_uri;
}
```

---

### Configuration complète sécurisée

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name login.42.fr;
    
    # Certificats SSL/TLS
    ssl_certificate     /etc/nginx/ssl/login.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/login.42.fr.key;
    
    # Versions TLS (v1.2 et v1.3 uniquement)
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Préférence des ciphers côté serveur
    ssl_prefer_server_ciphers on;
    
    # Durée de cache de la session SSL
    ssl_session_timeout 10m;
    ssl_session_cache shared:SSL:10m;
    
    # HSTS (force HTTPS pendant 1 an)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Servir les fichiers WordPress
    root /var/www/html;
    index index.php index.html;
    
    # Reverse proxy vers PHP-FPM
    location ~ \.php$ {
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_param HTTPS on;
    }
    
    # Fichiers statiques (images, CSS, JS)
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1d;
    }
}

# Redirection HTTP → HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name login.42.fr;
    return 301 https://$server_name$request_uri;
}
```

---

## Authentification et chiffrement

### Chiffrement symétrique vs asymétrique

#### Chiffrement asymétrique (clé publique/privée)
```
Message secret
    ↓
Chiffré avec clé PUBLIQUE du serveur
    ↓
Envoyé au serveur
    ↓
Déchiffré avec clé PRIVÉE du serveur (seul le serveur a cette clé)
    ↓
Message reçu
```

**Utilisé pour** : Authentification initiale, échange de clés

---

#### Chiffrement symétrique (clé secrète partagée)
```
Message secret
    ↓
Clé secrète partagée pendant le handshake
    ↓
Chiffré avec cette clé
    ↓
Déchiffré avec la même clé
    ↓
Message reçu
```

**Utilisé pour** : Communication de session (plus rapide)

---

### Flux TLS complet

```text
1. AUTHENTIFICATION (asymétrique)
   Client envoie: "Établissons une connexion sécurisée"
   Serveur envoie: Certificat avec clé PUBLIQUE
   Client vérifie: "C'est bien login.42.fr ?"
   
2. KEY EXCHANGE (asymétrique)
   Client génère une clé symétrique secrète
   Client chiffre avec clé PUBLIQUE du serveur
   Serveur déchiffre avec clé PRIVÉE
   
3. COMMUNICATION (symétrique)
   Les deux partagent maintenant la même clé secrète
   Tous les messages sont chiffrés/déchiffrés avec cette clé
   ← Plus rapide et sécurisé →
```

---

### Intégrité des données (HMAC)

TLS garantit l'intégrité avec des **codes d'authentification de messages** (HMAC) :

```
Message original: "montant = 100€"
  ↓
Hash du message: "A7F91B8C92D4..."
  ↓
Envoyé avec le message chiffré
  ↓
À la réception, recalculer le hash
  ↓
Si les hashs correspondent → Message intact ✅
Si les hashs diffèrent → Message modifié ❌ Rejeter
```

---

## Bonnes pratiques

### ✅ À faire

| Pratique | Raison |
|----------|--------|
| Utiliser TLS v1.2 minimum | Sécurité reconnue |
| Générer des certificats auto-signés en dev | Suffisant pour développement |
| Stocker la clé privée en sécurité | Accès restrictif (permissions 600) |
| Vérifier les certificats avant production | Éviter les avertissements de navigateur |
| Renouveler les certificats annuellement | Éviter l'expiration |
| Utiliser HTTPS partout | Pas d'exception |

---

### ❌ À éviter

| Mauvaise pratique | Risque |
|-------------------|--------|
| TLS v1.0/v1.1 | Vulnérabilités connues |
| Committer clés privées dans Git | Exposition de secrets |
| Certificats auto-signés en production | Avertissements utilisateur |
| HTTP mixte (HTTP + HTTPS) | Vulnérabilités |
| Certificats expirés | Blocage du navigateur |
| Partager la clé privée | Compromise totale |

---

### Permissions des fichiers

```bash
# La clé privée doit être protégée
chmod 600 /etc/nginx/ssl/login.42.fr.key

# Le certificat peut être lisible
chmod 644 /etc/nginx/ssl/login.42.fr.crt
```

---

### Teste de connexion TLS

```bash
# Test de la version TLS
openssl s_client -connect login.42.fr:443 -tls1_2

# Afficher les détails du certificat distant
openssl s_client -connect login.42.fr:443 -showcerts

# Vérifier la date d'expiration
openssl s_client -connect login.42.fr:443 | openssl x509 -noout -dates
```

---

### Curl avec certificat auto-signé

```bash
# Ignorer l'avertissement auto-signé (développement)
curl -k https://login.42.fr

# Spécifier le certificat CA
curl --cacert /path/to/login.42.fr.crt https://login.42.fr
```

---

## Checklist Sécurité

| Aspect | Vérification |
|--------|------------|
| TLS v1.2/v1.3 uniquement | ☐ |
| Certificat généré (auto-signé ok) | ☐ |
| Clé privée protégée (permissions 600) | ☐ |
| Domaine correct dans CN | ☐ |
| HTTPS forcé (redirection HTTP → HTTPS) | ☐ |
| Port 443 exposé uniquement | ☐ |
| Certificat valide et non expiré | ☐ |
| PHP-FPM communique via socket interne | ☐ |
| MariaDB non exposée au public | ☐ |

---

**Section suivante** : [Annexe - Références](Appendix-References.md)
