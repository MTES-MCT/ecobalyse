# Prise en compte de la durabilité

## Contexte

La prise en compte de la durabilité doit permettre d'introduire une estimation de la durée d'utilisation du produit dans la modélisation du coût environnemental.

Pour chaque produit, un **coefficient de durabilité** `C_Durabilité` est établi, permettant de corriger le calcul du coût environnemental pour prendre en compte la durée de vie du produit.

## Méthodes de calcul

### Prise en compte de la durabilité dans le calcul du coût environnemental&#x20;

Le coût environnemental est établi comme suit :&#x20;

$$
I = \frac{I_{Hors Utilisation}}{C_{Durabilité}}+I_{Utilisation}
$$

Avec :&#x20;

* `I` : le coût environnemental total du produit
* `I_HorsUtilisation` : la somme du cout environnemental du produit à chaque étape du cycle de vie, hors utilisation du produit
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité dont la valeur est située en `Coeff_min` pour les produits les moins durables, et `Coef_max`  pour les produits les plus durables
* `I_Utilisation` : le cout environnemental du produit relatif à son utilisation

### Calcul du coefficient de durabilité `C_Durabilité`&#x20;

Le calcul de `C_Durabilité` est propre à chaque secteur et décrits dans les pages sectorielles _Calcul de la durabilité_.

## Paramètres retenus pour le coût environnemental

Les paramètres `C_min`  et `C_max`  sont propres à chaque secteur et précisés dans les pages sectorielles _Calcul de la durabilité_.

## Exemple d'application

Les exemples d'application sont décrits dans les pages sectorielles _Calcul de la durabilité_.

