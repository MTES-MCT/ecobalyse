# 🚛 Transport

## Vue d'ensemble

Différentes étapes de transport peuvent être mobilisées dans le cycle de vie d'un produit alimentaire. Elles sont prises en compte comme suit :&#x20;

| #Etape                           | De...                           | Vers...                                   | Prise en compte                                                                                                             |
| -------------------------------- | ------------------------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| #1 - Ingrédient industrie        | Site de production agricole     | Site de transformation                    | Transport non paramétrable intégré dans les impacts de l'ingrédient industrie.                                              |
| **#1 - Ingrédient agricole**     | **Site de production agricole** | **Site de transformation ou de stockage** | **Transport paramétrable au niveau de la définition de l'ingrédient. Calcul d'impact dédié.**                               |
| **#2 - Ingrédient industrie**    | **Site de transformation**      | **Site de stockage**                      | **Transport paramétrable au niveau de la définition de l'ingrédient. Calcul d'impact dédié.**                               |
| <p>#2<br>Ingrédient agricole</p> | Site de transformation          | Site de stockage                          | Non encore pris en compte. A considérer lors de l'intégration de l'étape de stockage ?                                      |
| #3                               | Site de stockage                | Lieu de distribution                      | Non encore pris en compte. A considérer lors de l'intégration de l'étape de distribution ?                                  |
| #4                               | Lieu de distribution            | Lieu de consommation                      | Non pris en compte.                                                                                                         |
| #5                               | Lieu de consommation            | Site d'élimination                        | <p>Concerne uniquement les emballages.<br>Prise en compte dans les impacts de chaque matière qui constitue l'emballage.</p> |

**En première approche, on considère le transport de chaque ingrédient, depuis le site de production agricole (ingrédient agricole) ou depuis le site de transformation (ingrédient industrie), vers l'étape suivante du cycle de vie (transformation, stockage, distribution).**

**Le pays d'origine d'un ingrédient qui peut être paramétré est donc :**&#x20;

* **le site de production agricole pour les ingrédients agricoles**
* **le site de transformation pour les ingrédients industrie**

**Pour l'étape suivante (transformation, stockage, distribution), on ne considère que la France**.

{% hint style="warning" %}
Vérification à faire : \
\- prise en compte du transport en fin de vie dans les impacts des emballages ;\
\- prise en compte du transport depuis le/les sites de production dans les impacts des ingrédients industrie
{% endhint %}

## Calcul

Au regard du paragraphe précédent, un transport est considéré pour chacun des ingrédients de la recette.

$$
ImpactTransport = ImpactTransportIngrédient_1 + ImpactTransportIngrédient_2 ...
$$

Pour chaque ingrédient, l'impact est calculé comme suit, avec les procédés de transport introduits [ci-après](<transport (1).md#undefined>) :&#x20;

$$
ImpactTransport = MasseIngrédient (tonnes) * Distance (km) *  ImpactProccédéTransport
$$

{% hint style="warning" %}
La masse s'exprime en **tonnes**. Une conversion est donc à prendre en compte par rapport à la masse, considérée en g ou en kg dans les autres parties des calculs.&#x20;
{% endhint %}

## Types de transport

En première approche, on ne considère que du transport maritime et du transport terrestre routier. La formule proposée ci-après anticipe toutefois l'introduction future du transport aérien.

{% hint style="warning" %}
Le transport aérien sera introduit avec l'ajout d'ingrédients susceptibles d'être transportés par avion (Mangue du Pérou, Haricot du Kenya...)
{% endhint %}

La répartition des trois types de transport est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Si l'on nomme :

* `t` la part du transport terrestre rapportée au transport "terrestre + maritime"
* `a` la part du transport aérien rapportée au transport "aérien + terrestre + maritime"

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés :&#x20;

$$
ImpactTransport = a*ImpactAérien + (1-a)*(t*ImpactTerrestre+(1-t)*ImpactMaritime))
$$

{% hint style="warning" %}
**Ces hypothèses relatives aux transport relèvent d'une orientation spécifique à l'outil et devant être confrontée aux pratiques effectivement observées** .
{% endhint %}

## Répartition terrestre - maritime

**Par hypothèse**, la part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :&#x20;

| Distance terrestre                          | Part du transport terrestre (t) |
| ------------------------------------------- | ------------------------------- |
| <=500 km                                    | 100%                            |
| 500 km <= 1000 km                           | 90%                             |
| 1000 km <= 2000 km                          | 50%                             |
| 2000 km <= 3000 km                          | 25%                             |
| 3000 km (ou transport terrestre impossible) | 0%                              |

## Part du transport aérien

{% hint style="danger" %}
A introduire lors de l'ajout d'ingrédients susceptibles d'être transpotés par avion
{% endhint %}

## Distances

Toutes les distances considérées entre pays sont visibles sur cette page \[**lien à ajouter**]

Les distances entre pays sont considérées à partir des calculateurs mis en avant dans le projet de PEF CR Apparel & Footwear rendu public à l'été 2021 (Version 1.1 – Second draft PEFCR, 28 May 2021). Ainsi :

| Type de transport | Site de référence                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------------------- |
| Terrestre         | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Maritime          | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Aérien            | Calcul de distance à vol d'oiseau geopy.distance                                                         |

## Procédés de transport

Les procédés de transport considérés sont extraits de la base Agribalyse.&#x20;

| Type de transport  | Procédé | UUID |
| ------------------ | ------- | ---- |
| Transport maritime |         |      |
| Transport routier  |         |      |







