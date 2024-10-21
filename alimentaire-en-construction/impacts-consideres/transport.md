# 🚛 Transport

## Étapes considérées

Différentes étapes de transport peuvent être mobilisées dans le cycle de vie d'un produit alimentaire. Le modèle considéré s'appuie sur la documentation Agribalyse, et en particulier les deux figures suivantes (cf. [Méthodologie AGB 3.1\_Alimentation.pdf](https://3613321239-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1\_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971) - section 3.6 Transport le long de la chaîne de valeur) :&#x20;

<figure><img src="../../.gitbook/assets/Figure 10 transport.PNG" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/Figure 11 transport.PNG" alt=""><figcaption></figcaption></figure>

Par rapport à la modélisation mobilisée dans Agribalyse, des valeurs par défaut sont proposées. Ces valeurs correspondent à des hypothèses plutôt majorantes, dans la mesure où certains paramètres peuvent ensuite être précisés, par exemple le pays d'origine des différents ingrédients.&#x20;

Les étapes suivantes sont donc considérées :&#x20;

| Étape                                                                                                                   | Hypothèse et paramétrage                                                          | Remarques                                                                                                                                                                                                          |
| ----------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <p>1.RECETTE<br>Acheminement d'un ingrédient vers le site de transformation (ex: ferme - usine IAA)</p>                 | Hypothèse par défaut  : 160 km de transport terrestre                             | <p>Cette distance est considérée, que le site de transformation soit situé en France ou dans un autre pays.<br>Elle n'est pas considérée pour un ingrédient agricole</p>                                           |
| <p>2. RECETTE<br>Transport international - Acheminement d'un ingrédient vers la zone logistique (ex : ferme - port)</p> | Hypothèse par défaut : 500 km de transport terrestre                              | Cette distance n'est considérée que si un ingrédient a été produit hors de France. Elle s'applique que la transformation se fasse en France ou dans le pays d'origine, voire même s'il n'y a pas de transformation |
| <p>3. RECETTE<br>Transport international - Transport vers la France (ex: port brésil/port France)</p>                   | <p>Hypothèses par défaut détaillées ci-après.<br>Pays d'origine paramétrable.</p> | Cette distance n'est considérée que si un ingrédient a été produit hors de France.                                                                                                                                 |
| <p>4. STOCKAGE<br>Transport vers le site de stockage (ex: IAA - entrepôt de stockage)</p>                               | Hypothèse par défaut : 450 km de transport terrestre (cf. figure 11 ci-dessus)    | Distance considérée systématiquement <mark style="color:red;">\[lorsque l'étape de stockage sera intégrée]</mark>                                                                                                  |
| <p>5. VENTE<br>Transport vers le lieu de vente au détail (entrepôt-magasin)</p>                                         | Hypothèse par défaut : 150 km de transport terrestre (cf. figure 11 ci-dessus)    | Distance considérée systématiquement <mark style="color:red;">\[lorsque l'étape de vente sera intégrée]</mark>                                                                                                     |
| 6. CONSOMMATION                                                                                                         | Pas de transport considéré (cf. figure 11 ci-dessus)                              | Ceci ne dépend pas du produit mais du lieu de vie du consommateur et de ses modes d'achats (livraison, déplacement dédié, déplacement combiné...)                                                                  |

{% hint style="info" %}
**Ingrédients agricoles et ingrédients industrie**.\
Dans le cas des ingrédients importés, le pays d'origine peut être précisé (étape 3. RECETTE dans le tableau ci-dessus) : \
\- import d'un ingrédient agricole (ex: tomate brute)\
\- import d'un ingrédient transformé (ex: coulis de tomate) \


Par simplification, on considère de manière similaire l'import de l'ingrédient ou du produit transformé; en considérant que l'étape de transformation est systématiquement en France (usage du mix électrique FR pour la transformation).
{% endhint %}

{% hint style="warning" %}
Vérification à faire : \
\- prise en compte du transport en fin de vie dans les impacts des emballages ;\
\- prise en compte du transport depuis le/les sites de production dans les impacts des ingrédients industrie
{% endhint %}

## Circuits considérés

3 circuits principaux sont considérés :&#x20;

<table><thead><tr><th width="227">Etape</th><th>Circuit France</th><th>Circuit hors France</th><th>Circuit avion</th></tr></thead><tbody><tr><td>1.RECETTE<br>Acheminement d'un ingrédient vers le site de transformation</td><td>160 km de camion</td><td>160 km de camion</td><td>160 km de camion</td></tr><tr><td>2. RECETTE<br>Transport international - Acheminement d'un ingrédient vers la zone logistique</td><td>N/A</td><td>500 km de camion</td><td>500 km de camion</td></tr><tr><td>3. RECETTE<br>Transport international - Transport vers la France</td><td>N/A</td><td>Hypothèse par défaut et paramétrage détaillés ci-après</td><td>Hypothèse par défaut et paramétrage détaillés ci-après</td></tr><tr><td>4. STOCKAGE<br>Transport vers le site de stockage</td><td>450 km de camion</td><td>450 km de camion</td><td>450 km de camion</td></tr><tr><td>5. VENTE<br>Transport vers le lieu de vente au détail</td><td>150 km de camion</td><td>150 km de camion</td><td>150 km de camion</td></tr><tr><td>6. CONSOMMATION</td><td>N/A</td><td>N/A</td><td>N/A</td></tr></tbody></table>

En l'absence de paramétrage du pays d'origine, les hypothèses appliquées pour le choix de circuit et pour le transport vers la France (étape 3. RECETTE) sont établies en distinguant 4 catégories d'ingrédient. La catégorie à laquelle chaque ingrédient appartient est précisée dans [l'explorateur d'ingrédients](https://ecobalyse.beta.gouv.fr/#/explore/food/ingredients) (champ "origine par défaut"). Si le circuit à considérer par défaut n'est pas (encore) précisé dans la page méthodologique relative à un ingrédient, c'est le circuit EUROPE-MAGHREB qui s'applique par défaut.

<table><thead><tr><th>Catégorie d'ingrédient</th><th width="186.33333333333331">Circuit appliqué</th><th>Hypothèse par défaut (-> France)</th></tr></thead><tbody><tr><td>FRANCE<br>Ingrédients très majoritairement produits en France (seuil : ~95%)</td><td>Circuit France</td><td>N/A</td></tr><tr><td>EUROPE-MAGHREB<br>Ingrédients très majoritairement produits en Europe ou au Maghreb (seuil : ~95%)</td><td>Circuit hors France</td><td>Transport par défaut :  <br>- 2500 km de camion</td></tr><tr><td>HORS EUROPE-MAGHREB<br>Ingrédient provenant de façon significative de pays hors Europe / Maghreb (seuil : ~5%)</td><td>Circuit hors France</td><td>Transport par défaut : <br>- 18 000 km en bateau<br>- 2500 km en camion</td></tr><tr><td>HORS EUROPE-MAGHREB (AVION)<br>Cas particulier des ingrédients transportés de façon non marginale par avion (mangue, haricots...)</td><td>Circuit avion</td><td>Transport par défaut : <br>- 18 000 km en avion<br>- 2500 km en camion</td></tr></tbody></table>

{% hint style="info" %}
Sélecteur "_**\[x] par avion**_"\
Pour les ingrédients de la catégorie "HORS EUROPE-MAGHREB (AVION)", un sélecteur est proposé. Il permet de remplacer les 18 000 km en avion par 18 000 km en bateau.&#x20;
{% endhint %}

## Calcul

Pour les étapes relevant de la recette (ingrédients et jusqu'à une éventuelle transformation), un transport est considéré pour chacun des ingrédients de la recette. Au-delà, le transport est considéré pour l'ensemble du produit, avec son emballage.

$$
ImpactTransport = ImpactTransportIngrédient_1 + ImpactTransportIngrédient_2 ...
$$

Pour chaque ingrédient, l'impact est calculé comme suit, avec les procédés de transport introduits [ci-après](transport.md#undefined) :&#x20;

$$
ImpactTransport = MasseIngrédient (tonnes) * Distance (km) *  ImpactProcédéTransport
$$

{% hint style="warning" %}
La masse s'exprime en **tonnes**. Une conversion est donc à prendre en compte par rapport à la masse, considérée en g ou en kg dans les autres parties des calculs.&#x20;
{% endhint %}

## Types de transport

En première approche, hormis les ingrédients qui mobilisent le "circuit avion" défini ci-dessus, on ne considère que du transport maritime et du transport terrestre routier. La formule proposée ci-après anticipe toutefois l'introduction du transport aérien.

{% hint style="warning" %}
Le transport aérien sera introduit avec l'ajout d'ingrédients susceptibles d'être transportés par avion (Mangue du Pérou, Haricot du Kenya...)
{% endhint %}

La répartition des trois types de transport est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Si l'on nomme :

* `t` la part du transport terrestre rapportée au transport "terrestre + maritime"
* `a` la part du transport aérien rapportée au transport "aérien + terrestre + maritime"

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés :&#x20;

$$
ImpactTransport = a*ImpactAérien + (1-a)*(t*ImpactTerrestre+(1-t)*ImpactMaritime))
$$

{% hint style="warning" %}
**Ces hypothèses relatives aux transport relèvent d'une orientation spécifique à l'outil et devant être confrontée aux pratiques effectivement observées** .
{% endhint %}

## Répartition terrestre - maritime

**Par hypothèse**, la part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :&#x20;

| Distance terrestre                          | Part du transport terrestre (t) |
| ------------------------------------------- | ------------------------------- |
| <=500 km                                    | 100%                            |
| 500 km <= 1000 km                           | 90%                             |
| 1000 km <= 2000 km                          | 50%                             |
| 2000 km <= 3000 km                          | 25%                             |
| 3000 km (ou transport terrestre impossible) | 0%                              |

## Part du transport aérien

Pour les ingrédients relevant de la catégories "Hors Europe-Maghreb (Avion)", la part du transport aérien est, par défaut, à 100%.

Donc, pour ces ingrédients, le transport international se limite au seul transport par avion, sur une distance calculée spécifiquement pour le pays d'origine (lorsqu'il est sélectionné) come suit.

{% hint style="warning" %}
Dans un premier temps, les "états impossibles" ne sont pas traités. Il est donc théoriquement possible de simuler, par exemple, une mangue qui serait originaire de France et qui serait transportée par avion même si ceci n'a pas de réalité marché.&#x20;
{% endhint %}

{% hint style="info" %}
Sélecteur "_**\[x] par avion**_"\
Pour les ingrédients de la catégorie "HORS EUROPE-MAGHREB (AVION)", un sélecteur est proposé. Il permet de faire passer à 0% la part du transport en avion. Dès lors, le produit est considéré comme transporté par voie terrestre et maritime, suivant les règles générales applicables au pays d'origine.\
Rq : le cas particulier d'un ingrédient dont le pays d'origine n'aurait pas été précisé est traité ci-dessus, juste après le tableau qui introduit les 4 catégories d'ingrédients : France, Europe Maghreb, Hors Europe Maghreb, Hors Europe Maghreb (avion).&#x20;
{% endhint %}

## Distances

Toutes les distances considérées entre pays sont visibles sur [cette page](https://github.com/MTES-MCT/ecobalyse/blob/master/public/data/transports.json).

Les distances entre pays sont considérées à partir des calculateurs mis en avant dans le projet de PEF CR Apparel & Footwear rendu public à l'été 2021 (Version 1.1 – Second draft PEFCR, 28 May 2021). Ainsi :

| Type de transport | Site de référence                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------------------- |
| Terrestre         | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Maritime          | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Aérien            | Calcul de distance à vol d'oiseau geopy.distance                                                         |

## Procédés de transport

Les procédés de transport considérés sont extraits de la base Agribalyse. Ils sont visibles dans [l'explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/processes) ou, pour un public technique, dans [la base de code](https://github.com/MTES-MCT/ecobalyse/blob/master/public/data/food/processes.json).

Le choix d'un mode transport frigorifique dépend de l'ingrédient considéré. En accord avec la [documentation Agribalyse](https://3613321239-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1\_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971), un transport frigorifique est considéré pour :&#x20;

* Le lait et la viande sur toutes les étapes de transport
* Les fruits, légumes et céréales pour toutes les étapes à l'exception des étapes :&#x20;
  * "1. RECETTE Acheminement vers le site de transformations
  * "2. RECETTE Transport international - Acheminement d'un ingrédient vers la zone logistique"

{% hint style="info" %}
Au-delà de la première étape (Ingrédients), il faut considérer potentiellement le transport de plusieurs ingrédients. Dès lors qu'au moins un des ingrédients doit être transporté en frigorifique, c'est bien le transport frigorifique qui est considéré pour l'ensemble du produit.
{% endhint %}

<figure><img src="../../.gitbook/assets/Tableau 36.PNG" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
La méthodologie Agribalyse introduit différents véhicules pour le transport routier, le transport maritime (ex : tableau 38 de la méthodologie). En première approche, on ne retient qu'un seul procédé pour le transport terrestre et un pour le transport maritime.
{% endhint %}

&#x20;





