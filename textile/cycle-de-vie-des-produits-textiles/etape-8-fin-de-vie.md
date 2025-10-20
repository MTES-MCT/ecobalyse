---
hidden: true
---

# ♻️ Etape 8 - Fin de vie

## Contexte

Trois scénarios de fin de vie sont identifiables pour les vêtements :

1. Traitement comme déchets ménagers (collecte pour incinération ou décharge)
2. Recyclage
3. Export hors Europe avec fin de vie inconnue

{% hint style="info" %}
### Introduction d'un complément "Export hors Europe"

Le PEFCR Apparel & Footwear détaille bien les deux premiers scénarios (voir ci-dessous), mais considère que 100% des vêtements exportés sont réutilisés et ne génèrent aucun impact, ce qui ne correspond pas à la réalité et présente une limite à la méthode.

C'est pourquoi un complément hors ACV "Export hors Eurpoe" a été introduit par Ecobalyse en septembre 2023. Ce complément est détaillé dans une page spécifique [Export hors Europe](https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/export-hors-europe).&#x20;
{% endhint %}

**Cette page décrit les méthodes pour la fin de vie incluent dans le PEFCR Apparel & Footwear v1.3, hors complément.**

### **Scénarios** PEFCR Apparel & Footwear

<figure><img src="../../.gitbook/assets/image (379).png" alt=""><figcaption></figcaption></figure>

Le recyclage consiste essentiellement en du recyclage en chiffons (_wipers_) et en matériaux d'isolation (_insulation_). La prise en compte de ce recyclage se fait via la Circular Footprint Formula (CFF). [Nous avons estimé l'impact de ces circuits de recyclage et trouvé qu'il était négligeable sur cette page.](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/etape-1-matieres/circular-footprint-formula-cff-matiere-1)

Les étapes suivantes sont évaluées et détaillées dans cette page : Le traitement comme déchet municipal (_Municipal waste collection_) est évalué en prenant en compte les étapes suivantes :

* Transport en voiture par l'utilisateur du vêtement vers un point de collecte (_Recycling collection_) ;
* Transport en camion vers un site de tri puis de recyclage ou à défaut incinération (_Recycling collection_) ;
* Transport en camion vers un site de traitement des ordures ménagères (_Municipal waste collection_) ;
* Incinération (Incineration) ;
* Mise en décharge (Landfill).

## Méthodes de calcul

### Calcul général

Le calcul se décompose en une partie&#x20;

$$
I_{8} = I_{rec,collection,car}+ I_{rec,collection,truck}+ I_{mw,collection,truck}+I_{EoL,incineration}+I_{EoL,landfill}
$$

$$
I_{8} = \frac{m}{1000}* I_{EoL}+I_{rec,collection,car}
$$

Avec :

* `I_8` : l'impact environnemental de la fin de vie (hors complément hors ACV), dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg,
* `I_EoL` :  l'impact environnemental relatif à la fin de vie, dans l'unité de la catégorie d'impact analysée par kg
* `I_rec,collection,car` :  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée

### Impact environnemental du transport en voiture `I_rec,collection,car`

$$
I_{rec,collection,car} = d_{collection,car}*r_{sort}*\frac{V_{vetement}}{V_{coffre}}*I_{car}
$$

Avec :

* `I_rec,collection,car` :  l'impact environnemental du transport en voiture (déplacement vers le point de collecte), dans l'unité de la catégorie d'impact analysée
* `d_collection,car` : la distance parcourue en voiture pour déposer un vêtement dans un point de collecte (distance entre le domicile du consommateur et le point de collecte), en km
* `r_sort` : la part de produits collectée et triée en vue d'un recyclage, sans unité
* `V_vetement` : le volume du vêtement étudié, en m3
* `V_coffre` : le volume de coffre moyen d'une voiture, en m3
* `I_car` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par km parcouru

## Paramètres retenus pour le coût environnemental

La valeurs des paramètres sont directement issues du PEFCR Apparel & Footwear 3.1, essentiellement dans la _Table 45_ ci-dessous).

<figure><img src="../../.gitbook/assets/Capture d&#x27;écran 2025-09-25 171126.png" alt=""><figcaption></figcaption></figure>

Les valeurs de chaque paramètre sont également détaillées dans les sections suivantes.

### Part de produit pour chaque destination

* Part de produits traité comme ordure ménagère
  * `r_mw` = 80.5%
* Part de produits collectée et triée en vue d'un recyclage :&#x20;
  * `r_sort` = 19.5% (= `1-r_mw`)
* Part de produits collectée et triée puis recyclée :
  * `r_rec` = 16.9%
* Part de produits collectée et triée puis incinérée
  * `r_sort,inc` = 2.6% (= `r_sort-r_rec`)

### Distances de transport considérée

* Distance parcourue en voiture pour déposer un vêtement dans un point de collecte :
  * `d_collection,car` = 1km
* Distance entre le point de collecte et le site de tri :
  * `d_collect>sort` = 130km
* Distance entre le site de tri et le site de recyclage :
  * `d_sort>rec` = 100km
* Distance entre le site de tri et le site d'incinération :
  * `d_sort>inc` = 30km
* Distance entre le domicile du consommateur et le centre de traitement des ordures ménagères :
  * `d_mw,collection` = 30km

### Part du coffre occupée par le vêtement `V_vetement` et `V_coffre`

Ces données sont directement issues du PEFCR Apparel & Footwear 3.1, Table 44 (voir ci-dessous).

* Volume du vêtement étudié `V_vetement` : voir colonne _Default product_ dans le tableau.
* Volume de coffre moyen d'une voiture&#x20;
  * `V_coffre` = 0.2m3

Le rapport des deux correspond à la part du coffre occupée par le vêtement. Ce ratio est fourni dans la Table 44 ci-dessous, colonne _Allocation_).

<figure><img src="../../.gitbook/assets/image (378).png" alt=""><figcaption></figcaption></figure>

## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes),&#x20;

* [Fin de vie hors voiture (transport en camion, incinération, mise en décharge)](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/#/explore/textile/textile-processes/ab96b73f-8534-59ad-9f34-a579abe3b023)
* [Transport en voiture jusqu'au point de collecte précalculé pour la fin de vie](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/#/explore/textile/textile-processes/2fd6b74f-600a-577c-ba37-b84d8f0482c2)



### Calcul du procédé Fin de vie hors voiture

Le calcul se décompose en une partie&#x20;

$$
I_EoL = I_{rec,collection,truck}+ I_{mw,collection,truck}+I_{EoL,incineration}+I_{EoL,landfill}
$$

Avec :

* `I_EoL` :  l'impact environnemental relatif à la fin de vie, dans l'unité de la catégorie d'impact analysée par kg
* `I_rec,collection,truck` :  l'impact environnemental du transport en camion pour la collecte de vêtement destinés au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_wm,collection,truck` :  l'impact environnemental du transport en camion pour la collecte de vêtement en tant qu'ordures ménagères, dans l'unité de la catégorie d'impact analysée
* `I_EoL,incineration` :  l'impact environnemental relatif à l'incinération, dans l'unité de la catégorie d'impact analysée
* `I_EoL,landfill` :  l'impact environnemental relatif à l'enfouissement, dans l'unité de la catégorie d'impact analysée

#### Impact environnemental camion pour la collecte en vue d'un recyclage `I_sort,collection,truck`

$$
I_{sort,collection,truck} = \frac{m}{1000}*\big(d_{collect>sort}*r_{sort}+d_{sort>rec}*r_{rec}+d_{sort>inc}*r_{sort.inc}\big)*I_{truck}
$$

Avec :

* `I_sort,collection,truck` : l'impact environnemental du transport en camion pour la collecte de vêtements faisant l'objet d'un tri en vue d'un recyclage, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `d_collect>sort` : la distance entre le point de collecte et le site de tri, exprimée en km
* `r_sort` : la part de produits collectée et triée en vue d'un recyclage, sans unité
* `d_collect>sort` : la distance entre le site de tri et le site de recyclage, exprimée en km
* `r_rec` : la part de produits collectée et triée puis recyclée, sans unité
* `d_collect>sort` : la distance entre le site de tri et le site d'incinération, exprimée en km
* `r_sort,inc` : la part de produits collectée et triée puis incinérée, sans unité
* `I_truck` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par tonne.km

#### Impact environnemental camion pour la collecte en tant qu'ordure ménagère `I_mw,collection,truck`

$$
I_{mw,collection,truck} = \frac{m}{1000}*(d_{mw,collection} *r_{mw})*I_{truck}
$$

Avec :

* `I_mw,collection,truck` :&#x20;
* `m` : la masse du vêtement, exprimée en kg
* `d_mw,collection` : Distance entre le domicile du consommateur et le centre de traitement des ordures ménagères, exprimée en km
* `r_mw` : la part de produits traité comme ordure ménagère, sans unité
* `I_truck` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par tonne.km

#### Impact environnemental relatif à l'incinération `I_EoL,incineration`

$$
I_{EoL,incineration} = \frac{m}{1000}*(r_{mw}*r_{mw,incineration} +r_{sort,inc})*I_{truck}
$$

Avec :

* `I_EoL,incineration` : l'impact environnemental relatif à l'incinération, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `I_EoL,incineration` : l'impact environnemental relatif à l'incinération d'1 kg de produits, dans l'unité de la catégorie d'impact analysée par kg

#### Impact environnemental relatif à l'enfouissement `I_EoL,landfill`



Avec :

* `I_EoL,landfill` : l'impact environnemental relatif à l'enfouissement, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `I_EoL,landfill` : l'impact environnemental relatif à l'incinération d'1 kg de produits, dans l'unité de la catégorie d'impact analysée par kg

## Exemple d'application

Exemple pour un T-shirt de masse `m`=170g.

$$
I_{rec,collection,car} = d_{collection,car}*r_{sort}*\frac{V_{vetement}}{V_{coffre}}*I_{car}=1*0.195*\frac{0.0018}{0.2}*1.94=0.058
$$

$$
I_{sort,collection,truck} = \frac{m}{1000}*\big(d_{collect>sort}*r_{sort}+d_{sort>rec}*r_{rec}+d_{sort>inc}*r_{sort.inc}\big)*I_{truck}
$$

$$
I_{sort,collection,truck} = \frac{0.17}{1000}*\big(130*0.195+100*0.169+30*0.026)*20.6=\frac{0.17}{1000}*43.0*20.6=0.15Pts
$$

$$
I_{mw,collection,truck} = \frac{m}{1000}*(d_{mw,collection} *r_{mw})*I_{truck}=\frac{0.17}{1000}*24.2*20.6=0.08Pts
$$



FDV tot : 5.65Pt (5629/170kg)

FDV : 33,11 /kg

FDV voiture : 1.94Pts





