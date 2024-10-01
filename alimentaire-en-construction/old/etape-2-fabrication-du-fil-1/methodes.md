---
description: >-
  Cette page décrit les méthodes spécifique au calcul du cout environnemental
  des véhicules.
---

# 📐 Méthodes

## Périmètre de calcul

Ecobalyse intègre les étapes suivantes de la vie du véhicule :&#x20;

* La fabrication du véhicule, détaillant le châssis et la carrosserie, la batterie, le moteur, les jantes, les pneumatiques et l'assise
* Le remplacement des pneumatiques
* Le transport des composants et du véhicule
* La consommation d'électricité du véhicule

Les étapes et analyses suivantes ne sont à ce stade pas prise en compte :

* Le remplacement d'autres composants que les pneumatiques
* La fin de vie des véhicules
* La durabilité des véhicules
* Le processus d'assemblage

Seuls les véhicules électriques peuvent être évalués.

## Méthodes de calcul

Des données sont collectées sur les thématiques suivantes (les données obligatoires sont indiquées avec le symbole \*):

* Caractéristiques générales du véhicule\*
* Données sur les principaux composants du véhicule (poids, origine, matériaux selon les cas) :&#x20;
  * Châssis - carrosserie\*
  * Batterie
  * Moteur
  * Jantes
  * Pneumatiques
  * Assise
  * Cellules photovoltaïques
* Utilisation du véhicule\*

L'impact de la fabrication des composants est calculée à partir de l'identification du matériaux (et d'un procédé / donnée ICV associé) et de la quantité. Si l'unité du procédé utilisé n'est pas le kilogramme, une conversion est faite par Ecobalyse.

Les caractéristiques générales du véhicule et les données sur les composants permettent de calculer automatiquement :

* [l'impact des composants non listés](fabrication-des-composants/autres-composants.md), par différence de poids entre la somme des poids des composants identifiés et le poids du véhicule,
* [l'impact du transport des composants](transport-des-composants.md), à partir de l'origine de chaque composants et du lieu d'assemblage du véhicule,
* [l'impact du transport des véhicules](transport-des-vehicules.md), à partir du lieu d'assemblage du véhicule.

## Unité de calcul du coût environnemental

Le coût environnemental est calculé en premier lieu par véhicule, puis par kilomètre parcouru en divisant le cout environnemental par véhicule par la durée de vie du véhicule en kilomètres.

Une durée de vie par défaut est calculée en fonction de la catégorie de véhicule, et modifiable par l'utilisateur.

Il pourra également être calculé par tonne.km ou par passager.km.

## Enjeu de comparaison des véhicules

La comparaison de véhicules-types de catégories différentes sur la base du coût environnemental par kilomètre est à éviter ou nécessite des précautions. En effet, les kilométrages par défaut sont plus élevés pour les véhicules les plus lourds, ce qui est de nature à réduire significativement leur coût environnemental en comparaison des véhicules plus légers. Cependant, pour un usage donné, un véhicule plus léger aura en général un cout environnemental plus faible, et devrait être privilégié.

Deux véhicules, quelle que soit leurs tailles respectives, devraient donc se comparer avec un kilométrage identique et un remplacement de composants lié à ce kilométrage.

