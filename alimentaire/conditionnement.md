---
description: Choix du mode de conditionnement du produit modélisé
---

# 🥫 Conditionnement

La troisième étape du paramétrage d'un produit alimentaire dans Ecobalyse est le choix du mode de conditionnement. Cette étape est optionnelle, un produit pouvant ne pas avoir de conditionnement.&#x20;

Le paramétrage se fait à travers :

* le choix d'une liste de matières ==> en première approche, une seule matière peut être sélectionnée
* pour chaque matière, le paramétrage de la masse mobilisée, exprimée en grammes (g) \[**A confirmer**]

{% hint style="danger" %}
Dans la modélisation des produits CIQUAL de la base Agribalyse, des procédés de transport sont également mobilisés pour caractériser le conditionnement. En première approche, au regard de l'impact limité que semble avoir ce transport, il n'est pas pris en compte.
{% endhint %}

## Liste de matières proposées

La matières proposées sont les matières proposées à l'étape "at packaging" dans la modélisation des produits CIQUAL de la base Agribalyse.

Une liste de **X** matières est ainsi constituée.

## Caractérisation de chaque matière

La matière sélectionnée est caractérisée par :&#x20;

* Masse (g)

{% hint style="warning" %}
La masse est exprimée en grammes (g) pour la configuration du conditionnement. Dans le calcul (cf. ci-après), c'est toutefois une masse en kg qui est considérée (kg). Une conversion est donc réalisée.
{% endhint %}

&#x20;

## Calcul des impacts

L'impact du conditionnement est la somme des impacts de chaque matière mobilisée.

$$
ImpactConditionnement = ImpactMatière1 + ImpactMatière 2 + ...
$$

​L'impact de chaque matière est proportionnel à la masse paramétrée et à l'impact massique de l'ingrédient \[_**TODO : préciser ce que cela veut dire dans la base ACV**_]

$$
ImpactMatièreN = Masse (kg) * ImpactMassiqueMatièreN
$$

​

Les impacts considérés peuvent être indifféremment :&#x20;

* l'un des 16 impact PEF proposés dans la base Agribalyse (cf. [impacts-consideres.md](../textile/impacts-consideres.md "mention")) - \[_**TODO : une modif à prévoir sur cette page, voire sur l'explorateur, pour dissocier l'alimentaire et le textile**_]
* le score PEF calculé comme une somme pondérée des 16 impacts, en application de la méthode PEF (cf. [https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef](https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef) )
