---
hidden: true
---

# ♻️ Etape 8 - Fin de vie - old

L'impact de la fin de vie se décompose en deux modules :&#x20;

* le complément _Fin de vie Hors Europe_ introduit par Ecobalyse en septembre 2023,
* le scénario proposé dans la v.1.3 du _PEFCR Apparel & Footwear_.

Jusqu'à l'introduction du complément, la fin de vie pesait entre 0% et 1% de l'impact total d'un vêtement. L'introduction du complément permet de répondre à la principale limite des scénarios proposés par le PEFCR A\&F (limite = 100% des vêtements exportés sont réutilisés et ne génèrent aucun impact).&#x20;

## Complément Fin de vie Hors Europe

Cf. la [page](../complements-hors-acv/export-hors-europe.md) dédiée dans la rubrique "Compléments hors ACV"

## Scénario PEFCR Apparel & Footwear

Scénarios considérés pour la fin de vie d'un vêtement :&#x20;

![PEFCR v1.3 p121](<../../.gitbook/assets/image (163).png>)

&#x20;On prend en compte ces 2 scénarios :&#x20;

* Recyclage
* Décharge (incinératon & mise en décharge)

<details>

<summary>Recyclage</summary>

Pour le recyclage, 2 circuits sont proposés ici : le recyclage en chiffons (wipers) et en matériaux d'isolation (insulation). La prise en compte de ce recyclage se fait via la Circular Footprint Formula (CFF). [Nous avons estimé l'impact de ces circuits de recyclage et trouvé qu'il était négligeable sur cette page.](etape-1-matieres/circular-footprint-formula-cff-matiere-1.md)

</details>

<details>

<summary>Décharge</summary>

Pour évaluer l'impact de l'incinération et de la mise en décharge, on prend en compte les procédés suivants :

* le transport en camion (Truck)
* le transport en voiture (Passenger car)
* l'incinération
* la mise en décharge



### **Focus Transport**

**Distance transport (Table 41 / p. 122)**

![](<../../.gitbook/assets/image (213).png>)

**Volume produit (Table 40 / p. 121)**

![](<../../.gitbook/assets/image (212).png>)

#### Transport en camion

D'après le tableau Distance (Table 41), on peut estimer la distance faite en camion (notée d\_camion) pour l'étape de fin de vie d'un vêtement :

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

À partir du procédé de transport en camion P\__camion_\_cch, on peut en déduire l'impact sur le changement climatique du transport en camion de la fin de vie du t-shirt :

```
Impact_camion = D_camion * P_camion_cch
Impact_camion = 0.01147 * 0.269575
Impact_camion = 0.003092 kgCO2e
Impact_camion = 3.09 gCO2e
```

#### Transport en voiture

D'après le tableau Distance (Table 33), 19.5% des vêtements font 1 km en voiture pour être déposé dans le point de collecte des vêtements. D'où `d_voiture` la distance parcourue en voiture pour un vêtement.&#x20;

```
d_voiture = 1*19.5%
d_voiture = 0.195 km
```

Le PEFCR v1.3 indique qu'il faut prendre en compte la part du coffre qu'occupe le vêtement que l'on amène au point de collecte (cf. tableau Volume / Table 40).&#x20;

```
Impact_voiture = d_voiture * part_coffre_occupé * P_voiture_cch 
Avec part_coffre_occupé = volume_tshirt / volume_coffre

Finalement : 
Impact_voiture = 0.195 * 0.0018/0.2 * 0.18713
Impact_voiture = 0.000328 kgCO2e
Impact_voiture = 0.328 gCO2e
```

###

### Focus Incinération (CFF)&#x20;

On prend les hypothèses issues du document PEF RP study p.72 :

45% of municipal waste collected is incinerated and 55% is landfilled.

Soit P\_incinération le procédé d'incinération de déchets textiles en France:

```
Impact_incinération = m * part_incinération * P_incinération_cch
part_incinération = (80.5% + 2.6%) * 45% = 37.395%
Impact_incinération = 0.17 * 37.395% * 0.397022
Impact_incinération = 0.02523 kgCO2e
```

Dans la documentation de la Base Impacts, l'énergie de l'incinération est valorisée en électricité. Comme le stipule la CFF (Circular Footprint Formula) il faut donc retrancher l'impact de l'électricité si elle avait été généré d'une autre manière.\
On peut calculer d'abord l'impact de cette électricité si elle avait généré de façon standard :

```
Bénéfice_incinération = m * part_incinération * Elec_incinération * P_élec_FR
Elec_incinération = 2.25 MJ/kg incinéré
Elec_incinération = 2.25/3.6 kWh/kg incinéré
Bénéfice_incinération = 0.17 * 37.395% * 2.24 / 3.6 * 0.0813
Bénéfice_incinération = 0.003 kgCO2e
```

Finalement :

```
Impact_total_incinération = Impact_incinération - Bénéfice_incinération
Impact_total_incinération = 0.022 kgCO2e
```

###

### Focus Mise en décharge

De même pour la mise en décharge, avec P\_décharge le procédé de mise en décharge textile en France :

```
Impact_décharge = m * part_décharge * P_décharge_cch

part_décharge = (80.5% + 2.6%) * 55% = 45.705%
Impact_décharge = 0.17 * 45.705% * 2.22265
Impact_décharge = 0.17269 kgCO2e
```

</details>
