---
description: Cette page décrit les méthodes relatives à la consommation des véhicules
---

# ⚡ Consommation d'énergie

## Généralités

Les énergies utilisées par les véhicules sont aujourd'hui très variées.&#x20;

## Consommation de référence

### Voitures particulières et véhicules utilitaires légers : le WLTP comme référence

La procédure d'essai mondiale harmonisée pour les véhicules légers (Worldwide Harmonised Light Vehicles Test Procedure, WLTP) est une norme permettant de mesurer la consommation de carburant ou d'électricité d'un véhicule de catégorie M1 et N1.

### Velis : le WMTC comme référence

Le WMTC révisé est aujourd’hui le cycle de référence pour tous les nouveaux véhicules de catégorie L, et ce depuis la norme euro5.

La documentation technique est disponible ici :  [https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs](https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs)

Un rapport de la Commission EU de 2018 sur « les effets de la phase environnementale Euro 5 en ce qui concerne les véhicules de catégorie L » indique : « Les résultats de l’étude ont établi que l’utilisation du cycle WMTC était pertinente pour tous les véhicules de catégorie L. Il contribue à une meilleure protection de l’environnement dans des conditions d’utilisation réelles que les cycles de conduite actuellement utilisés. » [https://www.europarl.europa.eu/RegData/docs\_autres\_institutions/commission\_europeenne/com/2018/0136/COM\_COM(2018)0136\_FR.pdf](https://www.europarl.europa.eu/RegData/docs_autres_institutions/commission_europeenne/com/2018/0136/COM_COM\(2018\)0136_FR.pdf)

Le cycle comporte 3 phases, applicable ou non selon la vitesse maximale du véhicule. De plus les vitesses sont tronquées pour les véhicules limités à 45km/h ou moins (voir graphique ci-dessous).

<figure><img src="../../../.gitbook/assets/image (2) (1).png" alt=""><figcaption></figcaption></figure>

### Correction spécifique pour les véhicules hybrides rechargeables

Au regard des [écarts constatés par la commission européenne](https://climate.ec.europa.eu/news-your-voice/news/first-commission-report-real-world-co2-emissions-cars-and-vans-using-data-board-fuel-consumption-2024-03-18_en) entre les consommations réelles et les consommations WLTP des véhicules hybrides rechargeables, leurs consommations normées de diesel ou essence sont multipliées par Eobalyse par 2.&#x20;

### Cas particulier des véhicules électriques actif ou équipés de panneaux photovoltaïques

La consommation électrique est calculée comme suit :&#x20;

$$
C_r = max (0;Cwmtc-Ep-Epv.m)
$$

Avec :&#x20;

* C\_r : la consommation l'électricité par recharge sur le réseau électrique, exprimée en kWh pour 100km
* Cwmtc : La consommation du véhicule selon le cycle WMTC, exprimée en kWh pour 100km
* Ep : l'énergie apportée par pédalage, pour les véhicules actifs, établie par la classe WMTC, exprimée en kWh pour 100km, établie selon le calcul détaillé dans la page dédiée
* Epv.m : l'énergie maximale apportée par des panneaux solaires photovoltaïques, exprimée en kWh pour 100km, établie selon le calcul détaillé dans la [page dédiée](energie-apportee-par-des-panneaux-solaires-photovoltaique.md)

_A des fins de simplification, ces dispositions ne s'appliquent qu'aux véhicules électriques :_

* _L'impact sur la consommation est jugé non significatif pour des véhicules non-électriques_
* _La quantification de l'impact implique une conversion en termes de réduction de consommation de carburant, qui est ainsi évitée ici_
* _Ces dispositions sont peu pertinentes (impact peu significatif) pour des voitures électriques, mais y sont appliquées pour éviter de différencier le calcul d'un type de véhicule à un autre._

## Durée de vie des véhicules

La durée de vie en kilomètres s'exprime de la façon suivante :&#x20;

$$
D.vie=D.an*T.vie
$$

Avec :&#x20;

* D.vie : la durée de vie, en km
* D.an : le kilométrage annuel, en km\
  Cette donnée est modifiable par l'utilisateur dans Ecobalyse.
* T.vie : la durée de vie par défaut du véhicule, en années\
  Cette donnée est  modifiable par l'utilisateur dans Ecobalyse.

## Modélisation Ecobalyse

### Données renseignées par l’utilisateur

L'utilisateur renseigne les informations suivantes :

* Consommation du véhicule selon le cycle WMTC ou la procédure WLTP (kWh/100km ou L/100km)
* Apport d'énergie par pédalage (Oui/Non)
* Durée de vie du véhicule (en années)
* Kilométrage annuel (en km/an)

### Calcul du coût environnemental de la consommation d'énergie

Le coût environnemental de la consommation d'énergie se calcule comme suit (exemple pour l'impact sur le changement climatique) :

$$
CEe = 100*D_{vie}*\sum_{0<i<n}C_i*CE_i
$$

Avec&#x20;

* CEe : le coût environnemental de la consommation d'énergie en phase utilisation
* D\_vie : la durée de vie du véhicule, en km. Le calcul de la durée de vie du véhicule est détaillé ci-dessous
* Ci : la consommation de l'énergie i, en unité de l'énergie pour 100km.
* CE\_i : la quantité de kgCO2e émise pour produire 1 unité de l'énergie i

### Procédés utilisés pour chaque énergie

<table><thead><tr><th width="260">Energie</th><th width="420">Procédé</th><th>unité</th></tr></thead><tbody><tr><td>Diesel</td><td>Procédé créé par Ecobalyse à préciser</td><td>Litre</td></tr><tr><td>Essence</td><td>Procédé créé par Ecobalyse à préciser</td><td>Litre</td></tr><tr><td>Électricité du réseau</td><td>market for electricity, low voltage FR</td><td>kWh</td></tr><tr><td>Hydrogène</td><td></td><td>kg</td></tr><tr><td>GNV</td><td></td><td>kg</td></tr></tbody></table>

Voir la page dédiée relative à la construction de ces procédés.
