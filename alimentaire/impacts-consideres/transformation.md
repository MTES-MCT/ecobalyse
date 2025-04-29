---
description: Choix des procédés de transformation du produit alimentaire modélisé
---

# 🥧 Etape 2 : transformation

{% hint style="info" %}
La modélisation de l'étape transformation va être amenée à évoluer dans les prochains mois afin de proposer plus de choix à l'utilisateur. Un travail va également être conduit pour proposer un paramétrage de cette étape en fonction de pays de transformation.
{% endhint %}

La seconde étape du paramétrage d'un produit alimentaire dans Ecobalyse est le choix des procédés de transformation.

Le paramétrage se fait actuellement à travers :&#x20;

* le choix d'un procédé de transformation (optionnel) => en première approche, le choix d'un seul procédé est possible,
* pour chaque procédé de transformation, le paramétrage de la masse mobilisée, exprimée en grammes (g).

{% hint style="warning" %}
Le nombre de procédés de transformation est limité à ce stade. Seuls les procédés correspondant à la **dernière** **transformation non spécifique** d'un produit sont proposés : cuisson, mise en conserve et mélange. En effet, il est considéré, en première approche, que **les transformations spécifiques (vinification, découpe, hachage, affinage...) doivent être intégrées à la phase ingrédient** (les hypothèses Agribalyse sont donc reprises telles quelles).
{% endhint %}

Exemple : la transformation du lait en mozzarella n'est pas modélisable à ce stade dans l'outil. Le calcul de l'impact de la mozzarella se fait donc en choisissant l'ingrédient mozzarella dans le module ingrédient.&#x20;

## Détails sur les ICV des procédés de transformation proposés

Pour établir la liste des procédés de transformation, voilà les critères que l'on utilise :

* procédé utilisé dans un produit CIQUAL
* de catégorie `processing`
* ne produisant pas un ingrédient de base (viande, lait, …). Dans ce cas on part du principe que l’utilisateur utilisera directement l’ingrédient de base (viande, lait, …) dans sa recette

Voilà la liste des procédés de transformation retenus

| Mixing, processing, at plant \\"dummy process\\                       |
| --------------------------------------------------------------------- |
| Canning fruits or vegetables, industrial, 1kg of canned product/ FR U |
| Cooking, industrial, 1kg of cooked product/FR U                       |

Le détail des procédés mobilisés avec Ecobalyse est accessible via la rubrique "procédés" de l'explorateur : [https://ecobalyse.beta.gouv.fr/#/explore/food/food-processes](https://ecobalyse.beta.gouv.fr/#/explore/food/food-processes)

## Caractérisation du procédé de transformation

Chaque procédé de transformation est caractérisé par sa masse (g).

La masse est considérée en sortie de procédé de transformation.

Par défaut, la masse est initiée à une valeur correspondant à la somme des masses des [ingrédients](../etapes-du-cycles-de-vie/ingredients-agricoles-hors-viande/). Elle est modifiable.

$$
MasseTransfo (g) = MasseIngrédient1 (g) + MasseIngrédient2 (g)+...
$$

{% hint style="warning" %}
La masse est exprimée en grammes (g) pour la configuration du conditionnement. Dans le calcul (cf. ci-après), c'est toutefois une masse en kg qui est considérée (kg). Une conversion est donc réalisée.
{% endhint %}

{% hint style="danger" %}
La masse proposée par défaut pour le procédé de transformation devra évoluer à l'avenir pour intégrer, par exemple, les éventuelles pertes au niveau de la transformation (Cooking...).
{% endhint %}

## Calcul des impacts

Les impacts du procédé de transformation qui peut être sélectionné sont calculés à partir de la masse renseignée et de l'impact massique, tel que disponible dans \[_**A préciser**_]

$$
ImpactTransfo = MasseTransfo (kg) * ImpactMassiqueTransfo
$$

​
