---
description: >-
  Cette page décrit les composants spécifiques aux véhicules, non traités dans
  les sections précédentes.
---

# 🛞 Jantes / Roues

## Généralités

Les véhicules peuvent être équipés de jantes ou de roues à rayons.

Dans l'automobile, les jantes sont majoritairement fabriquées en tôle d'acier embouties.&#x20;

Les constructeurs de véhicules intermédiaires sont également nombreux à choisir des jantes en aluminium. Des jante en plastique renforcé par fibre de verre apparaissent également sur le marché.

Les roues de cycles sont en acier inoxydable ou en aluminium.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental des jantes se calcule ainsi :

$$
Impact_j=P*R*ICV_j
$$

Avec :

* Impactjj : l'impact environnemental des jantes à la fabrication
* P : le poids d'une jante, en kg par roue
* R : le nombre de roues, fixé par défaut en fonction de la catégorie de véhicule (voir tableau dans la page précédente sur les pneumatiques)
* ICV\_j le cout environnemental par kg de jante

### Procédé utilisé pour la modélisation

* Acier embouti
* Acier inoxydable
* Aluminium, moulé ou extrudé,
* Carbone
* Plastique renforcé de fibres de verre

