---
description: >-
  Cette page décrit la modélisation de l'étape d'utilisation du cycle de vie
  d'un vêtement
---

# 🌀 Etape 6 - Utilisation

## Qualité intrinsèque

La qualité intrinsèque est défini dans le réferentiel PEFCR de la comission européenne. C'est un nombre entre 0.67 et 1.45 qui represente la durabilité du vêtement. Pour le calculer un vêtement  doit passer des tests de durabilité physique. Les résultats de ces tests donneront un score entre 0.67 et 1.45. Si un vêtement ne passe pas de tests, il a une qualité par défaut de 0.67.

{% hint style="success" %}
Fairly Made a construit un tableur permettant de calculer le coefficient de qualité intrinsèque, [accessible ici](https://docs.google.com/spreadsheets/d/15L\_AVG1qcd2iSj4v1O0xd8nPkI83pzEQqXkPorFutjc/edit?usp=sharing)&#x20;
{% endhint %}

Ce score est ensuite appliqué en coefficient multiplicateur du nombre de jours d'utilisations.&#x20;

Prenons l'exemple d'une veste. Elle a par défaut 100 jours d'utilisation dans le réferentiel PEFCR. Avec une qualité intrinsèque de 0.67, elle aura 67 jours d'utilisation. Etant donné qu'elle fera moins de cycle d'entretiens l'impact de cette veste va légèrement diminuer. Par contre l'impact **par jour d'utilisation** lui va augmenter fortement (environ 1/0.67 = +50%) car on va diviser par un nombre plus petit .\
De la même manière, avec une qualité intrinsèque à 1.45, cette veste aura 145 jours d'utilisation. Son impact va augmenter légèrement (plus de cycle d'entretien). Mais l'impact **par jour d'utilisation** va diminuer fortement (environ 1/1.45 = -30%).

## Impacts pris en compte

Les impacts de la phase d'utilisation viennent en fait exclusivement de la phase d'entretien du produit. Conformément à la documentation textile de la [base Impacts](http://www.base-impacts.ademe.fr) nous prenons en compte les impacts suivants :&#x20;

* Lavage - Electricité
* Lavage - Lessive
* Lavage - Traitement des eaux usées
* Séchage - Electricité
* Repassage - Electricité

On peut exprimer l'impact de l'utilisation _I_\__utilisation_ de la manière suivante :

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + 
I_{eaux\_usées} + I_{élec\_séchage} + I_{élec\_repassage}
$$

Certaines grandeurs sont dépendantes du type de produit (jupe, pantalon, t-shirt,...). Pour indiquer cette dépendance on les noteras (p). Par exemple le nombre de cycles d'entretien par défaut est différent pour chaque type de produit. Il est de 45 pour un t-shirt et de 5 pour un manteau, ce qui exprime le fait que l'on va plus laver un t-shirt qu'un manteau.

Toutes les valeurs dépendantes du type de produit (p) sont à retrouver dans [l'explorateur de la table des produits](https://wikicarbone.beta.gouv.fr/#/explore/products).&#x20;



## Détail des calculs&#x20;

### Lavage

#### Electricité&#x20;

$$
I_{élec\_lavage} = n_{cycles}(p) \times m \times F_{kWh/kg\_lavage} \times C_{impact/kWh}
$$

Avec&#x20;

_I_\__élec\_lavage : l'impact dans l'indicateur sélectionné de l'électricité du au lavage du produit (unité : impact)_

_n\_cycles(p) :_ nombre de cycles d'entretien par défaut (unité : sans unité)

_m_ : la masse de la pièce textile (unité : kg)

_F\_kWh/kg\_lavage : la quantité d'électricité nécessaire à laver 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.1847 kWh/kg_

_C\_impact/kWh :  l'impact de la production d'1 kWh d'électricité dans le pays concerné (unité : impact/kWh)_

{% hint style="info" %}
_Sur l'interface, il est proposé de faire varier le nombre de cycles d'entretien (n\_cycles(p)), afin de visualiser les modifications d'impacts si un vêtement est entretenu plus souvent, ce qui correspond généralement à un vêtement porté plus longtemps._\
_Si l'impact global augmente avec le nombre de cycle d'entretien, l'impact par nombre de jour d'utilisation du même vêtement va en revanche diminuer. Cet aspect sera exploré prochainement à travers le projet de PERCR Apparel & Footwear._
{% endhint %}

#### Lessive

$$
I_{lessive} = n_{cycles}(p) \times m \times F_{kg\_lessive/kg\_lavage} \times C_{impact/kg\_lessive}
$$

_F\_kg\_lessive/kg\_lavage : la masse de lessive nécessaire à laver 1 kg de vêtement (unité : kg/kg = sans unité). En accord avec la documentation ADEME on prend une valeur de 0.036 kg lessive par kg de linge lavé._

_C\_impact/kg\_lessive :  l'impact de la production d'1 kg de lessive (unité : impact/kg)_

#### Traitement des eaux usées

$$
I_{eaux\_usées} = n_{cycles}(p)\times m \times F_{m3\_eaux/kg\_lavage} \times C_{impact/m3\_eaux}
$$

_F\_m3\_eaux/kg\_lavage : le volume d'eau nécessaire pour laver 1 kg de vêtement (unité : m3/kg). En accord avec la documentation ADEME on prend une valeur de 0.0097 m3 par kg de linge lavé._&#x20;

_C\_impact/m3\_eaux :  l'impact du traitement d'1 m3 d'eaux usées (unité : impact/m3)_

### Séchage

#### Electricité

Pour l'étape de séchage en sèche-linge, en accord avec le projet de PEFCR Apparel & Footwear (Table 33 - version de l'été 2021) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un T-Shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séché en sèche-linge que 12% du temps.

$$
I_{élec\_séchage} = n_{cycles}(p) \times m\times ratio_{sèche-linge}(p) \times F_{kWh/kg\_sèche-linge} \times C_{impact/kWh}
$$

_ratio_\__sèche-linge(p) : la part de vêtement qui va être séché en sèche-linge (unité : sans unité)_

_F\_kWh/kg\_sèche-linge : la quantité d'électricité nécessaire à sécher 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.335 kWh par kg de linge séché._&#x20;

### Repassage

#### Electricité

Pour l'étape de repassage, en accord avec le projet de PEFCR Apparel & Footwear (Table 33 - version de l'été 2021) on applique un ratio de produits repassés différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un T-Shirt a un temps de repassage de 2 min tandis qu'un pantalon a un temps de repassage de 4,3 min.

$$
I_{élec\_rpsg} = n_{cycles}(p)\times ratio_{rpsg}(p) \times tps_{rpsg}(p) \times F_{kWh/tps\_rpsg} \times C_{impact/kWh}
$$

_ratio_\__rpsg(p) : la part de vêtement qui va être repassé (unité : sans unité)_

_tps_\__rpsg(p) : le temps qui va être passé pour repasser un produit (unité : heure)_

_F\_kWh/tps\_rpsg : la quantité d'électricité nécessaire à repasser 1 h (unité : kWh/h = kW). En accord avec la documentation ADEME on prend une valeur de 1,5 kW._



### Exemple de calcul

Pour une jupe, on a n\_cycles = 23 et m = 0.3 kg

On sépare le calcul en 2 procédés :&#x20;

* 1 procédé de repassage, proportionnel au nombre de cycles d'entretien n\_cycles. L'impact ne provient que de l'électricité nécessaire au chauffage
* 1 procédé hors repassage comprenant les 4 autres procédés (élec lavage, élec séchage, lessive, eaux usées), proportionnel au nombre de cycles d'entretien **et** à la masse à laver

```
impact = impact_ironing + impact_élec_non_ironing + impact_eaux_lessive_non_ironing
```

#### Procédé de repassage (ironing)

```
impact_ironing = élec_ironing * P_élec_fr_cch
Avec P_élec_fr_cch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française

élec_ironing = n_cycles * P_ironing_élec
Avec  P_ironing_élec : la quantité d'électricité (MJ) nécessaire pour l'étape repassage du cycle d'entretien d'une jupe.

élec_ironing = 23 * 0.0729
élec_ironing = 1.68 MJ
élec_ironing = 0.47 kWh

d'où
impact_ironing = 0.47 * 0.081
impact_ironing = 0.038 kgCO2e
```

#### Procédé hors repassage (non ironing)

```
élec_non_ironing = n_cycles * m * P_non_ironing_élec
Avec  P_non_ironing_élec : la quantité d'électricité (MJ) nécessaire pour l'étape hors repassage (lave-linge, sèche-linge) du cycle d'entretien d'une jupe.
élec_non_ironing = 23 * 0.3 * 0.81
élec_non_ironing = 5.59 MJ
élec_non_ironing = 1.55 kWh

impact_élec_non_ironing = élec_non_ironing * P_élec_fr_cch
Avec P_élec_fr_cch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française
impact_élec_non_ironing = 1.55 * 0.081
impact_élec_non_ironing = 0.13 kgCO2e


impact_eaux_lessive_non_ironing = n_cycles * m * P_non_ironing_cch
Avec P_non_ironing_cch : la quantité de kgCO2e émise pour le processus hors ironing (lessive + traitement des eaux usées) pour 1 kg de linge à laver.
impact_eaux_lessive_non_ironing = 23 * 0.3 * 3.4E-02
impact_eaux_lessive_non_ironing = 0.23 kgCO2e
```

Finalement on a :

```
impact = impact_ironing + impact_élec_non_ironing + impact_eaux_lessive_non_ironing
impact = 0.038 + 0.13 + 0.23
impact = 0.40 kgCO2e
```

