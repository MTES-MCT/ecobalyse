---
description: >-
  Cette page décrit les composants spécifiques aux véhicules, non traités dans
  les sections précédentes.
---

# 🚙 Châssis-Carrosserie

## Généralités



## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental du châssis est la somme du coût environnemental de ses composants.



### Procédés spécifiques utilisé pour la modélisation



<details>

<summary>Verre</summary>

Le verre utilisé pour les véhicules est généralement du verre trempé.\
Il est modélisé de la façon suivante :&#x20;

* Matériau transformé : Verre
  * market for Flat glass, uncoated, RER (ecoinvent), 1kg
* Procédé de transformation : trempe du verre
  * market for Tempering, flat glass, GLO (ecoinvent), 1kg

</details>

<details>

<summary>Panneaux photovoltaïques</summary>

Le cout environnemental des cellules photovoltaïques peut s'exprimer :

* en fonction de la puissance installée, exprimée en watt-crete (Wc ou kWc), selon la norme IEC 61836. Il s'agit de l'unité la plus commune pour les professionnels de l'énergie. Compte-tenu des progrès techniques sur la filière, le coût environnemental par kWc baisse rapidement (-80% à -90% en 20 ans), notamment en raison de l'augmentation de la puissance par unité de surface.
* en fonction de la surface de cellules photovoltaïques, en m². Il s'agit de l'unité la plus utilisée dans l'analyse environnementale des procédés industriels de la filière. Elle est utilisée par ecoinvent notamment. Le coût environnemental par m² baisse, à un rythme lent (baisse de l'ordre de -50% en 20ans).

La puissance des cellules photovoltaïques est une donnée nécessaire au calcul de la [consommation d'électricité du véhicule](consommation-des-vehicules/energie-apportee-par-des-panneaux-solaires-photovoltaique.md).&#x20;

A des fins de simplification pour l'utilisateur, seule la puissance doit être renseignée dans Ecobalyse.

1Wc est modélisé à partir d'un procédé Ecoinvent :&#x20;

* photovoltaic cell production, single-Si wafer, RoW\
  unité : m²\
  Quantité : 2

Les hypothèses utilisées dans ce modèle sont les suivantes :&#x20;

* L'impact des installations photovoltaïques sur véhicules correspond aux cellules photovoltaîques, les autres composants sont négligés. Les cellules représentent en réalité de l'ordre de 90% de l'impact environnement d'un panneau photovoltaïque standard, le reste correspondant essentiellement au cadre et au verre du panneau, qui sont rarement utilisés pour les véhicules.
* Les cellules sont fabriquées en Asie
* Puissance de 250Wc/m²,&#x20;
* Amélioration de la performance environnementale de 100% par rapport à la donnée Ecoinvent, datant de 2004.

</details>
