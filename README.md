# wikicarbone ![Build status](https://github.com/MTES-MCT/wikicarbone/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

![image](https://user-images.githubusercontent.com/41547/142401805-56783edf-75c8-4f15-97ba-b86a876c6c31.png)

L'application est accessible [à cette adresse](https://wikicarbone.beta.gouv.fr/).

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm` sur votre machine.

## Installation

    $ npm install

# Frontend (client Web)

## Développement

Le serveur local de développement se lance au moyen de la commande suivante :

    $ npm start

Deux instances de développement sont alors accessibles :

- [localhost:3000](http://localhost:3000/) sert le frontend et le backend (API) ;
- [localhost:1234](http://localhost:1234/) sert seulement le frontend en mode *hot-reload*, permettant de mettre à jour en temps-réel l'interface Web à chaque modification du code frontend.

### Mode de débogage

Pour lancer le serveur de développement en mode de débuggage :

    $ npm run start:dev

Un server frontend de débogage est alors disponible sur [localhost:1234](http://localhost:1234/).

## Build

Pour compiler l'application :

    $ npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur la plateforme [Scalingo](https://scalingo.com/) pour toute mise à jour de la branche `master`.

Chaque *Pull Request* effectuée sur le dépôt est également automatiquement déploayée sur une instance de revue spécifique, par exemple `https://wikicarbone-pr44.osc-fr1.scalingo.io/` pour le pull request #44.

# Serveur de production

Pour lancer le serveur applicatif complet (frontend + backend), par exemple depuis un envorinnement de production, la démarche est la suivante :

```
$ npm run build        # build frontend code
$ npm run server:build # build backend code
$ npm run server:start # run app server
```

L'application est alors servie sur le port défini par la variable d'environnement `PORT` (par défaut: `3000`).
