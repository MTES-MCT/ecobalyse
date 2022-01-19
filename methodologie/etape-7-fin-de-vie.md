# ♻ Etape 7 - Fin de vie

Pour évaluer l'impact de la fin de vie on se base sur le PEF RP Study de la commission européenne.

On peut y trouver ce tableau :

![](<../.gitbook/assets/Screenshot 2022-01-14 at 14.24.24.png>)

On considère donc 2 circuits de fin de vie : le "municipal waste collection" et le "recycling collection".

On prend en compte 4 procédés sur ces 2 circuits :&#x20;

* le transport en camion (Truck)
* le transport en voiture (Passenger car)
* l'incinération
* la mise en décharge

### Transport en camion

D'après Table 33 on peut estimer la distance en faites en camion (notée d\_camion) pour l'étape de fin de vie d'un vêtement :&#x20;

```
d_camion = d_municipal_waste_collection + d_recycling_collection
d_municipal_waste_collection = 30 * 80.5%

d_recycling_collection = 130 * 19.5% + 100 * 16.9% + 30 * 3.6%

d_camion = 30 * 80.5% + 130 * 19.5% +  100 * 16.9% + 30 * 3.6%
d_camion = 67.48 km
```

La demande en transport en camion D\_camion s'exprime en tonnes.km. Pour un vêtement de masse m on a donc :

```
D_camion = m * d_camion
Pour un t-shirt m = 170 g = 0.00017 tonne

D_camion = 0.00017 * 67.48 
D_camion = 0.01147 tonnes.km
```

A partir du procédé de transport en camion P\__camion_\_cch, on peut en déduire l'impact sur le changement climatique du transport en camion de la fin de vie du t-shirt :&#x20;

```
Impact_camion = D_camion * P_camion_cch
Impact_camion = 0.01147 * 0.269575
Impact_camion = 0.003092 kgCO2e
Impact_camion = 3.09 gCO2e
```

### Transport en voiture

D'après Table 33, 19.5% des vêtements font 1 km en voiture pour être déposé dans le point de collecte des vêtements. D'où

```
d_voiture = 1*19.5%
d_voiture = 0.195 km
```

Pour chaque vêtement&#x20;

```
Impact_voiture = d_voiture * P_voiture_cch
Impact_voiture = 0.195 * 0.18713
Impact_voiture = 0.03649 kgCO2e
Impact_voiture = 36.49 gCO2e
```

### Incinération/Mise en décharge

On prend les hypothèses issue du document PEF RP study p.72 :&#x20;

> 45% of municipal waste collected is incinerated and 55% is landfilled.

Soit P\_incinération le procédé d'incinération de déchets textile en France :&#x20;

```
Impact_incinération = m * part_incinération * P_incinération_cch

part_incinération = (80.5% + 2.6%) * 45% = 37.395%
Impact_incinération = 0.17 * 37.395% * 0.397022
Impact_incinération = 0.02523 kgCO2e
```

De même pour la mise en décharge, avec P\_décharge le procédé de mise en décharge textile en France :&#x20;

```
Impact_décharge = m * part_décharge * P_décharge_cch

part_décharge = (80.5% + 2.6%) * 55% = 45.705%
Impact_décharge = 0.17 * 45.705% * 2.22265
Impact_décharge = 0.17269 kgCO2e
```

