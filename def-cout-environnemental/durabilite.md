# 🏷️ Durabilité

## Principes clés

La durabilité d'un produit reflète sa capacité à perdurer dans le temps.&#x20;

Plus la durabilité d'un produit est élevée, plus faible est son coût environnemental.

Le coût environnemental utilisé dans Ecobalyse repose sur une unité fonctionnelle fixe (ex : 45 jours de portées pour un t-shirt). Dès lors, pour chaque produit, un **coefficient de durabilité** `C_Durabilité` est établi afin de corriger le coût environnemental selon la durée de vie estimée.

## Méthode de calcul&#x20;

$$
CoûtEnvironnemental = \frac{Somme des Impacts}{C_{Durabilité}}
$$

Avec :&#x20;

* `CoûtEnvironnemental` : le coût environnemental total du produit
* `SommedesImpacts` : la somme du cout environnemental du produit à chaque étape du cycle de vie. Elle est aussi appelée _coût environnemental hors durabilité_
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité dont la valeur est située entre `Coeff_min` pour les produits les moins durables, et `Coef_max`  pour les produits les plus durables

{% hint style="info" %}
**L'unité fonctionnelle** utilisée pour le calcul du coût environnemental est un nombre de jours fixe d'utilisations (ex : 45 jours pour un t-shirt).

Ainsi,  le coefficient de durabilité permet de refléter dans le coût environnemental la capacité du produit à atteindre la durée de vie souhaitée (l'unité fonctionnelle).&#x20;

Dès lors :&#x20;

* une faible durabilité ( `C_Durabilité` < 1) reflète une durée de vie estimée inférieure à celle souhaitée. Une "fraction d'un second produit" sera donc nécessaire pour atteindre la durée de vie souhaitée.
* une forte durabilité ( `C_Durabilité` > 1) reflète la capacité du produit à atteindre la durée de vie souhaitée avant sa fin de vie. Dès lors, une fraction seulement du coût environnemental du produit est retenue.&#x20;
{% endhint %}

## Paramètres de calcul  <a href="#calcul-du-coefficient-de-durabilite-c_durabilite" id="calcul-du-coefficient-de-durabilite-c_durabilite"></a>

Les calcul de `C_Durabilité` , `C_min`  et `C_max`  sont spécifiques à chaque secteur et précisés dans les pages de documentation sectorielles.



