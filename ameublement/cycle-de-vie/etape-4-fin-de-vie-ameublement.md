---
icon: bin-recycle
---

# Etape 4 : Fin de vie Ameublement

## Contexte &#x20;

Evaluer le coût environnemental de la fin de vie d'un meuble consiste à calculer l'impact environnemental des débouchés du meuble.&#x20;

<figure><img src="../../.gitbook/assets/newplot.png" alt=""><figcaption></figcaption></figure>

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

### Deux  paramètres permettent de définir si un meuble est recyclable :&#x20;

#### **L'existence d'un schéma opérationnel**&#x20;

Ce paramètre reflète l'existence d'une filière de fin de vie permettant d'orienter chaque matière du meuble collecté vers leurs débouchés spécifiques (enfouissement, incinération, recyclage). L'abscence de schéma opérationnel implique l'impossibilité pour le meuble collecté d'être recyclé car il n'existe pas de schéma opérationnel permettant de collecter, séparer et recycler à l’échelle et en pratique les matières qui composent l’élément d’ameublement.&#x20;

Les catégories de meubles suivantes ne disposent pas de schéma opérationnel :&#x20;

* Décoration textile,
* Rembourrés d'assise et de couchage,
* Autres meubles rembourrés (ex : canapé, sommiers tappissiers)

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

Voir méthode transverse.

### <mark style="color:red;">Calcul de la recyclabilité produit</mark>

$$
Rp_2=S_{op}*(1-F_{limitant})
$$

<mark style="color:red;">Avec :</mark>

* <mark style="color:red;">`Rp_2`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la recyclabilité produit, égale à 1 (recyclable) ou 0 (non recyclable)</mark>
* <mark style="color:red;">`S_op`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'existence d'une filière en fin de vie des produits (schéma opérationnel)</mark>
* <mark style="color:red;">`F_limitant`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la présence d'un facteur limitant (perturbateur de recyclage ou matériau majoritaire)</mark>&#x20;

## Paramètres retenus pour les meubles&#x20;

### Recyclabilité&#x20;

La recyclabilité du produit est indiquée dans Ecobalyse par l'utilisateur.

### Taux de collecte `TC`

Pour l'Ameublement, un taux de collecte de 70% est appliqué par défaut pour l'ensemble des meubles. Cette valeur se base sur les tonnes collectés en fin de vie par la filière REP des éléments d'ameublement (1,2m en 2022) et les tonnes mises sur le marché comparables (c. 1,8m).&#x20;

### Scénarios Déchet

Les taux par défaut (issus de la filière ameublement) sont utilisés.

### Scénarios spécifiques à chaque matière

Les taux par défaut (issus de la filière ameublement) sont utilisés.





[^1]: &#x20;L'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement.
