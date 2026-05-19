#!/bin/bash
###############################################################################
# Script d'installation de Docker sur Debian
#
# Description :
#   Ce script installe Docker Engine, Docker CLI, containerd, et les plugins
#   Docker Buildx et Docker Compose sur une distribution Debian (10+).
#
# Usage :
#   Exécuter en tant qu'utilisateur avec droits sudo :
#       sudo bash install_docker.sh
#
# Auteur : Azaria (Etudiant a 42 Antananarivo)
# Date   : 2026-03-27
###############################################################################

# 1️⃣ Mettre à jour le système
sudo apt update
sudo apt upgrade -y

# 2️⃣ Installer les dépendances nécessaires
sudo apt install -y ca-certificates curl gnupg

# 3️⃣ Créer le dossier /etc/apt/keyrings avec les droits 0755
sudo install -m 0755 -d /etc/apt/keyrings

# 4️⃣ Télécharger la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null

# 5️⃣ Modifier les permissions pour que tous les utilisateurs puissent lire la clé
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 6️⃣ Récupérer l'architecture et le nom de code de Debian
ARCH=$(dpkg --print-architecture)
. /etc/os-release
DISTRO=$VERSION_CODENAME

# 7️⃣ Construire et ajouter le dépôt Docker
DOCKER_REPO="deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $DISTRO stable"
echo "$DOCKER_REPO" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 8️⃣ Mettre à jour la liste des paquets pour inclure Docker
sudo apt update

# 9️⃣ Installer Docker et ses composants essentiels
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
