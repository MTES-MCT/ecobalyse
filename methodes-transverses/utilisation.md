---
hidden: true
---

# ⌛ Utilisation

## Contexte

Dans sa phase d'utilisation, un produit peut consommer de l'énergie, de l'eau ou des matériaux, et avoir des émissions associées à cette utilisation.

Dans la plupart des cas, cette consommation dépend fortement de l'utilisateur final et ne peut pas être fournie par le fabricant. Dans ce cas, Ecobalyse propose une consommation établie selon les référentiels du secteur ou par concertation avec les parties prenantes. Cette consommation dépend en général directement du poids.

Pour certains produits, la consommation d'énergie dépend d'une part d'une consommation unitaire fournie par le fabricant, calculée selon une norme sectorielle, et d'autre part de la durée de vie du produit.

Exemples :&#x20;

* Consommation d'électricité pour la cuisson d'un aliment (dépend du poids)
* Consommation d'eau, de lessive et d'électricité pour le lavage d'un vêtement (dépend du poids)
* Consommation d'électricité pour le repassage d'un vêtement (dépend du type de vêtement, pas du poids)
* Consommation de carburant d'un véhicule (fournit par le fabricant selon un référentiel normé)

## Méthodes de calcul

$$
I_{utilisation} = \sum_iC_{use,i}*m_i*T_{life}*r_{use}*I_{consumable}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `C_use` : la consommation du consommable `i`, par unité d'utilisation.
* `I_consumable` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée

NB : un produit peut avoir plusieurs étapes d'utilisation. La formule est alors à dupliquer et sommer autant de fois que nécessaire.

## Paramètres retenus pour le coût environnemental

Le paramètre `C_utilisation,elec` est spécifique à chaque secteur. L'impact de l'utilisation des produits fait l'objet d'une page sectorielle dédiée.

## Procédés utilisés pour le coût environnemental

Ecobalyse utilise les procédés Ecoinvent basse tension du pays considérés, en l’occurrence la France : _market for electricity, low voltage, FR_

Ce procédé est rappelé dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

## Exemple d'application

Utilisation des textiles : le lavage des textiles comprend de la consommation d'électricité. Dans cet exemple, `C_utilisation,elec,lavage`  est le produit du nombre de cycles d'entretien, de la consommation d'électricité par cycle et du poids du vêtement.

Pour le secteur textile, certains produits nécessitent un repassage, correspondant également à de la consommation d'électricité.
