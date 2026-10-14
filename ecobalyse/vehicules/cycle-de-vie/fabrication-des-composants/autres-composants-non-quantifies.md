---
description: >-
  Cette page décrit comment sont modélisés les composants du véhicule non
  quantifiables.
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

Ces composants sont modélisés avec un composant constitué de trois éléments :&#x20;

* `Acier inoxydable` + `Lamination` + `Usinage, emboutissage`, de masse `m_autres,métaux`
* `Plastiques divers, granulé` + `moulage par injection`, de masse `m_autres,plastiques`
* `Composants électronique`, de masse `m_autres,électronique`

dont la somme des masses `m_autre` est définie comme la différence entre le poids réel du véhicule et la somme des poids de l'ensemble des composants quantifiés.

$$
m_{autres,métaux} =R_{metaux}*m_{autres}
$$

$$
m_{autres,plastiques} =R_{plastiques}*m_{autres}
$$

$$
m_{autres,electronique} =R_{electronique}*m_{autres}
$$

Avec `R_metaux`, `R_plastiques` et `R_electronique` les ratios de métaux, de plastiques et d'électronique supposés parmi les composants non quantifiés.

## Paramètres retenus pour le coût environnemental

### Ratios de métaux, de plastiques et d'électronique

* `R_metaux` = 0.4,
* `R_plastiques` = 0.3,
* `R_electronique` = 0.3.

### Origine des composants non quantifiés

L'origine des composants non quantifiés directement est définie comme `inconnue` pour le calcul du coût environnemental du transport des composants.

## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de composants et l'Explorateur de procédés](https://ecobalyse.beta.gouv.fr/#/explore/veli/veli-components).

