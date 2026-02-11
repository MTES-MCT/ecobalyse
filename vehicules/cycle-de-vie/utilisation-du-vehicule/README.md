---
description: Cette page décrit les méthodes relatives à la consommation des véhicules.
---

# ⚡ Utilisation du véhicule

## Contexte

Les énergies utilisées par les véhicules sont aujourd'hui très variées : essence, gazole, électrique, biocarburants, hydrogène... Des véhicules utilisent également plusieurs énergies.

Les émissions au roulage du véhicule dépendent directement de l'énergie utilisée.

### Consommations de référence

#### Voitures particulières et véhicules utilitaires légers : le WLTP comme référence

La procédure d'essai mondiale harmonisée pour les véhicules légers (Worldwide Harmonised Light Vehicles Test Procedure, WLTP) est une norme permettant de mesurer la consommation de carburant ou d'électricité d'un véhicule de catégorie M1 et N1.

#### Vehicules intermédiaires : le WMTC comme référence

Le WMTC révisé est aujourd’hui le cycle de référence pour tous les nouveaux véhicules de catégorie L, et ce depuis la norme euro5.

<details>

<summary>Détails</summary>

La documentation technique est disponible ici :  [https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs](https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs)

Un rapport de la Commission EU de 2018 sur « les effets de la phase environnementale Euro 5 en ce qui concerne les véhicules de catégorie L » indique : « Les résultats de l’étude ont établi que l’utilisation du cycle WMTC était pertinente pour tous les véhicules de catégorie L. Il contribue à une meilleure protection de l’environnement dans des conditions d’utilisation réelles que les cycles de conduite actuellement utilisés. » [https://www.europarl.europa.eu/RegData/docs\_autres\_institutions/commission\_europeenne/com/2018/0136/COM\_COM(2018)0136\_FR.pdf](https://www.europarl.europa.eu/RegData/docs_autres_institutions/commission_europeenne/com/2018/0136/COM_COM\(2018\)0136_FR.pdf)

Le cycle comporte 3 phases, applicable ou non selon la vitesse maximale du véhicule. De plus les vitesses sont tronquées pour les véhicules limités à 45km/h ou moins (voir graphique ci-dessous).

<figure><img src="../../../.gitbook/assets/image (2) (1) (1) (1) (1).png" alt=""><figcaption></figcaption></figure>

</details>

#### Différence entre consommation sur le cycle de référence et consommation réelle

La télémétrie mise en place dans les voitures particulières récentes permet de mesurer la consommation réelle de ces véhicules. Ces consommations et leurs différences à la consommation théorique [ont fait l'objet d'une communication par la commission européenne](https://climate.ec.europa.eu/news-your-voice/news/first-commission-report-real-world-co2-emissions-cars-and-vans-using-data-board-fuel-consumption-2024-03-18_en) (voir graphique ci-dessous).&#x20;

<figure><img src="../../../.gitbook/assets/image (1) (1) (1) (1) (1) (1) (1) (1) (1) (1).png" alt=""><figcaption><p>Real-world and WLTP consumption of cars</p></figcaption></figure>

Ces données présentent un écart de l'ordre de 20% pour l'essence, un peu moins pour le diesel, et une multiplication par 3 à 4.5 pour les véhicules hybrides rechargeables.

Pour les véhicules essence et diesel, la consommation WLTP peut être vue comme une consommation en ecoconduite.

### Émissions locales de particules des véhicules thermiques

Les véhicules thermiques émettent des pollutions locales, dont les principales sont : Oxydes d'azote (NOx), Monoxyde de carbone (CO), Hydrocarbures (HC), particules fines.

Les émissions locales maximales des véhicules sont fixées par les normes européenne d'émissions, dite norme Euro. La norme en cours pour les voitures est la norme Euro6d

Ces normes incluent les émissions liées à la combustion des carburants, mais aussi les émissions par l'usure des pneus et des plaquettes de frein.

Les impacts de ces émissions en termes de santé humaine dans les métropoles denses sont plutôt faiblement pris en compte dans les données d'Inventaire d'Analyse de Cycle de vie, qui prennent en compte l'impact à l'échelle globale.

## Méthodes de calcul

{% hint style="info" %}
La première version d'Ecobalyse ne comprend que des exemples de véhicules électriques.
{% endhint %}

{% hint style="info" %}
L'impact des émissions locales en terme de santé humaine dans les zones très dense apparait faiblement pris en compte à ce jour. Il pourrait faire l'objet d'un complément dans le futur (travaux en cours)
{% endhint %}

Le coût environnemental associé à la consommation d'énergie se calcule comme suit :

$$
I_{energie} = 100*D_{an}*T_{vie}*\sum_{0<i<n}C_i*I_i
$$

Avec&#x20;

* `I_energie` : l'impact environnemental de la consommation d'énergie en phase utilisation, y compris émissions directes , dans l'unité de la catégorie d'impact analysée
* `D_an` : le kilométrage annuel, en km\
  Cette donnée est modifiable par l'utilisateur dans Ecobalyse.
* `T_vie` : la durée de vie par défaut du véhicule, en années\
  Cette donnée est  modifiable par l'utilisateur dans Ecobalyse.
* `C_i` : la consommation de l'énergie i, en unité de l'énergie pour 100km
* `I_i` :  l'impact environnemental associé à la consommation d'une unité de l'énergie `i`, y compris l'impact des émissions directes, en unité de la catégorie d'impact analysée par unité de l'énergie (Pts/L par exemple)

## Paramètres retenus pour le coût environnemental

La consommation totale est renseignée par l'utilisateur pour chaque carburant.

{% hint style="info" %}
Ecobalyse ne permet pas encore de préciser séparément la consommation du véhicule, son kilométrage et sa durée de vie en année.

L'outil suivant permet de réaliser ce calcul, avec des propositions de kilométrage et de durée de vie par défaut :&#x20;

{% file src="../../../.gitbook/assets/Ecobalyse - Calculette utilisation (2).xlsx" %}

Cet outil permet également de prendre en compte des réduction de consommation permises par du pédalage ou par des panneaux photovoltaïques (voir [page dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/vehicules/cycle-de-vie/utilisation-du-vehicule/vehicules-legers-actifs-ou-equipes-de-panneaux-photovoltaiques)).
{% endhint %}

Le Cycle WLTP doit être utilisé comme référence pour les véhicules de catégorie M1 et N1 (voitures et véhicules utilitaires légers), et WMTC pour les véhicules de catégorie L (deux-roues, velis).

{% hint style="info" %}
Une correction devrait être prise en compte pour les véhicules hybrides rechargeables, dont les consommations réelles sont très éloignées des consommations normées. A ce stade cette correction n'est pas définie.
{% endhint %}

## Procédés utilisés pour le coût environnemental

Les procédés sont décrits dans l'Explorateur Ecobalyse.
