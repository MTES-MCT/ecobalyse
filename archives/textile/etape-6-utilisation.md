---
description: >-
  Cette page décrit la modélisation de l'étape d'utilisation du cycle de vie
  d'un vêtement
hidden: true
---

# 🌀 Etape 7 - Utilisation (old) - archive

L'étape Utilisation consiste à modéliser le nombre de jours portés du vêtement ainsi que les impacts associés.&#x20;

## Nombre de jours portés

Une durée moyenne d'utilisation spécifique à chaque catégorie de vêtement (ex : 45 jours pour un t-shirt) est définie dans Ecobalyse (cf. [explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products)). Ces valeurs ont été définies en s'appuyant sur les données du projet de PEFCR Apparel & Footwear lorsque disponibles.

De plus, un coefficient de durabilité (entre x0,5 et x1,5) a été introduit afin de préciser le nombre d'utilisation de chaque vêtement selon ses dimensions physiques et non physiques (cf. la section [Durabilité](https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite)). Plus un vêtement est durable, plus élevés seront sa durée de vie et donc son nombre de jours portés.

Dès lors, le nombre de jours d'utilisation modélisé dans Ecobalyse pour chaque vêtement est calculé ainsi :&#x20;

$$
NbJoursPortés= DuréeMoyenne* CoefficientDurabilité
$$

{% hint style="info" %}
Par exemple, pour un t-shirt avec une durabilité élevée (coefficient de x1,35); le nombre de jours d'utilisation retenu dans le calcul serait de 61 jours (45\*1,35).
{% endhint %}

## Impacts pris en compte

Les impacts de la phase d'utilisation concernent l'entretien du vêtement. Conformément à la documentation textile de la Base Impacts nous prenons en compte les impacts suivants :

* Lavage - Électricité
* Lavage - Lessive
* Lavage - Traitement des eaux usées
* Séchage - Électricité
* Repassage - Électricité

On peut exprimer l'impact de l'utilisation _I_\__utilisation_ de la manière suivante :

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + I_{eaux\_usées} + I_{élec\_séchage} + I_{élec\_repassage}
$$

Certains paramètres sont dépendants de la catégorie (jupe, pantalon, t-shirt,...) et de la durabilité du vêtement. Pour indiquer ces dépendances, nous utilisons le paramètre (p) spécifique à chaque vêtement.

Par exemple le nombre de cycles d'entretien est différent pour chaque catégorie de vêtement (45 pour un t-shirt vs 5 pour un manteau), ce qui exprime le fait que l'on va plus laver un t-shirt qu'un manteau pour une même durabilité.

Le mix électrique utilisé pour l'étape d'utilisation est l'électricité basse tension française, contrairement aux autres étapes.

<details>

<summary>Origine des données</summary>

Les procédés sont d'origine Ecoinvent SAUF pour 4 procédés Base Impacts mobilisés pour faire ce procédé précalculé  :

* proc\_landfill = "Mise en décharge de textiles, FR"&#x20;
* proc\_incineration = "Incinération de déchets - Déchets textiles, FR"
* &#x20;proc\_transport = "Transport en camion 7,5t (3t) France (dont parc, utilisation et infrastructure) (50%) \[tkm], FR"





<br>

</details>

<details>

<summary>Détail des calculs</summary>

### Lavage

#### Électricité

Avec

_I_\__élec\_lavage : l'impact dans l'indicateur sélectionné de l'électricité due au lavage du produit (unité : impact)_

_n\_cycles(p) :_ nombre de cycles d'entretien par défaut (unité : sans unité)

_m_ : la masse de la pièce textile (unité : kg)

_F\_kWh/kg\_lavage : la quantité d'électricité nécessaire à laver 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.1847 kWh/kg_

_C\_impact/kWh : l'impact de la production d'1 kWh d'électricité dans le pays concerné (unité : impact/kWh)_

_Sur l'interface, il est proposé de faire varier le nombre de cycles d'entretien (n\_cycles(p)), afin de visualiser les modifications d'impacts si un vêtement est entretenu plus souvent, ce qui correspond généralement à un vêtement porté plus longtemps._\
_&#x53;i l'impact global augmente avec le nombre de cycle d'entretien, l'impact par nombre de jour d'utilisation du même vêtement va en revanche diminuer. Cet aspect sera exploré prochainement à travers le projet de PERCR Apparel & Footwear._

#### Lessive

_F\_kg\_lessive/kg\_lavage : la masse de lessive nécessaire à laver 1 kg de vêtement (unité : kg/kg = sans unité). En accord avec la documentation ADEME on prend une valeur de 0.036 kg lessive par kg de linge lavé._

_C\_impact/kg\_lessive : l'impact de la production d'1 kg de lessive (unité : impact/kg)_

#### Traitement des eaux usées

_F\_m3\_eaux/kg\_lavage : le volume d'eau nécessaire pour laver 1 kg de vêtement (unité : m3/kg). En accord avec la documentation ADEME on prend une valeur de 0.0097 m3 par kg de linge lavé._

_C\_impact/m3\_eaux : l'impact du traitement d'1 m3 d'eaux usées (unité : impact/m3)_

### Séchage

#### Électricité

Pour l'étape de séchage en sèche-linge, en accord avec le projet de PEFCR Apparel & Footwear (Table 33 - version de l'été 2021) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un T-Shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séchée en sèche-linge que 12% du temps.

_ratio_\__sèche-linge(p) : la part de vêtement qui va être séché en sèche-linge (unité : sans unité)_

_F\_kWh/kg\_sèche-linge : la quantité d'électricité nécessaire à sécher 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.335 kWh par kg de linge séché._

### Repassage

#### Électricité

Pour l'étape de repassage, selon le PEFCR Apparel & Footwear, on applique un ratio de produits repassés différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un T-Shirt a un temps de repassage de 2 min tandis qu'un pantalon a un temps de repassage de 4,3 min.

_ratio_\__rpsg(p) : la part de vêtement qui va être repassé (unité : sans unité)_

_tps_\__rpsg(p) : le temps qui va être passé pour repasser un produit (unité : heure)_

_F\_kWh/tps\_rpsg : la quantité d'électricité nécessaire à repasser 1 h (unité : kWh/h = kW). En accord avec la documentation ADEME on prend une valeur de 1,5 kW._

</details>

## Méthodes de calcul

Pour une jupe avec un coefficient de durabilité de x1, on a n\_cycles = 23 et m = 0.3 kg

On sépare le calcul en 2 procédés :

* 1 procédé de repassage, proportionnel au nombre de cycles d'entretien n\_cycles. L'impact ne provient que de l'électricité nécessaire au chauffage,
* 1 procédé hors repassage comprenant les 4 autres procédés (élec lavage, élec séchage, lessive, eaux usées), proportionnel au nombre de cycles d'entretien **et** à la masse à laver.

```
impact = impact_ironing + impact_élec_non_ironing + impact_eaux_lessive_non_ironing
```

#### Procédé de repassage (ironing)

<pre><code><strong>impact_ironing = élec_ironing * P_élec_fr_cch
</strong>Avec P_élec_fr_cch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française

élec_ironing = n_cycles * P_ironing_élec
Avec  P_ironing_élec : la quantité d'électricité (MJ) nécessaire pour l'étape repassage du cycle d'entretien d'une jupe.

élec_ironing = 23 * 0.0729
élec_ironing = 1.68 MJ
élec_ironing = 0.47 kWh

d'où
impact_ironing = 0.47 * 0.081
impact_ironing = 0.038 kgCO2e
</code></pre>

#### Procédé hors repassage (non ironing)

```
élec_non_ironing = n_cycles * m * P_non_ironing_élec
Avec  P_non_ironing_élec : la quantité d'électricité (MJ) nécessaire pour l'étape hors repassage (lave-linge, sèche-linge) du cycle d'entretien d'une jupe.
élec_non_ironing = 23 * 0.3 * 0.81
élec_non_ironing = 5.59 MJ
élec_non_ironing = 1.55 kWh

impact_élec_non_ironing = élec_non_ironing * P_élec_fr_cch
Avec P_élec_fr_cch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française
impact_élec_non_ironing = 1.55 * 0.0729
impact_élec_non_ironing = 0.11 kgCO2e


impact_eaux_lessive_non_ironing = n_cycles * m * P_non_ironing_cch
Avec P_non_ironing_cch : la quantité de kgCO2e émise pour le processus hors ironing (lessive + traitement des eaux usées) pour 1 kg de linge à laver.
impact_eaux_lessive_non_ironing = 23 * 0.3 * 3.4E-02
impact_eaux_lessive_non_ironing = 0.23 kgCO2e
```

**Finalement on a :**

```
impact = impact_ironing + impact_élec_non_ironing + impact_eaux_lessive_non_ironing
impact = 0.038 + 0.11 + 0.23
impact = 0.38 kgCO2e
```
