---
hidden: true
---

# ♻️ \[V2 EN COURS] Etape 8 - Fin de vie

## Contexte

### Principes de modélisation

La modélisation de la fin de vie des produit s'appuie sur des principes communs à toutes les catégories de produits, définie dans la page [🗑️&#x20;Fin de vie des produits](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses/fin-de-vie#niveau-0).



Quatre exutoires de fin de vie sont identifiables pour les textiles d'habillement :

1. **Traitement comme déchets ménagers** (collecte pour incinération ou enfouissement)\
   Celui-ci s'applique lorsque les déchets textiles ne sont pas collectés, et ne se rentrouvent pas dans la filière de fin de vie dédiée aux textiles.&#x20;
2.  **Recyclage**\
    Le recyclage considère essentiellement la production de matériaux non-tissés isolants, de chiffons d'essuyage, et dans une plus faible mesure de nouveaux produits textiles repassant en filature ou filage. La prise en compte de ce recyclage se fait via la Circular Footprint Formula (CFF). [Nous avons estimé l'impact de ces circuits de recyclage et trouvé qu'il était négligeable sur cette page.](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/etape-1-matieres/circular-footprint-formula-cff-matiere-1)


3. **Réutilisation**\
   Cet exutoire comprend les produits réutilisés dans le cas de la seconde-main, et dont la durée de vie est donc augmentée. Cela comprend les vêtements réutilisés en France, en Europe, mais aussi exportés hors Europe. Néanmoins dans ce dernier cas, ne sont pas considérés comme réutilisés tous les vêtements exportés, comme explicité ci-dessous. La durée de vie des produits réutilisé étant allongée, nous ne leur modélisation pas d'impact en fin de vie. &#x20;
4. **Fin de vie hors Europe**\
   **U**ne part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés (entre 20% et 50% des cas selon les pays en Afrique selon une [étude ](https://changingmarkets.org/take-back-trickery/)Changing Markets de 2023). Ces vêtements, considérés comme des déchets hors Europe, sont généralement soit incinérés à ciel ouvert, enfouis en décharge non contrôlée ou abandonnés comme déchets sauvages. Ce traitement est intégré dans Ecobalyse avec l'hypothèse d'une incinération à ciel ouvert, correspondant à une approche majorante.



## Scénarios de fin de vie

### Hypothèses

La modélisation des flux des scénarios de fin de vie s'appuie principalement sur le rapport d'activité de l'année 2024 de Refashion.&#x20;

* Taux de collecte : 32,5% dont :&#x20;
  * 56,8% sont définis comme réutilisés, parmi lesquels 90% sont exporté. ([source](https://refashion.fr/devenir-des-textiles-et-chaussures-usages))&#x20;
  * 34,4% sont envoyés en recyclage (tout exutoire confondu)
  * 8,8% sont incinérés (CSR, avec valorisation énergétique, ou sans valorisation énergétique)
  *



### Probabilité de fin de vie hors Europe

Une part significative des vêtements exportés hors Europe sont directement jetés sans être réutilisés (entre 20% et 50% des cas selon les pays en Afrique selon une [étude ](https://changingmarkets.org/take-back-trickery/)Changing Markets de 2023). Parmi ces vêtements exportés, les vêtements synthétiques sont moins souvent réutilisés que les vêtements naturels. A partir des hypothèses décrites ci-dessous, il est donc estimé qu'environ 8% des vêtements finissent exportés sans être réutilisés, avec une probabilité d'environ 11% pour les vêtements synthétiques, contre 3% pour les vêtements naturels.&#x20;

<details>

<summary>Pourquoi les vêtements synthétiques seraient moins réutilisés ?  </summary>

Lorsqu'ils arrivent à destination, par exemple en Afrique, les vêtements sont généralement triés une seconde fois. Des observations, rapportées par différents échanges avec des spécialistes de la fin de vie et une revue de la bibliographie à ce sujet, font état d'une valeur perçue plus importante pour les vêtements en matières naturelles. Comparativement aux vêtements en matières synthétiques, ceux-ci ont plus de chance d'être revendus, repris, rapiécés, upcyclés. Ils ont donc moins de chances d'être directement jetés. \
\
Ce constat est notamment appuyé par :&#x20;

* les [travaux ](https://www.ifmparis.fr/en/faculty/andree-anne-lemieux)et différents échanges avec Andrée-Anne Lemieux (chaire Sustainability IFM-Kering),
* l'initiative [Fashion For Good](https://fashionforgood.com/) dans son rapport [Sorting For Circularity Europe](https://fashionforgood.com/our_news/sorting-for-circularity-europe-project-findings/). L'hypothèse que la perception des vêtements synthétiques par le consommateur pourrait être moindre (cf. extrait du rapport ci-dessous) est effectivement partagée : \
  "_The difference in fibre composition found could also reflect a preference from consumers in the focus countries for cotton products over polyester, or could be an effect of consumer disposal behaviour as they might regard polyester products as lower value and therefore, choose to dispose of them in household waste rather than giving it to charity for reuse_.",
* le retour d'expérience du principal marché secondaire de vêtements au Ghana (marché de Katamanto à Accra) via des échanges avec [_En Mode Climat_](https://www.enmodeclimat.fr/) et [_The Or Foundation_](https://theor.org/).&#x20;

</details>

{% hint style="info" %}
Les valeurs ProbaDéchet par type de fibre sont calculés sur la base de 3 hypothèses :&#x20;

1\) En moyenne, 50% des vêtements exportés hors Europe ne sont pas réutilisés,

2\) Les vêtements exportés hors Europe se composent à 69% de vêtements composés de fibres synthétiques vs 31% de vêtements composés d'autres matières (Source[^1] = marché mondial des fibres textile),

3\) les vêtements composés de matières synthétiques ont 65% de chance de ne pas être réutilisés (donc la probabilité des vêtements composés de matières non synthétiques d'être non réutilisés est de 17% afin de retrouver une probabilité moyenne de 50%). &#x20;
{% endhint %}

<table><thead><tr><th width="233">Scénario</th><th width="215">Export hors Europe</th><th>Déchets</th><th>ProbaDéchet</th></tr></thead><tbody><tr><td>Moyenne</td><td>16,6% <br>(= 32,5% * 56,8% * 0,9)</td><td>50%</td><td>8,3%</td></tr><tr><td>Vêtements synthétiques</td><td>cf. ci-dessus</td><td>65%</td><td>10,8%</td></tr><tr><td>Autres vêtements</td><td>cf. ci-dessus</td><td>17%</td><td>2,8%</td></tr></tbody></table>

###

### Arbre des flux

<figure><img src="../../.gitbook/assets/image (402).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/image (403).png" alt=""><figcaption></figcaption></figure>

<mark style="color:$warning;">**Question  à poser à Nicolas :**</mark> <mark style="color:$warning;"></mark><mark style="color:$warning;">est-ce que la partie transport pour la collecte est bien prise en compte ? Car pas de trace dans la doc générique, et à priori ce n'est pas négligeable sur le total de la FDV.</mark>&#x20;

Les étapes suivantes sont évaluées et détaillées dans ce paragraphe : Le traitement comme déchet municipal (_Municipal waste collection_) est évalué en prenant en compte les étapes suivantes :

* Transport en voiture par l'utilisateur du vêtement vers un point de collecte (_Recycling collection_) ;
* Transport en camion vers un site de tri puis de recyclage ou à défaut incinération (_Recycling collection_) ;
* Transport en camion vers un site de traitement des ordures ménagères (_Municipal waste collection_) ;
* Incinération (Incineration) ;
* Mise en décharge (Landfill).

## Méthodes de calcul

### Calcul général

Le calcul se décompose en une partie&#x20;

$$
I_{8} = \frac{m}{1000}* I_{EoL}+d_{collection,car}*\frac{V_{vetement}}{V_{coffre}}*I_{car}
$$

Avec :

* `I_8` : l'impact environnemental de la fin de vie (hors complément hors ACV), dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg,
* `I_EoL` :  l'impact environnemental relatif à la fin de vie, dans l'unité de la catégorie d'impact analysée par kg
* `d_collection,car` : la distance parcourue en voiture pour déposer un vêtement dans un point de collecte (distance entre le domicile du consommateur et le point de collecte), en km
* `V_vetement` : le volume du vêtement étudié, en m3
* `V_coffre` : le volume de coffre moyen d'une voiture, en m3
* `I_car` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par km parcouru

## Paramètres retenus pour le coût environnemental

### Distances de transport considérée

* Distance moyenne parcourue en voiture pour déposer un vêtement dans un point de collecte :
  * `d_collection,car` = 1km

### Part du coffre occupée par le vêtement `V_vetement` et `V_coffre`

Ces données sont directement issues du PEFCR Apparel & Footwear 3.1, Table 44 (voir ci-dessous).

* Volume du vêtement étudié `V_vetement` : voir colonne _Default product_ dans le tableau.
* Volume de coffre moyen d'une voiture&#x20;
  * `V_coffre` = 0.2m3

Le rapport des deux correspond à la part du coffre occupée par le vêtement. Ce ratio est fourni dans la Table 44 ci-dessous, colonne _Allocation_).

<figure><img src="../../.gitbook/assets/image (378).png" alt=""><figcaption></figcaption></figure>

## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) :&#x20;

* I\_EoL : [Fin de vie hors voiture (transport en camion, incinération, mise en décharge)](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/#/explore/textile/textile-processes/ab96b73f-8534-59ad-9f34-a579abe3b023)
* I\_car : [Transport en voiture jusqu'au point de collecte précalculé pour la fin de vie](https://ecobalyse.beta.gouv.fr/versions/v7.0.0/#/explore/textile/textile-processes/2fd6b74f-600a-577c-ba37-b84d8f0482c2)

{% hint style="info" %}
### Calcul du procédé Fin de vie hors voiture

Le calcul se décompose comme suit :

$$
I_{EoL} = I_{rec,collection,truck}+ I_{mw,collection,truck}+I_{EoL,incineration}+I_{EoL,landfill}
$$

Avec :

* `I_EoL` :  l'impact environnemental relatif à la fin de vie, dans l'unité de la catégorie d'impact analysée par kg
* `I_rec,collection,truck` :  l'impact environnemental du transport en camion pour la collecte de vêtement destinés au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_wm,collection,truck` :  l'impact environnemental du transport en camion pour la collecte de vêtement en tant qu'ordures ménagères, dans l'unité de la catégorie d'impact analysée
* `I_EoL,incineration` :  l'impact environnemental relatif à l'incinération, dans l'unité de la catégorie d'impact analysée
* `I_EoL,landfill` :  l'impact environnemental relatif à l'enfouissement, dans l'unité de la catégorie d'impact analysée

**Impact environnemental camion pour la collecte en vue d'un recyclage `I_sort,collection,truck`**

$$
I_{sort,collection,truck} = \frac{m}{1000}*\big(d_{collect>sort}*r_{sort}+d_{sort>rec}*r_{rec}+d_{sort>inc}*r_{sort.inc}\big)*I_{truck}
$$

Avec :

* `I_sort,collection,truck` : l'impact environnemental du transport en camion pour la collecte de vêtements faisant l'objet d'un tri en vue d'un recyclage, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `d_collect>sort` : la distance entre le point de collecte et le site de tri, exprimée en km
  * `d_collect>sort` = 130km
* `r_sort` : la part de produits collectée et triée en vue d'un recyclage, sans unité
  * `r_sort` = 19.5% (= `1-r_mw`)
* `d_sort>rec` : la distance entre le site de tri et le site de recyclage, exprimée en km
  * `d_sort>rec` = 100km
* `r_rec` : la part de produits collectées et triées puis recyclée, sans unité
  * `r_rec` = 16.9%
* `d_sort>inc` : la distance entre le site de tri et le site d'incinération, exprimée en km
  * `d_sort>inc` = 30km
* `r_sort,inc` : la part de produits collectée et triée puis incinérée, sans unité
  * `r_sort,inc` = 2.6% (= `r_sort-r_rec`)
* `I_truck` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par tonne.km

**Impact environnemental camion pour la collecte en tant qu'ordure ménagère `I_mw,collection,truck`**

$$
I_{mw,collection,truck} = \frac{m}{1000}*(d_{mw,collection} *r_{mw})*I_{truck}
$$

Avec :

* `I_mw,collection,truck` : l'impact environnemental du transport en camion pour les vêtements traités comme ordures ménagères, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `d_mw,collection` : Distance entre le domicile du consommateur et le centre de traitement des ordures ménagères, exprimée en km
* `r_mw` : la part de produits traité comme ordure ménagère, sans unité
  * `r_mw` = 80.5%
* `I_truck` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par tonne.km

**Impact environnemental relatif à l'incinération `I_EoL,incineration`**

$$
I_{EoL,incineration} = \frac{m}{1000}*(r_{mw}*r_{mw,incineration} +r_{sort,inc})*I_{incineration}
$$

Avec :

* `I_EoL,incineration` : l'impact environnemental relatif à l'incinération, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `I_incineration` : l'impact environnemental relatif à l'incinération d'1 kg de produits, dans l'unité de la catégorie d'impact analysée par kg

**Impact environnemental relatif à l'enfouissement `I_EoL,landfill`**

$$
I_{EoL,landfill} = \frac{m}{1000}*(r_{mw}*r_{mw,landfill} )*I_{landfill}
$$

Avec :

* `I_EoL,landfill` : l'impact environnemental relatif à l'enfouissement, dans l'unité de la catégorie d'impact analysée
* `m` : la masse du vêtement, exprimée en kg
* `I_EoL,landfill` : l'impact environnemental relatif à l'incinération d'1 kg de produits, dans l'unité de la catégorie d'impact analysée par kg



_<mark style="color:$info;">**NB : Les valeurs des paramètres sont directement issues du PEFCR Apparel & Footwear 3.1, essentiellement dans la Table 45 ci-dessous).**</mark>_

_<mark style="color:$info;">**Les valeurs de chaque paramètre sont également détaillées dans les sections suivantes.**</mark>_


{% endhint %}

<figure><img src="../../.gitbook/assets/Capture d&#x27;écran 2025-09-25 171126.png" alt=""><figcaption></figcaption></figure>

## Exemple d'application

Exemple pour un T-shirt de masse `m`=170g.

$$
I_{8} = \frac{m}{1000}* I_{EoL}+d_{collection,car}*\frac{V_{vetement}}{V_{coffre}}*I_{car} =  \frac{0.17}{1000}*33.11+1*\frac{0.0018}{0.2}*1.94=5.65Pts
$$





[^1]: Textile Exchange \_ The global fiber market 2025
