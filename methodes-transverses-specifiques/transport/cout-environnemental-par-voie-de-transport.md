---
description: >-
  Cette page décrit le calcul du coût environnemental pour chacune des voies de
  transport.
---

# Coût environnemental par voie de transport

## Contexte

Lorsqu'un produit est transporté par voie maritime (voie `mer`), en général deux modes de transport sont mobilisés : le bateau, mais aussi le camion pour le transport terrestre vers le port d'origine et depuis le port de destination :&#x20;

<figure><img src="../../.gitbook/assets/image (373).png" alt=""><figcaption></figcaption></figure>

Il en est de même pour le transport par voie aérienne (voie `air`) :&#x20;

<figure><img src="../../.gitbook/assets/image (374).png" alt=""><figcaption></figcaption></figure>

Pour le transport par voie routière (voie `terre`), le camion est le seul mode de transport :&#x20;

<figure><img src="../../.gitbook/assets/image (391).png" alt=""><figcaption></figcaption></figure>

Enfin, pour le transport par voie ferroviaire (voie `fer`), il peut y avoir une combinaison avec du transport routier. Cependant, aujourd'hui l'essentiel du transport ferroviaire de marchandise (hors transport messagerie) est réalisé pour des produits industriels dont le producteur et le destinataire sont raccordés au réseau ferroviaire (exemples : usine automobile vers un centre de distribution, transport de bois). Cette voie de transport n'est pas encore implémentée dans Ecobalyse.

## Méthodes de calcul

### Méthode générale

À chaque étape, le coût environnemental du transport pour une voie de transport i est calculé de la façon suivante :

$$
I_{v.i}=\frac{m}{1000}*(D_{intrazone,depart}∗I_{camion}+D_{i}∗I_{m.2}*D_{intrazone,arrivée}∗I_{camion})
$$

Avec :&#x20;

* `I_v.i` : le coût environnemental par voie, exprimé en points d'impact Pts
* `m` : la masse de produit transporté, exprimée en kg. La masse transportée dépend de l'étape du cycle de vie à laquelle a lieu le transport.
* `D_intrazone,départ` et `D_intrazone,arrivée` : la distance parcourue en camion entre le site et le hub de transport régional, pour le pays ou la zone de départ et pour le pays ou la zone d'arrivée respectivement, exprimée en km.
  * Cette distance dépend du pays ou de la zone géographique sélectionnée. Les valeurs sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".
* `D_i` : la distance parcourue par le mode de transport principal i, exprimée en km
  * `D_mer,bateau` , `D_terre,camion`,`D_air,avion` , `D_fer,train` sont des paramètres dont les valeurs sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".
* `I_camion` : le coût environnemental du camion, exprimé en Pts/t.km
* `I_m.i` : le coût environnemental du mode i, exprimé en Pts/t.km

Pour un pays donné, `D_Hub,départ` est identique à `D_Hub,arrivée`.

### Transport au sein d'un même pays

Les valeurs sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".

Lorsque deux étapes successives sont réalisées dans un même pays, le coût environnemental du transport est calculé de la façon suivante :&#x20;

$$
I=\frac{m}{1000}*(D_{intrazone}∗I_{camion})
$$

Avec les paramètres définis précédemment.

## Paramètres retenus pour le coût environnemental

### Distances entre pays `D_i`

La distance pour chaque voie et mode de transport est calculés en fonction du pays d'origines et de destination pour chaque étape de transport considérée.

Le tableau suivant décrit les sources de données et le mode de calcul des distances pour dans la situation où l'utilisateur connais les pays d'origine et de destination, et ceux-ci sont proposés dans Ecobalyse (**Situation 1**).

<table><thead><tr><th width="170">Distances</th><th>Source</th></tr></thead><tbody><tr><td>D_terre (camion)</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par le PEF, <a href="https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf">Product Environmental Footprint Category Rules Guidance</a>, 7.14.3 From factory to final client)</td></tr><tr><td>D_mer (bateau)</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_air (avion)</td><td>Distance à vol d'oiseau calculée avec geopy.distance, entre le centre de chaque pays.</td></tr><tr><td>D_fer (train)</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr></tbody></table>

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json) (hors distances vers et depuis les ports et aéroports).

### Distances `D_intrazone`&#x20;

Les autres distances sont paramétrées pour chaque zone géogaphique et sont disponibles dans l'explorateur "Pays".

### Situations où l'un des pays n'est pas connu ou pas proposé dans Ecobalyse

<details>

<summary>Situation 2 : je connais le pays mais il n'est pas proposé dans Ecobalyse</summary>

Dans ce cas, il faut choisir la région du pays.\
Exemple pour le pays _Allemagne ⇒_ je sélectionne la région _Europe de l'Ouest._

* Des distance `D_intrazone` sont définies pour chaque zone géographique.
* Un pays est défini en arrière plan pour déterminer la valeur `D_i` :
  * Europe de l'Ouest = Espagne
  * Europe de l'Est = République Tchèque
  * Asie = Chine
  * Afrique = Ethiopie
  * Amérique du Nord = Etats-Unis
  * Amérique latine = Brésil
  * Océanie = Australie
  * Moyen-Orient = Turquie

</details>

<details>

<summary>Situation 3 : je ne connais pas le pays </summary>

Je sélectionne "Inconnu"

Dans ce cas, les distances suivantes sont fixées par défaut, en cohérence avec la méthode PEF ([Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client) :&#x20;

* D\_mer = 18 000 km
* D\_air, air = 10 000 km
*   D\_intrazone,départ + D\_intrazone,arrivée = 2000km

    &#x20;

</details>

## Procédés utilisés pour le coût environnemental

Sauf indication contraire spécifique, les modes de transport sont modélisés par les procédés suivants, définissant les coûts environnementaux `I_m_j` :

<table><thead><tr><th width="230">Mode de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Camion</td><td>market group for transport, freight, lorry, unspecified, GLO (Ecoinvent)</td></tr><tr><td>Camion frigorifique</td><td>market for transport, freight, lorry with refrigeration machine, 7.5-16 ton, diesel, EURO 5, R134a refrigerant, cooling</td></tr><tr><td>Bateau</td><td>market for transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Bateau frigorifique</td><td>market for transport, freight, sea, container ship with reefer, cooling, GLO (Ecoinvent)</td></tr><tr><td>Avion</td><td>market for transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr><tr><td>Train</td><td>market group for transport, freight train, GLO (Ecoinvent)</td></tr></tbody></table>

{% hint style="info" %}
Le choix est fait de ne pas différencier les procédés en fonction de la géographie ou du type de produit, à des fins de simplification, et au regard de l'impact sur le coût environnemental global des produits. A titre d'exemple, le procédé Ecoinvent "transport, freight, lorry 16-32 metric ton, EURO5, RER" a un coût environnemental presque égale à celui du procédé "market group for transport, freight, lorry, unspecified" (différence inférieure à 1%), alors que le transport par camion représente en général une faible part du coût environnemental d'un produit.
{% endhint %}

Il en résulte les coûts environnementaux par mode de transport suivant (correspondant aux valeurs `I_m_j` ci-dessus) :&#x20;

<figure><img src="../../.gitbook/assets/image (5) (1) (1).png" alt=""><figcaption></figcaption></figure>

## Exemples d'application

### Exemple 1 : Transport depuis l'Inde vers la France, par voie maritime

* `D_mer, bateau` = 11 961 km (voir [cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json), FR-IN)
* `D_intrazone,départ` = 500km
* `D_intrazone,arrivée`= 500km
  * Correspondant par exemple à 500km en Inde + 500km en France, voir schéma ci-dessous

<figure><img src="../../.gitbook/assets/image (368).png" alt=""><figcaption></figcaption></figure>

Pour 1 kg transporté par voie maritime, le coût environnemental est calculé comme suit :

$$
I_{v.mer}=\frac{m}{1000}*(D_{intrazone, Inde}∗I_{camion}+D_{mer}∗I_{bateau}+D_{intrazone, France}∗I_{camion})
$$

$$
I_{v.mer}=\frac{1}{1000}*(11961∗1.3+1000∗15.5)=31.0 Pts
$$

### Exemple 3 : Transport interne à la France

* `D_intrazone`  = 500 km

$$
I_{v.terre}=\frac{m}{1000}*D_{terre,camion}∗I_{camion}
$$

$$
I_{v.terre}=\frac{m}{1000}*500*15.5=7.7Pts
$$

### Exemple 4 : Transport depuis ou vers un pays inconnu, par voie maritime

* `D_mer, bateau` = 18 000 km
* `D_intrazone,départ` = `D_intrazone,arrivée` = 2000 km
  * Correspond par exemple au schéma ci-dessous

Pour 1 kg transporté par voie maritime, le coût environnemental est calculé comme suit :

$$
I_{v.mer}=\frac{1}{1000}*(18000∗1.3+2000∗15.5)=54.3 Pts
$$

