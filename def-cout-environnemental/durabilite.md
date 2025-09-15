# 🏷️ Durabilité

## Principes clés

La durabilité d'un produit reflète sa capacité à perdurer dans le temps.&#x20;

Dès lors que l'utilisation d'un produit génère un impact (consommation d'énergie par exemple), **plus un produit est durable, plus il est utilisé, plus il est entretenu, et plus la somme des impacts qu'il génère est importante (sur une durée d'utilisation plus longue).**

**Le calcul du coût environnemental intègre la notion de durabilité, de telle sorte que plus la durabilité d'un produit est élevée, plus faible est son coût environnemental.**

Le coût environnemental utilisé dans Ecobalyse repose sur une unité fonctionnelle fixe (ex : 45 jours de portées pour un t-shirt). Dès lors, pour chaque produit, un **coefficient de durabilité** `C_Durabilité` est établi afin de corriger le coût environnemental selon la durée de vie estimée.

## Méthode de calcul&#x20;

$$
CoûtEnvironnemental = \frac{SommeDesImpacts}{C_{Durabilité}}
$$

Avec :&#x20;

* `CoûtEnvironnemental` : le coût environnemental du produit
* `SommeDesImpacts` : la somme des impacts environnementaux du produit sur l'ensemble du cycle de vie. Ces impacts environnementaux sont affichés dans le simulateur pour chaque étape, leur calcul est décrit dans les pages méthodologiques de la documentation. \
  &#xNAN;_&#x4C;a valeur_ `SommeDesImpacts` _est indiquée dans le simulateur sous le coût environnemental, avec la mention `hors durabilité`. Plus le produit est utilisé, plus cette valeur augmente._&#x20;
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité dont la valeur est située entre `Coeff_min` pour les produits les moins durables, et `Coef_max`  pour les produits les plus durables

{% hint style="info" %}
**L'unité fonctionnelle** utilisée pour le calcul du coût environnemental est une durée d'utilisation fixe (ex : 45 jours pour un t-shirt, 8 années pour une chaise, 200 000 km pour une voiture etc.).

Ainsi,  le coefficient de durabilité permet de refléter dans le coût environnemental la capacité du produit à atteindre la durée de vie souhaitée (l'unité fonctionnelle).&#x20;

Dès lors :&#x20;

* une faible durabilité ( `C_Durabilité` < 1) reflète une durée de vie estimée inférieure à celle souhaitée. Une "fraction d'un second produit" sera donc nécessaire pour atteindre la durée de vie souhaitée.
* une forte durabilité ( `C_Durabilité` > 1) reflète la capacité du produit à atteindre la durée de vie souhaitée avant sa fin de vie. Dès lors, une fraction seulement du coût environnemental du produit est retenue.&#x20;
{% endhint %}

{% hint style="info" %}
Le rapport entre `Coef_max` et `Coeff_min` correspond à l'amplitude de durée de vie pour une catégorie de produits données.

Par exemple, pour le Textile, on estime qu'un vêtement très durable (`Coef_max = 1.45`) sera porté 2.2 fois plus qu'un vêtement très peu durable (`Coeff_min = 0.67)`. Ainsi, un T-shirt, dont la durée de vie moyenne est de 45 jours d'utilisation (`C_Durabilité = 1`), aura en moyenne une durée de vie de 30 jours d'utilisation (pour les moins durables) à 65 jours (pour les plus durables).
{% endhint %}

## Paramètres de calcul  <a href="#calcul-du-coefficient-de-durabilite-c_durabilite" id="calcul-du-coefficient-de-durabilite-c_durabilite"></a>

Les calcul de `C_Durabilité` , `C_min`  et `C_max`  sont spécifiques à chaque secteur et précisés dans les pages de documentation sectorielles.

