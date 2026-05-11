# Règles des Dockerfiles - Projet Inception

Ce document répertorie l'ensemble des règles concernant les Dockerfiles dans le cadre du projet Inception de 42, ainsi que leurs justifications pédagogiques et techniques.

---

## 1. Nommage des images

**Règle :** Chaque image Docker doit avoir le même nom que son service correspondant.

**Avantage :** Simplifie la gestion et l'identification des conteneurs. Lorsqu'un conteneur plante, on sait immédiatement quel service est concerné.

**Pourquoi cette règle :** Dans une infrastructure multi-conteneurs, la clarté est primordiale. Un nommage cohérent évite les confusions lors du débogage et facilite la maintenance. C'est une bonne pratique d'organisation de code.

---

## 2. Base image : Alpine ou Debian (avant-dernière version stable)

**Règle :** Les conteneurs doivent être construits à partir de la version stable avant-dernière d'Alpine ou Debian.

**Avantage :** Équilibre parfait entre stabilité et sécurité. Les dernières versions peuvent contenir des bugs non détectés, tandis que les versions trop anciennes manquent de correctifs de sécurité.

**Pourquoi cette règle :** Cette contrainte vous oblige à réfléchir au choix de votre base image. Elle vous habitue à ne pas prendre systématiquement la toute dernière version, ce qui est une mauvaise pratique en production. Les environnements professionnels privilégient la stabilité.

---

## 3. Interdiction du tag `latest`

**Règle :** Le tag `latest` est interdit.

**Avantage :** Garantit la reproductibilité des builds. L'image que vous construisez aujourd'hui sera identique dans 6 mois.

**Pourquoi cette règle :** Le tag `latest` est dynamique : il pointe vers des versions différentes au fil du temps. Si vous reconstruisez votre projet plus tard avec `latest`, vous obtiendrez potentiellement une version différente, source de bugs imprévisibles. Docker recommande d'utiliser des tags explicites. Cette règle vous prépare à gérer des versions précises en production.

---

## 4. Interdiction de pull des images toutes prêtes

**Règle :** Il est interdit de télécharger des images Docker toutes prêtes depuis DockerHub (sauf Alpine/Debian).

**Avantage :** Vous comprenez exactement ce qui se trouve dans vos conteneurs. Vous maîtrisez chaque couche.

**Pourquoi cette règle :** L'objectif pédagogique d'Inception est que vous appreniez à **construire** vos images, pas à les utiliser. En écrivant vos propres Dockerfiles pour WordPress, NGINX et MariaDB, vous comprenez comment ces services s'installent et se configurent. C'est la différence entre utilisateur et administrateur système.

---

## 5. Pas de mots de passe en dur dans les Dockerfiles

**Règle :** Aucun mot de passe ne doit être présent dans les Dockerfiles.

**Avantage :** Les mots de passe ne sont pas exposés dans votre historique Git ni dans l'image finale.

**Pourquoi cette règle :** Un Dockerfile est souvent versionné (Git). Un mot de passe écrit en dur devient public si le dépôt est accessible. De plus, l'image construite contient ce mot de passe en clair dans ses couches (accessibles via `docker history`). C'est une faille de sécurité critique. La règle vous oblige à utiliser des variables d'environnement ou Docker Secrets.

---

## 6. Interdiction des hacky patches (`tail -f`, `bash`, `sleep infinity`, `while true`)

**Règle :** Sont interdits : `tail -f`, `bash`, `sleep infinity`, `while true` et toute boucle infinie.

**Avantage :** Les conteneurs s'arrêtent proprement (graceful shutdown) et répondent aux signaux système (SIGTERM, SIGINT).

**Pourquoi cette règle :** Beaucoup d'étudiants utilisent `tail -f /dev/null` ou `sleep infinity` pour maintenir artificiellement un conteneur en vie. C'est une mauvaise pratique car :
- Le processus principal n'est pas le service attendu (NGINX, PHP-FPM, MariaDB)
- Les signaux d'arrêt ne sont pas correctement propagés
- Le conteneur ne peut pas redémarrer automatiquement après un crash
- Cela cache une mauvaise compréhension de comment les daemons fonctionnent

Un bon conteneur exécute directement le service comme processus principal (PID 1).

---

## 7. Pas de boucle infinie dans CMD / ENTRYPOINT

**Règle :** Les conteneurs ne doivent pas être démarrés avec une commande exécutant une boucle infinie.

**Avantage :** Le conteneur fait exactement ce qu'il doit faire : exécuter un service, pas une astuce.

**Pourquoi cette règle :** Cette règle est un corollaire de la précédente. Un conteneur Docker doit exécuter un seul processus (le service) de premier plan (foreground). Par exemple, `nginx -g 'daemon off;'` ou `php-fpm -F` exécutent le service sans boucle artificielle. La règle vous force à comprendre cette architecture fondamentale.

---

## 8. Référence au PID 1 et aux bonnes pratiques

**Règle :** Lisez la documentation sur PID 1 et les bonnes pratiques pour écrire des Dockerfiles.

**Avantage :** Vous produisez des conteneurs robustes, capables de gérer correctement les arrêts, les redémarrages et les signaux.

**Pourquoi cette règle :** Le PID 1 dans un conteneur a un comportement spécial : il ignore les signaux par défaut si le processus n'est pas programmé pour les gérer. Cela peut empêcher `docker stop` de fonctionner correctement. Comprendre PID 1 est essentiel pour créer des conteneurs de production fiables.

---

## 9. NGINX : TLS v1.2 ou v1.3 uniquement

**Règle :** Le conteneur NGINX doit utiliser uniquement TLSv1.2 ou TLSv1.3.

**Avantage :** Sécurité maximale. Les versions TLS antérieures (v1.0, v1.1) ont des vulnérabilités connues.

**Pourquoi cette règle :** Les standards de sécurité évoluent. Aujourd'hui, TLS 1.2 est le minimum acceptable, TLS 1.3 est recommandé. Cette règle vous sensibilise à la cryptographie et à la configuration sécurisée des serveurs web. En production, un site sans TLS correct est inacceptable.

---

## 10. NGINX : unique point d'entrée via le port 443

**Règle :** NGINX doit être le seul point d'entrée de votre infrastructure via le port 443.

**Avantage :** Architecture sécurisée et standard. Une seule porte d'entrée = surface d'attaque réduite.

**Pourquoi cette règle :** C'est le pattern standard des infrastructures modernes : un reverse proxy (NGINX) gère le TLS et redirige les requêtes vers les services internes (WordPress). Vos autres services (MariaDB, PHP-FPM) ne sont pas exposés directement sur le réseau extérieur, ce qui est bien plus sécurisé.

---

## 11. WordPress : avec php-fpm uniquement, sans nginx

**Règle :** Le conteneur WordPress doit contenir PHP-FPM uniquement, pas de serveur web.

**Avantage :** Séparation des responsabilités (separation of concerns). Chaque conteneur fait une seule chose.

**Pourquoi cette règle :** Dans une architecture orientée services, chaque conteneur doit avoir une responsabilité unique. NGINX gère le HTTP/TLS, PHP-FPM exécute le code PHP, MariaDB gère la base de données. Cette séparation permet :
- De mettre à jour chaque service indépendamment
- De scaler horizontalement (plusieurs PHP-FPM)
- De remplacer un composant sans toucher aux autres

---

## 12. MariaDB : seulement, sans nginx

**Règle :** Le conteneur MariaDB ne doit contenir que MariaDB, pas de serveur web.

**Avantage :** Minimisation de l'image. Un service de base de données n'a pas besoin d'un serveur web.

**Pourquoi cette règle :** La philosophie Docker est "un processus par conteneur". MariaDB doit être seule dans son conteneur car :
- La base de données a ses propres besoins (persistance, mémoire, I/O)
- Ajouter un serveur web augmenterait inutilement la surface d'attaque
- Les conteneurs doivent être aussi légers que possible

---

## 13. Bonus : un Dockerfile par service supplémentaire

**Règle :** Pour le bonus, écrivez un Dockerfile pour chaque service additionnel.

**Avantage :** Cohérence entre services. L'infrastructure reste homogène et maintenable.

**Pourquoi cette règle :** Si vous avez écrit vos propres Dockerfiles pour les services obligatoires, vous avez acquis la compétence. La règle vous oblige à appliquer le même niveau d'exigence aux services bonus (Redis, FTP, Adminer, etc.). Aucun service prêt-à-l'emploi n'est autorisé.

---

## Résumé des interdictions

| Interdiction | Raison principale |
|--------------|-------------------|
| Tag `latest` | Non reproductibilité |
| Pull d'images prêtes | Objectif pédagogique (apprendre à construire) |
| Mots de passe en clair | Sécurité |
| `tail -f`, `sleep infinity`, etc. | Mauvaise pratique, masque la compréhension des daemons |
| Boucles infinies | Le conteneur doit exécuter un vrai service |
| TLS < 1.2 | Sécurité insuffisante |

---

*Document établi à partir du sujet Inception version 5.2 - 42 Network*