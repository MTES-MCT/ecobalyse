---
hidden: true
---

# 🌀 Etape 7 - Utilisation (New)

## Contexte

### Impacts pris en compte

Les impacts de la phase d'utilisation concernent l'entretien du vêtement. Conformément à la documentation textile de la Base Impacts, nous prenons en compte les impacts suivants :

* Lavage - Électricité
* Lavage - Lessive
* Lavage - Traitement des eaux usées
* Séchage - Électricité
* Repassage - Électricité

### Durée de vie des vêtements

La durée de vie se définie en nombres de jours portés. Celle-ci est spécifique à chaque catégorie de vêtement (ex : 45 jours pour un t-shirt) et définie dans Ecobalyse (cf. [explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products)). Ces valeurs ont été définies en s'appuyant sur les données du projet de PEFCR Apparel & Footwear lorsque disponibles.

Le coefficient de durabilité (cf. la section [Durabilité](https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite)) vient corriger le nombre de jours portés.&#x20;

Plus un vêtement est durable, plus élevé sera sa durée de vie et donc son nombre de jours portés.

### Repassage

Pour l'étape de repassage, le PEFCR Apparel & Footwear, propose d'appliquer un ratio de produits repassés en fonction de la catégorie de produit. Par exemple on fait l'hypothèse qu'une chemise est repassé 70% du temps tandis qu'un pull n'est jamais repassé. De plus on fait l'hypothèse que le temps de repassage est différent pour chaque type de vêtement. Ainsi on suppose qu'un T-Shirt a un temps de repassage de 2 min tandis qu'un pantalon a un temps de repassage de 4,3 min.

## Méthodes de calcul

### Impact de l'utilisation&#x20;

$$
I_{7} = n_{cycles}*m*\Big(E_{7,hors repassage}*I_{élec} + I_{7,i} +E_{repassage,i}*I_{élec}\Big)
$$

Avec :&#x20;

* `I_7` : I'impact environnemental associé à l'utilisation du vêtement sur sa durée de vie, exprimé en unité de la catégorie d'impact analysée.
* `n_cycles` : le nombre de cycles d'entretiens du vêtement, sur l'ensemble de sa durée de vie, sans unité
* `m` : la masse du vêtement, en kg
* `E_7,horsrepassage,i` : la quantité d'électricité moyenne consommée (hors repassage) pour le cycle d'entretien d'un kg de vêtement de la catégorie `i`, en kWh/kg. Cette quantité est définie dans le procédé `Utilisation : Impact hors repassage (i)` comme flux externe.
* `I_elec` : l'impact environnemental pour 1 kWh d'électricité, exprimé en unité de la catégorie d'impact analysée
* `I_7,i` : I'impact environnemental associé à l'entretien d'1kg de vêtement de la catégorie i, exprimé en unité de la catégorie d'impact analysée par kg. Il s'agit de l'impact du procédé  `Utilisation : Impact hors repassage (i)`&#x20;
* `E_repassage,i` : la quantité d'électricité moyenne consommée associée au repassage, pour le cycle d'entretien d'un kg de vêtement de la catégorie i, en kWh/kg.&#x20;

### Durée de vie et nombre de cycles d'entretien

#### Nombre de cycles par défaut

Un nombre de cycle d'entretien par défaut est calculé pour chaque catégorie de vêtement i, en fonction de la durée de vie du vêtement (en nombre de jours portés) et de la durée entre deux cycles d'entretien (en jours) :

$$
n_{cycles,i,defaut}= \frac{d_{portés,i}}{d_{cycle.entretien,i}}
$$

Avec :&#x20;

* `n_cycles,i,defaut` : le nombre de cycles d'entretien par défaut pour la catégorie de produit i ;
* `d_portés,i` : la durée de vie du vêtement, en nombre de jours portés ;
* `d_cycle.entretien,i` : la durée entre deux cycles d'entretiens, en nombre de jours.

#### Nombre de cycles d'entretien du vêtement

Un nombre de cycle est calculé pour chaque vêtement, calculé en fonction du nombre de cycle par défaut et de son coefficient de durabilité :&#x20;

$$
n_{cycles}= n_{cycles,i,defaut}*C_{Durabilité}
$$

Avec :&#x20;

* `n_cycles` : le nombre de cycles d'entretien pour la catégorie de produit i ;
* `n_cycles,i,defaut` : le nombre de cycles d'entretien par défaut pour la catégorie de produit i ;
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité ;

{% hint style="info" %}
Par exemple, pour un t-shirt avec une durabilité élevée (coefficient de x1,35); le nombre de cycles d'entretiens retenu dans le calcul serait de 61 jours (45\*1,35).
{% endhint %}

### Energie pour le repassage

$$
E_{repassage_i} = r_{repassage,i}*t_{repassage,1}*E_{repassage,heure}
$$

Avec :&#x20;

* `E_repassage,i` : la quantité d'électricité moyenne consommée associée au repassage, pour le cycle d'entretien d'un kg de vêtement de la catégorie i, en kWh/kg ;
* `r_repassage,i` : la part des vêtements de la catégorie i faisant l'objet d'un repassage, exprimé en pourcentage et situé entre 0% et 100% ;
* `t_repassage,i` : le temps de repassage d'un vêtement de la catégorie i, exprimé en heures ;
* `P_repassage,heure` : la puissance électrique nécessaire au repassage (ou consommation d'électricité moyenne pour une heure de repassage), en kWh ;

## Paramètres retenus pour le coût environnemental

### Calcul du nombre de cycles d'entretien

Les paramètres suivants sont fournis pour chaque catégorie de produit dans l'[Explorateur ](https://ecobalyse.beta.gouv.fr/#/explore/textile/products):&#x20;

* `n_cycles,i,defaut` : colonne _Cycles d'entretien (par défaut)_ ;
* `d_portés,i` : colonne _Nombre de jours porté_ ;
* `d_cycle.entretien,i` : colonne _Utilisations avant lavage_.

### Repassage

Les paramètres suivants sont fournis pour chaque catégorie de produit dans l'[Explorateur produits ](https://ecobalyse.beta.gouv.fr/#/explore/textile/products):&#x20;

* `E_repassage,i` : colonne _Repassage_ ;
* `r_repassage,i` : colonne _Repassage, part_ ;
* `t_repassage,i` : colonne _Repassage, temps_ ;

La consommation d'électricité est obtenue à partir de la puissance suivante :

* `P_repassage,heure` : 1,5 kW (documentation ADEME) ;

## Procédés utilisés pour le coût environnemental

### Impacts hors repassage : `Utilisation : Impact hors repassage (i)`&#x20;

Des procédés dédiés nommés `Utilisation : Impact hors repassage (i)`, avec `i` la catégorie de produit, ont été créés pour chaque catégorie de produit i. Ces procédés sont identifiés pour chaque catégorie de produit dans l'[Explorateur produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), dans la colonne "_Procédé d'utilisation hors-repassage_". sous la dénomination ".

Ces procédés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).

Ils ont été construits spécifiquement par Ecobalyse.

Ils précisent une consommation d'électricité, modélisée comme flux externe, ainsi que des impacts environnementaux.

Les calculs de ces deux composantes sont précisés dans les deux sous-parties suivantes

#### Consommation d'électricité pour 1kg de vêtement (hors repassage)

E=E\_{lavage}+r\_{séchage,i}\*E\_{sechage}

E\_lavage _: la quantité d'électricité nécessaire à laver 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.1847 kWh/kg_

Pour l'étape de séchage en sèche-linge, en accord avec le projet de PEFCR Apparel & Footwear (Table 33 - version de l'été 2021) on applique un ratio de produits séchés en sèche-linge différent pour chaque type de produit. Par exemple on fait l'hypothèse qu'un T-Shirt est séché en sèche-linge 30% du temps tandis qu'une jupe n'est séchée en sèche-linge que 12% du temps.

* r\_séchage,i _: la part de vêtement qui va être séché en sèche-linge (unité : sans unité)_
* E\_sechage _: la quantité d'électricité nécessaire à sécher 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.335 kWh par kg de linge séché._

#### Impacts environnementaux pour 1kg de vêtement (hors repassage)

#### Lessive

_F\_kg\_lessive/kg\_lavage : la masse de lessive nécessaire à laver 1 kg de vêtement (unité : kg/kg = sans unité). En accord avec la documentation ADEME on prend une valeur de 0.036 kg lessive par kg de linge lavé._

_C\_impact/kg\_lessive : l'impact de la production d'1 kg de lessive (unité : impact/kg)_



#### Traitement des eaux usées

_F\_m3\_eaux/kg\_lavage : le volume d'eau nécessaire pour laver 1 kg de vêtement (unité : m3/kg). En accord avec la documentation ADEME on prend une valeur de 0.0097 m3 par kg de linge lavé._

_C\_impact/m3\_eaux : l'impact du traitement d'1 m3 d'eaux usées (unité : impact/m3)_

### Séchage

#### Électricité





Lavage et séchage

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + I_{eaux\_usées} + I_{élec\_séchage}
$$



Lessive

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + I_{eaux\_usées} + I_{élec\_séchage} + I_{élec\_repassage}
$$



Eaux usées

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + I_{eaux\_usées} + I_{élec\_séchage} + I_{élec\_repassage}
$$



Repassage

$$
I_{élec\_repassage}=X
$$



Avec :&#x20;

Repassage

#### Électricité

Avec





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



## Exemple d'application

{% hint style="info" %}
\[optionnel mais utile] Application à un exemple, pour permettre une meilleure compréhension au lecteur
{% endhint %}

