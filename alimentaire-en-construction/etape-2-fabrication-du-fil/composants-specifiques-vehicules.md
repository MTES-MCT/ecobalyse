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

* Matiériau transformé : Verre
  * market for Flat glass, uncoated, RER (ecoinvent), 1kg
* Procédé de transformation : trempe du verre
  * market for Tempering, flat glass, GLO (ecoinvent), 1kg

</details>

<details>

<summary>Batterie</summary>

Le coût environnement de la batterie est évaluée d'après sa chimie, sa capacité et son pays de fabrication (assemblage du pack batterie).&#x20;

Les sites et méthodes de fabrication des modules, cellules, ainsi que les sites et méthode d'extraction et de rafinage des matières premières ont également une réelle influence sur le coût environnemental. \
Cependant, par souci de simplification et compte-tenu de la difficulté à détailler la chaine de valeur de fabrication, ils ne sont pas utilisés comme paramètres dans Ecobalyse.

Les données sont issues de la Base Empreinte.

</details>

<details>

<summary>Moteur</summary>

Ecoinvent propose 2 jeux de données pour les moteurs électriques :&#x20;

1\) "electric motor, vehicle" : basé a priori sur un petit moteur, donnée créée en 2011, basé sur des informations de 2007

2\) "electric motor production, vehicle (electric powertrain)" : basé sur un moteur de 53kg (voiture compacte), donnée créée en 2022, basé sur des informations de 2011

Le second jeu de données est utilisé car il est mieux détaillé, plus récent, et plus conservateur.



</details>

<details>

<summary>Pneumatique</summary>

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



</details>
