---
description: Choix des ingrédients du produit modélisé
---

# 🍅 Ingrédients

La première étape du paramétrage d'un produit alimentaire dans Ecobalyse est le choix des ingrédients mobilisés.&#x20;

{% hint style="info" %}
La recette d'un produit, et donc le choix des ingrédients, représente généralement de l'ordre de 80% de l'impact environnemental total du produit.
{% endhint %}

Le paramétrage se fait à travers :

* le choix d'une liste d'ingrédient ==> en première approche, jusqu'à 8 ingrédients différents peuvent être sélectionnés)
* pour chaque ingrédient, le paramétrage de la masse mobilisée, exprimée en grammes (g)

## Liste d'ingrédients proposés

Les ingrédients proposés sont l'ensemble des ingrédients entrant dans la composition des \~2800 produits CIQUAL référencés dans la base Ecobalyse.

En termes ACV, il s'agit des procédés _at plant,_ à l'exception des procédés qui correspondent à une opération de transformation _(cooking, pasteurisation...)._

Une liste de \~600 ingrédients est ainsi établie et proposée pour paramétrer un produit alimentaire.

{% hint style="danger" %}
En première approche, la liste des 600 ingrédients ne fait l'objet d'aucun tri. On y trouve néanmoins :&#x20;

* différentes versions d'un même ingrédient (tomate ES, tomate IT...)
* des produits bruts (olives) et déjà transformés (huile d'olive)

Le classement des 600 ingrédients pourra faire l'objet de travaux ultérieurs.
{% endhint %}

## Caractérisation de chaque ingrédient

En première approche, chaque ingrédient n'est caractérisé que par :&#x20;

* Masse (g)

{% hint style="danger" %}
Dans un second temps, d'autres paramètres pourraient être intégrés :&#x20;

* Pays (à définir plus précisément)
* Label (Agriculture biologique par exemple)
{% endhint %}

{% hint style="warning" %}
La masse est exprimée en grammes (g) pour la configuration du conditionnement. Dans le calcul (cf. ci-après), c'est toutefois une masse en kg qui est considérée (kg). Une conversion est donc réalisée.
{% endhint %}

## Calcul des impacts

L'impact des ingrédients est la somme des impacts de chaque ingrédient.

$$
ImpactIngrédients = ImpactIngrédient1 + ImpactIngrédient2 + ... + Impact Ingrédient N
$$

L'impact de chaque ingrédient est proportionnel à la masse paramétrée et à l'impact massique de l'ingrédient \[_**TODO : préciser ce que cela veut dire dans la base ACV**_]

$$
ImpactIngrédientN = MasseIngrédientN(kg) * ImpactMassiqueIngrédientN
$$

Les impacts considérés peuvent être indifféremment :&#x20;

* l'un des 16 impact PEF proposés dans la base Agribalyse (cf. [impacts-consideres.md](../textile/impacts-consideres.md "mention")) - \[_**TODO : une modif à prévoir sur cette page, voire sur l'explorateur, pour dissocier l'alimentaire et le textile**_]
* le score PEF calculé comme une somme pondérée des 16 impacts, en application de la méthode PEF (cf. [https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef](https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef) )





