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

## Distances et mode de transport

La distance pour chaque voie et mode de transport est calculés en fonction du pays d'origines et de destination pour chaque étape de transport considérée.

Le tableau suivant décrit les sources de données et le mode de calcul des distances pour dans la situation où l'utilisateur connais les pays d'origine et de destination, et ceux-ci sont proposés dans Ecobalyse (Situation 1).

<table><thead><tr><th width="170">Distances</th><th>Source</th></tr></thead><tbody><tr><td>D_terre</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par le PEF, <a href="https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf">Product Environmental Footprint Category Rules Guidance</a>, 7.14.3 From factory to final client)</td></tr><tr><td>D_mer, bateau</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_mer, camion</td><td><code>=min(D_mer,camion,défaut;D_terre/2)</code></td></tr><tr><td>D_air, avion</td><td>Distance à vol d'oiseau calculée avec geopy.distance, entre le centre de chaque pays.</td></tr><tr><td>D_air, camion</td><td><code>=min(D_air,camion,défaut;D_terre/2)</code></td></tr><tr><td>D_fer, train</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_fer, camion</td><td>défini comme nul</td></tr></tbody></table>

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json) (hors istances vers et depuis les ports et aéroports).

### Transport au sein d'un même pays

Lorsque deux étapes successives sont réalisées dans un même pays, des distances par défaut sont considérées :

* Distance par voie terrestre : `D_terre,interne`
* Distance par voie aérienne : `D_air,avion,interne + D_terre,interne/2`
* Distance par voie ferroviaire : `D_fer,train,interne`
* Le transport maritime est exclu.

### Situations où l'un des pays n'est pas connu ou pas proposé dans Ecobalyse

<details>

<summary>Situation 2 : je connais les pays d'origine et de destination, mais ou ou les deux pays ne sont proposé dans Ecobalyse</summary>

Je sélectionne la région (ex : _Europe de l'Ouest_ pour _Allemagne_)

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

<summary>Situation 3 : je ne connais pas le pays de départ et/ou celui d'arrivée pour l'étape considérée</summary>

Je sélectionne "Inconnu (par défaut)"

Dans ce cas, les distances suivantes sont fixées par défaut, en cohérence avec la méthode PEF ([Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client) :&#x20;

* 1000 km de transport routier, correspondant au transport de l'usine au port ou aéroport de départ et au transport du port ou aéroport d'arrivée à l'usine ou lieu de stockage d'arrivée
* 18 000 km de transport maritime ou 10 000 km de transport aérien (pas de transport par train)

</details>

## Coût environnemental pour une voie de transport

À chaque étape, le coût environnemental du transport pour une voie de transport i est calculé de la façon suivante :

$$
CE_i=Masse*(D_{i,1}∗CE_1+D_{i, 2}∗CE_2)
$$

Avec :&#x20;

* `CEv_i` : le coût environnemental par voie, exprimé en points d'impact Pts
* `Masse` : la masse de produit transportée, exprimée en tonnes. Une conversion est donc à prendre en compte par rapport à la masse en kg dans les autres parties des calculs. La masse transportée est celle du produit fini, à laquelle s'ajoutent les pertes liées aux étapes de transformation aval
* `D_i,j` : la distance parcourue par le mode de transport j pour la voie i, exprimée en km
* `CEm_j` : le coût environnemental du mode j, exprimé en Pts/t.km

## Paramètres retenus pour l'affichage environnemental

Les autres distances sont paramétrées comme suit pour l'affichage environnemental :

* D\_mer, camion, défaut = 1000 km
* D\_air, camion, défaut = 1000 km
* D\_fer, camion, défaut = 0 km
* D\_terre,interne = 500 km
* D\_air,avion,interne = 500 km
* D\_fer,train,interne = 500 km
* D\_terre,distriFR = 500km

## Procédés utilisés

Sauf indication contraire spécifique, les modes de transport sont modélisés par les procédés suivants, définissant les coûts environnementaux `CE_i,j` :

<table><thead><tr><th width="230">Type de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Camion</td><td>market group for transport, freight, lorry, unspecified, GLO (Ecoinvent)</td></tr><tr><td>Camion frigorifique</td><td></td></tr><tr><td>Bateau</td><td>market for transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Bateau frigorifique</td><td></td></tr><tr><td>Avion</td><td>market for transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr><tr><td>Train</td><td>market group for transport, freight train, GLO (Ecoinvent)</td></tr></tbody></table>

{% hint style="info" %}
Le choix est fait de ne pas différencier les procédés en fonction de la géographie ou du type de produit, à des fins de simplification, et au regard de l'impact sur le coût environnemental global des produits. A titre d'exemple, le procédé Ecoinvent "transport, freight, lorry 16-32 metric ton, EURO5, RER" a un coût environnemental presque égale à celui du procédé "market group for transport, freight, lorry, unspecified" (différence inférieure à 1%), alors que le transport par camion représente en général une faible part du coût environnemental d'un produit.
{% endhint %}

Il en résulte les coûts environnementaux par mode de transport suivant (correspondant aux valeurs CE\_i,j ci-dessus) :&#x20;

<figure><img src="../../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

