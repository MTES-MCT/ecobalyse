---
description: Cette page décrit les méthodes relatives à la consommation des véhicules
---

# ⚡ Consommation des véhicules

## Calcul de l'impact de la consommation électrique

Le coût environnemental de la consommation électrique se calcule comme suit (exemple pour l'impact sur le changement climatique) :

$$
ImpactElec = C_r*PelecFRcch
$$

Avec&#x20;

* C\_r la consommation l'électricité par recharge sur le réseau électrique
* PélecFRcch : la quantité de kgCO2e émise pour produire 1 kWh d'électricité française

## Calcul de la consommation électrique

### Formule de calcul

La consommation électrique est définit comme suit :&#x20;

$$
C_r = Cwmtc-Ep-Epv
$$

Avec :&#x20;

* C\_r : la consommation l'électricité par recharge sur le réseau électrique
* Cwmtc : La consommation du véhicule selon le cycle WMTC, retenu comme référence pour la consommation des VeLI. Cela signifie que les constructeurs indiquent la consommation de leurs véhicules lorsque celui-ci suit ce cycle, selon la classe du cycle qui correspond au véhicule.
* Ep : l'énergie apportée par pédalage, pour les véhicules à pédale, établie par la classe WMTC. Les données par catégorie de véhicules sont fournies dans le tableau ci-dessous
* Epv : l'énergie apportée par des panneaux solaires photovoltaïques, selon le calcul détaillé dans la section dédiée

### Données clés par catégorie de véhicule

<table><thead><tr><th width="140">Catégories</th><th width="138">Classe WMTC</th><th>Vitesse moyenne WMTC (km/h</th><th>% maintien de vitesse ou accélération WMTC</th><th>Energie par pédalage (Wh/km)</th></tr></thead><tbody><tr><td>VAE</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>4.0</td></tr><tr><td>L1e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L1e-A</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>4.0</td></tr><tr><td>L1e-B</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L2e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L3e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L4e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L5e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr><tr><td>L6e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>2.2</td></tr><tr><td>L7e</td><td>Class2-2-90</td><td>39.4</td><td>50%</td><td>1.3</td></tr><tr><td>Autre</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.9</td></tr></tbody></table>

