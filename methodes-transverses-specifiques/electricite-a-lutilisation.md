# 💡 Electricité à l'utilisation

## Contexte

Un produit peut nécessiter de l'électricité lors de sa phase d'utilisation.

Pour la plupart des produits modélisés dans Ecobalyse, il s'agit d'une consommation domestique.

## Méthodes de calcul

$$
I_{utilisation, électricité} = C_{utilisation}*I_{elec}
$$

Avec :

* `I_utilisation, électricité` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `C_utilisation,elec` : la consommation d'électricité à l'utilisation par kg, en kWh/kg
* `I_elec` : l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée

NB : un produit peut avoir plusieurs étapes d'utilisation. La formule est alors à dupliquer et sommer autant de fois que nécessaire.

## Paramètres retenus pour le coût environnemental

Le paramètre `C_utilisation,elec` est spécifique à chaque secteur. L'impact de l'utilisation des produits fait l'objet d'une page sectorielle dédiée.

## Procédés utilisés pour le coût environnemental

Ecobalyse utilise les procédés Ecoinvent basse tension du pays considérés, en l’occurrence la France : _market for electricity, low voltage, FR_

Ce procédé est rappelé dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

## Exemple d'application

Utilisation des textiles : le lavage des textiles comprend de la consommation d'électricité. Dans cet exemple, `C_utilisation,elec,lavage`  est le produit du nombre de cycles d'entretien, de la consommation d'électricité par cycle et du poids du vêtement.

Pour le secteur textile, certains produits nécessitent un repassage, correspondant également à de la consommation d'électricité.
