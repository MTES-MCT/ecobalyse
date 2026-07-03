# 🪛 Assemblage

## Contexte&#x20;

L'assemblage correspond à l'assemblage des composants sur un site d'assemblage, avant transport vers la zone de de distribution (France).

Cette étape est structurante pour calculer l'impact du transport.

{% hint style="info" %}
A ce jour, aucun impact environnemental n'est associé à cette étape. La suite de cette page de documentation décrit le calcul prévu.
{% endhint %}

L'assemblage implique une consommation d'énergie, relativement proportionnelle au poids du produit.

## Méthode de calcul

### Grands principes

Selon les secteurs, un processus d'assemblage peut être proposé, correspondant à un procédé visible dans l'explorateur.

### Formule de calcul

L'impact de l'étape d'assemblage est calculé comme suit :

$$
I_{utilisation} = \sum_i{Q_i*I_{i}}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `Q_i` : la quantité du produit, exprimée en kg&#x20;
* `I_i` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée par kg

{% hint style="info" %}
L'énergie est ici modélisée comme Flux externe (voir [Modélisation de la consommation d'énergie](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses/production/energies-des-etapes-de-transformation)).
{% endhint %}

## Paramètres retenus pour le coût environnemental

Non applicable

## Procédés utilisés pour le coût environnemental

Les procédés sont indiqués dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

## Exemple d'application

### Exemple 1 : Assemblage d'un véhicule de 2 tonnes

* Le procédé "Assemblage véhicule" a un impact environnemental nul ( `I_i`=0) et de l'énergie associée comme Flux externe :&#x20;
  * `unit` : kg
  * `eleckWh` : 1.5 (kWh/kg)
  * `heatMJ` : 3 (MJ/kg)
* La masse de produit est de 2 tonnes : `Q_i`=2000
* `I_Energy` = 14,06 Pts/kWh pour l'électricité et 4.08 Pts/kWh pour la chaleur

$$
I_{assemblage,vehicule} = \sum_i{Q_i*(eleckWh*I_{elec}+heatMJ*I_{chaleur}\big)}
$$

$$
I_{assemblage,vehicule} = 2000*\big(1*0+1.5*14.06+3*4.08\big)=66 660 Pts
$$

