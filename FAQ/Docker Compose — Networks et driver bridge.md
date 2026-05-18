# 🐳 Docker Compose — Networks et driver bridge

## 📌 Introduction

Dans Docker Compose, la section `networks` permet de créer et organiser les réseaux entre conteneurs.

Un réseau Docker est un **réseau virtuel privé** qui permet aux conteneurs de :

- communiquer entre eux
- se découvrir par nom
- être isolés des autres conteneurs

---

## 🧱 Exemple étudié

```yaml
networks:
  inception-network:
    driver: bridge
````

---

## 🔎 Explication ligne par ligne

### 1. `networks:`

C’est la section principale où on définit tous les réseaux du projet Docker Compose.

---

### 2. `inception-network:`

C’est le **nom du réseau**.

👉 Tous les conteneurs qui utilisent ce réseau seront connectés ensemble.

Exemple :

* nginx
* wordpress
* mariadb

s’ils utilisent `inception-network`, ils peuvent communiquer.

---

### 3. `driver: bridge`

C’est le type de réseau utilisé.

Le driver `bridge` est le **réseau Docker par défaut sur une machine**.

---

## 🌉 C’est quoi un réseau bridge ?

Un réseau `bridge` est un **réseau virtuel isolé sur une machine Docker**.

Il fonctionne comme un **switch réseau virtuel** :

```
nginx ----\
           >  bridge network (switch virtuel)
wordpress --/
mariadb ---/
```

Tous les conteneurs connectés peuvent communiquer entre eux.

---

## 🔥 Ce que permet le driver bridge

✔ Communication entre conteneurs
✔ Isolation des autres réseaux
✔ DNS automatique (nom du service = hostname)
✔ Réseau privé sur la même machine

---

## 🧠 Exemple concret

```yaml
services:
  nginx:
    image: nginx
    networks:
      - inception-network

  wordpress:
    image: wordpress
    networks:
      - inception-network

networks:
  inception-network:
    driver: bridge
```

---

## 🌐 Résultat

Dans ce cas :

* `nginx` peut appeler `wordpress` avec :

  ```
  http://wordpress
  ```

* `wordpress` peut appeler la base de données :

  ```
  mariadb
  ```

👉 Sans connaître les IPs.

---

## 🧭 Pourquoi utiliser un réseau personnalisé ?

Docker crée déjà un réseau `bridge` par défaut, mais un réseau personnalisé est meilleur.

### ✔ Avantages :

* meilleure organisation
* sécurité (isolation des projets)
* communication plus simple (DNS interne)
* séparation backend / frontend / database

---

## 🔐 Isolation des réseaux

Les conteneurs dans des réseaux différents :

❌ ne peuvent pas communiquer entre eux

Exemple :

* réseau A : frontend
* réseau B : database

Ils sont séparés automatiquement.

---

## 🧪 Ce que fait Docker en interne

Quand tu crées ce réseau, Docker :

* crée un bridge Linux
* assigne des IPs aux conteneurs
* configure un DNS interne
* applique des règles réseau (iptables)

---

## ⚡ Résumé simple

```text
driver: bridge = réseau privé local entre conteneurs
```

✔ Même machine
✔ Communication facile
✔ Isolation des autres projets
✔ DNS automatique

---

## 🧩 À retenir

👉 `networks` = définition des réseaux
👉 `inception-network` = nom du réseau
👉 `bridge` = type de réseau local Docker

---

## 🚀 Conclusion

Le bloc :

```yaml
networks:
  inception-network:
    driver: bridge
```

signifie simplement :

> "Créer un réseau privé Docker (bridge) pour connecter mes conteneurs entre eux de manière isolée et simple."