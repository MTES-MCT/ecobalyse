# 📚 Source des procédés

Le champs `Source` visible dans l'[explorateur des procédés](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) indique l'origine des données utilisées pour caractériser un procédé. Cette information est importante pour comprendre la provenance et la fiabilité des données.

\
Ce champs peut faire référence a des bases de données reconnues telles que :

* BAFU 2025v2 (prochainement remplacé par BAFU:2026v2)
* Ecoinvent 3.9.1 (pour les méthodes réglementaires textile et des ingrédients alimentaires)
* Agribalyse 3.1
* Base Impacts 2.01
* D'autres bases de données d'inventaires de cycle de vie (ICV)

Outre ces bases de données standards, certaines sources spécifiques peuvent apparaître :

### `Ecobalyse_custom_lci`

Lorsque la source indique `Ecobalyse_custom_lci`, cela signifie que le procédé a été construit par l'équipe Ecobalyse à partir d'ICV existants dans des bases de données standards. Cette création intervient lorsqu'il n'existe pas d'ICV existante satisfaisante dans les bases de données standards.

Ces procédés construits sont spécifiés dans le fichier `custom_lci.json` visible dans le repo ecobalyse [custom\_lci.json](https://github.com/MTES-MCT/ecobalyse/blob/master/data/custom_lci.json).

\
Plusieurs cas de figure conduisent à construire un procédé :

* Absence d'un **procédé moyen** dans les bases de données ⇒ construction d'un procédé résultant de la moyenne pondérée de plusieurs procédés disponibles dans les bases de données. C'est le cas par exemple de certains procédés d'ingrédients bio proposés dans l'outil :

{% file src="../.gitbook/assets/20221215 ICV bio moyen (1)-8.xlsx" %}

* Nécessité de créer **plusieurs variantes d'un produit**&#x20;
  * **Principal usage : créer des variantes d'ingrédients "transformés"** (viandes ou ingrédients industriels) à partir de différents inventaires "sortie de ferme" ⇒ remplacement d'un ICV par un autre à l'intérieur d'un procédé.\
    Exemple : en plus de la Farine FR, plusieurs variantes de farines (Farine bio, Farine UE, Farine par défaut) sont créées à partir :
    * de la farine Agribalyse (Farine FR)
    * des 3 blés tendres 'sortie de ferme' disponibles dans Agribalyse (blé tendre bio, blé tendre UE, blé tendre par défaut)
* Nécessité d'adapter les ICV de bases de données pour permettre leur usage dans Ecobalyse :&#x20;
  * Correction de la gestion des pertes
  * Inventaire par kg de produit transformé pour les ICV de transformation ou finition
  * Inventaire par unité d'utilisation
* Nécessité de créer un **procédé manuellement** à partir d'un travail réalisé par un responsable méthode :&#x20;
  * batteries li-ion détaillés par chimie et origine
  * consommation de carburant (inventaire amont+aval)

### `Ecobalyse_manual_lcia`

Lorsque la source indique `Ecobalyse_custom_lci`, cela signifie que le procédé a été construit par l'équipe Ecobalyse en fournissant directement les impacts du cycle de vie (AICV) par indicateur d'impact.&#x20;

Les procédés concernés contenant des impacts sont progressivement remplacés par des procédés issus de bases de données ou construits avec traçabilité.

Cette méthode est également utilisée pour construire des procédés auxquels aucun ICV n'est rataché et donc l'impact est nul en-dehors de la consommation d'énergie (electricité et chaleur, voir [Modélisation de la consommation d'énergie](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-tous-secteurs/modelisation-de-la-consommation-denergie))

Pour les procédés contenant des données d'impacts :

* Le champs `Commentaire` contient normalement un résumé succinct des transformations effectuées
* ainsi qu'une référence de type `corr#` (par exemple [`corr1`](https://fabrique-numerique.gitbook.io/ecobalyse/textile/correctifs-donnees/corr1-coton-recycle)) renvoyant à une page de documentation dédiée détaillant les raisons et la méthodologie du correctif appliqué.
