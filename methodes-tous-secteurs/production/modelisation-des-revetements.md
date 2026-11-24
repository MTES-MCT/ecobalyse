---
icon: layer-plus
---

# Modélisation des revêtements

## Contexte

Les revêtements correspondent à un ajout de matière en surface d'un matériau pour y apporter des propriétés spécifiques. L'ajout de matière est de l'ordre de plusieurs dizaines de micromètre (µm), et représente une faible quantité par rapport aux matériaux sur lequel il est appliqué.

Il n'y a pas de modélisation spécifique aux revêtements dans Ecobalyse. Dans les bases de données, des inventaires par m² de revêtement sont souvent fournis, cependant ces données ne sont pas exploitables en l'état dans Ecobalyse.

Ecobalyse permet d'ajouter les données ou bien comme procédé matière ("Matière première") ou bien comme procédé de transformation ("Transformation"), voir [Page Production des matériaux](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-tous-secteurs/production).

Deux méthodes sont possibles pour modéliser un revêtement :&#x20;

* Méthode 1 : Modélisation du revêtement comme procédé de transformation, ce qui implique de ramener le revêtement à un procédé dont l'unité est le kg de matériau revêtu. Cette méthode a l'avantage d'être simple d'implémentation pour l'utilisateur, mais implique une densité et une épaisseur de matériau définis.
* Méthode 2 : Modélisation du revêtement comme procédé matière et donc de construire des matériaux avec deux éléments (sous-matériaux), le matériaux revêtu et le revêtement. Cette méthode permet à l'utilisateur de personnaliser la quantité de revêtement, et de modéliser des situations qui ne sont pas standards (épaisseur et densité fixes).

En fonction des situations, l'une ou l'autre des méthode sera préférable.

## Méthodes de calcul

### Méthode 1 : modélisation comme procédé de transformation

Le processus de traitement des données est le suivant :&#x20;

1. Les consommations d'énergie sont séparées de l'inventaire BAFU:20XY, dans [`custom_lci`](https://github.com/MTES-MCT/ecobalyse/blob/main/data/custom_lci.json)
2. Les inventaires sont convertis pour être calculés par kg de matériau revêtu, dans [`custom_lci`](https://github.com/MTES-MCT/ecobalyse/blob/main/data/custom_lci.json)
   * Plusieurs inventaires par revêtement peuvent être proposés, par exemple pour proposer un revêtement à 1 couche ou 2 couches
3. Le procédé de transformation est créé dans [`lci_catalog/ecobalyse_custom_lci`](https://github.com/MTES-MCT/ecobalyse/tree/main/data/lci_catalog/ecobalyse_custom_lci) à partir de l'inventaire modifié
   * Les consommations d'énergie sont ré-implémentées à ce stade
   * Une variation de la quantité de matière est paramétrée pour modéliser la bonne quantité de matériaux avant revêtement pour 1kg de matériaux revêtu
   * Un material\_type est associé pour que la transformation soit disponible pour les bons matériaux

### Méthode 2 : modélisation comme procédé Matière

1. Les consommations d'énergie sont séparées de l'inventaire BAFU:20XY, dans [`custom_lci`](https://github.com/MTES-MCT/ecobalyse/blob/main/data/custom_lci.json)
2. Le revêtement est ajouté comme matière première dans [`lci_catalog/ecobalyse_custom_lci`](https://github.com/MTES-MCT/ecobalyse/tree/main/data/lci_catalog/ecobalyse_custom_lci)
3. Un procédé de transformation du revêtement est créée dans [`lci_catalog/ecobalyse_manual_lcia`](https://github.com/MTES-MCT/ecobalyse/tree/main/data/lci_catalog/ecobalyse_manual_lcia) :&#x20;
   * Les consommations d'énergie sont ré-implémentées à ce stade
   * Une variation de la quantité de matière est paramétrée pour modéliser la bonne quantité de revêtement et prendre en compte les pertes
   * Un material\_type est associé pour que la transformation soit disponible pour le nouveau procédé correspondant au revêtement
4. Un matériau est modélisé dans [`component.json`](https://github.com/MTES-MCT/ecobalyse/blob/main/public/data/object/components.json) avec les bonnes quantités de matériaux à revetir et de revêtement respectivement, avec le procédé de transformation du revêtement attaché à ce dernier.&#x20;

## Procédés utilisés pour le coût environnemental

Les procédés de revêtement utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).

## Exemple d'application

La calculette suivante permet de retrouver les calculs et une partie des exemples fournis dans Ecobalyse.

Elle peut également aider à la création d'un matériaux adapté au besoin de l'utilisateur.

{% file src="../../.gitbook/assets/Calculette Revetements.xlsx" %}

