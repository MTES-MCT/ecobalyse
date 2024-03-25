---
description: >-
  Présentation de l'intégration d'un coefficient de durabilité dans la méthode
  de calcul
---

# ⏳ Durabilité

{% hint style="danger" %}
EN CONSTRUCTION
{% endhint %}

{% hint style="info" %}
Plus un vêtement est porté, plus son impact est faible
{% endhint %}

La prise en compte de la durabilité doit permettre d'introduire une estimation du nombre d'utilisation de chaque vêtement dans la modélisation du coût environnemental.

## Quelles sont les dimensions de la durabilité ? Lesquelles sont prises en compte ?

Deux principales dimensions sont généralement considérées pour apprécier la durabilité d'un vêtement :&#x20;

* sa durabilité physique (capacité du vêtement à résister à l'usure physique liée à son utilisation et son entretien)
* sa durabilité non physique (propension qu'aura le vêtement à être porté plus longtemps en fonction d'autres critères : réparabilité, attachement...)

Ces deux dimensions sont mises en avant dans différents travaux à l'échelle européenne

> Parlement Européen - Résolution sur la stratégie textile durable (juin 2023) : "Calls on the Commission and the Member States to ensure that the policy framework on textiles takes a holistic view of durability, including both the physical and the emotional durability of textile products put on the market, which describes the garment design that takes into account long-term relevance and desirability to consumers, as clothing represents a cultural value"

> Secrétariat technique du PEFCR Apparel & Footwear (juin 2023) : "\[Acknowledges] that product lifetime in Apparel & Footwear is subject to three influences:
>
> a.the intrinsic durability of the productb.the extrinsic durability andc.the reparability of the product"

Dans un premier temps, le coefficient de durabilité introduit dans la modélisation du coût environnemental intègre la dimension non physique de la durabilité. La durabilité physique fait par ailleurs l'objet de travaux dans le cadre du projet de PEFCR Apparel & Footwear, en s'appuyant notamment sur le projet Durhabi porté par l'IFTH, en lien avec de nombreux acteurs en France et avec le soutien de l'Ademe.

## Calcul du coût environnemental

Pour chaque vêtement, un **coefficient de durabilité** est établi. Sa valeur est comprise entre 0,5, pour les produits les moins durables, et 1,5 pour les produits les plus durables.

Le coût environnemental est établi comme suit :&#x20;

$$
CoûtEnvironnemental = Somme des Impacts / CoefficientDurabilité
$$

Avec :&#x20;

* SommedesImpacts : Somme des impacts du vêtement considéré sur l'ensemble de son cycle de vie. Pour la phase d'utilisation, on considère un nombre de portés et un nombre de cycles d'utilisation proportionnels au coefficient de durabilité. Plus un vêtement est durable, plus il est porté, plus il est entretenu, plus la somme des impacts qu'il génère est importante (sur une durée d'utilisation plus longue).
* Coût environnemental : Le coût environnemental ainsi considéré revient à considérer une unité fonctionnelle "utilisation du vêtement sur une durée de X jours", où X est la durée moyenne d'utilisation considérée pour la catégorie de vêtement considérée (cf. nombre de portés et d'utilisation avant lavage spécifiés dans l'[explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products)).

## Calcul du coefficient de durabilité

Le coefficient de durabilité est établi à partir de 5 critères pondérés comme suit :&#x20;

* Largeur de gamme -> 20%
* Durée de commercialisation -> 20%
* Incitation à la réparation -> 30%
* Matières -> 15%
* Affichage de la traçabilité -> 15%

<figure><img src="../../.gitbook/assets/image.png" alt=""><figcaption><p>Pondération des 5 composantes du coefficient de durabilité</p></figcaption></figure>

Chacune des 5 composantes s'exprime à travers un indice (I) compris entre 0 et 1 et pouvant donc être exprimé en pourcentage (%). En intégrant les pondérations mentionnées ci-dessus, et les valeurs minimale (0,5) et maximale (1,5) du coefficient de durabilité, la formule permettant de l'établir est :&#x20;



$$
CoefDurabilité = 0,5 + (1,5-0,5)*0,2*Ilargeurdegamme + 0,2*Iduréecommercialisation + ...
$$

La définition et la modélisation de chaque indice sont détaillées ci-après.

## Largeur de gamme

A compléter

## Durée de commercialisation

A compléter

## Incitation à la réparation

A compléter

## Matières

A compléter

## Affichage de la traçabilité

A compléter
