---
description: >-
  Acheminement des marchandises d'une étape de la chaîne de production à une
  autre.
---

# 🚢 Transport

## Vue d'ensemble

Le transport considéré est la somme des transports à prévoir entre chaque étape du cycle de production.

Entre chaque étape, la masse à considérer est ajustée en fonction des [Pertes et rebut](pertes-et-rebus.md).

<table><thead><tr><th width="102">#Etape</th><th width="169">De</th><th width="213">Vers</th><th>Masse de produit considéré</th></tr></thead><tbody><tr><td>1.</td><td><p>Matière</p><p>Pays défini par défaut dans <a href="../etapes-du-cycle-de-vie/filature/">Matière et filature</a></p></td><td><p>Filature</p><p>Pays défini par défaut dans <a href="../etapes-du-cycle-de-vie/filature/">Matière et filature</a></p></td><td>Matière première</td></tr><tr><td>2.</td><td><p>Filature</p><p>Pays défini par défaut dans <a href="../etapes-du-cycle-de-vie/filature/">Matière et filature</a></p></td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td>Matière première</td></tr><tr><td>3.</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td><p>Teinture</p><p>Pays*</p></td><td>Fil</td></tr><tr><td>4.</td><td><p>Teinture</p><p>Pays*</p></td><td><p>Confection</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>5.</td><td><p>Confection</p><p>Pays*</p></td><td><p>Entrepôt</p><p>Pays : France</p></td><td>Habit</td></tr><tr><td>6.</td><td><p>Entrepôt</p><p>Pays : France</p></td><td><p>Magasin ou Point de retrait</p><p>Pays : France</p></td><td>Habit</td></tr></tbody></table>

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

#### Cas particulier des étapes 1 (Matière première --> Filature) et 2 (Filature --> Tricotage / Tissage)

| Etape                                      | Distance terrestre                                                                                                                                                    | Distance maritime                                                                                                                                                     |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Etape 1 (Matière première --> Filature)    | Non pris en compte. Distance internalisée dans le procédé unique                                                                                                      | Non pris en compte. Distance internalisée dans le procédé unique                                                                                                      |
| Etape 2 (Filature --> Tricotage / Tissage) | Distance par défaut entre le pays de Tricotage / Tissage et le pays par défaut attaché à la filature (cf. [Matière et filature](../etapes-du-cycle-de-vie/filature/)) | Distance par défaut entre le pays de Tricotage / Tissage et le pays par défaut attaché à la filature (cf. [Matière et filature](../etapes-du-cycle-de-vie/filature/)) |

### Part du transport aérien

Une part de transport aérien est considérée :

* Seulement pour le transport entre la confection et l'entrepôt (étape #5 ci-dessus)
* Cette part n'est considérée que lorsque la confection est réalisée hors Europe (ou Turquie). Pour mémo, il est considéré que l'entrepôt est en France (cf. [Distribution](../etapes-du-cycle-de-vie/distribution.md))

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit :

| a      | Pays X (hors Europe - Turquie) |
| ------ | ------------------------------ |
| France | 33%                            |

{% hint style="info" %}
Curseur permettant d'ajuster la part du transport aérien en sortie de confection

Le curseur "part du transport aérien", proposé sous l'étape "confection" permet d'ajuster le paramètre `a`, en partant de l'hypothèse par défaut : 33% en provenance d'un pays hors Europe (ou Turquie), 0% sinon.
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

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur. Cette hypothèse est conforme à la méthodologie ADEME (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).

## Procédés

Les procédés utilisés pour modéliser les impacts des différents modes de transport sont les suivants :

<table><thead><tr><th width="153">Type de transport</th><th width="252">Procédé</th><th>UUID</th></tr></thead><tbody><tr><td><p>Terrestre</p><p>Jusqu'à la confection</p></td><td>Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO</td><td>cf6e9d81-358c-4f44-5ab7-0e7a89440576</td></tr><tr><td><p>Terrestre</p><p>Confection - Entrepôt</p></td><td>Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER</td><td>c0397088-6a57-eea7-8950-1d6db2e6bfdb</td></tr><tr><td><p>Terrestre</p><p>Distribution</p></td><td>Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR</td><td>f49b27fa-f22e-c6e1-ab4b-e9f873e2e648</td></tr><tr><td>Maritime</td><td>Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO</td><td>8dc4ce62-ff0f-4680-897f-867c3b31a923</td></tr><tr><td>Aérien</td><td>Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO</td><td>839b263d-5111-4318-9275-7026937e88b2</td></tr></tbody></table>
