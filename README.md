# wikicarbone ![Build status](https://github.com/MTES-MCT/wikicarbone/actions/workflows/node.js.yml/badge.svg)

> Accélerer la mise en place de l'affichage environnemental

![](https://i.imgur.com/s6wAYhZ.png)

L'application est accessible [à cette adresse](https://mtes-mct.github.io/wikicarbone/).

## Socle technique et prérequis

Cette application est écrite en [Elm](https://elm-lang.org/). Vous devez disposer d'un environnement [NodeJS](https://nodejs.org/fr/) 14+ et `npm` sur votre machine.

## Installation

    $ npm install

## Développement

Le serveur local de développement se lance au moyen de la commande suivante :

    $ npm start

L'instance de développement est alors accessible via [localhost:3000](http://localhost:3000/)

### Mode de débogage

Pour lancer le serveur de développement en mode de débuggage :

    $ npm run start:debug

## Build

Pour compiler l'application :

    $ npm run build

Les fichiers générés sont alors générés dans le répertoire `build` à la racine du projet.

## Déploiement

Cette application est hébergée sur [Github Pages](https://pages.github.com/). Pour déployer l'application, il faut lancer la commande suivante :

```
$ npm run deploy
```
