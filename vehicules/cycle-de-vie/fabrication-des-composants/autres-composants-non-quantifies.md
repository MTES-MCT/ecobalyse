---
description: >-
  Cette page décrit comment sont modélisés les composants du véhicule non
  traités dans les sections précédentes.
---

# ⛓️ Autres composants, non quantifiés

## Contexte

Un véhicule est composé d'un grand nombre de composants non quantifiable de façon simple, notamment :

* composants électroniques (chargeur, écran, compteur, ...),
* transmissions (courroie, chaine, cardan selon les véhicules) et freins,
* éléments réglementaires et de sécurité (phares, plaques d'immatriculation...)
* direction (volant ou guidon, autres éléments de commande)

Il est difficile de quantifier leur coût environnemental de façon exhaustive et précise, d'une part en raison de la difficulté à en faire un inventaire complet, et d'autre part en raison de la difficulté à modéliser les composants concernés, souvent composés de divers matériaux (métaux, plastiques, électronique).

Un groupe de travail constitué de constructeurs de véhicules intermédiaire a retenu comme hypothèse pour ces véhicules que ces composants sont constitués de 40% d'acier inoxydable, de 30% de plastiques et de 30% de composants électroniques. La même hypothèse est retenue pour les autres véhicules, excepté pour les véhicules non motorisés.

## Méthode de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Ces composants sont modélisés avec trois modules composants dont la somme des masses m\_autre est définie comme la différence entre le poids du véhicule et la somme des poids de l'ensemble des composants quantifiés&#x20;

$$
Impact_j =\Big(Ptot-\sum_{
\begin{subarray}{l}
   i
\end{subarray}}P_i\Big)*ICV_j
$$

Avec :

* I : L'impact environnemental des composants non quantifiés directement, sur la catégorie d'impact j
* Ptot : le poids total du véhicule, en kg
* Pi : le poids des composants quantifiés directement, en kg
* I\_autres-composants : l'impact environnemental pour 1kg du procédé modélisant les autres composants sur la catégorie d'impact j

## Paramètres retenus pour le coût environnemental

### Origine des composants non quantifiés

L'origine des composants non quantifiés directement est définie comme `inconnue` pour le calcul du coût environnemental du transport des composants.

## Procédés utilisés pour le coût environnemental

Un procédé spécifique est modélisé, à partir des procédés Ecoinvent suivants :&#x20;

* Acier inoxydable\
  Procédé Ecobalyse Acier inoxydable\
  0.4kg
* Plastiques\
  Procédé Ecobalyse Plastique PP (polypropylene)\
  0.3kg
* Composants électroniques\
  Procédé Ecoinvent "electronic component production, passive, unspecified, GLO"\
  0.3kg

NB : les éventuelles pertes sont intégrées dans la modélisation des trois procédés utilisés.

###
