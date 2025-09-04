---
hidden: true
---

# 🌀 Etape 7 - Utilisation (New)

{% hint style="danger" %}
Cet encadré rouge et les 4 encadrés en gris doivent être supprimés avant mise en ligne
{% endhint %}

## Contexte

### Nombre de jours portés

Une durée moyenne d'utilisation spécifique à chaque catégorie de vêtement (ex : 45 jours pour un t-shirt) est définie dans Ecobalyse (cf. [explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products)). Ces valeurs ont été définies en s'appuyant sur les données du projet de PEFCR Apparel & Footwear lorsque disponibles.

De plus, un coefficient de durabilité (entre x0,5 et x1,5) a été introduit afin de préciser le nombre d'utilisation de chaque vêtement selon ses dimensions physiques et non physiques (cf. la section [Durabilité](https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite)). Plus un vêtement est durable, plus élevés seront sa durée de vie et donc son nombre de jours portés.

{% hint style="info" %}
Il s’agit d’éléments de contexte sectoriels, permettant au lecteur de comprendre le sujet abordé.

Cette partie n’est pas utile pour le développement du produit. Elle peut permettre d’introduire des choix méthodologiques, mais pas des choix de paramètres.

Elle peut se limiter à une phrase d’introduction.
{% endhint %}

### Impacts pris en compte

Les impacts de la phase d'utilisation concernent l'entretien du vêtement. Conformément à la documentation textile de la Base Impacts nous prenons en compte les impacts suivants :

* Lavage - Électricité
* Lavage - Lessive
* Lavage - Traitement des eaux usées
* Séchage - Électricité
* Repassage - Électricité

## Méthodes de calcul

### Nombre de jours portés et nombre de cycles d'entretien

Un nombre de cycle d'entretien par défaut est calculé pour chaque catégorie de vêtement i, en fonction de la durée de vie du vêtement (en nombre de jours portés) et de la durée entre deux cycles d'entretien (en jours) :

$$
n_{cycles,i,defaut}= \frac{d_{portés,i}}{d_{cycle.entretien,i}}
$$

Un nombre de cycle corrigé est utilisé, calculé en fonction du coefficient de durabilité :&#x20;

$$
n_{cycles,i}= n_{cycles,i,defaut}*C_{durabilité}
$$

### Impact par cycle d'entretien

nombre de cycle d'entretien par défaut

$$
I_{7} = n_{cycles,i}*m*\Big(E_{7,hors repassage}*I_{élec} + I_{7,i} +E_{repassage,i}*I_{élec}\Big)
$$

Avec :

* `I_élec_lavage` : l'impact dans l'indicateur sélectionné de l'électricité due au lavage du produit (unité : impact)
* `I_7,i` : Procédé d'utilisation hors-repassage



Repassage :&#x20;



$$
E_{repassage_i} = r_{repassage,i}*t_{repassage,1}*E_{repassage,heure}
$$

| Nombre de jours porté\* ↕ | Utilisations avant lavage\* ↕ | Cycles d'entretien (par défaut)\*\* ↑ | Repassage\* ↕ | Procédé d'utilisation hors-repassage\*\* ↕ | Séchage électrique\* ↕ | Repassage (part)\* ↕ | Repassage (temps)\* |
| ------------------------- | ----------------------------- | ------------------------------------- | ------------- | ------------------------------------------ | ---------------------- | -------------------- | ------------------- |

{% hint style="info" %}
Par exemple, pour un t-shirt avec une durabilité élevée (coefficient de x1,35); le nombre de jours d'utilisation retenu dans le calcul serait de 61 jours (45\*1,35).
{% endhint %}

{% hint style="info" %}
Cette partie se compose essentiellement de formules de calcul et de l’introduction des paramètres mobilisés. Elle est très voire exclusivement “mathématique”, sans chiffre.

Ci-dessous un exemple pour l'ennoblissement
{% endhint %}

Lavage et séchage

$$
I_{utilisation} = I_{élec\_lavage} + I_{lessive} + I_{eaux\_usées} + I_{élec\_séchage} + I_{élec\_repassage}
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



_m_ : la masse de la pièce textile (unité : kg)

_F\_kWh/kg\_lavage : la quantité d'électricité nécessaire à laver 1 kg de vêtement (unité : kWh/kg). En accord avec la documentation ADEME on prend une valeur de 0.1847 kWh/kg_

_C\_impact/kWh : l'impact de la production d'1 kWh d'électricité dans le pays concerné (unité : impact/kWh)_

_Sur l'interface, il est proposé de faire varier le nombre de cycles d'entretien (n\_cycles(p)), afin de visualiser les modifications d'impacts si un vêtement est entretenu plus souvent, ce qui correspond généralement à un vêtement porté plus longtemps._\
&#xNAN;_&#x53;i l'impact global augmente avec le nombre de cycle d'entretien, l'impact par nombre de jour d'utilisation du même vêtement va en revanche diminuer. Cet aspect sera exploré prochainement à travers le projet de PERCR Apparel & Footwear._

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

* <mark style="color:red;">`I_ennoblissement`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'ennoblissement, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`m`</mark> <mark style="color:red;"></mark><mark style="color:red;">la masse de tissu, exprimée en kg. Pour plus d'information sur la gestion des masses cf. la section</mark> [<mark style="color:red;">Pertes et rebut</mark>](../precisions-methodologiques/pertes-et-rebus.md)<mark style="color:red;">.</mark>
* <mark style="color:red;">`e_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la quantité d'électricité nécessaire au procédé i pour 1 kg de tissu, en kWh/kg</mark>
* <mark style="color:red;">`a_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: Le taux d'application du procédé i pour le vêtement évalué, sans unité</mark>
  * <mark style="color:red;">Egal à 1 si le procédé est mobilisé pour ce vêtement</mark>
  * <mark style="color:red;">Egal à 0 si le procédé n'est pas mobilisé</mark>
  * <mark style="color:red;">Situé entre 0 et 1 pour l'impression (voir paragraphe dédié)</mark>
* <mark style="color:red;">`I_elec`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`c_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la quantité de chaleur nécessaire au procédé i pour 1 kg de tissu, en MJ/kg</mark>
* <mark style="color:red;">`I_chaleur`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée.</mark>

## Paramètres retenus pour le coût environnemental

{% hint style="info" %}
Les paramètres retenus pour l’affichage environnemental sont présentés dans une partie séparée des formules de calcul, de façon à identifier facilement ce qui relève de la structure et ce qui relève du paramétrage.\
Cette distinction devrait être en miroir de ce qui est dans le code.\
Ne pas hésiter à renvoyer vers des pages de code si le nombre de paramètres est important mais à faible enjeu.
{% endhint %}

### Paramètres spécifiques pour l'affichage environnemental réglementaire



## Procédés utilisés pour le coût environnemental

Des procédés dédiés ont été créés pour chaque catégorie de produit.



{% hint style="info" %}
A priori un renvoi vers l'explorateur suffit ici. Si des procédés spécifiques sont construits, ils peuvent être expliqués ici.
{% endhint %}

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), avec les noms utilisés dans cette page.

## Exemple d'application

{% hint style="info" %}
\[optionnel mais utile] Application à un exemple, pour permettre une meilleure compréhension au lecteur
{% endhint %}

