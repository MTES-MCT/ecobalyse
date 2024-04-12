# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait initialement **Wikicarbone**.

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm`, ainsi que d'un environnement [python](https://www.python.org/) >=3.10 et [pipenv](https://pipenv.pypa.io/) sur votre machine :

## Installation

    $ npm install
    $ pipenv install

Pour initialiser la base de données (attention, toutes les données présentes, si il y en a, seront supprimées) :

    $ npm run auth:init

## Configuration

Les variables d'environnement suivantes doivent être définies :

- `SENTRY_DSN`: le DSN [Sentry](https://sentry.io) à utiliser pour les rapports d'erreur.
- `MATOMO_HOST`: le domaine de l'instance Matomo permettant le suivi d'audience du produit (typiquement `stats.beta.gouv.fr`).
- `MATOMO_SITE_ID`: l'identifiant du site Ecobalyse sur l'instance Matomo permettant le suivi d'audience du produit.
- `MATOMO_TOKEN`: le token Matomo permettant le suivi d'audience du produit.

En développement, copiez le fichier `.env.sample`, renommez-le `.env`, et mettez à jour les valeurs qu'il contient ; le serveur de développement node chargera les variables en conséquences.

## Développement

### Environnement de développement local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    $ npm start

Trois instances de développement sont alors accessibles :

- [localhost:8000](http://localhost:8000/) sert le backend django utilisé pour l'authentification, et sert aussi les fichiers statiques de elm
- [localhost:8001](http://localhost:8001/) sert le frontend et le backend (API) ;
- [localhost:1234](http://localhost:1234/) sert seulement le frontend en mode _hot-reload_, permettant de mettre à jour en temps-réel l'interface Web à chaque modification du code frontend.

### Hooks Git avec Husky et Formatage de Code avec Prettier

Ce projet utilise Husky pour gérer les hooks Git, et Prettier pour le formatage automatique du code.
Le build sur le CI échouera si les fichiers javascript et json ne sont pas proprement formattés.

#### Pré-requis

- Husky
- Prettier

Si vous clonez le dépôt pour la première fois, les dépendances devraient être installées automatiquement après avoir exécuté npm install. Si ce n'est pas le cas, vous pouvez les installer manuellement.

    $ npm install --save-dev husky prettier

#### Vérification Automatique avant chaque Commit

Un hook de pre-commit a été configuré pour vérifier que le code est bien formaté avant de permettre le commit. Si le code n'est pas correctement formaté, le commit sera bloqué.

Pour résoudre ce problème, vous pouvez exécuter la commande suivante :

    $ npm run format:json

Si vous ne souhaitez pas que la vérification se fasse de manière automatique, vous pouvez désinstaler les hooks :

    $ npx husky uninstall

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

L'application est alors servie sur le port 8001.

# Ecobalyse data

Ce dépôt contient aussi les scripts (principalement python) utilisés pour
importer et exporter les données du projet [Ecobalyse](https://github.com/MTES-MCT/ecobalyse).

Ces scripts se trouvent dans `data/`, et un fichier [README](data/README.md) spécifique
en détaille l'installation et l'utilisation.
