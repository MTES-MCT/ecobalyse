# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait initialement **Wikicarbone**.

## Socle technique et prérequis

Le frontend de cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm`. Pour le backend vous devez disposer d'un environnement [python](https://www.python.org/) >=3.11, [pipenv](https://pipenv.pypa.io/) et [gettext](https://www.gnu.org/software/gettext/) sur votre machine.

## Installation

### Frontend

    $ npm install

### Backend

    $ pipenv install

Assurez-vous d'avoir un PostgreSQL >=16 qui tourne localement si vous souhaitez vous rapprocher de l'environnement de production. À défaut, `sqlite` sera utilisé.

Pour créer et lancer un PostgreSQL sur le port 5433 en local en utilisant `docker` :

    # Création du volume pour persister les données
    docker volume create ecobalyse_postgres_data

    # Lancement du docker postgres 16
    docker run --name ecobalyse-postgres -e POSTGRES_PASSWORD=password -d -p 5433:5432 -v ecobalyse_postgres_data:/var/lib/postgresql/data postgres:16

    # Création de la base de données ecobalyse_dev
    docker exec -it ecobalyse-postgres createdb -U postgres ecobalyse_dev

Vous devriez pouvoir y accéder via votre `psql` local avec la commande suivante :

    psql -U postgres -p 5433 -h localhost ecobalyse_dev

## Configuration

Les variables d'environnement suivantes doivent être définies :

- `BACKEND_ADMINS` : la liste des emails des administrateurs initiaux, séparés par une virgule
- `DEFAULT_FROM_EMAIL` : l'email utilisé comme origine pour les mails liés à l'authentification (par défaut ecobalyse@beta.gouv.fr)
- `DJANGO_DEBUG`: la valeur du mode DEBUG de Django (par défaut `True`)
- `DJANGO_SECRET_KEY` : la [clé secrète de Django](https://docs.djangoproject.com/en/5.0/ref/settings/#std-setting-SECRET_KEY)
- `ECOBALYSE_DATA_DIR`: l'emplacement du dépôt de données détaillées sur le système de fichier. Note: à terme, cette valeur deviendra optionnelle pour autoriser un fonctionnement en mode restreint.
- `EMAIL_HOST` : le host SMTP pour envoyer les mail liés à l'authentification
- `EMAIL_HOST_USER`: l'utilisateur du compte SMTP
- `EMAIL_HOST_PASSWORD` : le mot de passe du compte SMTP pour envoyer les mail liés à l'authentification
- `MATOMO_HOST`: le domaine de l'instance Matomo permettant le suivi d'audience du produit (typiquement `stats.beta.gouv.fr`).
- `MATOMO_SITE_ID`: l'identifiant du site Ecobalyse sur l'instance Matomo permettant le suivi d'audience du produit.
- `MATOMO_TOKEN`: le token Matomo permettant le suivi d'audience du produit.
- `NODE_ENV`: l'environnement d'exécution nodejs (par défaut, `production`)
- `SCALINGO_POSTGRESQL_URL` : l'uri pour accéder à Postgresl (définie automatiquement par Scalingo). Si non défini sqlite3 est utilisé.
- `SENTRY_DSN`: le DSN [Sentry](https://sentry.io) à utiliser pour les rapports d'erreur.

En développement, copiez le fichier `.env.sample`, renommez-le `.env`, et mettez à jour les valeurs qu'il contient ; le serveur de développement node chargera les variables en conséquences.

Pour utiliser le PostgreSQL lancé avec docker, configurez la variable `SCALINGO_POSTGRESQL_URL` comme ceci :

    SCALINGO_POSTGRESQL_URL=postgres://postgres:password@localhost:5433/ecobalyse_dev

## Chargement des données par défaut

Pour initialiser la base de données (attention, toutes les données présentes, si il y en a, seront supprimées) :

    $ pipenv run ./backend/update.sh

## Développement

### Environnement de développement local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    $ npm start

Trois instances de développement sont alors accessibles :

- [localhost:8002](http://localhost:8002/) sert le backend django utilisé pour l'authentification, et sert aussi les fichiers statiques de elm. Sert aussi [l'admin django](http://localhost:8002/admin/)
- [localhost:8001](http://localhost:8001/) sert l'API ;
- [localhost:1234](http://localhost:1234/) est l'URL à utiliser en développement pour tester l'intégration des trois composants (le front, l'API et le Django) car un proxy Parcel renvoie certaines requêtes vers le port 8001 ou 8002 (voir `.proxyrc`). Le frontend est servi en mode _hot-reload_, pour recharger! l'interface Web à chaque modification du code frontend.

> ℹ️ Pour accéder à l'admin django, utilisez l'email `foo@bar.baz`. Le lien d'activation pour se connecter automatiquement à l'admin sera affiché dans votre terminal.

### Hooks Git avec pre-commit et Formatage de Code avec Prettier et Ruff

Ce projet utilise https://pre-commit.com/ pour gérer les hooks Git ainsi que Prettier et Ruff pour le formatage automatique du code.
Le build sur le CI échouera si les fichiers python, javascript et json ne sont pas proprement formattés.

#### Vérification Automatique avant chaque Commit

Pour installer les hooks pre-commit, exécutez la commande suivante :

    $ pipenv run pre-commit install

Un hook de pre-commit sera alors configuré pour vérifier que le code est bien formaté avant de permettre le commit. Le hook corrigera les erreurs dans la mesure du possible. Il vous suffira alors d'ajouter les modifications à votre staging, git puis à refaire votre commit.

Il est possible de lancer la vérification du formatage à la main grâce à la commande suivante :

    $ npm run lint:all

Si vous voulez lancer la correction automatique de tous les problèmes détectés, lancez :

    $ npm run fix:all

Si vous ne souhaitez pas que la vérification se fasse de manière automatique, vous pouvez désinstaller pre-commit et les hooks associés :

    $ pipenv run pre-commit uninstall

## Compilation

Pour compiler la partie client de l'application :

    $ npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur la plateforme [Scalingo](https://scalingo.com/) à chaque mise à jour de la branche `master` sur [le dépôt](https://github.com/MTES-MCT/ecobalyse/tree/master).

Chaque _Pull Request_ effectuée sur le dépôt est également automatiquement déployée sur une instance de revue spécifique, par exemple `https://ecobalyse-pr44.osc-fr1.scalingo.io/` pour la pull request #44. **Ces instances de recette restent actives 72 heures, puis sont automatiquement décommisionnées passé ce délai ou si la pull request correspondante est mergée.**

### Ajout d'une variable d'environnement

Pour ajouter une variable d'environnement sur une application, il est recommandé d'utiliser le CLI scalingo qui permet d'ajouter des valeurs qui contiennent plusieurs lignes (à la différence de l'interface graphique qui ne le permet pas) :

    scalingo --app ecobalyse env-set "MY_VAR=$(cat fichier.key)"

### Lien avec ecobalyse_private

Lorsqu'un déploiement est effectué sur une branche, les données utilisées du dépôt `ecobalyse_private` sont celles de la branche `main`. Cependant, si la description de la Pull Request sur le repo `ecobalyse` mentionne `ecobalyse_data: branch-a` avec branch-a étant une branche du dépôt `ecobalyse_private`, alors la PR utilisera les données de la branche `branch-a` du dépôt `ecobalyse_private`.

#### Points d'attention

Lors du merge d'une PR, il est important de merger d'abord la PR correspondante sur ecobalyse_private, puis celle sur ecobalyse.

# Serveur de production

## Variables d'environnement

Les variables d'environnement doivent être positionnées via l'interface de [configuration Scalingo](https://dashboard.scalingo.com/apps/osc-fr1/ecobalyse/environment) (voir la section [Configuration](#configuration)).

## Lancement du serveur

Pour lancer le serveur applicatif complet (frontend + backend), par exemple depuis un environnement de production, la démarche est la suivante :

```
$ npm run build
$ npm run server:start
```

L'application est alors servie sur le port 1234.

# Ecobalyse data

Ce dépôt contient aussi les scripts (principalement python) utilisés pour
importer et exporter les données du projet [Ecobalyse](https://github.com/MTES-MCT/ecobalyse).

Ces scripts se trouvent dans `data/`, et un fichier [README](data/README.md) spécifique
en détaille l'installation et l'utilisation.

# Versioning

Le versioning de l'application permet de revenir à des anciennes versions d'Ecobalyse. Pour que ce versioning puisse fonctionner, les anciennes versions (<= 2.0.0) doivent être patchées rétroactivement. Le script `./bin/build-specific-app-version.sh` permet de générer une version spécifique de l'application et d'appliquer les patchs si nécessaire. Par exemple, pour générer la version `1.3.2` (le deuxième paramètre est le commit du répertoire data associé) :

    pipenv run ./bin/build-specific-app-version.sh v1.3.2 3531c73f23a1eb6f1fc6b9c256a5344742230fcf

Un fichier `v1.3.2-dist.tar.gz` sera disponible à la racine du projet et un répertoire `v1.3.2` aura été créé dans `versions/`.

Le script python permettant de patcher les fichiers est disponible ici : `./bin/patch_files_for_versions_compat.py`.

Toutes les versions disponibles dans les releases Github ont été patchées comme il se doit.
