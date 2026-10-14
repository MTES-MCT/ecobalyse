# 🏷️ Durabilité

## Contexte

### Principes clés

La durabilité d'un produit reflète sa capacité à perdurer dans le temps.&#x20;

Plus un produit est durable, plus il est vertueux.

Cependant, l'impact environnemental d'un produit peut augmenter avec sa durabilité. En effet, lorsqu'un produit génère un impact à l'utilisation (ex : consommation d'énergie pour laver un t-shirt), son impact environnemental augmente en parallèle de l'accroissement de sa durée d'utilisation plus longue.

Le calcul du coût environnemental intègre donc la notion de durabilité, de telle sorte que plus la durabilité d'un produit est élevée, plus faible est son coût environnemental.&#x20;

Le coût environnemental utilisé dans Ecobalyse repose donc sur une unité fonctionnelle souhaitée fixe (ex : 45 jours pour un t-shirt, 8 années pour une chaise, 200 000 km pour une voiture etc.). Dès lors, pour chaque produit, un **coefficient de durabilité** `C_Durabilité` est introduit afin de ramener l'impact environnemental estimé du produit sur la durée de vie souhaitée.

### Dimensions de la durabilité : causes de fin de vie

La fin de vie de tout produit s'explique par des causes physiques (ex : casse d'un pied de chaise, rétrécissement d'un vêtement, etc.) et/ou non-physiques (ex : t-shirt jeté faute de réparations du fait d'un coût de réparation trop élevé par rapport au rachat d'un produit neuf vendu à un _prix dérisoire, fréquence de renouvellement des collections incitant à l'achat, etc._).

## Méthode de calcul

### Calcul du coût environnemental en fonction du coefficient de durabilité&#x20;

$$
CoûtEnvironnemental = \frac{SommeDesImpacts}{C_{Durabilité}}
$$

Avec :&#x20;

* `CoûtEnvironnemental` : le coût environnemental du produit
* `SommeDesImpacts` : la somme des impacts environnementaux du produit sur l'ensemble du cycle de vie. Ces impacts environnementaux sont affichés dans le simulateur pour chaque étape, leur calcul est décrit dans les pages méthodologiques de la documentation. La valeur `SommeDesImpacts` est indiquée dans le simulateur sous le coût environnemental, avec la mention `hors durabilité`. Plus le produit est utilisé, plus cette valeur augmente (si l'utilisation a un impact).&#x20;
* `C_Durabilité` : le coefficient de durabilité du produit, sans unité dont la valeur est située entre `Coeff_min` pour les produits les moins durables, et `Coef_max`  pour les produits les plus durables.&#x20;

{% hint style="info" %}
Le coefficient de durabilité permet de refléter dans le coût environnemental la capacité du produit à atteindre la durée de vie souhaitée (l'unité fonctionnelle).&#x20;

Pour chaque produit sont définis :&#x20;

* une durée de vie souhaitée = l'unité fonctionnelle,
* `Coef_max` et `Coeff_min`  qui reflètent l'amplitude de durée de vie possible du produit.&#x20;

Par exemple, pour les T-shirt, la durée de vie moyenne souhaitée est de 45 jours d'utilisation tandis que l'amplitude est de 2.2 (`Coef_max = 1.45`  / `Coeff_min = 0.67)`. Un vêtement durable pourrait donc être porté au maximum 2.2 fois plus qu'un vêtement peu durable.&#x20;

Dès lors :&#x20;

* une faible durabilité ( `C_Durabilité` < 1) reflète une durée de vie estimée inférieure à celle souhaitée. Une "fraction d'un second produit" sera donc nécessaire pour atteindre la durée de vie souhaitée.
* une forte durabilité ( `C_Durabilité` > 1) reflète la capacité du produit à atteindre la durée de vie souhaitée avant sa fin de vie. Dès lors, une fraction seulement du coût environnemental du produit est retenue.&#x20;
{% endhint %}

## Calcul du coefficient de durabilité `C_Durabilité` <a href="#calcul-du-coefficient-de-durabilite-c_durabilite" id="calcul-du-coefficient-de-durabilite-c_durabilite"></a>

Le coefficient de durabilité du produit est issu de la combinaison de deux paramètres :&#x20;

* `C_physique` : le coefficient de durabilité physique,
* `C_nonPhysique` : le coefficient de durabilité non-physique.

Ces deux paramètres sont pondérés selon une variable de pondération `x` permettant de refléter les causes de fin de vie spécifiques à chaque secteur d'activité. Cette pondération permet donc de préciser l'importance donnée à chacune des deux dimensions de la durabilité selon les réalités d'usage constatées sur le marché. &#x20;

$$
C_{Durabilité} = x*C_{Physique} + (1-x)*C_{NonPhysique}
$$

{% hint style="info" %}
Le choix d'une pondération permet, quels que soient les coefficients de durabilité `C_physique` et `C_nonphysique`, d'encourager les entreprises à améliorer leur produit sur les deux dimensions de la durabilité.
{% endhint %}

## Paramètres retenus pour le coût environnemental <a href="#calcul-du-coefficient-de-durabilite-c_durabilite" id="calcul-du-coefficient-de-durabilite-c_durabilite"></a>

`C_physique`, `C_nonphysique` et `x` sont spécifiques à chaque secteur et détaillés dans les pages de documentation sectorielles.&#x20;

`C_physique`, `C_nonphysique` reposent sur la même amplitude que `C_Durabilité`.&#x20;

