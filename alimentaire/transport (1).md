# 🚛 Transport

## Étapes considérées

Différentes étapes de transport peuvent être mobilisées dans le cycle de vie d'un produit alimentaire. Le modèle considéré s'appuie sur la documentation Agribalyse, et en particulier les deux figures suivantes (cf. [Méthodologie AGB 3.1\_Alimentation.pdf](https://3613321239-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1\_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971) - section 3.6 Transport le long de la chaîne de valeur) :&#x20;

<figure><img src="../.gitbook/assets/Figure 10 transport.PNG" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/Figure 11 transport.PNG" alt=""><figcaption></figcaption></figure>

Par rapport à la modélisation mobilisée dans Agribalyse, des valeurs par défaut sont proposées de manière assez systématique. Ces valeurs correspondent plutôt à des hypothèses majorantes, dans la mesure où certains paramètres peuvent ensuite être précisés, par exemple le pays d'origine des différents ingrédients.&#x20;

Les étapes suivantes sont donc considérées :&#x20;

| Étape                                                                                               | Hypothèse et paramétrage                                                          | Remarques                                                                                                                                                                                                          |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <p>1.RECETTE<br>Acheminement d'un ingrédient vers le site de transformation</p>                     | Hypothèse par défaut  : 160 km de transport terrestre                             | <p>Cette distance est considérée, que le site de transformation soit situé en France ou dans un autre pays.<br>Elle n'est pas considérée pour un ingrédient agricole</p>                                           |
| <p>2. RECETTE<br>Transport international - Acheminement d'un ingrédient vers la zone logistique</p> | Hypothèse par défaut : 160 km de transport terrestre                              | Cette distance n'est considérée que si un ingrédient a été produit hors de France. Elle s'applique que la transformation se fasse en France ou dans le pays d'origine, voire même s'il n'y a pas de transformation |
| <p>3. RECETTE<br>Transport international - Transport vers la France</p>                             | <p>Hypothèses par défaut détaillées ci-après.<br>Pays d'origine paramétrable.</p> | Cette distance n'est considérée que si un ingrédient a été produit hors de France.                                                                                                                                 |
| <p>4. STOCKAGE<br>Transport vers le site de stockage</p>                                            | Hypothèse par défaut : 450 km de transport terrestre (cf. figure 11 ci-dessus)    | Distance considérée systématiquement <mark style="color:red;">\[lorsque l'étape de stockage sera intégrée]</mark>                                                                                                  |
| <p>5. VENTE<br>Transport vers le lieu de vente au détail</p>                                        | Hypothèse par défaut : 150 km de transport terrestre (cf. figure 11 ci-dessus)    | Distance considérée systématiquement <mark style="color:red;">\[lorsque l'étape de vente sera intégrée]</mark>                                                                                                     |
| 6. CONSOMMATION                                                                                     | Pas de transport considéré (cf. figure 11 ci-dessus)                              |                                                                                                                                                                                                                    |

{% hint style="info" %}
**Ingrédients agricoles et ingrédients industrie**.\
Le payse d'origine qui peut être paramétré pour l'étape de transport international (étape 3. RECETTE dans le tableau ci-dessus) peut correspondre : \
\- au site de production agricole pour les ingrédients agricoles \
\- au site de transformation pour les ingrédients industrie\
On considère, en première approche, que les ingrédients agricoles considérés dans les recettes sont ensuite tous transformés en France.
{% endhint %}

{% hint style="warning" %}
Vérification à faire : \
\- prise en compte du transport en fin de vie dans les impacts des emballages ;\
\- prise en compte du transport depuis le/les sites de production dans les impacts des ingrédients industrie
{% endhint %}

## Circuits considérés

3 circuits principaux sont considérés :&#x20;

| Etape                                                                                               | Circuit France   | Circuit hors France                                    | Circuit avion                                          |
| --------------------------------------------------------------------------------------------------- | ---------------- | ------------------------------------------------------ | ------------------------------------------------------ |
| <p>1.RECETTE<br>Acheminement d'un ingrédient vers le site de transformation</p>                     | 160 km de camion | 160 km de camion                                       | 160 km de camion                                       |
| <p>2. RECETTE<br>Transport international - Acheminement d'un ingrédient vers la zone logistique</p> | N/A              | 160 km de camion                                       | 160 km de camion                                       |
| <p>3. RECETTE<br>Transport international - Transport vers la France</p>                             | N/A              | Hypothèse par défaut et paramétrage détaillés ci-après | Hypothèse par défaut et paramétrage détaillés ci-après |
| <p>4. STOCKAGE<br>Transport vers le site de stockage</p>                                            | 450 km de camion | 450 km de camion                                       | 450 km de camion                                       |
| <p>5. VENTE<br>Transport vers le lieu de vente au détail</p>                                        | 150 km de camion | 150 km de camion                                       | 150 km de camion                                       |
| 6. CONSOMMATION                                                                                     | N/A              | N/A                                                    | N/A                                                    |

En l'absence de paramétrage du pays d'origine, les hypothèses appliquées pour le choix de circuit et pour le transport vers la France (étape 3. RECETTE) sont établies en distinguant 4 catégories d'ingrédient. La catégorie à laquelle chaque ingrédient appartient est précisée dans la page méthodologique de l'ingrédient en question \[_<mark style="color:red;">à initier</mark>_]. Si le circuit à considérer par défaut n'est pas (encore) précisé dans la page méthodologique relative à un ingrédient, c'est le circuit EUROPE-MAGHREB qui s'applique par défaut.

| Catégorie d'ingrédient                                                                                                | Circuit appliqué    | Hypothèse par défaut (-> France)                                                                                     |
| --------------------------------------------------------------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------- |
| <p>FRANCE<br>Ingrédients très majoritairement produits en France (seuil : ~95%)</p>                                   | Circuit France      | N/A                                                                                                                  |
| <p>EUROPE-MAGHREB<br>Ingrédients très majoritairement produits en Europe ou au Maghreb (seuil : ~95%)</p>             | Circuit hors France | <p>Transport par défaut :  <br>- 2500 km de camion</p>                                                               |
| <p>HORS EUROPE-MAGHREB<br>Ingrédient provenant de façon significative de pays hors Europe / Maghreb (seuil : ~5%)</p> | Circuit hors France | <p>Transport par défaut : <br>- 18 000 km en bateau<br>- 2500 km en camion</p>                                       |
| <p>AVION<br>Cas particulier des ingrédients transportés de façon non marginale par avion (mangue, haricots...)</p>    | Circuit avion       | Transport en avion, avec distance à préciser ingrédient par ingrédient (ex : distance Pérou-France pour la mangue ?) |

## Calcul

Pour les étapes relevant de la recette (ingrédients et jusqu'à une éventuelle transformation), un transport est considéré pour chacun des ingrédients de la recette. Au-delà, le transport est considéré pour l'ensemble du produit, avec son emballage.

$$
ImpactTransport = ImpactTransportIngrédient_1 + ImpactTransportIngrédient_2 ...
$$

Pour chaque ingrédient, l'impact est calculé comme suit, avec les procédés de transport introduits [ci-après](<transport (1).md#undefined>) :&#x20;

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

{% hint style="danger" %}
A introduire lors de l'ajout d'ingrédients susceptibles d'être transportés par avion
{% endhint %}

## Distances

Toutes les distances considérées entre pays sont visibles sur cette page \[<mark style="color:red;">**lien à ajouter**</mark>]

Les distances entre pays sont considérées à partir des calculateurs mis en avant dans le projet de PEF CR Apparel & Footwear rendu public à l'été 2021 (Version 1.1 – Second draft PEFCR, 28 May 2021). Ainsi :

| Type de transport | Site de référence                                                                                        |
| ----------------- | -------------------------------------------------------------------------------------------------------- |
| Terrestre         | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Maritime          | ​[https://www.searates.com/services/distances-time/](https://www.searates.com/services/distances-time/)​ |
| Aérien            | Calcul de distance à vol d'oiseau geopy.distance                                                         |

## Procédés de transport

Les procédés de transport considérés sont extraits de la base Agribalyse.&#x20;

| Type de transport               | Procédé                                        | UUID |
| ------------------------------- | ---------------------------------------------- | ---- |
| Transport maritime              | \[<mark style="color:red;">à compléter</mark>] |      |
| Transport routier               |                                                |      |
| Transport maritime frigorifique |                                                |      |
| Transport routier frigorifique  |                                                |      |
| Transport aérien                |                                                |      |

Le choix d'un mode transport frigorifique dépend de l'ingrédient considéré. En accord avec la documentation Agribalyse, un transport frigorifique est considéré pour :&#x20;

* Le lait et la viande sur toutes les étapes de transport
* Les fruits, légumes et céréales pour toutes les étapes à l'exception de l'étape "2. RECETTE\
  Transport international - Acheminement d'un ingrédient vers la zone logistique"

<figure><img src="../.gitbook/assets/Tableau 36.PNG" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
La méthodologie Agribalyse introduit différents véhicules pour le transport routier, le transport maritime (ex : tableau 38 de la méthodologie). En première approche, on ne retient qu'un seul procédé pour le transport terrestre et un pour le transport maritime.
{% endhint %}

&#x20;





