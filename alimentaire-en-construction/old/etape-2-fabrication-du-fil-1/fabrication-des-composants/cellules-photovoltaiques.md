# 💠 Cellules photovoltaïques

## Généralités

Une partie des constructeurs intègrent des cellules photovoltaïques sur le toit de leur véhicule pour augmenter leur autonomie. Ce choix a un impact à la fabrication, mais vient réduire le besoin de recharge du véhicule sur le réseau électrique.

Cette section présente les méthodes de calcul de l'impact environnemental de la fabrication des cellules.

Les méthodes associées à la réduction du besoin de recharge sont détaillée dans la [partie utilisation du véhicule](../utilisation-du-vehicule/).

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental des cellules photovoltaïques peut s'exprimer :

* en fonction de la puissance installée, exprimée en watt-crete (Wc ou kWc), selon la norme IEC 61836. Il s'agit de l'unité la plus commune pour les professionnels de l'énergie. Compte-tenu des progrès techniques sur la filière, le coût environnemental par kWc baisse rapidement (-80% à -90% en 20 ans), notamment en raison de l'augmentation de la puissance par unité de surface.
* en fonction de la surface de cellules photovoltaïques, en m². Il s'agit de l'unité la plus utilisée dans l'analyse environnementale des procédés industriels de la filière. Elle est utilisée par ecoinvent notamment. Le coût environnemental par m² baisse, à un rythme lent (baisse de l'ordre de -50% en 20ans).

La puissance des cellules photovoltaïques est de fait une donnée nécessaire au calcul de la consommation d'électricité du véhicule.&#x20;

A des fins de simplification pour l'utilisateur, la puissance doit être renseignée dans Ecobalyse, mais pas la surface.

L'utilisateur doit également préciser, pour le calcul de la consommation d'électricité, l'inclinaison des cellules photovoltaïques, en degrés : &#x20;

* 0° si les cellules sont à plat (sur le toit par exemple)
* 90° si elles sont orientées vers le coté.

### Procédé utilisé pour la modélisation

1Wc est modélisé à partir d'un procédé Ecoinvent :&#x20;

* photovoltaic cell production, single-Si wafer, RoW\
  unité : m²\
  Quantité : 2

### Hypothèses

* L'impact des installations photovoltaïques sur véhicules correspond aux cellules photovoltaîques, les autres composants sont négligés. Les cellules représentent en réalité de l'ordre de 90% de l'impact environnement d'un panneau photovoltaïque standard, le reste correspondant essentiellement au cadre et au verre du panneau, qui sont rarement utilisés pour les véhicules.
* Les cellules sont fabriquées en Asie
* Puissance de 250Wc/m²,&#x20;
* Amélioration de la performance environnementale de 100% par rapport à la donnée Ecoinvent, datant de 2004.
