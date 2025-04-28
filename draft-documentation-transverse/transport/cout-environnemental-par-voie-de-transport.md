---
description: >-
  Cette page décrit le calcul du coût environnemental pour chacune des voies de
  transport.
---

# Coût environnemental par voie de transport

{% hint style="info" %}
Dans cette page, les définitions et paramètres suivants sont utilisés :

* `i` la voie de transport (terre, mer, air, fer)
* `j` le mode de transport (camion, bateau, avion, train)
* `D_i,j` la distance effectuée par la voie i avec le mode de transport j
{% endhint %}

## Méthodes de calcul

### Méthode générale

À chaque étape, le coût environnemental du transport pour une voie de transport i est calculé de la façon suivante :

$$
I_{v_i}=Masse*(D_{i,1}∗I_{m_1}+D_{i, 2}∗I_{m_2})
$$

Avec :&#x20;

* `I_v_i` : le coût environnemental par voie, exprimé en points d'impact Pts
* `Masse` : la masse de produit transporté, exprimée en tonnes. Une conversion est donc à prendre en compte par rapport à la masse en kg dans les autres parties des calculs. La masse transportée dépend de l'étape du cycle de vie à laquelle a lieu le transport.
* `D_i,j` : la distance parcourue par le mode de transport j pour la voie i, exprimée en km
  * `D_mer,bateau` , `D_terre,camion`,`D_air,avion` , `D_fer,train` sont des paramètres dont les valeurs sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".
  * Le calcul de `D_i,camion` est précisé dans la section suivante (hors voie terre)
  * Les autres distances ne sont pas applicables
* `I_m_j` : le coût environnemental du mode j, exprimé en Pts/t.km

### Calcul de la distance en camion sur les voies hors route

$$
D_{i, camion}=min(D_{i,camion,défaut};\frac {D_{terre,camion}}{2})
$$

Avec :&#x20;

* `D_i,camion` : la distance parcourue en camion pour la voie i (mer, air, ou fer), exprimée en km
* `D_i,camion,défaut` = la distance par défaut parcourue par camion pour la voie i (mer, air, ou fer), exprimée en km
* `D_terre,camion` = distance parcourue par camion pour la voie terrestre, exprimée en km

### Transport au sein d'un même pays

Lorsque deux étapes successives sont réalisées dans un même pays, les distances concernées sont calculées comme suit :&#x20;

$$
D_{terre, camion}=D_{terre, camion,interne}
$$

$$
D_{air, avion}=D_{air, avion,interne} ;D_{air,camion}=(D_{terre, camion,interne})/2
$$

$$
D_{fer,train}=D_{fer,train,interne}
$$

Les distances non mentionnées ici ne s'appliquent pas pour le transport interne à un pays.

## Paramètres retenus pour l’affichage environnemental

### Distances entre pays

La distance pour chaque voie et mode de transport est calculés en fonction du pays d'origines et de destination pour chaque étape de transport considérée.

Le tableau suivant décrit les sources de données et le mode de calcul des distances pour dans la situation où l'utilisateur connais les pays d'origine et de destination, et ceux-ci sont proposés dans Ecobalyse (Situation 1).

<table><thead><tr><th width="170">Distances</th><th>Source</th></tr></thead><tbody><tr><td>D_terre,camion</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par le PEF, <a href="https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf">Product Environmental Footprint Category Rules Guidance</a>, 7.14.3 From factory to final client)</td></tr><tr><td>D_mer, bateau</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_air, avion</td><td>Distance à vol d'oiseau calculée avec geopy.distance, entre le centre de chaque pays.</td></tr><tr><td>D_fer, train</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr></tbody></table>

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json) (hors distances vers et depuis les ports et aéroports).

### Situations où l'un des pays n'est pas connu ou pas proposé dans Ecobalyse

<details>

<summary>Situation 2 : je connais le pays mais il n'est pas proposé dans Ecobalyse</summary>

Dans ce cas, il faut choisir la région du pays.\
Exemple pour le pays _Allemagne ⇒_ je sélectionne la région _Europe de l'Ouest._

Afin de définir les distances et modes de transport utilisés pour chaque région, un pays est défini en arrière plan :

* Europe de l'Ouest = Espagne
* Europe de l'Est = République Tchèque
* Asie = Chine
* Afrique = Ethiopie
* Amérique du Nord = Etats-Unis
* Amérique latine = Brésil
* Océanie = Australie
* Moyen-Orient = Turquie

Le transport est ensuite calculé de la même façon que si ce pays était directement sélectionné.

</details>

<details>

<summary>Situation 3 : je ne connais pas le pays </summary>

Je sélectionne "Inconnu" ou "Inconnu (par défaut)"

Dans ce cas, les distances suivantes sont fixées par défaut, en cohérence avec la méthode PEF ([Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client) :&#x20;

* D\_mer, bateau = 18 000 km
* D\_mer, camion = D\_mer, camion, défaut
* D\_air, air = 10 000 km
* D\_air, camion = D\_air, camion, défaut
* D\_fer, fer = 10 000 km
* D\_fer, camion = D\_fer, camion, défaut
  * En pratique, le transport ferroviaire n'est pas mobilisé dans les scénarios par défaut.&#x20;

</details>

### Distances `D_i,camion` par défaut

Les autres distances sont paramétrées comme suit pour l'affichage environnemental :

* D\_mer,camion,défaut = 1000 km
* D\_air,camion,défaut = 1000 km
* D\_fer,camion,défaut = 0 km

### Distances de transport au sein d'un même pays

* D\_terre,interne = 500 km
* D\_air,avion,interne = 500 km
* D\_fer,train,interne = 500 km

## Procédés utilisés

Sauf indication contraire spécifique, les modes de transport sont modélisés par les procédés suivants, définissant les coûts environnementaux `I_m_j` :

<table><thead><tr><th width="230">Type de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Camion</td><td>market group for transport, freight, lorry, unspecified, GLO (Ecoinvent)</td></tr><tr><td>Camion frigorifique</td><td>market for transport, freight, lorry with refrigeration machine, 7.5-16 ton, diesel, EURO 5, R134a refrigerant, cooling</td></tr><tr><td>Bateau</td><td>market for transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Bateau frigorifique</td><td>market for transport, freight, sea, container ship with reefer, cooling, GLO (Ecoinvent)</td></tr><tr><td>Avion</td><td>market for transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr><tr><td>Train</td><td>market group for transport, freight train, GLO (Ecoinvent)</td></tr></tbody></table>

{% hint style="info" %}
Le choix est fait de ne pas différencier les procédés en fonction de la géographie ou du type de produit, à des fins de simplification, et au regard de l'impact sur le coût environnemental global des produits. A titre d'exemple, le procédé Ecoinvent "transport, freight, lorry 16-32 metric ton, EURO5, RER" a un coût environnemental presque égale à celui du procédé "market group for transport, freight, lorry, unspecified" (différence inférieure à 1%), alors que le transport par camion représente en général une faible part du coût environnemental d'un produit.
{% endhint %}

Il en résulte les coûts environnementaux par mode de transport suivant (correspondant aux valeurs `I_m_j` ci-dessus) :&#x20;

<figure><img src="../../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

