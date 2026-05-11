## Obligations sur les Dockerfiles

### 1. Base image
- Utiliser **Alpine** ou **Debian** (penultimate stable version = l'avant-dernière version stable)
- Exemple : si Debian 12 est stable, utiliser Debian 11

### 2. Nommage
- Chaque Dockerfile doit porter le nom de son service correspondant
- Un Dockerfile par service

### 3. Interdictions strictes
| Interdit | Raison |
|----------|--------|
| `latest` tag | Non reproductible |
| Pull d'images pré-construites (DockerHub) | Sauf Alpine/Debian |
| Mots de passe en clair dans le Dockerfile | Sécurité |
| Hacky patches (`tail -f`, `bash`, `sleep infinity`, `while true`) | Mauvaise gestion du PID 1 |

### 4. Construction
- Les images doivent être **buildées** via `docker-compose.yml`
- Le Makefile doit appeler `docker-compose.yml` pour la construction
- Pas de pull d'images toutes faites pour WordPress, NGINX ou MariaDB

---

## Obligations dans le Dockerfile (contenu)

### Pour NGINX
- Configuration TLSv1.2 **ou** TLSv1.3 uniquement
- Port 443 seul point d'entrée

### Pour WordPress
- Doit contenir **php-fpm** (installé et configuré)
- Absence de NGINX dans ce container

### Pour MariaDB
- Uniquement MariaDB, pas de NGINX

### Pour tous
- Aucune commande qui lance une boucle infinie
- Respect des bonnes pratiques PID 1
- Les credentials doivent passer par variables d'environnement (pas de hardcode)

---

## Résumé des commandes interdites dans les Dockerfiles/scripts

```dockerfile
# INTERDIT :
CMD tail -f /dev/null
CMD while true; do sleep 1; done
CMD bash
CMD sleep infinity
ENTRYPOINT ["tail", "-f"]
```

```dockerfile
# ACCEPTABLE (exemple pour un daemon) :
CMD ["nginx", "-g", "daemon off;"]
CMD ["php-fpm", "-F"]
CMD ["mysqld"]
```

---

## Ce qui n'est PAS imposé dans les Dockerfiles

- La méthode d'installation précise (apt/apk)
- L'ordre des instructions
- L'utilisation ou non d'entrypoint scripts (tant qu'ils respectent l'interdiction des boucles infinies)
- La taille de l'image (mais Alpine est plus petit)

---

## Vérification rapide

| Critère | Statut |
|---------|--------|
| Base = Alpine/Debian (penultimate stable) | ✅ Obligatoire |
| Pas de `latest` | ✅ Obligatoire |
| Pas de mots de passe en clair | ✅ Obligatoire |
| Pas de hacky patches | ✅ Obligatoire |
| Un Dockerfile par service | ✅ Obligatoire |
| Build via docker-compose.yml | ✅ Obligatoire |