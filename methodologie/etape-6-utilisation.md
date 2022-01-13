---
description: >-
  Cette page décrit la modélisation de l'étape d'utilisation du cycle de vie
  d'un vêtement
---

# Etape 6 - Utilisation

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

Certaines grandeurs sont dépendantes du type de produit (jupe, pantalon, t-shirt). Pour indiquer cette dépendance on les noteras (p). Par exemple le nombre de cycles d'entretien par défaut est différent pour chaque type de produit. Il est de 45 pour un T-shirt et de 5 pour un manteau.

### Détail des calculs&#x20;

### Lavage

#### Electricité&#x20;

$$
I_{élec\_lavage} = n_{cycles}(p) \times m \times F_{kWh/kg\_lavage} \times C_{impact/kWh}
$$

Avec&#x20;

_I_\__élec\_lavage : l'impact dans l'indicateur sélectionné de l'électricité du au lavage du produit (unité : impact)_

_n\_cycles(p) :_ nombre de cycles d'entretien par défaut (unité : sans unité)

_m_ : la masse de la pièce textile (kg)

_FkWh/kglavage : la quantité d'électricité nécessaire à laver 1 kg de vêtement (kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.1847 kWh/kg_

_C\_impact/kWh :  l'impact de la production d'1 kWh d'électricité dans le pays concerné (impact/kWh)_

#### Lessive

$$
I_{lessive} = n_{cycles}(p) \times m \times F_{kg\_lessive/kg\_lavage} \times C_{impact/kg\_lessive}
$$

_F\_kg\_lessive/kg\_lavage : la masse de lessive nécessaire à laver 1 kg de vêtement (unité : sans unité). En accord avec la documentation ADEME on prend une valeur de 0.036 kg lessive par kg de linge lavé._

_C\_impact/kg\_lessive :  l'impact de la production d'1 kg de lessive (impact/kg)_

#### Traitement des eaux usées

$$
I_{eaux\_usées} = n_{cycles}(p)\times m \times F_{m3\_eaux/kg\_lavage} \times C_{impact/m3\_eaux}
$$

_F\_m3\_eaux/kg\_lavage : le volume d'eau nécessaire pour laver 1 kg de vêtement (unité : m3/kg). En accord avec la documentation ADEME on prend une valeur de 0.0097 m3 par kg de linge lavé._&#x20;

_C\_impact/m3\_eaux :  l'impact du traitement d'1 m3 d'eaux usées (unité : impact/m3)_

### Séchage

#### Electricité

Pour l'étape de séchage en sèche-linge, en accord avec le PEFCR Apparel & Footwear (Table 33) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un T-Shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séché en sèche-linge que 12% du temps.

$$
I_{élec\_séchage} = n_{cycles}(p) \times m\times ratio_{sèche-linge}(p) \times F_{kWh/kg\_sèche-linge} \times C_{impact/kWh}
$$

_ratio_\__sèche-linge(p) : la part de vêtement qui va être séché en sèche-linge (unité : sans unité)_

_F\_kWh/kg\_sèche-linge : la quantité d'électricité nécessaire à sécher 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.335 kWh par kg de linge séché._&#x20;

### Repassage

#### Electricité

Pour l'étape de repassage, en accord avec le PEFCR Apparel & Footwear (Table 33) on applique un ratio de produits repassés différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un T-Shirt a un temps de repassage de 2 min tandis qu'un pantalon a un temps de repassage de 4,3 min.

$$
I_{élec\_rpsg} = n_{cycles}(p)\times ratio_{rpsg}(p) \times tps_{rpsg}(p) \times F_{kWh/tps\_rpsg} \times C_{impact/kWh}
$$

_ratio_\__rpsg(p) : la part de vêtement qui va être repassé (unité : sans unité)_

_tps_\__rpsg(p) : le temps qui va être passé pour repasser un produit (unité : heure)_

_F\_kWh/tps\_rpsg : la quantité d'électricité nécessaire à repasser 1 h (unité : kWh/h = kW). En accord avec la documentation ADEME on prend une valeur de 1,5 kW._





