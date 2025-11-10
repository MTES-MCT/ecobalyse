---
hidden: true
---

# 🏙️ Complément : santé humaine en zone très dense

## Contexte

La modélisation de la consommation de carburant inclut la modélisation des émissions de particules fines et autres polluants ayant un impact sur la santé humaine à une échelle locale.

Cette modélisation est réalisée en évaluant les émissions, et en appliquant les flux élémentaires correspondant (Particulate matter, <2.5pm, Nitrogen oxides,...), avec les compartiments et sous-compartiments "air, urban air close to ground". Ceci permet de prendre en compte une utilisation des véhicules dans des zones urbaines.

Cependant, la définition de zone urbaine correspond ici à une zone de plus de 400 personnes par km2 pour une suface de 12km2. Cette densité est 10 à 50 fois plus faible que la [densité des grandes villes françaises](https://fr.wikipedia.org/wiki/Liste_des_communes_de_France_les_plus_denses).

De plus, la part de l'impact sur la santé humaine liée aux émissions particules des véhicules ne reflète pas les préoccupations des élus locaux de grandes villes sur ce sujet. En effet, ils s'intéressent davantage à cet enjeu qu'à l'impact sur le changement climatique par exemple.

Il est donc proposé d'ajouter, de façon optionnelle, un complément santé humaine pour les zones très denses, en augmentant l'impact formation de particules, de façon à prendre en compte les impacts dans les zones très denses.

## Méthodes de calcul

A court terme, cette nouvelle modélisation est proposée à travers le choix d'un procédé dédié, dont les émissions de particules sont multipliées par `5` par rapport au procédé de référence.

## Paramètres retenus pour le coût environnemental

_En cours de rédaction_

## Procédés utilisés pour le coût environnemental

_En cours de rédaction_

## Exemple d'application

_En cours de rédaction_
