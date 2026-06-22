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
  * Cette consommation s'exprime par cycle d'entretien, ce qui correspond à un ou plusieurs jours portés, selon le vêtement
* Consommation d'électricité pour le repassage d'un vêtement (dépend du type de vêtement, pas du poids)
  * Cette consommation s'exprime par cycle d'entretien
* Consommation de carburant d'un véhicule (fournit par le fabricant selon un référentiel normé)
  * Cette consommation s'exprime pour 100km

## Méthodes de calcul

### Grands principes

Pour chaque secteur, plusieurs consommables sont proposés, correspondant chacune à un procédé (visible dans l'explorateur)

Les attributs suivants sont attachés à chaque consommable pour définir son utilisation :&#x20;

* `productmassdependent` : définit si la consommation dépend de la masse du produit (cas des cuisson alimentaire par exemple)
* `unit` : définit l'unité du procédé&#x20;
* `productdependant` : définit si la quantité est définie par l'utilisateur ou fixée par Ecobalyse
*

### Formule de calcul

$$
I_{utilisation} = \sum_i{\big(C_{use,i}*m_i*r_{i}*I_{i}\big)}*T_{life}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `C_use,i` : la consommation du consommable `i`, par unité d'utilisation. Celle-ci dépend des attribut attachés au consommable
  * `eleckWh` : définit une quantité d'électricité
  * `heatMJ` : définit une quantité de chaleur
  * `productdependant` : valeur fixée l'utilisateur
  * absence d'attribut : `C_use,i` = 1
* `m_i` : la masse du produit OU `1` si la consommation ne dépend pas de la masse
* `r_use,i` : un ratio de conversion entre l'unité de la durée de vie et l'unité d'utilisation du consommable
  * Ce ratio dépend de la catégorie de produit
* `I_i` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée
* `T_life` : la durée de vie du produit, fixée par catégorie de produit

## Paramètres retenus pour le coût environnemental

Le paramètre `C_utilisation,elec` est spécifique à chaque secteur. L'impact de l'utilisation des produits fait l'objet d'une page sectorielle dédiée.

## Procédés utilisés pour le coût environnemental

Ecobalyse utilise les procédés Ecoinvent basse tension du pays considérés, en l’occurrence la France : _market for electricity, low voltage, FR_

Ce procédé est rappelé dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

## Exemple d'application

Utilisation des textiles : le lavage des textiles comprend de la consommation d'électricité. Dans cet exemple, `C_utilisation,elec,lavage`  est le produit du nombre de cycles d'entretien, de la consommation d'électricité par cycle et du poids du vêtement.

Pour le secteur textile, certains produits nécessitent un repassage, correspondant également à de la consommation d'électricité.
