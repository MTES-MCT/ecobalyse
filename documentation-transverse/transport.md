# 🚚 Transport

## Principales étapes de transport <a href="#distribution" id="distribution"></a>

Les étapes de transport prisent en compte dans le coût environnemental du produit sont de trois types : &#x20;

* Le transport des ingrédients, matériaux ou composants jusqu'au dernier site industriel de fabrication (Confection textile, assemblage)&#x20;
* Le transport du produit fini vers la France
* La distribution du produit en France.

## Voies et modes de transports proposés

4 voies sont considérés, faisant appel à un ou deux modes de transport chacune :

* Voie Terrestre\
  Mode de transport : camion
* Maritime (+ terrestre)\
  Modes de transport : bateau + camion\
  &#xNAN;_&#x44;ans le cas d'un transport par voie maritime, le transport est réalisé en trois étapes : transport par la route vers le port de départ, transport par la mer de port à port, transport par la route depuis le port d'arrivée._
* Aérien\
  Modes de transport : avion + camion\
  &#xNAN;_&#x44;ans le cas d'un transport par voie aérienne, le transport est réalisé en trois étapes : transport par la route vers l'aéroport de départ, transport par avion d'aéroport à aéroport, transport par la route depuis l'aéroport d'arrivée._&#x20;
* Ferroviaire\
  Modes de transport : train

A des fins de simplification, ces 4 voies ne sont pas toujours proposés pour toutes les étapes de transport.

## Calcul du coût environnemental par voie

### Distances et mode de transport

Pour chaque voie, la distance par mode de transport est calculée sur la base des pays d'origines et de destination de l'étape de transport considérée. Ces pays sont déterminés à partir des pays d'origine des matières premières et de la localisation de chaque étape du cycle de vie, constitue pour chaque étape de de transport.

<details>

<summary>Situation 1 : je connais les pays d'origine et de destination, ils sont proposés dans Ecobalyse</summary>

Les distances entre pays sont calculées de la façon suivante en fonction du mode de transport principal choisi :&#x20;

**Voie terrestre :**&#x20;

La distance par voie terrestre est calculée avec le calculateur [https://www.searates.com/services/distances-time](https://www.searates.com/services/distances-time/) (calculateur indiqué dans la méthode PEF, [Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client)

**Voie maritime (+ terrestre)** :&#x20;

Le choix d'une voie maritime se décline en deux composantes :

* Transport par bateau, avec une distance de port à port. Calcul de la distance avec le calculateur [https://www.searates.com/services/distances-time](https://www.searates.com/services/distances-time/) (calculateur indiqué dans la méthode PEF).
* Transport par camion : distance fixée à 1000km. Pour les pays situés à moins de 2000 en transport terrestre, cette distance est ramenée à la moitié de la distance en transport terrestre.

**Voie aérienne (+ terrestre)** :&#x20;

Le choix d'une voie aérienne se décline en deux composantes :

* Transport par avion, avec une distance d'aéroport à aéroport. Calcul de distance à vol d'oiseau avec geopy.distance, entre le centre de chaque pays.
* Transport par camion : distance fixée à 1000km. Pour les pays situés à moins de 2000 en transport terrestre, cette distance est ramenée à la moitié de la distance en transport terrestre.

**Voie ferroviaire** : La distance par voie ferroviaire est calculée avec le calculateur [https://www.searates.com/services/distances-time](https://www.searates.com/services/distances-time/) EN COURS



Lorsque deux étapes successives sont réalisées dans un même pays, des distances par défaut est considérée :&#x20;

* Distance par voie terrestre : 500 km
* Distance par voie aérienne : 500 km en avion + 250 km par camion
* Distance par voie ferroviaire : 500 km
* Le transport maritime est exclu.

_Ce choix de distance par défaut relève d'une orientation spécifique à l'outil et devant être discutée. Le cas de deux étapes successives réalisées sur un même site, avec donc une distance nulle, pourrait être intégré._

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json) (hors distances vers et depuis les ports et aéroports)

</details>

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

<summary>Situation 3 : je ne connais pas un des deux pays</summary>

Je sélectionne "Inconnu (par défaut)"

Dans ce cas, les distances suivantes sont fixées par défaut, en cohérence avec la méthode PEF ([Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client) :&#x20;

* 1000 km de transport routier, correspondant au transport de l'usine au port ou aéroport de départ et au transport du port ou aéroport d'arrivée à l'usine ou lieu de stockage d'arrivée
* 18 000 km de transport maritime ou 10 000 km de transport aérien (pas de transport par train)

</details>

#### Cas de la distribution

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur.

Cette hypothèse est conforme à la méthodologie ADEME pour le textile (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).&#x20;

### Coût environnemental pour une voie de transport

À chaque étape, l'impact d'une voie de transport est calculé de la façon suivante :

$$
CEvoie=Masse*(D_1∗CE[m1]+D_2∗CE[m2])
$$

Avec :&#x20;

* CEvoie : le coût environnemental par voie, exprimé en points d'impact
* Masse : la masse transportée, en tonnes. La masse transportée s'exprime en tonnes. Une conversion est donc à prendre en compte par rapport à la masse, considérée en kg dans les autres parties des calculs.
* D\_1 : la distance parcourue par le mode de transport 1, exprimée en km
* CE\[m1] : le coût environnemental du mode 1, exprimé en Pt/t.km
* Le cas échéant, D\_2 : la distance parcourue par le mode de transport 2, exprimée en km
* Le cas échéant, CE\[m2] : le coût environnemental du mode 2, exprimé en Pt/t.km

## Procédés utilisés

Sauf indication contraire spécifique, les modes de transport sont modélisés par les procédés suivants :

<table><thead><tr><th width="230">Type de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Routier, hors distribution</td><td>transport, freight, lorry, unspecified, RoW (Ecoinvent)</td></tr><tr><td>Routier, distribution</td><td>Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR<br>UUID = f49b27fa-f22e-c6e1-ab4b-e9f873e2e648<br>(Base Impact)</td></tr><tr><td>Bateau</td><td>transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Avion</td><td>transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr><tr><td>Train</td><td>transport, freight train, GLO (Ecoinvent)</td></tr></tbody></table>

Il est résulte les coûts environnementaux par mode de transport suivant (correspndant aux valeurs CE\[mi] ci-dessus) :&#x20;

<figure><img src="../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

## Mix des voies de transport

En pratique, pour une même chaine d'approvisionnement, plusieurs voies de transports sont utilisées, dans des proportions qui dépendent du type de produit, de la distance et de choix industriels.

### Transport jusqu'au dernier site industriel de fabrication : pas de choix de voie de transport

Pour ces étapes de transport, l'utilisateur ne peut pas choisir la voie de transport des ingrédients, matériaux ou composants. Sauf mention explicite dans la documentation spécifique métier, un mix de transports par voies terrestre et maritime est considéré.

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime port à port", est alors établie comme suit :

<table data-header-hidden><thead><tr><th width="297"></th><th></th></tr></thead><tbody><tr><td><strong>Distance terrestre</strong></td><td><strong>t</strong></td></tr><tr><td>&#x3C;=500 km</td><td>100%</td></tr><tr><td>500 km &#x3C;= 1000 km</td><td>90%</td></tr><tr><td>1000 km &#x3C;= 2000 km</td><td>50%</td></tr><tr><td>2000 km &#x3C;= 3000 km</td><td>25%</td></tr><tr><td>> 3000 km</td><td>0%</td></tr></tbody></table>

Le ratio s'entend hors prise en compte du transport par camion dans la voie maritime. Le transport par camion vers et depuis les ports est ajouté au transport par bateau au regard de la part de cette voie.



### Transport du produit fini  : choix ou plus sont proposés, avec un ratio pour chaque voie

Ce cas n'est proposé que pour le transport de produits finis vers la France.

A ce stade, seul un ratio de transport aérien ou ferroviaire est proposé, à de



L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés :&#x20;



`ImpactTransportX=a∗ImpactAeˊrien+(1−a)∗(t∗ImpactTerrestre+(1−t)∗ImpactMaritime)ImpactTransportX=a∗ImpactAeˊrien+(1−a)∗(t∗ImpactTerrestre+(1−t)∗ImpactMaritime)`

**Ces hypothèses relatives aux transport relèvent d'une orientation spécifique à l'outil et devant être confrontée aux pratiques effectivement observées dans l'industrie**.







##

### &#x20;<a href="#distribution" id="distribution"></a>



### Calcul des distances <a href="#distribution" id="distribution"></a>

La répartition des deux types de transport (terrestre et maritime) est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Des scénarios par défaut sont proposés pour répondre aux différents cas d'usage rencontrés :&#x20;

<details>

<summary>Je connais le pays d'où provient le composant</summary>

Option 1 => le pays est proposé dans Ecobalyse => je le sélectionne

Option 2 => le pays n'est pas proposé dans Ecobalyse => je sélectionne la région (ex : _Europe de l'Ouest_ pour _la Croatie_)

Afin de définir les distances et modes de transport utilisés pour chaque région, un pays est défini en arrière plan :

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

<summary>Je ne connais pas le pays d'où provient le composant</summary>

Je sélectionne l'option _Inconnu (par défaut)._

L'Inde est utilisé en arrière plan pour définir les distances et modes de transport utilisés pour cette option.

</details>

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :

### Calcul de l'impact environnemental du transport <a href="#distribution" id="distribution"></a>

À chaque étape, l'impact du transport se calcule comme une pondération des deux types de transport considérés :&#x20;

$$
ImpactTransportX=t∗ImpactTerrestre+(1−t)∗ImpactMaritime
$$

## &#x20;<a href="#distribution" id="distribution"></a>





Véhicules et ameublement :&#x20;

Il est retenu comme hypothèse que tous les composants sont transportés par voie terrestre ou terrestre + maritime.

Alim et textile : ratio de transport aérien

Cas du transport du produit fini : Train
