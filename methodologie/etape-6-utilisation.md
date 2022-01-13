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

On peut exprimer l'impact de l'utilisation _Impact_\__utilisation_ de la manière suivante

$$
Impact_{utilisation} = Impact_{électricité} + Impact_{autre}
$$

Avec&#x20;

$$
Impact_{électricité} = Impact_{électricité - lavage} + Impact_{électricité - séchage} + Impact_{électricité - repassage}
$$

Et

$$
Impact_{autre} = Impact_{lessive} + Impact_{eaux \_usées}
$$

Tous ces impacts sont directement proportionnels au nombre de cycles d'entretiens effectuées _n\_cycles_. On peut donc écrire :&#x20;

$$
Impact_{utilisation} = n_{cycles} \times (I_{électricité - lavage} + I_{électricité - séchage} + I_{électricité - repassage} + I_{lessive} + I_{eaux \_usées})
$$

Avec I\_x l'impact unitaire d'un cycle de x&#x20;

### Impacts non différenciés par type de produit

#### Electricité - Lavage

$$
Impact_{électricité\_lavage} = n_{cycles} \times m \times I_{kWh/kg\_lavage} \times C_{impact/kWh}
$$

Avec _m_ la masse de la pièce textile

_I\_kWh/kg_\__lavage la quantité d'électricité nécessaire à laver 1 kg de vêtement_

_C\_impact/kWh l'impact de la production d'1 kWh d'électricité dans le pays concerné_

#### Lessive - Lavage

$$
Impact_{lessive} = n_{cycles} \times m \times I_{kg\_lessive/kg\_lavage}\times C_{impact/kg\_lessive}
$$

#### Traitement des eaux usées - Lavage

$$
Impact_{eaux\_usées} = n_{cycles} \times m \times I_{L\_eaux\_usées/kg\_lavage}\times C_{impact/L\_eaux\_usées}
$$

### Impacts différenciés par type de produit

Par hypothèse chaque impact unitaire d'un cycle est indépendant du type de produit (T-Shirt, jupe, pantalon, ...), à l'exception des impacts du sèchage et du repassage.&#x20;

#### Electricité - Séchage

Pour l'étape de séchage en sèche-linge, en accord avec le PEFCR Apparel & Footwear (Table 33) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un T-Shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séché en sèche-linge que 12% du temps.

$$
Impact_{élec\_séchage}(prod) = n_{cycles} \times m\times ratio_{sèche-linge}(prod) \times I_{kWh/kg\_sèche-linge} \times C_{impact/kWh}
$$

#### Electricité - Repassage

Pour l'étape de repassage, en accord avec le PEFCR Apparel & Footwear (Table 33) on applique un ratio de produits repassés différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un T-Shirt a un temps de repassage de 2 min tandis qu'un pantalon a un temps de repassage de 4,3 min.

$$
Impact_{électricité\_repassage}(prod) = n_{cycles} \times ratio_{repassage}(prod) \times temps_{repassage}(prod) \times I_{kWh/temps\_repassage} \times C_{impact/kWh}
$$

Tableau avec les ratio\_sèche-linge ratio\_repassage temps repassage selon le type de produit



Finalement

$$
Impact_{électricité\_lavage\_séchage}(prod) = n_{cycles} \times m \times (I_{kWh/kg\_lavage} +ratio_{sèche-linge}(prod) \times I_{kWh/kg\_séchage}) \times C_{impact/kWh}
$$

$$
Impact_{lessive\_eaux\_usées} = n_{cycles} \times m \times ( I_{kg\_lessive/kg\_lavage}\times C_{impact/kg\_lessive} + I_{L\_eaux\_usées/kg\_lavage}\times C_{impact/L\_eaux\_usées})
$$

On peut résumer ça en 2 procédés :&#x20;



$$
Impact_{électricité\_repassage}(prod) = n_{cycles} \times I_{repassage}(prod)
$$



$$
Impact_{utilisation\_hors\_repassage}(prod) = n_{cycles} \times  m \times I_{utilisation\_hors\_repassage}(prod)
$$

















$$
Impact_{utilisation}(prod) = n_{cycles} \times [  m \times ((I_{kWh/kg\_lavage} +ratio_{sèche-linge}(prod) \times I_{kWh/kg\_séchage}) \times C_{impact/kWh} + I_{kg\_lessive/kg\_lavage}\times C_{impact/kg\_lessive} + I_{L\_eaux\_usées/kg\_lavage}\times C_{impact/L\_eaux\_usées}) + ratio_{repassage}(prod) \times temps_{repassage}(prod) \times I_{kWh/temps\_repassage} \times C_{impact/kWh}]
$$



