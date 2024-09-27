---
description: >-
  Cette page décrit les composants spécifiques aux véhicules, non traités dans
  les sections précédentes.
---

# 🛺 Composants spécifiques véhicules

### Procédés spécifiques :



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

<summary>Batterie</summary>

Le coût environnement de la batterie est évaluée d'après sa chimie, sa capacité (en kWh) et son pays de fabrication (assemblage du pack batterie).

Les chimies de batterie suivantes sont différenciées : NMC532, NMC622, NMC811, LFP.

Les sites et méthodes de fabrication des modules et cellules de batterie, ainsi que les sites et méthode d'extraction et de raffinage des matières premières ont également une réelle influence sur le coût environnemental. \
Cependant, par souci de simplification et compte-tenu de la difficulté à détailler la chaine de valeur de fabrication, ils ne sont pas utilisés comme paramètres dans Ecobalyse.

Les données sur l'impact environnemental sont issues de la Base Empreinte.

</details>

<details>

<summary>Moteur</summary>

Le cout environnemental du moteur est calculé en fonction de son poids, en kg.

Les données sur l'impact environnemental par kg sont issues de la base de données Ecoinvent.

Ecoinvent propose 2 jeux de données pour les moteurs électriques :&#x20;

1\) "electric motor, vehicle" : basé a priori sur un petit moteur, donnée créée en 2011, basé sur des informations de 2007

2\) "electric motor production, vehicle (electric powertrain)" : basé sur un moteur de 53kg (voiture compacte), donnée créée en 2022, basé sur des informations de 2011

Le second jeu de données est utilisé car il est mieux détaillé, plus récent, et plus conservateur.



</details>

<details>

<summary>Pneumatique</summary>

Le cout environnemental des pneumatiques est calculé en fonction de leur poids, en kg.

Les proportions de chaque matériau dépendent des types de pneus. Les proportions suivantes peuvent être retenue :&#x20;

* 40% à 60% de caoutchouc, majoritairement synthétique
* 20% à 30% de noir de carbone
* Polyester, acier, nylon pour le renforcement,&#x20;
* soufre, oxyde de zinc, huiles et résines, autres produits chimiques.

A des fins de simplification, la modélisation suivante a été retenue

* Matière transformée
  * 80%\*50% kg de caoutchouc synthétique
    * _Synthetic rubber production, RER (ecoinvent),_ 0.48 kg
  * 20%\*50% kg de caoutchouc naturel
    * _Chemical production, organic, GLO (ecoinvent), 0.12 kg (in ecoinvent,_ Caoutchouc is approximated by the dataset "Chemicals, organic")
  * 30% Noir de carbone
    * _carbon black production, GLO (ecoinvent), 0.3 kg_
  * _20% Polyester_
    * market for fibre, polyester, GLO _(ecoinvent), 0.15kg_
* Etape de transformation additionnelle => thermoformage Procédé Ecoinvent => I_njection moulding, RER_ Quantité => 1kg

Le cout environnemental des pneus prend en compte leur remplacement au cours de la vie du véhicule. Par défaut, Ecobalyse prend en compte que 8 pneus par roue sont utilisés, soit 7 remplacement.

Le cout environnemental des pneus se calcule donc ainsi :\
CE = M x R x ICV x N, avec

* CE le cout environnemental, exprimé en mPts
* M la masse d'un pneumatique
* R le nombre de roues
* ICV le cout environnemental par kg de pneumatique
* N le nombre de roues utilisées sur la vie du véhicule.



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
