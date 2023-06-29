# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait initialement **Wikicarbone**.

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm` sur votre machine.

## Installation

    $ npm install

## Développement

### Environnement de développement local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    & npm run db:build
    $ npm start

Deux instances de développement sont alors accessibles :

- [localhost:3000](http://localhost:3000/) sert le frontend et le backend (API) ;
- [localhost:1234](http://localhost:1234/) sert seulement le frontend en mode _hot-reload_, permettant de mettre à jour en temps-réel l'interface Web à chaque modification du code frontend.

### Mode débogage

Pour lancer le serveur de développement en mode de débogage:

    & npm run db:build
    $ npm run start:dev

Un server frontend de débogage est alors disponible sur [localhost:1234](http://localhost:1234/).

## Compilation

Pour compiler la partie client de l'application :

    $ npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur la plateforme [Scalingo](https://scalingo.com/) à chaque mise à jour de la branche `master` sur [le dépôt](https://github.com/MTES-MCT/ecobalyse/tree/master).

Chaque _Pull Request_ effectuée sur le dépôt est également automatiquement déployée sur une instance de revue spécifique, par exemple `https://ecobalyse-pr44.osc-fr1.scalingo.io/` pour la pull request #44. **Ces instances de recette restent actives 72 heures, puis sont automatiquement décommisionnées passé ce délai ou si la pull request correspondante est mergée.**

# Serveur de production

## Variables d'environnement

Certaines variables d'environnement doivent être configurées via l'interface de [configuration Scalingo](https://dashboard.scalingo.com/apps/osc-fr1/ecobalyse/environment) :

- `SENTRY_DSN`: le DSN [Sentry](https://sentry.io) à utiliser pour les rapports d'erreur.
- `MATOMO_TOKEN`: le token [Matomo](https://stats.data.gouv.fr/) permettant le suivi d'audience de l'API.

## Lancement du serveur

Pour lancer le serveur applicatif complet (frontend + backend), par exemple depuis un environnement de production, la démarche est la suivante :

```
$ npm run build
$ npm run server:start
```

L'application est alors servie sur le port défini par la variable d'environnement `PORT` (par défaut: `3000`).


# Ecobalyse data

Ce dépôt contient aussi les scripts (principalement python) utilisés pour
importer et exporter les données du projet [Ecobalyse](https://github.com/MTES-MCT/ecobalyse).

Ces scripts se trouvent dans `data/`, et un fichier [README](data/README.md) spécifique
en détaille l'installation et l'utilisation.
