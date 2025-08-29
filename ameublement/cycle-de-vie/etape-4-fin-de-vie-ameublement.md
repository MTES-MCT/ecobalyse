---
icon: bin-recycle
---

# Etape 4 : Fin de vie Ameublement

## Contexte &#x20;

Evaluer le coût environnemental de la fin de vie d'un meuble consiste à calculer l'impact environnemental des débouchés du meuble.

Les principaux scénarios de fin de vie sont décrits dans la [page de documentation transversale](https://fabrique-numerique.gitbook.io/ecobalyse/pages-en-cours-de-revue/fin-de-vie).

La page ci-dessous apporte des précision spécifique au secteur de l'ameublement.

<figure><img src="../../.gitbook/assets/newplot.png" alt=""><figcaption></figcaption></figure>

### La collecte en fin de vie dans le secteur de l'ameublement&#x20;

<details>

<summary>Approfondir le taux de collecte</summary>

Le taux de collecte de 70% correspond au ratio entre les tonnes collectées (1,2m) et celles mises sur le marché pour renouveler le parx existant (1,8m) :&#x20;

{% hint style="info" %}
Source :  scénario de fin de vie d'un meuble non recyclable / référentiel _Meubles Meublants (FCBA x ADEME)_
{% endhint %}

* 1,8 millions de tonnes de meubles mises sur le marché afin de renouveler le parc existant,
* 1,2 millions de tonnes collectées par la filière en fin de vie. &#x20;

_**Focus : Mises sur le marché**_

Les rapports annuels de la filière proposent des mises sur le marché annuelles incluant les meubles destinés à renouveller le parc existant (renouvellement) ainsi que les meubles destinés à de nouveaux usages/périmètres. Ces nouveaux usages sont triples : construction neuve, solde démographique en hausse, taux d'équipement en hausse).&#x20;

En 2022, 3 millions de tonnes ont été mises sur le marché (source : Filière des éléments d'ameublement _Données 2023_ Bilan annuel). Suite à des entretiens avec la filière, nous estimons que 40% (1,2 millions de tonnes) des mises sur le marché correspondent à des nouveaux usages.&#x20;

![](<../../.gitbook/assets/Mises sur le marché 2022.png>)

_**Focus : Tonnes collectées**_

En 2022, 1,2 millions de tonnes ont été collectées par la filière; que ce soit via des déchetteries gérées opérationnellement par la filière ou des déchetteries soutenues financièrement (source : Filière des éléments d'ameublement _Données 2023_ Bilan annuel).&#x20;

</details>

### Deux paramètres permettent de définir si un meuble est recyclable :&#x20;

#### **L'existence d'un schéma opérationnel**&#x20;

Ce paramètre reflète l'existence d'une filière de fin de vie permettant d'orienter chaque matière du meuble collecté vers leurs débouchés spécifiques (enfouissement, incinération, recyclage). L'abscence de schéma opérationnel implique l'impossibilité pour le meuble collecté d'être recyclé car il n'existe pas de schéma opérationnel permettant de collecter, séparer et recycler à l’échelle et en pratique les matières qui composent l’élément d’ameublement.&#x20;

Les catégories de meubles suivantes ne disposent pas de schéma opérationnel :&#x20;

* Décoration textile,
* Rembourrés d'assise et de couchage,
* Autres meubles rembourrés (ex : canapé, sommiers tapissiers)

{% hint style="info" %}
Cette liste reflète l'état de la filière à un instant T.&#x20;

L'organisme coordinateur de la filière (l'OCABJ) se charge de s'assurer que la liste des éléments d'ameublement ne disposant pas de schéma opérationnel est à jour.&#x20;
{% endhint %}

#### **La présence d'au moins un facteur limitant** &#x20;

Les facteurs limitants identifient des éléments empêchant la capacité d'un meuble à être orienté vers les filières de recyclable spécifiques à ses composants/matières.&#x20;

Les facteurs limitants dans l'ameublement regroupent deux paramètres :&#x20;

* la présence de perturbateur de tri ou de recyclage\
  Certaines substances, matières ou associations de matériaux peuvent perturber le tri ou le recyclage des éléments d’ameublement. De plus, ces perturbateurs peuvent s’appliquent à (i) tous  types d’élément d’ameublement ou (ii) sont spécifiques à certains.\
  Si au moins un perturbateur de recyclage est présent, le meuble est considéré comme "Non Recyclable".
* L'absence de matériau majoritaire\
  Selon les éléments d'ameublement (ex : chaise, table, etc.), un seuil de "matériaux majoritaires" est à atteindre afin que le meuble soit orienté vers les filières de fin de vie spécifiques à chaque meuble.

{% hint style="info" %}
Il est de la responsabilité de l'utilisateur de préciser la présence ou non de facteurs limitants.

La liste détaillée des facteurs limitant la recyclabilité du meuble est tenue à jour par l'organisme coordinateur de la filière REP des éléments d'ameublement : l'OCABJ[^1].&#x20;

Par défaut, le meuble est considéré avec au moins un facteur limitant (meuble non recyclable).

L'utilisateur a la possibilité de modifier ce paramètre.
{% endhint %}

## Méthode de calcul

La méthode de calcul des impacts de la fin de vie est précisée dans la [page de documentation transversale](https://fabrique-numerique.gitbook.io/ecobalyse/pages-en-cours-de-revue/fin-de-vie).

### Calcul de la recyclabilité produit

$$
r_p=S_{op}*(1-F_{limitant})
$$

Avec :

* `r_p` : la recyclabilité produit, égale à 1 (recyclable) ou 0 (non recyclable)
* `S_op` : l'existence d'une filière en fin de vie des produits (schéma opérationnel)
* `F_limitant` : la présence d'un facteur limitant (perturbateur de recyclage ou matériau majoritaire)&#x20;

## Paramètres retenus pour les meubles&#x20;

### Existence d'une filière en fin de vie des produits `S_op`&#x20;

L'existence d'une filière en fin de vie des produits est indiquée dans Ecobalyse par l'utilisateur :&#x20;

* Oui : `S_op` = 1
* Non : `S_op` =0

### Existence d'une filière en fin de vie des produits `F_limitant`

La présence d'un facteur limitant est indiquée dans Ecobalyse par l'utilisateur :&#x20;

* Présence de facteur limitant : `F_limitant` = 1
* Absence de facteur limitant : `F_limitant` =0

### Taux de collecte `TC`

Pour l'Ameublement, un taux de collecte de 70% est appliqué par défaut pour l'ensemble des meubles. Cette valeur se base sur les tonnes collectés en fin de vie par la filière REP des éléments d'ameublement (1,2m en 2022) et les tonnes mises sur le marché comparables (c. 1,8m).&#x20;

### Taux de collecte pour Export `TE`

Il n'y a pas d'export de meubles en fin de vie. `TE` est fixé à zéro.&#x20;

### Paramètres du scénarios spécifiques à chaque matière

Les taux de recyclage, incinération et enfouissement pour le scénario Spécifique matière (produits collectés et recyclables) sont détaillés ci-dessous:

<table><thead><tr><th width="267">Matériau i</th><th>R_S,Rec,i</th><th>R_S,Inc,i</th><th>R_S,Enf,i</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>69%</td><td>31%</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>4%</td><td>94%</td><td>2%</td></tr><tr><td>Plastique*</td><td>92%</td><td>8%</td><td>0%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'Explorateur de procédé. Ils sont précisés dans la [page de documentation transversale](https://fabrique-numerique.gitbook.io/ecobalyse/pages-en-cours-de-revue/fin-de-vie).

[^1]: &#x20;L'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement.
