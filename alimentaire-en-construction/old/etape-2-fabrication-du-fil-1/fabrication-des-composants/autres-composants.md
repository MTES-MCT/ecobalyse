---
description: >-
  Cette page décrit comment sont modélisés les composants du véhicule non
  traités dans les sections précédentes.
---

# ⛓️ Autres composants

## Généralités

Un véhicule est composé d'un grand nombre de composants supplémentaires non quantifiés directement dans Ecobalyse, notamment :

* composants électroniques (chargeur, écran, compteur, ...),
* transmission (courroie, chaine, cardan selon les véhicules) et freins,
* éléments réglementaires et de sécurité (phares, plaques d'immatriculation...)
* direction (volant ou guidon, autres éléments de commande)

Il est difficile de quantifier leur coût environnemental de façon exhaustive et précise, d'une part en raison de la difficulté à en faire un inventaire complet, et d'autre part en raison de la difficulté à modéliser les composants concernés, souvent composés de divers matériaux (métaux, plastique, électronique).

Le groupe de travail constitué de constructeurs de véhicules intermédiaire a retenu comme hypothèse que ces composants sont composés de 40% d'acier inoxydable, de 30% de plastiques et de 30% de composants électroniques.

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental de ces composants est calculé de la façon suivante :&#x20;

$$
Impact_j =\Big(Ptot-\sum_{
\begin{subarray}{l}
   i
\end{subarray}}P_i\Big)*ICV_j
$$

Avec :

* Impact\_j : L'impact environnemental des composants non quantifiés directement, sur la catégorie d'impact j
* Ptot : le poids total du véhicule, en kg
* Pi : le poids des composants quantifiés directement, en kg
* ICV\_j : l'impact environnemental pour 1kg du procédé modélisant les autres composants sur la catégorie d'impact j

### Procédé utilisé

Un procédé spécifique est modélisé, à partir des procédés Ecoinvent suivants :&#x20;

* Acier inoxydable\
  Procédé Ecobalyse Acier inoxydable\
  0.4kg
* Plastiques\
  Procédé Ecobalyse Plastique PP\
  0.3kg
* Composants électroniques\
  Procédé Ecoinvent "electronic component production, passive, unspecified, GLO"\
  0.3kg

NB : les éventuelles pertes sont intégrées dans la modélisation des trois procédés utilisés.

### Origine des composants non quantifiés

L'origine des composants non quantifiés directement est définie comme inconnue.
