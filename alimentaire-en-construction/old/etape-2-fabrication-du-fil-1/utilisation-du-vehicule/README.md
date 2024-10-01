---
description: Cette page décrit les méthodes relatives à la consommation des véhicules
---

# ⚡ Utilisation du véhicule

## Généralités

Les véhicules électriques nécessitent pour la plupart de se recharger en électricité pour rouler. Cette consommation d'électricité dépend de la consommation du véhicule, mais aussi de la présence éventuelle d'un apport d'énergie par pédalage ou par des cellules photovoltaïques.

### Cycle de test de référence : le WMTC&#x20;

le WMTC révisé est aujourd’hui le cycle de référence pour tous les nouveaux véhicules de catégorie L, et ce depuis la norme euro5.

La documentation technique est disponible ici :  [https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs](https://unece.org/transport/standards/transport/vehicle-regulations-wp29/global-technical-regulations-gtrs)

Un rapport de la Commission EU de 2018 sur « les effets de la phase environnementale Euro 5 en ce qui concerne les véhicules de catégorie L » indique : « Les résultats de l’étude ont établi que l’utilisation du cycle WMTC était pertinente pour tous les véhicules de catégorie L. Il contribue à une meilleure protection de l’environnement dans des conditions d’utilisation réelles que les cycles de conduite actuellement utilisés. » [https://www.europarl.europa.eu/RegData/docs\_autres\_institutions/commission\_europeenne/com/2018/0136/COM\_COM(2018)0136\_FR.pdf](https://www.europarl.europa.eu/RegData/docs\_autres\_institutions/commission\_europeenne/com/2018/0136/COM\_COM\(2018\)0136\_FR.pdf)

Le cycle comporte 3 phases, applicable ou non selon la vitesse maximale du véhicule. De plus les vitesses sont tronquées pour les véhicules limités à 45km/h. Cependant, je n’ai pas réussi à trouver très concrètement comment le WMTC est tronqué en termes de vitesse maximale pour correspondre aux différentes catégories (voir graphique ci-dessous).

<figure><img src="../../../../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

### Energie musculaire par pédalage

L’énergie musculaire apportée au vélo serait de l’ordre de 100W. C’est ce qui est retenu dans la thèse suivante par exemple : [2014LIMO4007.pdf](https://aurore.unilim.fr/theses/nxfile/default/e64bb679-1855-427d-93c0-36b85f2dbe69/blobholder:0/2014LIMO4007.pdf). A ce stade aucune étude plus détaillée n’a été identifiée, indiquant les niveaux de puissance en fonction du profil de cycliste et de motif de déplacement par exemple.

Cette valeur de 100W a été présentée au groupe de travail et validée à titre provisoire. Elle pourra être revue une fois davantage de données collectées sur ce sujet.

Il est donc retenu comme hypothèse que les véhicules équipés de pédales permettent de réduire la puissance moteur de 100W sur les phases d’accélération et de maintien de vitesse du cycle WMTC.

## Modélisation Ecobalyse

### Données renseignées par l'utilisateurs

L'utilisateur renseigne les informations suivantes :

* Consommation du véhicule selon le cycle WMTC (kWh/km)\
  Des informations supplémentaires sur ce cycle sont fournies sur cette page
* Apport d'énergie par pédalage (Oui/Non)
* Durée de vie du véhicule (en années)
* Kilométrage annuel (en km/an)

## Calcul de l'impact de la consommation électrique

Le coût environnemental de la consommation électrique se calcule comme suit (exemple pour l'impact sur le changement climatique) :

$$
ImpactElec = C_r*Tkm*PelecFRcch
$$

Avec&#x20;

* C\_r : la consommation l'électricité par recharge sur le réseau électrique, en kWh/km.
* Tkm : la durée de vie du véhicule, en km. Le calcul de la durée de vie du véhicule est détaillée dans la [page dédiée](duree-de-vie-des-vehicules.md).
* PélecFRcch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française

## Calcul de la consommation électrique

### Formule de calcul

La consommation électrique est définit comme suit :&#x20;

$$
C_r = max (0;Cwmtc-Ep-Epv.m)
$$

Avec :&#x20;

* C\_r : la consommation l'électricité par recharge sur le réseau électrique
* Cwmtc : La consommation du véhicule selon le cycle WMTC, retenu comme référence pour la consommation des VeLI. Cela signifie que les constructeurs indiquent la consommation de leurs véhicules lorsque celui-ci suit ce cycle, selon la classe du cycle qui correspond au véhicule.
* Ep : l'énergie apportée par pédalage, pour les véhicules à pédale, établie par la classe WMTC. Les données par catégorie de véhicules sont fournies dans le tableau ci-dessous
* Epv.m : l'énergie maximale apportée par des panneaux solaires photovoltaïques, selon le calcul détaillé dans la [page dédiée](energie-apportee-par-des-panneaux-solaires-photovoltaique.md)

### Données clés par catégorie de véhicule

<table><thead><tr><th width="140">Catégories</th><th width="138">Classe WMTC</th><th>Vitesse moyenne WMTC (km/h</th><th>% maintien de vitesse ou accélération WMTC</th><th>Energie par pédalage (Wh/km)</th></tr></thead><tbody><tr><td>VAE</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>4.0</td></tr><tr><td>L1e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L1e-A</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>4.0</td></tr><tr><td>L1e-B</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L2e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L3e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L4e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L5e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L6e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L7e</td><td>Class2-2-90</td><td>39.4</td><td>50%</td><td>1.3</td></tr><tr><td>Autre</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr></tbody></table>

