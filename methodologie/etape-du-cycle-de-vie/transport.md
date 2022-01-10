---
description: >-
  Acheminement des marchandises d'une étape de la chaîne de production à une
  autre.
---

# Transport

## Vue d'ensemble

Le transport considéré est la somme des transports à prévoir entre chaque étape du cycle de production.

Entre chaque étape, la masse à considérer est ajustée en fonction des [Pertes et rebut](../pertes-et-rebus.md).

| #Etape | De                                                                                              | Vers                                                                                            | Masse de produit considéré |
| ------ | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | -------------------------- |
| 1.     | <p>Matière</p><p>Pays défini par défaut dans <a href="filature.md">Matière et filature</a></p>  | <p>Filature</p><p>Pays défini par défaut dans <a href="filature.md">Matière et filature</a></p> | Matière première           |
| 2.     | <p>Filature</p><p>Pays défini par défaut dans <a href="filature.md">Matière et filature</a></p> | <p>Tissage/tricotage</p><p>Pays*</p>                                                            | Matière première           |
| 3.     | <p>Tissage/tricotage</p><p>Pays*</p>                                                            | <p>Teinture</p><p>Pays*</p>                                                                     | Fil                        |
| 4.     | <p>Teinture</p><p>Pays*</p>                                                                     | <p>Confection</p><p>Pays*</p>                                                                   | Etoffe                     |
| 5.     | <p>Confection</p><p>Pays*</p>                                                                   | <p>Entrepôt</p><p>Pays : France</p>                                                             | Habit                      |
| 6.     | <p>Entrepôt</p><p>Pays : France</p>                                                             | <p>Magasin ou Point de retrait</p><p>Pays : France</p>                                          | Habit                      |

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

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :

* Transport entre pays Européen (+ Turquie) et Inde - Bangladesh

| t                   | Pays X |
| ------------------- | ------ |
| si trajet < 1000 km | 90%    |
| si trajet < 2000 km | 50%    |
| si trajet > 2000 km | 25%    |

Application aux pays Européen :

| t        | Turquie | France | Espagne | Portugal |
| -------- | ------- | ------ | ------- | -------- |
| Turquie  | 100%    |        |         |          |
| France   | 25%     | 100%   |         |          |
| Espagne  | 25%     | 90%    | 100%    |          |
| Portugal | 25%     | 50%    | 90%     | 100%     |

Application à Inde - Bangladesh :

| t          | Inde |
| ---------- | ---- |
| Bangladesh | 50%  |

* Transport interne à un même pays, si deux étapes successives sont réalisées dans un même pays

| t      | Pays X |
| ------ | ------ |
| Pays X | 100%   |

* Autre transport entre deux pays distincts, dont au moins un est hors Europe (+ Turquie)

| t      | Pays Y |
| ------ | ------ |
| Pays Z | 0%     |



* Cas particulier des étapes 1 (Matière première --> Filature) et 2 (Filature --> Tricotage / Tissage)

| Etape                                      | Distance terrestre                                                                                                                            | Distance maritime                                                                                                                             |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Etape 1 (Matière première --> Filature)    | Non pris en compte. Distance internalisée dans le procédé unique                                                                              | Non pris en compte. Distance internalisée dans le procédé unique                                                                              |
| Etape 2 (Filature --> Tricotage / Tissage) | Distance par défaut entre le pays de Tricotage / Tissage et le pays par défaut attaché à la filature (cf. [Matière et filature](filature.md)) | Distance par défaut entre le pays de Tricotage / Tissage et le pays par défaut attaché à la filature (cf. [Matière et filature](filature.md)) |

### Part du transport aérien

Une part de transport aérien est considérée :

* Seulement pour le transport entre la confection et l'entrepôt (étape #5 ci-dessus)
* Cette part n'est considérée que lorsque la confection est réalisée hors Europe (ou Turquie). Pour mémo, il est considéré que l'entrepôt est en France (cf. [Distribution](distribution.md))

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit :

| a      | Pays X (hors Europe - Turquie) |
| ------ | ------------------------------ |
| France | 33%                            |

{% hint style="info" %}
Curseur permettant d'ajuster la part du transport aérien en sortie de confection

Le curseur "part du transport aérien", proposé sous l'étape "confection" permet d'ajuster le paramètre `a`, en partant de l'hypothèse par défaut : 33% en provenance d'un pays hors Europe (ou Turquie), 0% sinon.
{% endhint %}

## Distances

Les distances entre pays sont considérées à partir des calculateurs mis en avant dans le projet de PEF CR Apparel & Footwear rendu public à l'été 2021 (Version 1.1 – Second draft PEFCR, 28 May 2021).

Ainsi :

| Type de transport | Site de référence                                                                                            |
| ----------------- | ------------------------------------------------------------------------------------------------------------ |
| Terrestre         | [https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)       |
| Maritime          | [https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)       |
| Aérien            | [https://co2.myclimate.org/en/flight\_calculators/new](https://co2.myclimate.org/en/flight\_calculators/new) |

Lorsque deux étapes successives sont réalisées dans un même pays, une distance par défaut est considérée. Cette distance est également considérée pour du transport aérien si le curseur "transport aérien" est utilisé.

| Distance par défaut | Pays X |
| ------------------- | ------ |
| Pays X              | 500 km |

{% hint style="warning" %}
**Ce choix de distance par défaut relève d'une orientation spécifique à l'outil et devant être discutée. Le cas de deux étapes successives réalisées sur un même site, avec donc une distance nulle, pourrait être intégré.**
{% endhint %}

Les distances ainsi calculées sont :

| Terrestre (km) | Turquie | France | Espagne | Portugal |
| -------------- | ------- | ------ | ------- | -------- |
| Turquie        | 500     |        |         |          |
| France         | 2 798   | 500    |         |          |
| Espagne        | 3 312   | 801    | 500     |          |
| Portugal       | 3 709   | 1 138  | 399     | 500      |



| Maritime (km)    | Tous les pays...                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------------------------------- |
| Tous les pays... | cf. [https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/) |

| Aérien (km) | France |
| ----------- | ------ |
| Turquie     | 2 200  |
| Tunisie     | 1 500  |
| Inde        | 6 600  |
| Chine       | 8 200  |
| Bangladesh  | 7 900  |
| Espagne\*   | 1 100  |
| Portugal\*  | 1 500  |
| France\*    | 500    |

\*Pour l'Espagne, le Portugal et la France, la part du transport aérien (a) étant positionnée par défaut à 0%, ces distances ne sont mobilisées dans le calcul que si le curseur est déplacé manuellement.

## Distribution

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur. Cette hypothèse est conforme à la méthodologie ADEME (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).

## Procédés

Les procédés utilisés pour modéliser les impacts des différents modes de transport sont les suivants :

| Type de transport                            | Procédé                                                                                             | UUID                                 |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------ |
| <p>Terrestre</p><p>Jusqu'à la confection</p> | Transport en camion (dont parc, utilisation et infrastructure) (50%) \[tkm], GLO                    | cf6e9d81-358c-4f44-5ab7-0e7a89440576 |
| <p>Terrestre</p><p>Confection - Entrepôt</p> | Transport en camion (dont parc, utilisation et infrastructure) (50%) \[tkm], RER                    | c0397088-6a57-eea7-8950-1d6db2e6bfdb |
| <p>Terrestre</p><p>Distribution</p>          | Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) \[tkm], FR | f49b27fa-f22e-c6e1-ab4b-e9f873e2e648 |
| Maritime                                     | Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) \[tkm], GLO  | 8dc4ce62-ff0f-4680-897f-867c3b31a923 |
| Aérien                                       | Transport aérien long-courrier (dont flotte, utilisation et infrastructure) \[tkm], GLO             | 839b263d-5111-4318-9275-7026937e88b2 |

