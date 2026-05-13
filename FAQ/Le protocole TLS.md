# Le protocole TLS (Transport Layer Security)

## Introduction

TLS (*Transport Layer Security*) est un protocole de sécurité utilisé pour protéger les communications sur Internet.

Son rôle principal est de :

- chiffrer les données,
- vérifier l’identité du serveur,
- garantir que les données ne sont pas modifiées pendant le transport.

TLS est utilisé presque partout sur Internet moderne :
- HTTPS,
- API,
- emails sécurisés,
- VPN,
- applications mobiles,
- jeux en ligne,
- cloud computing,
- bases de données.

---

# Pourquoi TLS est important ?

Quand des données circulent sur Internet, elles passent par plusieurs réseaux et équipements :

```text
Ordinateur → Routeur → Fournisseur Internet → Serveurs → Site Web
```

Sans protection, une personne malveillante pourrait :

- lire les données,
- voler des mots de passe,
- modifier les informations,
- espionner les communications.

TLS protège contre ces attaques.

---

# Les 3 objectifs principaux de TLS

## 1. Confidentialité (Chiffrement)

TLS chiffre les données pour empêcher leur lecture par des personnes non autorisées.

### Exemple

Sans TLS :

```text
motdepasse=123456
```

Avec TLS :

```text
A7F91B8C92D...
```

Même si quelqu’un intercepte les données, elles sont illisibles.

---

## 2. Authentification

TLS permet de vérifier que le serveur est authentique.

Quand tu visites :

```text
https://google.com
```

TLS utilise un certificat numérique pour vérifier que le serveur appartient réellement à Google.

Cela empêche certaines attaques comme :

- le phishing,
- les faux serveurs,
- les attaques Man-In-The-Middle (MITM).

---

## 3. Intégrité des données

TLS garantit que les données ne sont pas modifiées pendant leur transport.

Exemple :

- le serveur envoie :
  
```text
montant = 100€
```

- un attaquant tente de modifier :
  
```text
montant = 1000€
```

TLS détecte cette modification et bloque la connexion.

---

# Comment fonctionne TLS ?

Le fonctionnement de TLS commence par une étape appelée :

# TLS Handshake

Le "handshake" est une négociation entre :

- le client (navigateur/app),
- le serveur.

---

# Étapes simplifiées du Handshake TLS

## Étape 1 : Client Hello

Le client contacte le serveur et envoie :

- les versions TLS supportées,
- les algorithmes de chiffrement disponibles,
- des informations aléatoires.

Exemple :

```text
Bonjour serveur,
je supporte TLS 1.2 et TLS 1.3.
```

---

## Étape 2 : Server Hello

Le serveur répond :

- version TLS choisie,
- algorithme sélectionné,
- certificat numérique.

Exemple :

```text
Utilisons TLS 1.3.
Voici mon certificat.
```

---

## Étape 3 : Vérification du certificat

Le client vérifie :

- si le certificat est valide,
- s’il est signé par une autorité reconnue,
- si le nom du site correspond.

Si le certificat est faux :

```text
Connexion non sécurisée
```

---

## Étape 4 : Génération de clé secrète

Le client et le serveur créent une clé secrète commune.

Cette clé servira pour le chiffrement de la session.

---

## Étape 5 : Communication sécurisée

Toutes les données sont maintenant chiffrées.

Exemple :

```text
Navigateur <==== données chiffrées ====> Serveur
```

---

# Le chiffrement symétrique et asymétrique

TLS utilise deux types de cryptographie.

---

# 1. Chiffrement asymétrique

Utilise :

- une clé publique,
- une clé privée.

## Fonctionnement

- la clé publique chiffre,
- la clé privée déchiffre.

Avantage :
- sécurisé pour échanger des clés.

Inconvénient :
- lent.

Exemple d’algorithmes :
- RSA,
- ECC.

---

# 2. Chiffrement symétrique

Une seule clé sert à :

- chiffrer,
- déchiffrer.

Avantage :
- très rapide.

Exemples :
- AES,
- ChaCha20.

---

# Pourquoi TLS utilise les deux ?

TLS combine les avantages des deux systèmes :

| Type | Utilisation |
|---|---|
| Asymétrique | Échange sécurisé des clés |
| Symétrique | Chiffrement rapide des données |

---

# Les certificats numériques

Un certificat numérique contient :

- le nom du domaine,
- la clé publique,
- la date d’expiration,
- la signature de l’autorité de certification.

---

# Autorités de certification (CA)

Les certificats sont signés par des organismes appelés :

- Certificate Authorities (CA)

Exemples :
- Let's Encrypt,
- DigiCert,
- GlobalSign.

Les navigateurs font confiance à ces autorités.

---

# HTTPS et TLS

HTTPS signifie :

```text
HTTP + TLS
```

HTTP seul :
- pas sécurisé.

HTTPS :
- sécurisé grâce à TLS.

---

# Exemple d’une connexion HTTPS

```text
https://example.com
```

Le cadenas dans le navigateur indique généralement :

- connexion TLS active,
- certificat valide.

---

# Différence entre SSL et TLS

## SSL

Ancien protocole :
- SSL 2.0
- SSL 3.0

Aujourd’hui :
- obsolète,
- vulnérable.

---

## TLS

Version moderne et sécurisée.

Versions :
- TLS 1.0
- TLS 1.1
- TLS 1.2
- TLS 1.3

---

# TLS 1.3

TLS 1.3 est actuellement la version recommandée.

Avantages :
- plus rapide,
- plus sécurisé,
- moins complexe,
- meilleure confidentialité.

---

# Attaques contre TLS

## 1. Man-In-The-Middle (MITM)

Un attaquant intercepte la communication.

TLS réduit fortement ce risque.

---

## 2. Certificats falsifiés

Un faux certificat peut tromper l’utilisateur.

Les navigateurs modernes détectent souvent cela.

---

## 3. Anciennes versions vulnérables

TLS 1.0 et 1.1 sont considérés faibles aujourd’hui.

---

# Où TLS est utilisé ?

## Web

```text
HTTPS
```

---

## APIs

```python
requests.get("https://api.example.com")
```

---

## Emails

- SMTPS
- IMAPS
- POP3S

---

## VPN

Sécurisation du trafic réseau.

---

## Applications mobiles

Communication sécurisée avec les serveurs.

---

## Cloud Computing

Protection des échanges entre services.

---

# Exemple concret en Python

```python
import requests

response = requests.get("https://example.com")

print(response.status_code)
```

La bibliothèque utilise TLS automatiquement.

---

# Exemple concret en JavaScript

```javascript
fetch("https://api.example.com")
  .then(response => response.json())
  .then(data => console.log(data))
```

Le navigateur utilise TLS automatiquement.

---

# Avantages de TLS

## Sécurité

Protection des données sensibles.

---

## Confidentialité

Empêche l’espionnage réseau.

---

## Confiance

Permet de vérifier l’identité des serveurs.

---

## Intégrité

Empêche les modifications des données.

---

# Inconvénients de TLS

## Consommation CPU

Le chiffrement demande des ressources.

---

## Complexité

Les certificats doivent être gérés correctement.

---

## Mauvaise configuration

Une mauvaise configuration TLS peut créer des failles.

---

# Résumé

TLS est un protocole fondamental de la sécurité Internet moderne.

Il permet :

- le chiffrement,
- l’authentification,
- l’intégrité des données.

TLS protège les communications entre :
- navigateurs,
- applications,
- serveurs,
- APIs,
- services cloud.

Sans TLS, Internet moderne serait extrêmement vulnérable.

---

# Résumé ultra-court

```text
TLS = tunnel sécurisé sur Internet
```

Il protège les données contre :
- l’espionnage,
- le vol,
- la modification,
- les attaques réseau.