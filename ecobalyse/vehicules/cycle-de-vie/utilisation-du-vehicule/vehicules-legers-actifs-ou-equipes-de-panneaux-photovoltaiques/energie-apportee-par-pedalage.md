# 🚴 Energie apportée par pédalage

Les véhicules actifs se différencie par une énergie apportée par le conducteur par pédalage. Cette énergie est prise en compte pour les Vehicules Legers Intermédiaires (velis) 100% électriques.

### Puissance musculaire par pédalage

La puissance musculaire apportée à un véhicule actif serait de 40W à 100W en fonction du conducteur. le valeur de 100W est retenu dans la thèse suivante par exemple : [2014LIMO4007.pdf](https://aurore.unilim.fr/theses/nxfile/default/e64bb679-1855-427d-93c0-36b85f2dbe69/blobholder:0/2014LIMO4007.pdf). A ce stade aucune étude plus détaillée n’a été identifiée, indiquant les niveaux de puissance en fonction du profil de cycliste et du motif de déplacement par exemple.

Cette valeur de 100W a été présentée au groupe de travail de l'eXtreme Défi sur l'empreinte environnementale des velis, et validée à titre provisoire. Elle pourra être revue une fois davantage de données collectées sur ce sujet.

Il est donc retenu comme hypothèse que les véhicules électriques équipés de pédales permettent de réduire la puissance moteur de 100W sur les phases d’accélération et de maintien de vitesse du cycle WMTC.

### Calcul de l'électricité économisée par pédalage

L'énergie apportée par pédalage est calculée pour chaque catégorie de véhicule comme suit :&#x20;

Avec :

* E\_actif, l'électricité par pédalage, en kWh/km
* P\_actif, la puissance musculaire apportée par le conducteur, exprimée en kW, et fixée à 100W, soit 0.1kW.
* r\_actif : la part du cycle WLTP où le conducteur est actif, en %, avec l'hypothèse qu'elle correspond à la part de maintien de vitesse ou d'accélération sur le cycle
* Vm la vitesse moyenne (km/h) sur le cycle WMTC, en km/h

Les résultats sont détaillés dans le tableau suivant catégorie par catégorie :

<table><thead><tr><th width="140">Catégorie</th><th width="138">Classe WMTC</th><th>Vm</th><th width="144">r_actif</th><th>E_actif</th></tr></thead><tbody><tr><td>VAE</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>0.4</td></tr><tr><td>L1e-A</td><td>Class1-25</td><td>17.6</td><td>70%</td><td>0.4</td></tr><tr><td>L1e-B</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>0.22</td></tr><tr><td>L2e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>0.22</td></tr><tr><td>L3e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.09</td></tr><tr><td>L4e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.09</td></tr><tr><td>L5e</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.09</td></tr><tr><td>L6e</td><td>Class1-45</td><td>22.8</td><td>50%</td><td>0.22</td></tr><tr><td>L7e</td><td>Class2-2-90</td><td>39.4</td><td>50%</td><td>0.13</td></tr><tr><td>Autre</td><td>class3-2</td><td>57.8</td><td>54%</td><td>0.09</td></tr></tbody></table>
