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

Pour chaque secteur, plusieurs processus d'utilisation sont proposés, correspondant chacun à un procédé visible dans l'explorateur.

Un attribut `productmassdependent` définit si la consommation dépend de la masse du produit (cas des cuisson alimentaire par exemple) ou pas (cas du repassage, de la consommation de carburant ou des émissions de particules d'un véhicule par exemple). En l'absence de cet attribut, la quantité du procédé doit être fournie par l'utilisateur, éventuellement en suivant les indications de la documentation sectorielle.

### Formule de calcul

$$
I_{utilisation} = \sum_i{Q_i*I_{i}}
$$

Avec :

* `I_utilisation` : l'impact environnemental à l'utilisation d'un produit, dans l'unité de la catégorie d'impact analysée
* `Q_i` : la quantité du consommable
  * si le procédé de consommation a l'attribut `productmassdependent`, `Q_i` est la masse du produit, exprimée en kg
  * sinon, `Q_i` est modifiable et à définir selon les situations par l'utilisateur (voir documentations sectorielles).
* `I_i` : l'impact environnemental du consommable `i` , dans l'unité de la catégorie d'impact analysée par unité du procédé

{% hint style="info" %}
L'énergie est généralement modélisée comme Flux externe (voir [Modélisation de la consommation d'énergie](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses/production/energies-des-etapes-de-transformation)).
{% endhint %}

## Paramètres retenus pour le coût environnemental

Non applicable

## Procédés utilisés pour le coût environnemental

Les procédés sont indiqués dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) de chaque secteur.

## Exemple d'application

### Exemple 1 : cuisson à la poële de 100 g d'aliments

* Le procédé "Cuisson à la poële" a de l'énergie associée comme Flux externe et un impact environnemental nul par ailleurs (`I_ICV` = 0). Il a les attributs suivants :&#x20;
  * `productmassdependent`&#x20;
  * `unit` : kg
  * `eleckWh` : 0.18 (kWh/kg)
  * `heatMJ` : 0.95 (MJ/kg)
* La masse de produit est de 100g : `Q_i`=0.1
* L'impact unitaire de l'électricité est de `I_elec` = 19.33 Pts/kWh
* L'impact unitaire de la chaleur est de `I_chaleur` = 3.75 Pts/MJ

$$
I_{utilisation} = \sum_i{Q_i*(I_{ICV}+ eleckWh*I_{elec}+heatMJ*I_{chaleur}\big)}
$$

$$
I_{utilisation} = \sum_i{m_i*\big(C_{use,i,current}*I_{i}+E_{use,i}*I_{Energy}\big)}
$$

$$
I_{cuisson,poele} = 0.1*\big(0+0.18*19.33+0.95*4.08\big)=0.70 Pts
$$
