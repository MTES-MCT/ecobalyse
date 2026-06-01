# 🧩 Composants

## Contexte

La plupart des produits consistent en un assemblage de composants, eux mêmes constitués de plusieurs éléments (un élément étant une matière transformée).

Dans une logique de déploiement à grande échelle du calcul du coût environnemental, un module Composant a été développé. Ce dernier permet de modéliser un grand nombre de produits grâce à la création de un ou plusieurs composants. \
Chaque composant est créé à partir d'une liste de matériaux (ex : acier, plastique, bois, etc.) et de procédés de transformation associés (ex : sciage de grumes de bois, moulage plastique, etc.).

Les cas d'usages sont nombreux; voici quelques exemples :&#x20;

* boutons d'un vêtement (composant avec des paramètres imposés pour l'affichage réglementaire)
* pied de chaise
* pneu d'une voiture
* ampoule d'une lampe

{% tabs %}
{% tab title="Composants d'un produit" %}
<figure><img src="../../.gitbook/assets/image (382).png" alt=""><figcaption></figcaption></figure>

Un ou plusieurs composants peuvent être modélisés (3 dans l'exemple ci-dessus).&#x20;

Un composant peut être présent en une ou plusieurs unités (ex : 2 tissus dans un canapé, 4 pieds de chaise, 4 pneus de voiture, etc.).

Chaque composant est constitué d'au moins une matière transformée (cf. "_Focus Elément_")
{% endtab %}

{% tab title="Détail d'un composant" %}
<figure><img src="../../.gitbook/assets/image (383).png" alt=""><figcaption></figcaption></figure>

Chaque composant est constitué d'au moins un élément. Un élément correspond à une matière qui peut être transformée.&#x20;

Dans l'exemple ci-dessus, la structure acier du canapé est constituée d'un seul élément (de l'acier sur lequel est appliqué un procédé de transformation).&#x20;
{% endtab %}
{% endtabs %}

## Méthode de calcul

### Grands principes

Un composant est constitué d'un ou plusieurs éléments, chaque élément correspondant à un matériaux pouvant subir une ou des transformations.

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

<figure><img src="../../.gitbook/assets/image (1) (1) (1) (1) (1) (1) (1).png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
### Prise en compte du taux de perte <a href="#calcul-des-masses" id="calcul-des-masses"></a>

Dans Ecobalyse le taux de perte `p` est définit comme suit :&#x20;

$$p=\frac{m_{perte}}{m_{entrante}}$$

Avec :&#x20;

* `m_perte` la quantité de matière perdue lors du procédé de transformation, en kg ;
* `m_entrante`​​​ la quantité de matière avant transformation, en kg.

Pour remonter la chaîne de production, on calcule la quantité de matière _avant_ transformation `m_entrante` à partir de la quantité de matière _après_ transformation `m_sortante` et du taux de perte `p` de l'étape en utilisant cette formule :&#x20;

$$m_{entrante} = \frac{m_{sortante}}{1- p}$$&#x20;
{% endhint %}

### Calculs schématisés

L'impact environnemental d'un composant est la somme des impacts de ses éléments. L'impact d'un élément est l'impact du matériau correspondant plus la somme des impacts éventuels des transformations de ce matériau. L'impact est la multiplication de la quantité (en général, masse en kg) par l'impact unitaire (en général, en Pt par kg)

<figure><img src="../../.gitbook/assets/image (5) (1).png" alt="" width="375"><figcaption></figcaption></figure>

La masse de matériaux nécessaire à la fabrication d'un élément est calculée en remontant le calcul suivant :&#x20;

<figure><img src="../../.gitbook/assets/image (3) (1).png" alt="" width="318"><figcaption></figcaption></figure>

Avec `p_i,j` le taux de perte lié à l'étape de transformation `j` de l'élément `i`, en pourcentage&#x20;

{% hint style="info" %}
### Prise en compte du taux de perte <a href="#calcul-des-masses" id="calcul-des-masses"></a>

Dans Ecobalyse le taux de perte `p` est définit comme suit :&#x20;

$$p=\frac{m_{perte}}{m_{entrante}}$$

Avec :&#x20;

* `m_perte` la quantité de matière perdue lors du procédé de transformation, en kg ;
* `m_entrante`​​​ la quantité de matière avant transformation, en kg.

Pour remonter la chaîne de production, on calcule la quantité de matière _avant_ transformation `m_entrante` à partir de la quantité de matière _après_ transformation `m_sortante` et du taux de perte `p` de l'étape en utilisant cette formule :&#x20;

$$m_{entrante} = \frac{m_{sortante}}{1- p}$$&#x20;
{% endhint %}

### Formules de calcul détaillées

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
Méthode de calcul pour un composant constitué de deux éléments `e1` et `e2`, `e1` subissant une transformation `t` :&#x20;

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

