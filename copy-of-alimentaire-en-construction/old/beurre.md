# 🧈 Beurre

{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient industrie à partir d'ingrédients agricoles

Les procédés proposés dans Agribalyse pour le beurre "sortie de crèmerie" sont :&#x20;

* **Butter, salted, at dairy**
* **Butter, salted, at dairy (WFLDB 3.1)**
* **Butter, unsalted, at dairy**
* **Butter, unsalted, at dairy (WFLDB 3.1)**

{% hint style="info" %}
**Attente des graphes Simapro pour isoler le procédé retenu.**

**En l'absence de procédé "consumption mix", deux hypothèses :**&#x20;

* un procédé "beurre" retenu correspondant au procédé impliqué dans le beurre produit fini => **identification du procédé à partir des graphes Simapro des 4 procédés ci-dessus**
* un procédé "beurre" retenu correspondant au beurre intervenant dans les recettes industrielles **=> identification de l'ingrédient beurre mobilisé dans "'Chocolate croissant, puff pastry, from bakery, at plant' (kilogram, FR, None)"**
{% endhint %}

$$
huilecolzaREF
$$

{% hint style="danger" %}
A confirmer avec le graphe Simapro
{% endhint %}



Ce procédé est construit à partir :&#x20;

* de

$$
BléREF
$$

* d'opérations industrielles : mouture (milling), réception, prélavage, stockage.&#x20;

<figure><img src="../../.gitbook/assets/Image collée à 2022-11-9 17-42.png" alt=""><figcaption><p>Arborescence du procédé Wheat flour at industrial mill</p></figcaption></figure>

On construit différents procédés de farine **(N)**, sur la base du procédé de référence (Wheat flour at industrial mill), en appliquant les opérations industrielles à différents procédés de blé tendre **(N)**.

$$
ImpactFarine_N = (ImpactFarineREF - ImpactBléREF )+ImpactBlé_N
$$

## Procédés retenus

| Label / Origine        | France                                                                                                                                                        | Autres pays                                                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> |
| Agriculture biologique | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : Soft wheat grain, organic, 15% moisture, Central Region, at farm gate</p>           | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : Soft wheat grain, organic, 15% moisture, Central Region, at farm gate</p>           |

{% hint style="info" %}
Le blé bio considéré dans un premier temps pour le calcul de la farine bio est celui dont le taux d'humidité correspond au taux d'humidité du blé panifiable (principal usage du blé tendre)
{% endhint %}

Les impacts comparés de ces procédés sont :&#x20;

_<mark style="color:red;">\[Intégration d'un graphique comparant les scores PEF décomposés des deux Farines qui seraient considérées]</mark>_&#x20;

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Beurre => catégorie 3 : PAYS TIERS** (source : dires d'experts/à confirmer)&#x20;

