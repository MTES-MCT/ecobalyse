# Prise en compte de la durabilité

## Contexte

Voir page sur le coût environnemental relative à la durabilité&#x20;

Pour chaque produit, un **coefficient de durabilité** `C_Durabilité` est établi, permettant de corriger le calcul du coût environnemental pour prendre en compte des&#x20;

## Méthodes de calcul

Le coût environnemental est établi comme suit :&#x20;

$$
I = \frac{I_{Hors Utilisation}}{C_{Durabilité}}+I_{Utilisation}
$$

Avec :&#x20;

* `I` : le coût environnemental total du produit
* `I_HorsUtilisation` : la somme du cout environnemental du produit à chaque étape du cycle de vie, hors utilisation du produit
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité dont la valeur est située en `C_min` pour les produits les moins durables, et `C_max`  pour les produits les plus durables
* `I_Utilisation` : le cout environnemental du produit relatif à son utilisation

## Paramètres retenus pour le coût environnemental

Le calcul de `C_Durabilité` et les paramètres `C_min`  et `C_max`  sont définis secteur par secteur et décrits dans les pages sectorielles _Calcul de la durabilité_.

### Paramètres spécifiques pour l'affichage environnemental réglementaire

## Exemple d'application

{% hint style="info" %}
\[optionnel mais utile] Application à un exemple, pour permettre une meilleure compréhension au lecteur
{% endhint %}

