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

L'instance de développement est alors accessible via [localhost:1234](http://localhost:1234/).

### Mode de débogage

Pour lancer le serveur de développement en mode de débuggage :

    $ npm run start:dev

## Build

Pour compiler l'application :

    $ npm run build

Les fichiers sont alors générés dans le répertoire `build` à la racine du projet, qui peut être servi de façon statique.

## Déploiement

L'application est déployée automatiquement sur [Github Pages](https://pages.github.com/) pour toute mise à jour de la branche `master`.

Il est cependant possible de déployer l'application manuellement au moyen de la commande suivante :

```
$ npm run deploy
```

# Backend (serveur d'API)

```
$ npm run server:start
```
