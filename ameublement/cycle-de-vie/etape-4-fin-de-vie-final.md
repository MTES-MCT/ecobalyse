---
icon: bin-recycle
---

# Etape 4 : Fin de vie (final)

## Contexte  et Méthode de calcul

Lire la page suivante : [Fin de vie (transverse)](https://fabrique-numerique.gitbook.io/ecobalyse/pages-en-cours-de-revue/fin-de-vie)

## Paramètres spécifiques à l'ameublement&#x20;

### Recyclabilité `rP`

Un meuble peut être : recyclable ou non recyclable. Définir la recyclabilité du produit revient à comprendre les règles applicables tout au long de la filière de fin de vie du produit (ex : perturbateurs de recyclage, existence d'un schéma opérationnel, etc.).&#x20;

Ces règles sont souvent spécifiques à chaque secteur d'activité (ex : la filière de fin de vie de véhicules thermiques est structurée différement de celle d'éléments d'ameublement).&#x20;

Deux  paramètres permettant de définir si un meuble est recyclable :&#x20;

{% tabs %}
{% tab title="#1 Schéma opérationnel" %}
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
{% endtab %}

{% tab title="#2 Facteur(s) limitant(s)" %}
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
{% endtab %}
{% endtabs %}

### Taux de collecte `TC`

Pour l'Ameublement, un taux de collecte de 70% est appliqué par défaut pour l'ensemble des meubles.&#x20;

Cette valeur se base sur les tonnes collectés en fin de vie par la filière REP des éléments d'ameublement (1,2m en 2022) et les tonnes mises sur le marché comparables (c. 1,8m).&#x20;

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

### Scénarios spécifiques à chaque matière&#x20;

### `R_S, Rec(i)`  R\_S, `Inc(i)`  R\_S, `Enf(i)`&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>R_S, Rec(i)</th><th>R_S, Inc(i)</th><th>R_S, Enf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>69%</td><td>31%</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>4%</td><td>94%</td><td>2%</td></tr><tr><td>Plastique*</td><td>92%</td><td>8%</td><td>0%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

&#x20;   \*Source : Filière REP EA _données 2022 (Bilan annuel 2023)_\
&#x20; _\*\*Source : Référentiel Mobilier Meublant  \__ scénarios emballages (FCBA-ADEME)

{% hint style="warning" %}
<mark style="color:red;">Liste à compléter/préciser (ex : latex, Mousse PU, etc.) = attente de retours précis de la filière</mark>
{% endhint %}

## Exemples&#x20;

<mark style="color:red;">A actualiser</mark>



[^1]: &#x20;L'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement.
