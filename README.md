# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait initialement **Wikicarbone**.

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm`, ainsi que d'un environnement [python](https://www.python.org/) >=3.11 et [pipenv](https://pipenv.pypa.io/) sur votre machine :

## Installation

Ensure having a PostgreSQL >=16 server running locally.

    $ npm install
    $ pipenv install

Pour initialiser la base de données (attention, toutes les données présentes, si il y en a, seront supprimées) :

    $ npm run start:backend

## Configuration

Les variables d'environnement suivantes doivent être définies :

- `BACKEND_ADMINS` : la liste des emails des administrateurs initiaux, séparés par une virgule
- `DEFAULT_FROM_EMAIL` : l'email utilisé comme origine pour les mails liés à l'authentification (par défaut ecobalyse@beta.gouv.fr)
- `DJANGO_DEBUG`: la valeur du mode DEBUG de Django (par défaut `False`)
- `DJANGO_SECRET_KEY` : la [clé secrète de Django](https://docs.djangoproject.com/en/5.0/ref/settings/#std-setting-SECRET_KEY)
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

## Développement

### Environnement de développement local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    $ npm start

Trois instances de développement sont alors accessibles :

- [localhost:8002](http://localhost:8002/) sert le backend django utilisé pour l'authentification, et sert aussi les fichiers statiques de elm. Sert aussi [l'admin django](http://localhost:8002/admin/)
- [localhost:8001](http://localhost:8001/) sert l'API ;
- [localhost:1234](http://localhost:1234/) est l'URL à utiliser en développement pour tester l'intégration des trois composants (le front, l'API et le Django) car un proxy Parcel renvoie certaines requêtes vers le port 8001 ou 8002 (voir `.proxyrc`). Le frontend est servi en mode _hot-reload_, pour recharger! l'interface Web à chaque modification du code frontend.

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
