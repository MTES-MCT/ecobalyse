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
  * Cette consommation s'exprime usuellement pour 100km, puis multipliée pour obtenir la consommation sur la durée de vie du véhicule.

## Méthodes de calcul

### Grands principes

Pour chaque secteur, plusieurs consommables sont proposés, correspondant chacune à un procédé (visible dans l'explorateur)

Les attributs suivants sont attachés à chaque consommable pour définir son utilisation :&#x20;

* `productmassdependent` : définit si la consommation dépend de la masse du produit (cas des cuisson alimentaire par exemple)
* `unit` : définit l'unité du procédé&#x20;
* `productdependant` : définit si la quantité est définie par l'utilisateur ou fixée par Ecobalyse
* `eleckWh` : définit une quantité d'électricité
* `heatMJ` : définit une quantité de chaleur

### Formule de calcul en cours de développement

$$
I_{utilisation} = \sum_i{m_i*\big(C_{use,i,current}*I_{i}+E_{use,i}*I_{Energy}\big)}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `C_use,i,current` : la consommation du consommable `i`, par unité d'utilisation. Celle-ci dépend des attributs attachés au consommable :
  * `productdependant` : valeur fixée l'utilisateur
  * absence d'attribut : `C_use,i` = 1
* `E_use,i` = `eleckWh`  et/ou `heatMJ` : quantité d'électricité consommée&#x20;
* `m_i` : la masse du produit, exprimée en kg OU `1` si la consommation ne dépend pas de la masse&#x20;
* `I_i` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée (hors énergie)
  * Dans de nombreux cas où seuls de l'électricité et de la chaleur sont appelé, `I_i` = 0
* `I_Energy` : l'impact environnemental de l'électricité ou de la chaleur, dans l'unité de la catégorie d'impact analysée

### Formule de calcul projetée

$$
I_{utilisation} = \sum_i{m_i*r_{i}*\big(C_{use,i,futur}*I_{i}+E_{use,i}*I_{Energy}\big)}*T_{life}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `C_use,i,future` : la consommation du consommable `i`, par unité d'utilisation. Celle-ci dépend des attributs attachés au consommable :&#x20;
  * `productdependant` : valeur fixée l'utilisateur
  * absence d'attribut : `C_use,i` = 1
* `E_use,i` = `eleckWh`  et/ou `heatMJ` : quantité d'électricité consommée&#x20;
* `m_i` : la masse du produit OU `1` si la consommation ne dépend pas de la masse
* `r_use,i` : un ratio de conversion entre l'unité de la durée de vie et l'unité d'utilisation du consommable
  * Ce ratio dépend de la catégorie de produit
* `I_i` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée
  * Dans de nombreux cas où seuls de l'électricité et de la chaleur sont appelé, `I_i` = 0
* `I_Energy` : l'impact environnemental de l'électricité ou de la chaleur, dans l'unité de la catégorie d'impact analysée
* `T_life` : la durée de vie du produit, fixée par catégorie de produit

## Paramètres retenus pour le coût environnemental



## Procédés utilisés pour le coût environnemental

Les procédés sont indiqués dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

Précision sur les procédés `I_Energy` :&#x20;

* Lorsqu'une consommation d'électricité est appelée, Ecobalyse utilise les procédés Ecoinvent basse tension du pays considérés, en l’occurrence la France : _market for electricity, low voltage, FR_
* Lorsqu'une consommation de chaleur est appelée, Ecobalyse utilise un procédé construit "Mix Chaleur (Europe)", décrit dans la [page relative à l'énergie consommée au étape de transformation](https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/lSaq6DJynGgBREOg7dWI/methodes-transverses/composants/energies-des-etapes-de-transformation).

## Exemple d'application

### Exemple 1 : cuisson à la poële de 100 g d'aliments

* Le procédé "Cuisson à la poële" a un impact environnemental nul ( `I_i`=0). Il a les attributs suivants :&#x20;
  * `productmassdependent`&#x20;
  * `unit` : kg
  * `eleckWh` : 0.18 (kWh/kg)
  * `heatMJ` : 0.95 (MJ/kg)
* La masse de produit est de 100g : `m_i`=0.1
* `I_Energy` = 19.33 Pts/kWh pour l'électricité et 4.08 Pts/kWh pour la chaleur

$$
I_{utilisation} = \sum_i{m_i*\big(C_{use,i,current}*I_{i}+E_{use,i}*I_{Energy}\big)}
$$

$$
I_{cuisson,poele} = I_{cuisson,poele} = 0.1*\big(1*0+0.18*19.33+0.95*4.08\big)=0.73 Pts
$$

### Exemple 2 : Véhicule consommant&#x20;
