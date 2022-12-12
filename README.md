# Ecobalyse ![Build status](https://github.com/MTES-MCT/ecobalyse/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

![image](https://user-images.githubusercontent.com/41547/142401805-56783edf-75c8-4f15-97ba-b86a876c6c31.png)

L'application est accessible [à cette adresse](https://ecobalyse.beta.gouv.fr/).

> Note: le projet Ecobalyse s'appellait précédemment **Wikicarbone**.

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm` sur votre machine.

## Installation

    $ npm install

## Développement

### Environnement de dev local

Le serveur local de développement se lance au moyen des deux commandes suivantes :

    & npm run db:build
    $ npm start

Deux instances de développement sont alors accessibles :

- [localhost:3000](http://localhost:3000/) sert le frontend et le backend (API) ;
- [localhost:1234](http://localhost:1234/) sert seulement le frontend en mode _hot-reload_, permettant de mettre à jour en temps-réel l'interface Web à chaque modification du code frontend.

### Mode de débogage

Pour lancer le serveur de développement en mode de débuggage :

    & npm run db:build
    $ npm run start:dev

Un server frontend de débogage est alors disponible sur [localhost:1234](http://localhost:1234/).

## Build

Pour compiler l'application :

    $ npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur la plateforme [Scalingo](https://scalingo.com/) pour toute mise à jour de la branche `master`.

Chaque _Pull Request_ effectuée sur le dépôt est également automatiquement déployée sur une instance de revue spécifique, par exemple `https://wikicarbone-pr44.osc-fr1.scalingo.io/` pour la pull request #44.

# Serveur de production

## Variables d'environnement

Certaines variables d'environnement peuvent ou doivent être configurées via l'interface de [configuration Scalingo](https://dashboard.scalingo.com/apps/osc-fr1/wikicarbone/environment) :

- `SENTRY_DSN`: le DSN [Sentry](https://sentry.io) à utiliser pour les rapports d'erreur.
- `MATOMO_TOKEN`: le token [Matomo](https://stats.data.gouv.fr/) permettant le suivi d'audience de l'API.

## Lancement du serveur

Pour lancer le serveur applicatif complet (frontend + backend), par exemple depuis un environnement de production, la démarche est la suivante :

```
$ npm run build
$ npm run server:start
```

L'application est alors servie sur le port défini par la variable d'environnement `PORT` (par défaut: `3000`).
