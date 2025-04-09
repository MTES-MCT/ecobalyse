---
icon: bin-recycle
---

# Etape 4 : Fin de vie

## Eléments de contexte &#x20;

Définir les scénarios de fin de vie d'un meuble consiste à définir les débouchés de l'ensemble des matériaux entrant dans la composition du meuble.&#x20;

Illustration de la modélisation des scénarios de fin de vie d'un meuble&#x20;

<mark style="color:red;">Intégrer Sankey Graphe afin d'illustrer.</mark>

3 débouchés sont proposés dans la méthode :&#x20;

* recyclage,
* incinération,
* enfouissement.

## Paramètres mobilisés

### 1) Taux de collecte&#x20;

Ce paramètre définit la capacité du meuble à être collécté en fin de vie.

Un taux de collecte de 70% est appliqué par défaut pour l'ensemble des meubles.

<details>

<summary>Comprendre le taux de collecte de 70%</summary>

Le taux de collecte de 70% correspond au ratio entre les tonnes collectées (1,2m) et celles mises sur le marché pour renouveler le parx existant (1,8m) :&#x20;

* 1,8 millions de tonnes de meubles mises sur le marché afin de renouveler le parc existant,
* 1,2 millions de tonnes collectées par la filière en fin de vie. &#x20;

_**Focus : Mises sur le marché**_

Les rapports annuels de la filière proposent des mises sur le marché annuelles incluant les meubles destinés à renouveller le parc existant (renouvellement) ainsi que les meubles destinés à de nouveaux usages/périmètres. Ces nouveaux usages sont triples : construction neuve, solde démographique en hausse, taux d'équipement en hausse).&#x20;

En 2022, 3 millions de tonnes ont été mises sur le marché (source : Filière des éléments d'ameublement _Données 2023_ Bilan annuel). Suite à des entretiens avec la filière, nous estimons que 40% (1,2 millions de tonnes) des mises sur le marché correspondent à des nouveaux usages.&#x20;

![](<../../.gitbook/assets/Mises sur le marché 2022.png>)

_**Focus : Tonnes collectées**_

En 2022, 1,2 millions de tonnes ont été collectées par la filière; que ce soit via des déchetteries gérées opérationnellement par la filière ou des déchetteries soutenues financièrement (source : Filière des éléments d'ameublement _Données 2023_ Bilan annuel).&#x20;

</details>

### 2) Schéma opérationnel&#x20;

Ce paramètre reflète l'existence d'une filière de fin de vie.

Certains meubles, bien que collectés par la filière, ne peuvent pas être recyclés car il n'existe pas de schéma opérationnel permettant de collecter, séparer et recycler à l’échelle et en pratique les matières qui composent l’élément d’ameublement.&#x20;

Dans ce cas, ces meubles sont considérés comme terminant leur fin de vie en décharge avec l'application du scénario par défaut "meuble non recyclable" (cf. ci-dessous).&#x20;

La liste des éléments d'ameublement de disposant pas de schéma opérationnel est maintenue à jour par l'OCABJ (l'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement).  <mark style="color:red;">Liste exacte en attente de confirmation par l'OCABJ.</mark>

Eléments d'ameublement non recycables faute de schéma opérationnel existant :&#x20;

* canapé,
* <mark style="color:red;">à compléter</mark>

### 3) Présence de perturbateur de tri ou de recyclage

Ce paramètre identifie des caractéristiques du meuble empêchant sa recyclabilité.

Certaines substances, matières ou associations de matériaux peuvent perturber le tri ou le recyclage des éléments d’ameublement. Certains perturbateurs s’appliquent à tous les types d’élément d’ameublement et d’autres perturbateurs sont spécifiques à certains éléments d’ameublement. Il convient donc à cette étape de vérifier l’absence de perturbateurs.&#x20;

Si au moins un perturbateur de recyclage est présent, le meuble est considéré comme "Non Recyclable".&#x20;

{% hint style="info" %}
La liste des pertubateurs de recyclage est mise à jour par OCABJ[^1]. Cet organisme tient à disposition de la filière des outils permettant d'identifier les perturbateurs de recyclage spécifiques à chaque meuble.

Par défaut, le meuble est considéré avec un perturbateur de recyclage (meuble non recyclable).

L'utilisateur a la possibilité de modifier ce paramètre.
{% endhint %}

### 4) Matériau majoritaire

Lorsqu'un meuble dispose d'un schéma opérationnel et ne présente pas de perturbateur, un dernier paramètre spécifique au matériau majoritaire est à considérer.&#x20;

En effet, certains meubles ne sont pas recyclables si certains types de matières (ex : bois massif) ne sont pas présents dans une concentration suffisante (exprimée en % de la masse du meuble).

<table data-full-width="false"><thead><tr><th width="405">Plastique / Bois massif / Panneaux</th><th>Autres cas</th></tr></thead><tbody><tr><td>Meuble recyclable si la concentration d'un de ces types de matériaux ≥ 70% </td><td>Meuble non recyclable </td></tr></tbody></table>

{% hint style="danger" %}
E**xception "Métal"**

Qu'un meuble soit recyclable ou non, les composants métalliques sont dans tous les cas triés et recyclés à 100%.
{% endhint %}

## Scénarios par défaut

### Meuble non recyclable

Lorsqu'un meuble est non recyclable, ce dernier est incinéré à 82%) et enfoui à 18%.&#x20;

{% hint style="info" %}
Ce scénario se base sur le référentiel _Meubles Meublants \_ FCBA (Novembre 2023)._
{% endhint %}

### Meuble recyclable&#x20;

Lorsqu'un meuble est recyclable, c'est à dire qu'il est en capacité d'être orienté vers les filières de fin de vie spécifiques à chacune de ses matières, la fin de vie de ce dernier dépend des matières entrant dans sa composition.&#x20;

<table><thead><tr><th width="267">Matière</th><th>% recyclage</th><th>% incinération</th><th>% enfouissement</th></tr></thead><tbody><tr><td>Bois d'oeuvre*</td><td>69%</td><td>31</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td><mark style="color:red;">Latex</mark></td><td><mark style="color:red;">A intégrer ?</mark></td><td><mark style="color:red;">A intégrer ?</mark></td><td><mark style="color:red;">A intégrer ?</mark></td></tr><tr><td><mark style="color:red;">Mousse PU</mark> </td><td><mark style="color:red;">A intégrer ?</mark></td><td><mark style="color:red;">A intégrer ?</mark></td><td><mark style="color:red;">A intégrer ?</mark></td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>2%</td><td>91%</td><td>7%</td></tr><tr><td>Plastique*</td><td>90%</td><td>10%</td><td>1%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières***</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

&#x20;   \*Source : Filière des éléments d'ameublement \_ données 2021 (Bilan annuel 2022)\
&#x20; \*\*Source : Référentiel Meubles meublants révisé en 2023 (FCBA-ADEME)\
\*\*\*Application du scénario par défaut "Meuble non recyclable"

## Données Ecoinvent mobilisées&#x20;

Pour chaque débouché, au moins un procédé par défaut t est proposé (ex : procédé "Treatment of municipal solid waste, sanitary landfill, RoW" pour le débouché "Enfouissement").&#x20;

Pour certains types de matière (ex : plastique), des procédés spécifiques sont disponibles (ex : procédé "Polyethylene production, high density, granulate, recycled, US" pour le recyclage du plastique).&#x20;

#### Liste des procédés par type de matière

<table data-full-width="false"><thead><tr><th width="113.6666259765625">Type de matière</th><th width="166.66656494140625">Recyclage</th><th>Incinération</th><th>Enfouissement</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)</td><td>Treatment of waste wood, post-consumer, sorting and shredding, CH</td><td>Treatment of waste wood, untreated, municipal incineration, CH</td><td>Treatment of waste wood, untreated, sanitary landfill, RoW</td></tr><tr><td>Métal</td><td>Treatment of aluminium scrap, post-consumer, by collecting, sorting, cleaning, pressing, RER</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Rembourré / Matelas</td><td>Ttreatment of waste polyurethane, municipal incineration FAE, CH</td><td>Treatment of waste polyurethane, municipal incineration FAE, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Plastique</td><td>Polyethylene production, high density, granulate, recycled, US</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (withou CH)</td><td>Treatment of waste plastic, mixture, sanitary landfill, RoW</td></tr><tr><td>Emballage (carton)</td><td>Containerboard production, fluting medium, recycled</td><td>Treatment of waste paperboard, municipal incineration, Europe (withou CH)</td><td>Treatment of waste paperboard, sanitary landfill, CH</td></tr><tr><td>Emballage (plastique)</td><td>Polyethylene production, high density, granulate, recycled, US</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (withou CH)</td><td>Treatment of waste plastic, mixture, sanitary landfill, RoW</td></tr><tr><td>Emballage (autre)</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Autres</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr></tbody></table>

#### Coût environnemental (Pt d'impact / kg) des procédés (cf. ci-dessus)

| Type de matière          | Recyclage | Incinération | Enfouissement |
| ------------------------ | --------- | ------------ | ------------- |
| Bois (massif & panneaux) | 1         | 2            | 2             |
| Métal                    | 27        | 21           | 39            |
| Rembourré / Matelas      | 96        | 96           | 39            |
| Plastique                | 63        | 80           | 12            |
| Emballage (carton)       | 68        | 7            | 46            |
| Emballage (plastique)    | 63        | 80           | 12            |
| Emballage (autre)        | 21        | 21           | 39            |
| Autres                   | 21        | 21           | 39            |

## Illustration&#x20;

<mark style="color:red;">Trouver outil pour générer Sankey Graphe.</mark>





[^1]: &#x20;L'organisme coordinateur de la filière de Responsabilité Elargie du Producteur des Eléments d'Ameublement.
