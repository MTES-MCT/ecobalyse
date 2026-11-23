---
hidden: true
---

# 🚢 OLD - Transport

## Vue d'ensemble

Le transport considéré correspond à l'ensemble des transports mobilisés sur la chaîne de valeur du vêtement.

Entre chaque étape, la masse à considérer est ajustée en fonction des [Pertes et rebut](../../textile/precisions-methodologiques/pertes-et-rebus.md).

<table><thead><tr><th width="117">#Etape</th><th width="169">De</th><th width="213">Vers</th><th>Masse de produit considéré</th></tr></thead><tbody><tr><td>1.</td><td>Matière<br>Pays*</td><td>Filature<br>Pays*</td><td>Matière première</td></tr><tr><td>2.</td><td>Filature<br>Pays*</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td>Fil</td></tr><tr><td>3.</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td><p>Teinture</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>4.</td><td><p>Teinture</p><p>Pays*</p></td><td><p>Confection</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>5.</td><td><p>Confection</p><p>Pays*</p></td><td><p>Entrepôt</p><p>Pays : France</p></td><td>Vêtement</td></tr><tr><td>6.</td><td><p>Entrepôt</p><p>Pays : France</p></td><td><p>Magasin ou Point de retrait</p><p>Pays : France</p></td><td>Vêtement</td></tr></tbody></table>

\*Pays paramétré directement dans le calculateur.

$$
ImpactTransport = ImpacTansport1 + ... + ImpactTransport6
$$

À chaque étape, l'impact du transport est le produit suivant :

$$
ImpactTransportX = MasseTransportée(tonnes) * Distance (km) * ImpactProcédéTransport
$$

{% hint style="warning" %}
La masse transportée s'exprime en **tonnes**. Une conversion est donc à prendre en compte par rapport à la masse, considérée en kg dans les autres parties des calculs.
{% endhint %}

## Type de transport

3 types de transport sont considérés :

* terrestre
* maritime
* aérien

La répartition des trois types de transport est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Si l'on nomme :

* `t` la part du transport terrestre rapportée au transport "terrestre + maritime"
* `a` la part du transport aérien rapportée au transport "aérien + terrestre + maritime"

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés :

$$
ImpactTransportX = a * ImpactAérien + (1-a) * (t * ImpactTerrestre + (1-t) * ImpactMaritime)
$$

{% hint style="warning" %}
**Ces hypothèses relatives aux transport relèvent d'une orientation spécifique à l'outil et devant être confrontée aux pratiques effectivement observées dans l'industrie**.
{% endhint %}

### Répartition terrestre - maritime

#### Hypothèses

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :

| **Distance terrestre** | **t** |
| ---------------------- | ----- |
| <=500 km               | 100%  |
| 500 km <= 1000 km      | 90%   |
| 1000 km <= 2000 km     | 50%   |
| 2000 km <= 3000 km     | 25%   |
| > 3000 km              | 0%    |

Si 2 étapes successives ont lieu dans un même pays, on fait l'hypothèse que le déplacement est fait à 100% par la voie terrestre avec une distance de 500 km.

#### Exemples

| t        | Turquie | France | Espagne | Portugal |
| -------- | ------- | ------ | ------- | -------- |
| Turquie  | 100%    |        |         |          |
| France   | 25%     | 100%   |         |          |
| Espagne  | 0%      | 90%    | 100%    |          |
| Portugal | 0%      | 50%    | 90%     | 100%     |

_"Pour un déplacement "Turquie-France", le transport terrestre-maritime sera fait de 25% de terrestre et de 75% de maritime"_

### Part du transport aérien

Une part de transport aérien est considérée, comme paramètre optionnel :

* Seulement pour le transport entre la confection et l'entrepôt (étape #5 ci-dessus)
* Cette part n'est considérée que lorsque la confection est réalisée hors Europe (ou Turquie). Pour mémo, il est considéré que l'entrepôt est en France (cf. [Distribution](etape-6-distribution-old-archive.md))

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit pour la **valeur par défaut**:

**Si le coefficient de durabilité est > 1**

* 0% pour les pays situés en Europe ou Afrique,
* 33% pour les autres pays.

**Si le coefficient de durabilité est < 1**

* 0% pour les pays situés en Europe ou Afrique,
* 100% pour les autres pays.

{% hint style="info" %}
Un curseur permettant d'ajuster la part du transport aérien en sortie de confection est proposé dans Ecobalyse

Le curseur "part du transport aérien", proposé sous l'étape "confection" permet d'ajuster le paramètre `a`, en partant de l'hypothèse par défaut : 33% en provenance d'un pays hors Europe et hors-Afrique, 0% sinon.
{% endhint %}

{% hint style="info" %}
**L'aérien est-il un mode de transport privilégié pour les acteurs de l'habillement ?**

Une récente [étude de l'ONG suisse "Public Eye" parue fin 2023 ](https://www.publiceye.ch/fr/thematiques/industrie-textile/en-mode-avion-zara-attise-la-crise-climatique)met en lumière l'importance du secteur Textile dans le fret aérien. De manière générale, peu de données précises sont disponibles sur ces pratiques car les entreprises Textile sont discrètes à ce sujet.

Quelques enseignements clés de l'étude :

* le fret aérien est utilisé au sein même de l'UE alors que l'avantage en termes de temps reste faible (c. 42,658 tonnes de vêtements transportées par avion au sein de l'UE en 2022 d'après les estimations de l'étude),
* Shein a signé un partenariat stratégique avec China Southern Airlines afin d'optimiser ses flux logistiques aériens,
* Le groupe espagnol Inditex (propriétaire de Zara) affrète près de 1,600 vols par an depuis l'aéroport de Saragosse,
* Même au sein de l’UE, où le fret aérien n’offre qu’un faible avantage en termes de temps, des vêtements sont tout de même transportés par avion (en 2022, il s’agissait d’au moins 42 658 tonnes).
{% endhint %}

## Distances

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json)

Les distances entre pays sont considérées à partir des calculateurs mis en avant dans le projet de PEF CR Apparel & Footwear rendu public à l'été 2021 (Version 1.1 – Second draft PEFCR, 28 May 2021).

Ainsi :

<table><thead><tr><th width="197">Type de transport</th><th>Site de référence</th></tr></thead><tbody><tr><td>Terrestre</td><td><a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time/</a></td></tr><tr><td>Maritime</td><td><a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time/</a></td></tr><tr><td>Aérien</td><td>Calcul de distance à vol d'oiseau geopy.distance</td></tr></tbody></table>

Lorsque deux étapes successives sont réalisées dans un même pays, une distance par défaut est considérée. Cette distance est également considérée pour du transport aérien si le curseur "transport aérien" est utilisé.

| Distance par défaut | Pays X |
| ------------------- | ------ |
| Pays X              | 500 km |

{% hint style="warning" %}
**Ce choix de distance par défaut relève d'une orientation spécifique à l'outil et devant être discutée. Le cas de deux étapes successives réalisées sur un même site, avec donc une distance nulle, pourrait être intégré.**
{% endhint %}

## Distribution

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur.

Cette hypothèse est conforme à la méthodologie ADEME (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).

## Pays par défaut (étapes de Transformation)

Pour les étapes de transformation (filature, tissage/tricotage, ennoblissement et confection), des scénarios par défaut sont proposés pour répondre aux différents cas d'usage :

<details>

<summary>Je connais le pays où a lieu l'étape</summary>

Option 1 => le pays est proposé dans Ecobalyse => je le sélectionne

Option 2 => le pays n'est pas proposé dans Ecobalyse => je sélectionne la région (ex : _Europe de l'Ouest_ pour _Allemagne_)

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

<summary>Je ne connais pas le lieu où a lieu l'étape</summary>

Je sélectionne l'option _Inconnu (par défaut)._

L'Inde est utilisé en arrière plan pour définir les distances et modes de transport utilisés pour cette option.

</details>

## Procédés

Les procédés utilisés pour modéliser les impacts des différents modes de transport sont les suivants :

<table><thead><tr><th width="198">Type de transport</th><th>Procédé</th></tr></thead><tbody><tr><td>Terrestre</td><td>transport, freight, lorry, unspecified, RoW</td></tr><tr><td>Maritime</td><td>transport, freight, sea, container ship, GLO</td></tr><tr><td>Aérien</td><td>transport, freight, aircraft, long haul, GLO</td></tr><tr><td>Ferroviaire</td><td>transport, freight train, GLO</td></tr></tbody></table>

## Coût environnemental

<figure><img src="../../.gitbook/assets/Coût environnemental de différents modes de transport disponibles dans Ecobalyse (uPts _ tonne_km) .png" alt=""><figcaption></figcaption></figure>
