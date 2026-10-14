# 🪛 Assemblage

{% hint style="info" %}
A ce jour la phase d'assemblage n'est prise en compte que dans le calcul du transport.

La consommation d'énergie à cette étape sera prise en compte prochainement.
{% endhint %}

## Contexte

L'assemblage des véhicules par les constructeurs nécessite de l'énergie.

<details>

<summary>Publications relatives à la consommation d'énergie pour l'assemblage de véhicules</summary>

* Sato, F. E. K., & Nakata, T. (2020). [Energy Consumption Analysis for Vehicle Production through a Material Flow Approach](https://doi.org/10.3390/en13092396). _Energies_, _13_(9), 2396 :&#x20;
  * données de l'étude : consommation d'énergie de 41.8MJ/kg, dont 13% pour l'assemblage
  * résultat : 5.4MJ/kg, soit 1.5 kWh/kg
* Volkswagen Group, données 2021-2023
  * données : 20.8 à 22 TWh/an, 2.16 à 2.43 MWh/véhicule, dont la moitié en électricité
  * estimation : 0.8 kWh/kg d'électricité et 2.9 MJ/kg de chaleur et énergie de procédés (pour un poids moyen de 1.4t)
* Documentation ecoinvent (accès restreint)
  * Données cohérentes avec les autres sources mais plus élevées, pouvant inclure certaines transformations de matière&#x20;
* [ACEA](https://www.acea.auto/figure/energy-consumption-during-car-production-in-eu/) :&#x20;
  * donnée : autour de 2.6 MWh/voiture en Europe
  * estimation : 2 kWh/kg (7.2MJ/kg)

</details>

## Méthode de calcul

Voir [documentation transversale relative à la consommation d'énergie dans les étapes de transformation](https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/GoOQOxssr5oxJOdJn2nn/methodes-transverses-specifiques/energies-des-etapes-de-transformation).

{% embed url="https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/GoOQOxssr5oxJOdJn2nn/methodes-transverses-specifiques/energies-des-etapes-de-transformation" %}

## Paramètres retenus pour le coût environnemental

La consommation d'énergie pour l'assemblage d'1kg de véhicule est fixée comme suit :&#x20;

* E\_Transformation,électricité = 1.5 kWh d'électricité par kg de véhicule
* E\_Transformation,chaleur = 3 MJ de chaleur par kg de véhicule

## Procédés utilisés pour le coût environnemental <a href="#procedes-utilises-pour-le-cout-environnemental" id="procedes-utilises-pour-le-cout-environnemental"></a>

Voir [documentation transversale relative à la consommation d'énergie dans les étapes de transformation](https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/GoOQOxssr5oxJOdJn2nn/methodes-transverses-specifiques/energies-des-etapes-de-transformation).&#x20;
