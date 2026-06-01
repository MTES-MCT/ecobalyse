---
description: Cette page décrit le calcul du coût environnemental de la batterie.
---

# 🔋 Batterie

## Contexte

La batterie représente 10% à 50% du coût environnemental d'un véhicule électrique. Ce chiffre varie principalement en fonction de l'autonomie recherchée pour le véhicule (capacité de la batterie), et du poids du véhicule.&#x20;

L'impact environnemental de la batterie dépend également de sa technologie : NMC811, LFP sont les deux principales technologies utilisées aujourd'hui.

Enfin, les sites et méthodes à chaque étape de fabrication ont également une réelle influence sur le coût environnemental.

L'ADEME a construit un modèle de calcul basé sur les Données GREET permettant de réaliser un inventaire détaillé du cycle de vie de la batterie, en fonction de la chimie et des lieux de production à chaque étape. Ce travail est utilisé dans Ecobalyse pour modéliser des batteries.

## Méthodes de calcul

La batterie est modélisée comme un composant (voir [page générique](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses-specifiques/composants)), constitué de cellules et d'autres éléments d'assemblage.

* Plusieurs procédés permettent de modéliser une variété de cellules de batteries représentatives du marché, en fonction de leur poids (voir section Procédés)
* Un procédé de transformation "Assemblage batterie" doit être ajouté aux cellules pour prendre en compte les opérations d'assemblage. Ce procédé est appliqué aux cellules uniquement pour permettre une facilité d'utilisation tout en s'intégrant dans la méthode de calcul générique d'Ecobalyse
* Divers procédés permettent de modéliser les différents matériaux utilisés dans la fabrication de batterie

L'outil XLS suivant permet de construire les composants batteries&#x20;

## Procédés utilisés pour le coût environnemental

Les cellules suivantes sont modélisées :&#x20;

* LFP hydrothermal, CN
* LFP Solid State, CN
* NMC811, CN
* NMC811, FR<br>

<figure><img src="../../../.gitbook/assets/image (392).png" alt=""><figcaption></figcaption></figure>



Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).
