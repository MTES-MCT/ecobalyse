# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait initialement **Wikicarbone**.

## Socle technique et prérequis

Le frontend de cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm`. Pour le backend vous devez disposer d'un environnement [python](https://www.python.org/) >=3.11, [pipenv](https://pipenv.pypa.io/) et [gettext](https://www.gnu.org/software/gettext/) sur votre machine. Certains fichiers d’impacts détaillés nécessitent d’installer et de configurer [`transcrypt`](https://github.com/elasticdog/transcrypt) pour les lire en local.

## Configuration

Les variables d'environnement suivantes doivent être définies :

- `BACKEND_ADMINS` : la liste des emails des administrateurs initiaux, séparés par une virgule
- `DEFAULT_FROM_EMAIL` : l'email utilisé comme origine pour les mails liés à l'authentification (par défaut ecobalyse@beta.gouv.fr)
- `DJANGO_DEBUG`: la valeur du mode DEBUG de Django (par défaut `True`)
- `DJANGO_SECRET_KEY` : la [clé secrète de Django](https://docs.djangoproject.com/en/5.0/ref/settings/#std-setting-SECRET_KEY)
- `EMAIL_SERVER_HOST`: serveur SMTP (`localhost` permet de bénéficier d'une instance [maildev](https://github.com/maildev/maildev))
- `EMAIL_SERVER_PASSWORD`: le mot de passe du serveur SMTP
- `EMAIL_SERVER_PORT`: Port su serveur SMTP (`1025` permet de bénéficier d'une instance *maildev*)
- `EMAIL_SERVER_USER`: Nom d'utilisateur SMTP
- `EMAIL_SERVER_USE_TLS`: Utilisation de TLS (par defaut à `True`, positionner à `False` pour utiliser l'instance *maildev*)
- `ENABLE_FOOD_SECTION` : affichage ou non de la section expérimentale dédiée à l'alimentaire (valeur `True` ou `False`, par défault `False`)
- `ENABLE_OBJECTS_SECTION` : affichage ou non de la section expérimentale dédiée aux objets génériques (valeur `True` ou `False`, par défault `False`)
- `ENABLE_VELI_SECTION` : affichage ou non de la section expérimentale dédiée aux véhicules intermédiaires (valeur `True` ou `False`, par défault `False`)
- `MATOMO_HOST`: le domaine de l'instance Matomo permettant le suivi d'audience du produit (typiquement `stats.beta.gouv.fr`).
- `MATOMO_SITE_ID`: l'identifiant du site Ecobalyse sur l'instance Matomo permettant le suivi d'audience du produit.
- `MATOMO_TOKEN`: le token Matomo permettant le suivi d'audience du produit.
- `NODE_ENV`: l'environnement d'exécution nodejs (par défaut, `development`)
- `PLAUSIBLE_HOST`: Le domaine du serveur [Plausible](https://plausible.io/) (optionnel)
- `RATELIMIT_MAX_RPM`: le nombre de requêtes maximum par minute et par ip (par défaut: 5000)
- `RATELIMIT_WHITELIST`: liste des adresses IP non soumises au rate-limiting, séparées par des virgules
- `SCALINGO_POSTGRESQL_URL` : l'uri pour accéder à Postgresl (définie automatiquement par Scalingo). Si non défini sqlite3 est utilisé.
- `SECRET_KEY`: le secret 32bits pour le backend; vous pouvez en générer une avec `openssl rand -hex 32`
- `SENTRY_DSN`: le DSN [Sentry](https://sentry.io) à utiliser pour les rapports d'erreur.
- `TRANSCRYPT_KEY`: la clé utilisée et autogénérée par [transcrypt](https://github.com/elasticdog/transcrypt/blob/main/INSTALL.md) et disponible dans [https://vaultwarden.incubateur.net](https://vaultwarden.incubateur.net/).
- `ENCRYPTION_KEY` : la clé utilisée par les scripts `npm run encrypt` et  `npm run decrypt` pour chiffrer/déchiffrer les fichiers d’impacts détaillés inclus dans chaque archive de release. Pour générer une nouvelle clé, vous pouvez utiliser le script `bin/generate-crypto-key`.
- `VERSION_POLL_SECONDS`: The number of seconds between two http polls to retrieve the current app version (`/version.json`, défault: `300`)

En développement, copiez le fichier `.env.sample`, renommez-le `.env`, et mettez à jour les valeurs qu'il contient ; le serveur de développement node chargera les variables en conséquences.

Pour utiliser le PostgreSQL lancé avec docker, configurez la variable `SCALINGO_POSTGRESQL_URL` comme ceci :

    SCALINGO_POSTGRESQL_URL=postgres://postgres:password@localhost:5433/ecobalyse_dev

Note: docker est également une dépendance requise pour lancer la suite de tests (`npm test`).

## Installation

### Frontend

- Installation des dépendances

    ```sh
    npm ci --ignore-scripts
    ```

- Déchiffrage du fichier des impacts détaillés. Attention, la variable d’environnement
`TRANSCRYPT_KEY` documentée plus haut **doit** être renseignée et exportée auparavant.

    ```sh
    export TRANSCRYPT_KEY="<clé de déchiffrement>"
    ./bin/run-transcrypt.sh
    ```

### Backend

    pipenv install -d

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


## Chargement des données par défaut

Pour initialiser la base de données (attention, toutes les données présentes, si il y en a, seront supprimées) :

    pipenv run ./backend/update.sh

## Développement

### Environnement de développement local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    npm start

Trois instances de développement sont alors accessibles :

- [localhost:8002](http://localhost:8002/) sert le backend django utilisé pour l'authentification, et sert aussi les fichiers statiques de elm. Sert aussi [l'admin django](http://localhost:8002/admin/)
- [localhost:8001](http://localhost:8001/) sert l'API ;
- [localhost:1234](http://localhost:1234/) est l'URL à utiliser en développement pour tester l'intégration des trois composants (le front, l'API et le Django) car un proxy Parcel renvoie certaines requêtes vers le port 8001 ou 8002 (voir `.proxyrc`). Le frontend est servi en mode _hot-reload_, pour recharger! l'interface Web à chaque modification du code frontend.

> ℹ️ Pour accéder à l'admin django, utilisez l'email `foo@bar.baz`. Le lien d'activation pour se connecter automatiquement à l'admin sera affiché dans votre terminal.

## Auto-hébergement avec Docker

Vous trouverez dans `./docker` des scripts permettant d’héberger une version publiée d’Ecobalyse en local en utilisant `docker`. Vous pouvez éditez le `Dockerfile` pour spécifier la version que vous souhaitez lancer, puis la lancer en utilisant `docker compose` :

    docker compose -f docker/compose.yaml up --build

Un server `express` sera lancé sur `http://localhost:8001`. À noter qu’actuellement, vous ne pouvez pas avoir accès aux impacts détailés de cette façon.

### Hooks Git avec pre-commit et Formatage de Code avec Prettier et Ruff

Ce projet utilise https://pre-commit.com/ pour gérer les hooks Git ainsi que Prettier et Ruff pour le formatage automatique du code.
Le build sur le CI échouera si les fichiers python, javascript et json ne sont pas proprement formattés.

#### Vérification Automatique avant chaque Commit

Pour installer les hooks pre-commit, exécutez la commande suivante :

    pipenv run pre-commit install

Un hook de pre-commit sera alors configuré pour vérifier que le code est bien formaté avant de permettre le commit. Le hook corrigera les erreurs dans la mesure du possible. Il vous suffira alors d'ajouter les modifications à votre staging, git puis à refaire votre commit.

Il est possible de lancer la vérification du formatage à la main grâce à la commande suivante :

    npm run lint:all

Si vous voulez lancer la correction automatique de tous les problèmes détectés, lancez :

    npm run fix:all

Si vous ne souhaitez pas que la vérification se fasse de manière automatique, vous pouvez désinstaller pre-commit et les hooks associés :

    pipenv run pre-commit uninstall

### Débogage des emails

Une instance [maildev](https://github.com/maildev/maildev) est lancé en même temps que le serveur de développement, elle est accessible à l'adresse `http://localhost:1081`.

## Compilation

Pour compiler la partie client de l'application :

    npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur la plateforme [Scalingo](https://scalingo.com/) à chaque mise à jour de la branche `master` sur [le dépôt](https://github.com/MTES-MCT/ecobalyse/tree/master).

Chaque _Pull Request_ effectuée sur le dépôt est également automatiquement déployée sur une instance de revue spécifique, par exemple `https://ecobalyse-pr44.osc-fr1.scalingo.io/` pour la pull request #44. **Ces instances de recette restent actives 72 heures, puis sont automatiquement décommisionnées passé ce délai ou si la pull request correspondante est mergée.**

### Ajout d'une variable d'environnement

Pour ajouter une variable d'environnement sur une application, il est recommandé d'utiliser le CLI scalingo qui permet d'ajouter des valeurs qui contiennent plusieurs lignes (à la différence de l'interface graphique qui ne le permet pas) :

    scalingo --app ecobalyse env-set "MY_VAR=$(cat fichier.key)"

### Fichiers d’impacts détaillés

Les fichiers d’impacts détaillés sont chiffrés à l’aide de [transcrypt](https://github.com/elasticdog/transcrypt) sur le dépôt public Github. En revanche, la version locale est une version décryptée par `transcrypt`. Vous pouvez donc utiliser, localement, les commandes git habituelles pour voir les différences dans ces fichiers, par exemple :

    git diff master HEAD public/data/textile/processes_impacts.json

Des commandes supplémentaires sont disponibles pour chiffrer et déchiffrer les fichiers manuellement au besoin (débogage par exemple). Notez que ces commandes requièrent la présence de la variable d’environnement `ENCRYPTION_KEY` pour fonctionner correctement :

    npm run encrypt public/data/textile/processes_impacts.json dist/processes_impacts_textile.json.enc
    npm run decrypt dist/processes_impacts.json.enc dist/processes_impacts_textile.json

#### Points d'attention

Lors du merge d'une PR, il est important de merger d'abord la PR correspondante sur ecobalyse-private, puis celle sur ecobalyse.

# Serveur de production

## Variables d'environnement

Les variables d'environnement doivent être positionnées via l'interface de [configuration Scalingo](https://dashboard.scalingo.com/apps/osc-fr1/ecobalyse/environment) (voir la section [Configuration](#configuration)).

## Lancement du serveur

Pour lancer le serveur applicatif complet (frontend + backend), par exemple depuis un environnement de production, la démarche est la suivante :

```
npm run build
npm run server:start
```

L'application est alors servie sur le port 1234.

# Ecobalyse data

Le dépôt [ecobalyse-data](https://github.com/MTES-MCT/ecobalyse-data) contient les scripts (principalement Python) utilisés pour
importer et exporter les données du projet Ecobalyse.

# Versioning

Le versioning de l'application permet de revenir à des anciennes versions d'Ecobalyse. Pour que ce versioning puisse fonctionner, les anciennes versions (<= 2.0.0) doivent être patchées rétroactivement. Le script `./bin/build-specific-app-version.sh` permet de générer une version spécifique de l'application et d'appliquer les patchs si nécessaire. Par exemple, pour générer la version `1.3.2` (le deuxième paramètre est le commit du répertoire https://github.com/MTE-extended/ecobalyse-private associé à cette version, si applicable) :

    pipenv run ./bin/build-specific-app-version.sh v1.3.2 3531c73f23a1eb6f1fc6b9c256a5344742230fcf

Un fichier `v1.3.2-dist.tar.gz` sera disponible à la racine du projet et un répertoire `v1.3.2` aura été créé dans `versions/`.

Le script python permettant de patcher les fichiers est disponible ici : `./bin/patch_files_for_versions_compat.py`.

Toutes les versions disponibles dans les releases Github ont été patchées comme il se doit.
