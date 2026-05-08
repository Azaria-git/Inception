# Installation de Docker

Docker peut être installé de différentes façons selon le système d’exploitation utilisé.

Dans mon cas, j’ai utilisé la méthode :

- **Installation par paquets Linux**  
  Utilisation des gestionnaires de paquets natifs comme :
  - `APT`
  - `YUM`
  - `DNF`

## Documentation officielle

[Méthode officielle d’installation](https://docs.docker.com/engine/install/#other-linux-distros)

---

# Installation de Docker sur Debian

## 1️⃣ Mettre à jour le système

```bash
sudo apt update
sudo apt upgrade -y
````

---

## 2️⃣ Installer les dépendances nécessaires

```bash
sudo apt install -y ca-certificates curl gnupg
```

---

## 3️⃣ Créer le dossier `/etc/apt/keyrings`

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

---

## 4️⃣ Télécharger la clé GPG officielle de Docker

```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
```

---

## 5️⃣ Modifier les permissions de la clé

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

---

## 6️⃣ Récupérer l’architecture et le nom de code Debian

```bash
ARCH=$(dpkg --print-architecture)
. /etc/os-release
DISTRO=$VERSION_CODENAME
```

---

## 7️⃣ Ajouter le dépôt Docker

```bash
DOCKER_REPO="deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $DISTRO stable"

echo "$DOCKER_REPO" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

## 8️⃣ Mettre à jour la liste des paquets

```bash
sudo apt update
```

---

## 9️⃣ Installer Docker et ses composants essentiels

```bash
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

---

# Script d’installation

Le script utilisé pour automatiser l’installation :

[install_docker.sh](install_docker.sh)
