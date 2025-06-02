---
icon: bin-recycle
---

# Etape 4 : Fin de vie

## Contexte &#x20;

Evaluer le coût environnemental de la fin de vie d'un meuble consiste à calculer l'impact environnemental des débouchés du meuble.&#x20;

<figure><img src="../../.gitbook/assets/newplot.png" alt=""><figcaption></figcaption></figure>

## Méthode de calcul

Le calcul de l'impact de la fin de vie d'un meuble se fait en deux temps :&#x20;

1. définir les scénarios de fin de vie du meuble,
2. calculer l'impact de ces scénarios.

### Etape 1 = Définir les scénarios de fin de vie du meuble

La définition des scénarios se fait en 3 étapes :&#x20;

#### 1) Taux de collecte&#x20;

Ce paramètre définit la capacité du meuble à être collécté en fin de vie.

#### 2) Schéma opérationnel&#x20;

Ce paramètre reflète l'existence d'une filière de fin de vie permettant d'orienter chaque matière du meuble collecté vers leurs débouchés spécifiques (enfouissement, incinération, recyclage).

L'abscence de schéma opérationnel implique l'impossibilité pour le meuble collecté d'être recyclé car il n'existe pas de schéma opérationnel permettant de collecter, séparer et recycler à l’échelle et en pratique les matières qui composent l’élément d’ameublement.&#x20;

#### 3) Facteurs limitants&#x20;

Les facteurs limitants regroupent deux types de paramètres empêchant la recyclabilité du meuble.&#x20;

* la présence de perturbateur de tri ou de recyclage\
  Certaines substances, matières ou associations de matériaux peuvent perturber le tri ou le recyclage des éléments d’ameublement. De plus, ces perturbateurs peuvent s’appliquent à (i) tous  types d’élément d’ameublement ou (ii) sont spécifiques à certains.\
  Si au moins un perturbateur de recyclage est présent, le meuble est considéré comme "Non Recyclable".
* L'absence de matériau majoritaire\
  Selon les éléments d'ameublement (ex : chaise, table, etc.), un seuil de "matériaux majoritaires" est à atteindre afin que le meuble soit orienté vers les filières de fin de vie spécifiques à chaque meuble.

{% hint style="danger" %}
**Exception "Métal"**

Qu'un meuble soit recyclable ou non, les composants métalliques sont dans tous les cas triés et recyclés à 100%.
{% endhint %}

#### &#x20;Dès lors, 3 scénarios de fin de vie sont possibles :&#x20;

* Scénario 1 = le meuble dispose d'un schéma opérationnel et ne présente pas de facteur limitant (meuble recyclable),
* Scénario 2 = le meuble dispose d'un schéma opérationnel et présente au moins un facteur limitant (meuble non recyclable),
* Scénario 3 = le meuble ne dispose pas de schéma opérationnel (meuble non recyclable).  &#x20;

### Etape 2 = Calculer l'impact de la fin de vie du meuble

Niveau 1 de calcul :

$$
FDV = TC*M*ImpC+ (1-TC)*M*ImpNC
$$

{% hint style="info" %}
Liste des variables mobilisées dans les formules ci-dessus :&#x20;

* TC = % = Taux de collecte,
* M = kg = la masse du meuble,
* ImpC = Pt / kg = coût environnemental du matériau collecté
* ImpNC = Pt / kg = coût environnemental du matériau non-collecté
{% endhint %}

Niveau 2 de calcul :&#x20;

$$
ImpC =   \sum (i) * (Enf(i)*Ienf(i) + Inc(i)*Iinc(i) + Recy(i) *Irec(i))
$$

$$
ImpNC  =  Inc*Iinc + Enf*Ienf
$$

{% hint style="info" %}
Liste des variables mobilisées dans les formules ci-dessus :&#x20;

* Inc / Enf = % = scénario par défaut de Incinération et Enfouissement
* Iinc / Ienf = Pt / kg = coût environnemental des procédés par défaut Incinération et Enfouissement
* Enf(i) = % = la performance d'enfouissement du matériau (i) lorsque le meuble est collecté et recyclable\*
* Inc(i) = % = la performance d'incinération du matériau (i) lorsque le meuble est collecté et recyclable\*
* Rec(i) = % = la performance de recyclage du matériau (i) lorsque le meuble est collecté et recyclable\*
* Ienf(i) / Iinc(i) / Irec(i) = l'impact du procédé enfouissement/incinération/recyclage du matériau (i)
{% endhint %}

## Paramètres retenus pour le calcul du coût environnemetnal&#x20;

### Taux de collecte `TC`

Pour l'Ameublement, un taux de collecte de 70% est appliqué par défaut pour l'ensemble des meubles. Cette valeur se base sur les tonnes collectés en fin de vie par la filière REP des éléments d'ameublement (1,2m en 2022) et les tonnes mises sur le marché comparables (c. 1,8m).&#x20;

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

### Scénarios par défaut

Ce scénario est applicable aux matériaux non collectés et aux matériaux collectés mais non recyclables.

### &#x20;`Inc` `Iinc` &#x20;

<table><thead><tr><th width="267">Matière</th><th>% recyclage</th><th>Inc (% incinération) </th><th>Enf (% enfouissement)</th></tr></thead><tbody><tr><td>Toutes</td><td>n/a</td><td>82%</td><td>18%</td></tr></tbody></table>

`Ienf` = Treatment of municipal solid waste, sanitary landfill, RoW = 21 Pt / kg

`Iinc` = Treatment of municipal solid waste, municipal incineration, FR = 39 Pt / kg

{% hint style="info" %}
Ce scénario est basé sur le scénario de fin de vie d'un mobilier meublant dont la recyclabilité du meuble est de 0% dans la dernière version du référentiel BPX30 _Meubles Meublants \_ FCBA (Novembre 2023)_
{% endhint %}

### Scénarios spécifiques&#x20;

### `Rec(i)`  `Inc(i)`  `Enf(i)`&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Rec(i)</th><th>Inc(i)</th><th>Enf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>69%</td><td>31</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>2%</td><td>91%</td><td>7%</td></tr><tr><td>Plastique*</td><td>90%</td><td>10%</td><td>1%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières</td><td>0%</td><td>82%</td><td>18%</td></tr><tr><td><mark style="color:red;">Liste à compléter/préciser (ex : latex, Mousse PU, etc.)</mark></td><td><mark style="color:red;">xx</mark></td><td><mark style="color:red;">xx</mark></td><td><mark style="color:red;">xx</mark></td></tr></tbody></table>

&#x20;   \*Source : Filière REP EA _données 2022 (Bilan annuel 2023)_\
&#x20; _\*\*Source : Référentiel Mobilier Meublant  \__ scénarios emballages (FCBA-ADEME)

### `Irec(i)`  `Iinc(i)`  `Ienf(i)`&#x20;

#### Liste des procédés

6 procédés sont utilisés pour modéliser le coût environnemental de la fin de vie des meubles.  &#x20;

<table data-full-width="false"><thead><tr><th width="113.6666259765625">Matériau (i)</th><th width="166.66656494140625">Recyclage</th><th>Incinération</th><th>Enfouissement</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)</td><td>n/a (cut-off)</td><td>Treatment of waste wood, untreated, municipal incineration, CH</td><td>n/a</td></tr><tr><td>Métal</td><td>n/a (cut-off)</td><td>n/a</td><td>n/a</td></tr><tr><td>Rembourré / Matelas</td><td>n/a (cut-off)</td><td>Treatment of waste polyurethane, municipal incineration FAE, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Plastique</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (without CH)</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (carton)</td><td>n/a (cut-off)</td><td>Treatment of waste paperboard, municipal incineration, Europe (without CH)</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (plastique)</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (without CH)</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (autre)</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Autres</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr></tbody></table>

#### Coût environnemental (Pt d'impact / kg)&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Irec(i)</th><th>Iinc(i)</th><th>Ienf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>0</td><td>2</td><td>n/a</td></tr><tr><td>Métal*</td><td>0</td><td>n/a</td><td>n/a</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>0</td><td>96</td><td>39</td></tr><tr><td>Plastique*</td><td>0</td><td>80</td><td>39</td></tr><tr><td>Emballage (carton)**</td><td>0</td><td>7</td><td>39</td></tr><tr><td>Emballage (plastique)**</td><td>0</td><td>80</td><td>39</td></tr><tr><td>Emballage (autres)**</td><td>n/a</td><td>21</td><td>39</td></tr><tr><td>Autres matières</td><td>n/a</td><td>21</td><td>39</td></tr><tr><td><mark style="color:red;">Liste à compléter/préciser (ex : latex, Mousse PU, etc.)</mark></td><td><mark style="color:red;">xx</mark></td><td><mark style="color:red;">xx</mark></td><td><mark style="color:red;">xx</mark></td></tr></tbody></table>

{% hint style="info" %}
**Recyclage = Impact nul (approche cut-off)**

Ecobalyse utilise l'approche cut-off pour allouer l'impact du recyclage des matériaux.

Dit autrement, l'impact du recyclage des matériaux est alloué 100% au produit utilisant ces matières recyclées. Ainsi, l'impact en fin de vie d'un meuble 100% recyclé serait nul.&#x20;
{% endhint %}

<details>

<summary>Vision simplifiée des procédés spécifiques mobilisés</summary>

<figure><img src="../../.gitbook/assets/Coût environnement (Pt _ kg) des scénarios de fin de vie (1).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/Tableau fin de vie.png" alt=""><figcaption></figcaption></figure>



</details>

### Schémas opérationnels&#x20;

Les catégories de meubles suivantes ne disposent pas de schéma opérationnel :&#x20;

* Décoration textile,
* Rembourrés d'assise et de couchage,
* Autres meubles rembourrés (ex : canapé, sommiers tappissiers)

{% hint style="info" %}
Cette liste reflète l'état de la filière à un instant T.&#x20;

L'organisme coordinateur de la filière (l'OCABJ) se charge de s'assurer que la liste des éléments d'ameublement ne disposant pas de schéma opérationnel est à jour.&#x20;
{% endhint %}

### Facteurs limitants

Les facteurs limitants sont spécifiques à chaque catégorie de meubles (canapé, table, etc.). Il est de la responsabilité de l'utilisateur de préciser la présence ou non de facteurs limitants.

Par défaut, la modélisation d'un meuble dans Ecobalyse intègre la présence d'au moins un facteur limitant.

{% hint style="info" %}
La liste détaillée des facteurs limitant la recyclabilité du meuble est tenue à jour par l'organisme coordinateur de la filière REP des éléments d'ameublement : l'OCABJ[^1].&#x20;

Par défaut, le meuble est considéré avec un perturbateur de recyclage (meuble non recyclable).

L'utilisateur a la possibilité de modifier ce paramètre.
{% endhint %}

## Exemples&#x20;

<mark style="color:red;">A actualiser</mark>



[^1]: &#x20;L'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement.
