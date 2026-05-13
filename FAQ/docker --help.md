# Docker — Explication complète de `docker --help`

Docker est une plateforme qui permet de créer, lancer et gérer des **conteneurs**.

Un conteneur est un environnement isolé contenant :
- une application
- ses dépendances
- sa configuration
- parfois un système minimal Linux

---

# 📦 Structure générale

Commande de base :

```bash
docker [OPTIONS] COMMAND
````

Exemple :

```bash
docker run nginx
```

Ici :

* `docker` = programme principal
* `run` = commande
* `nginx` = image utilisée

---

# 🧠 Concept important : les 3 objets principaux Docker

| Objet     | Description                                      |
| --------- | ------------------------------------------------ |
| Image     | Template immuable servant à créer des conteneurs |
| Container | Instance en exécution d’une image                |
| Volume    | Espace persistant pour sauvegarder les données   |

---

# 📚 Common Commands (les commandes les plus utilisées)

---

# 🚀 docker run

```bash
docker run nginx
```

## Rôle

Créer ET lancer un conteneur.

Docker va :

1. chercher l’image
2. créer un container
3. lancer le process principal

## Exemple

```bash
docker run -p 8080:80 nginx
```

Cela :

* lance nginx
* expose le port 80 du container
* vers le port 8080 de la machine

Accès :

```txt
localhost:8080
```

---

# ⚙️ docker exec

```bash
docker exec
```

## Rôle

Exécuter une commande dans un container déjà lancé.

## Exemple

```bash
docker exec -it mycontainer bash
```

Explication :

* `-i` = mode interactif
* `-t` = terminal
* `bash` = shell lancé

Tu entres DANS le container.

Très utilisé pour :

* debug
* inspection
* tests

---

# 📋 docker ps

```bash
docker ps
```

## Rôle

Afficher les containers actifs.

## Exemple sortie

```txt
CONTAINER ID   IMAGE   COMMAND   STATUS
```

---

## Voir tous les containers

```bash
docker ps -a
```

Même les stoppés.

---

# 🏗 docker build

```bash
docker build .
```

## Rôle

Construire une image depuis un Dockerfile.

Docker lit :

```txt
Dockerfile
```

et crée une image.

---

## Exemple

```bash
docker build -t myimage .
```

* `-t` = tag (nom de l’image)
* `.` = dossier courant

---

# 📥 docker pull

```bash
docker pull nginx
```

## Rôle

Télécharger une image depuis Docker Hub.

Equivalent à :

```txt
apt install
```

mais pour Docker.

---

# 📤 docker push

```bash
docker push myimage
```

## Rôle

Envoyer une image vers un registre Docker.

Souvent :

* Docker Hub
* GitHub Container Registry

---

# 🖼 docker images

```bash
docker images
```

## Rôle

Lister les images locales.

---

# 🔐 docker login

```bash
docker login
```

## Rôle

Connexion à Docker Hub.

Permet :

* push
* pull privé

---

# 🚪 docker logout

Déconnexion.

---

# 🔎 docker search

```bash
docker search nginx
```

## Rôle

Chercher des images sur Docker Hub.

---

# ℹ️ docker version

```bash
docker version
```

## Rôle

Afficher :

* version client
* version daemon

---

# 🧾 docker info

```bash
docker info
```

## Rôle

Informations complètes du système Docker :

* stockage
* réseau
* containers
* images
* volumes

Très utile en debug.

---

# 🛠 Management Commands

---

# 🏗 docker builder

Gestion du système de build Docker.

Rarement utilisé au début.

---

# ⚡ docker buildx

Version moderne du build Docker.

Permet :

* multi-architecture
* cache avancé
* build optimisé

Très important plus tard.

---

# 🧩 docker compose

Très important 🔥

Permet de lancer plusieurs services ensemble.

Exemple :

* nginx
* wordpress
* mariadb

avec un seul fichier :

```yaml
docker-compose.yml
```

Puis :

```bash
docker compose up
```

---

# 📦 docker container

Gestion avancée des containers.

Exemple :

```bash
docker container ls
```

équivalent à :

```bash
docker ps
```

---

# 🖼 docker image

Gestion avancée des images.

Exemple :

```bash
docker image rm nginx
```

---

# 🌐 docker network

Gestion des réseaux Docker.

Permet aux containers de communiquer.

---

# 💾 docker volume

Gestion des volumes.

IMPORTANT pour Inception 🔥

Les volumes servent à :

* conserver les données
* même si le container est supprimé

Exemple :

* base de données MariaDB
* fichiers WordPress

---

# ⚙️ docker system

Nettoyage global Docker.

Exemple :

```bash
docker system prune
```

Supprime :

* containers stoppés
* images inutilisées
* cache

---

# 🧱 Swarm

```bash
docker swarm
```

Mode orchestration Docker.

Pas utilisé dans Inception.

---

# 📚 Commandes détaillées

---

# 📎 docker attach

Se connecter au terminal principal du container.

Différence avec exec :

* attach = process principal
* exec = nouveau process

---

# 💾 docker commit

Créer une image depuis un container modifié.

Peu utilisé en production.

---

# 📂 docker cp

Copier des fichiers :

* host → container
* container → host

Exemple :

```bash
docker cp file.txt mycontainer:/tmp
```

---

# 🔨 docker create

Créer un container SANS le lancer.

---

# 🔍 docker diff

Voir les fichiers modifiés dans un container.

---

# 📡 docker events

Voir les événements Docker en temps réel.

---

# 📦 docker export

Exporter le filesystem d’un container.

---

# 🕘 docker history

Historique des layers d’une image.

Très utile pour comprendre :

* taille
* couches
* optimisation

---

# 📥 docker import

Importer un filesystem comme image.

---

# 🔎 docker inspect

Commande ULTRA IMPORTANTE 🔥

Affiche :

* IP
* volumes
* réseau
* config JSON complète

Exemple :

```bash
docker inspect mycontainer
```

---

# ☠️ docker kill

Stop brutal.

Equivalent :

```txt
SIGKILL
```

---

# 📥 docker load

Charger une image depuis un `.tar`.

---

# 📜 docker logs

Voir les logs d’un container.

Très important.

Exemple :

```bash
docker logs mycontainer
```

---

## Suivre en temps réel

```bash
docker logs -f mycontainer
```

---

# ⏸ docker pause

Mettre en pause les process.

---

# 🌐 docker port

Voir les ports exposés.

---

# ✏️ docker rename

Renommer un container.

---

# 🔄 docker restart

Redémarrer un container.

---

# ❌ docker rm

Supprimer un container.

---

# 🗑 docker rmi

Supprimer une image.

---

# 💽 docker save

Exporter une image en `.tar`.

---

# ▶️ docker start

Lancer un container déjà existant.

---

# 📊 docker stats

Voir :

* CPU
* RAM
* réseau

en temps réel.

Très utile.

---

# 🛑 docker stop

Arrêt propre.

Envoie :

```txt
SIGTERM
```

puis :

```txt
SIGKILL
```

si nécessaire.

---

# 🏷 docker tag

Créer un alias/tag d’image.

---

# 🔝 docker top

Voir les process du container.

Equivalent de :

```bash
ps aux
```

dans le container.

---

# ▶️ docker unpause

Retirer la pause.

---

# ⚙️ docker update

Modifier :

* RAM
* CPU
* limites

d’un container existant.

---

# ⏳ docker wait

Attendre la fin d’un container.

Très utilisé dans les scripts.

---

# 🌍 Global Options

---

# --config

Changer le dossier de configuration Docker.

---

# --context

Changer de contexte Docker.

Exemple :

* local
* serveur distant

---

# -D / --debug

Activer le mode debug.

---

# -H / --host

Changer le socket Docker.

Exemple :

```txt
unix:///var/run/docker.sock
```

---

# --tls

Activer TLS.

---

# --tlsverify

Vérifier les certificats TLS.

---

# -v / --version

Afficher la version.

---

# 🧠 Architecture Docker

```txt
Docker Client
      ↓
Docker Daemon
      ↓
Containers
```

---

# 🔥 Workflow classique Docker

---

## 1. Créer Dockerfile

```Dockerfile
FROM debian:12
RUN apt update
```

---

## 2. Build image

```bash
docker build -t myimage .
```

---

## 3. Lancer container

```bash
docker run myimage
```

---

# 📦 Cycle de vie d’un container

```txt
Image
  ↓
Container créé
  ↓
Container lancé
  ↓
Container stoppé
  ↓
Container supprimé
```

---

# 🧠 Très important pour Inception

Tu vas surtout utiliser :

| Commande       | Importance |
| -------------- | ---------- |
| docker build   | 🔥🔥🔥     |
| docker run     | 🔥🔥🔥     |
| docker ps      | 🔥🔥       |
| docker exec    | 🔥🔥🔥     |
| docker logs    | 🔥🔥🔥     |
| docker compose | 🔥🔥🔥🔥   |
| docker volume  | 🔥🔥🔥     |
| docker network | 🔥🔥       |

---

# 🚀 Commandes essentielles à mémoriser

```bash
docker build -t myimage .
docker run myimage
docker ps
docker ps -a
docker images
docker exec -it container bash
docker logs -f container
docker stop container
docker rm container
docker rmi image
docker compose up
docker compose down
```
