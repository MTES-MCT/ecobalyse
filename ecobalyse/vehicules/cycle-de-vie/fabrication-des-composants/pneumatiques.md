---
description: >-
  Cette page décrit les composants spécifiques aux véhicules, non traités dans
  les sections précédentes.
hidden: true
---

# 🛞 Pneumatiques

## Généralités

### Impact environnemental des pneumatiques

Si l'impact environnemental des pneumatiques est relativement faible à la fabrication du véhicule, il peut représenter jusqu'à 30% du coût environnemental sur la vie du véhicule. En effet, les pneumatiques doivent être régulièrement changés.

### Matériaux composant les pneumatiques

Les proportions de chaque matériau dépendent des types de pneus. Les proportions suivantes peuvent être retenue :&#x20;

* 40% à 60% de caoutchouc, majoritairement synthétique
* 20% à 30% de noir de carbone
* Polyester, acier, nylon pour le renforcement,&#x20;
* soufre, oxyde de zinc, huiles et résines, autres produits chimiques.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental des pneumatiques est calculé en fonction de leur poids, en kg.

Le cout environnemental des pneus prend en compte leur remplacement au cours de la vie du véhicule. Par défaut, Ecobalyse prend en compte que 8 pneus par roue sont utilisés, soit 7 remplacement.

Le cout environnemental des pneus se calcule donc ainsi :

$$
Impact_j=P*R*N*ICV_j
$$

Avec :

* Impactjj : l'impact environnemental des pneumatiques sur la durée de vie du véhicule
* P : le poids d'un pneumatique, en kg
* R : le nombre de roues, fixé dans les caractéristiques du véhicule
* N : le nombre de pneus utilisées par roue, sur la vie du véhicule, fixé par défaut à 8
* ICV\_j le cout environnemental par kg de pneumatique

### Matière des pneumatique - procédé utilisé pour la modélisation

A des fins de simplification, et en l'absence de procédé Ecoinvent spécifique, des composants par défaut ont été modélisé avec les ratios suivants :

* Matière transformée
  * 80%\*50% kg de caoutchouc synthétique
    * _Synthetic rubber production, RER (ecoinvent),_ 0.48 kg
  * 20%\*50% kg de caoutchouc naturel
    * _Chemical production, organic, GLO (ecoinvent), 0.12 kg (in ecoinvent,_ Caoutchouc is approximated by the dataset "Chemicals, organic")
  * 30% Noir de carbone
    * _carbon black production, GLO (ecoinvent), 0.3 kg_
  * _20% Polyester_
    * market for fibre, polyester, GLO _(ecoinvent), 0.15kg_
* Etape de transformation additionnelle
  * thermoformage \
    _&#x49;njection moulding, RER, 1 kg (procédé corrigé par Ecobalyse)_

