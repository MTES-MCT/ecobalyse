---
description: Cette page décrit les méthodes relatives à la consommation des véhicules
---

# ⚡ Utilisation : énergie et émissions directes

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

<figure><img src="../../../.gitbook/assets/image (2) (1) (1).png" alt=""><figcaption></figcaption></figure>

</details>

#### Correction spécifique pour les véhicules hybrides rechargeables

Au regard des [écarts constatés par la commission européenne](https://climate.ec.europa.eu/news-your-voice/news/first-commission-report-real-world-co2-emissions-cars-and-vans-using-data-board-fuel-consumption-2024-03-18_en) entre les consommations réelles et les consommations WLTP des véhicules hybrides rechargeables, leurs consommations normées de diesel ou essence ne sont pas pertinentes.

### Émissions liées à l'usure des pneus et des freins





### Émissions des véhicules thermiques



&#x20;

## Méthodes de calcul

### Périmètre retenu

Les émissions relatives à l'usure des pneus et des freins et l'impact en terme de santé humaine de la pollution locale ne sont pas pris en compte à ce jour.

### Calcul du coût environnemental

Le coût environnemental de la consommation d'énergie se calcule comme suit (exemple pour l'impact sur le changement climatique) :

$$
I_{energie} = 100*D_{vie}*\sum_{0<i<n}C_i*I_i
$$

Avec&#x20;

* `I_energie` : l'impact environnemental de la consommation d'énergie en phase utilisation, y compris émissions directes , dans l'unité de la catégorie d'impact analysée
* `D_vie` : la durée de vie du véhicule, en km. Le calcul de la durée de vie du véhicule est détaillé ci-dessous
* `C_i` : la consommation de l'énergie i, en unité de l'énergie pour 100km
* `I_i` :  l'impact environnemental associé à la consommation d'une unité de l'énergie i, y copris l'impact des émissions directes, en unité de la catégorie d'impact analysée par unité de l'énergie (Pts/L par exemple)

### Durée de vie des véhicules

La durée de vie en kilomètres s'exprime de la façon suivante :&#x20;

$$
D_{vie}=D_{an}*T_{vie}
$$

Avec :&#x20;

* `D_vie` : la durée de vie, en km
* `D_an` : le kilométrage annuel, en km\
  Cette donnée est modifiable par l'utilisateur dans Ecobalyse.
* `T_vie` : la durée de vie par défaut du véhicule, en années\
  Cette donnée est  modifiable par l'utilisateur dans Ecobalyse.

## Paramètres précisés par l'utilisateur

L'utilisateur renseigne les informations suivantes :&#x20;

* Consommation du véhicule selon le cycle WMTC ou la procédure WLTP (kWh/100km ou L/100km)
* Durée de vie du véhicule (en années)
* Kilométrage annuel (en km/an)

## <mark style="color:red;">Paramètres retenus pour le coût environnemental</mark>

<mark style="color:red;">Hybride : consommation de carburant multipliées par 2.</mark>&#x20;

### <mark style="color:red;">Procédés utilisés pour chaque énergie</mark>



<table><thead><tr><th width="260">Energie</th><th width="420">Procédé</th><th>unité</th></tr></thead><tbody><tr><td>Diesel</td><td>Procédé créé par Ecobalyse à préciser</td><td>Litre</td></tr><tr><td>Essence</td><td>Procédé créé par Ecobalyse à préciser</td><td>Litre</td></tr><tr><td>Électricité du réseau</td><td>market for electricity, low voltage FR</td><td>kWh</td></tr><tr><td>Hydrogène</td><td></td><td>kg</td></tr><tr><td>GNV</td><td></td><td>kg</td></tr></tbody></table>

Voir la page dédiée relative à la construction de ces procédés.



