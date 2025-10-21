---
hidden: true
---

# 🧩 Composants

## Contexte

La plupart des produits consistent en un assemblage de composants, eux mêmes constitués de plusieurs matériaux transformés.

Dans une logique de déploiement du calcul du coût environnemental pour un nombre croissant de secteurs et de produits, Ecobalyse a construit un module Composant, qui permet de modéliser un composant à partir de matériaux de base et d'étapes de transformation.

Les cas d'usages sont nombreux, en voici quelques exemples :&#x20;

* boutons d'un vêtement (composant avec des paramètres imposés pour l'affichage réglementaire)
* pied d'une chaise
* pneu d'une voiture

## Méthode de calcul

{% tabs %}
{% tab title="Exemple A : 1 élément, 2 transformations " %}
Méthode de calcul pour un composant constitué d'un élément `e` subissant deux transformations, `t1` puis `t2` :&#x20;

$$
I_{c} =\frac{1}{(1-p_{t1})} *\frac{1}{(1-p_{t2})}*m_{e}*I_{e} + \frac{1}{(1-p_{t1})} *\frac{1}{(1-p_{t2})}*m_{e}*I_{t1} + \frac{1}{(1-p_{t2})}*m_{e}*I_{t2}
$$

Avec :&#x20;

* `I_c` : l'impact environnemental du composant modélisé, dans l'unité de la catégorie d'impact analysée
* `m_e` la masse finale de l'élément `e` présente dans le composant, exprimée en kg ;
* `p_t1` le taux de perte lié à la 1ere étape de transformation, en pourcentage ;
* `p_t2` le taux de perte lié à la 2e étape de transformation, en pourcentage ;
* `I_e` : l'impact environnemental associé à la fabrication du matériaux de l'élément, dans l'unité de la catégorie d'impact analysée par kg ;
* `I_t1` : l'impact environnemental associé à la 1ere étape de transformation du matériaux, dans l'unité de la catégorie d'impact analysée par kg ;
* `I_t2` : l'impact environnemental associé à la 2e étape de transformation du matériaux, dans l'unité de la catégorie d'impact analysée par kg
{% endtab %}

{% tab title="Exemple B : 2 éléments, dont 1 transfo." %}
Méthode de calcul pour un composant constitué de deux éléments `e1` et `e1`, `e1` subissant une transformation `t` :&#x20;

$$
I_{c} =\frac{1}{(1-p_{t})} *m_{e1}*I_{e1} + \frac{1}{(1-p_{t})}*m_{e1}*I_{t1} + m_{e2}*I_{e2}
$$

Avec :&#x20;

* `I_c` : l'impact environnemental du composant modélisé, dans l'unité de la catégorie d'impact analysée
* `m_e1` la masse finale de l'élément `e1` présente dans le composant, exprimée en kg ;
* `m_e2` la masse finale de l'élément `e2` présente dans le composant, exprimée en kg ;
* `p_t` le taux de perte lié à l'étape de transformation du matériaux de l'élément `e1`, en pourcentage ;
* `I_e1` : l'impact environnemental associé à la fabrication du matériaux de l'élément `e1`, dans l'unité de la catégorie d'impact analysée par kg ;
* `I_t` : l'impact environnemental associé à l'étape de transformation du matériaux de l'élément `e1`, dans l'unité de la catégorie d'impact analysée par kg ;
* `I_e2` : l'impact environnemental associé à la fabrication du matériaux de l'élément `e2`, dans l'unité de la catégorie d'impact analysée par kg ;
{% endtab %}

{% tab title="Calcul générique" %}
Formule mathématique exhaustive pour le calcul d'impact environnemental d'un composant constitué de plusieurs éléments `i`, subissant chacun `n` transformations :&#x20;

$$
I_{c} = \sum_{i}\Bigg(\Big(\displaystyle\prod_{j=1}^n\frac{1}{(1-p_{i,j})} \Big)*m_i*I_{i} + \displaystyle\sum_{j=1}^n\Big(\displaystyle\prod_{k=j}^n\frac{1}{(1-p_{i,j})} \Big) *m_i*I_{ti,j}\Bigg)
$$

Avec :&#x20;

* `I_c` : l'impact environnemental du composant modélisé, dans l'unité de la catégorie d'impact analysée
* `m_i` la masse finale de l'élément `i` présente dans le composant, exprimée en kg ;
* `p_i,j` le taux de perte lié à l'étape de transformation `j` de l'élément `i`, en pourcentage ;
* `I_i` : l'impact environnemental associé à la fabrication du matériaux de base de l'élément `i`, dans l'unité de la catégorie d'impact analysée par kg ;
* `I_ti,j` : l'impact environnemental associé à l'étape de transformation `j` de l'élément `i`, dans l'unité de la catégorie d'impact analysée par kg ;
{% endtab %}
{% endtabs %}

{% hint style="info" %}
### Prise en compte du taux de perte <a href="#calcul-des-masses" id="calcul-des-masses"></a>

Dans cette documentation le taux de perte `p` est définit comme suit :&#x20;

$$p=\frac{m_{perte}}{m_{entrante}}$$

Avec :&#x20;

* `m_perte` la quantité de matière perdue lors du procédé de transformation, en kg ;
* `m_entrante`​​​ la quantité de matière avant transformation, en kg.

Pour remonter la chaîne de production, on calcule la quantité de matière _avant_ transformation `m_entrante` à partir de la quantité de matière _après_ transformation `m_sortante` et du taux de perte `p` de l'étape en utilisant cette formule :&#x20;

$$m_{entrante} = \frac{m_{sortante}}{1- p}$$&#x20;
{% endhint %}

{% hint style="info" %}
Pour le bois, l'unité de mesure de la quantité n'est pas la masse (en kg) mais le volume, exprimé en m3.
{% endhint %}

## Procédés utilisés pour le coût environnemental

Les procédés utilisés dans chaque composants (matériaux de l'élément ou procédé de transformation) sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), avec les noms d'affichage indiqué dans le calculateur.

Pour les procédés de transformation, le taux de perte est indiqué dans l'Explorateur.

Pour les procédés de type matériaux, une densité est indiquée le cas échéant dans l'Explorateur.

Pour un éléments donné, seules les procédés de transformations correspondant à la même catégorie de matière sont proposé dans la construction d'un composant.

## Exemple d'application

\[En cours de préparation]

