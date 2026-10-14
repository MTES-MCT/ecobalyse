# 📚 Source des procédés

Le champs `Source`  visible dans l'[explorateur des procédés](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) indique l'origine des données utilisées pour caractériser un procédé. Cette information est importante pour comprendre la provenance et la fiabilité des données.

\
Ce champs peut faire référence a des bases de données reconnues telles que :&#x20;

* Ecoinvent 3.9.1
* Agribalyse 3.1
* Base Impacts 2.01
* D'autres bases de données d'inventaires de cycle de vie (ICV)

Outre les bases de données standards, certaines sources particulières peuvent apparaître :

### `Ecobalyse_custom_lci`

Lorsque la source indique `Ecobalyse_custom_lci`, cela signifie que le procédé a été construit par l'équipe Ecobalyse. Cette création intervient lorsqu'il n'existe pas d'ICV existante satisfaisante dans les bases de données standard.

Ces procédés construits sont spécifiés dans le fichier `custom_lci.json` visible dans le repo ecobalyse [custom\_lci.json](https://github.com/MTES-MCT/ecobalyse/blob/master/data/custom_lci.json).

\
Plusieurs cas de figure conduisent à construire un procédé :&#x20;

* Absence d'un **procédé moyen** dans les bases de données ⇒ construction d'un procédé résultant de la moyenne pondérée de plusieurs procédés disponibles dans les bases de données. C'est le cas par exemple de certains procédés d'ingrédients bio proposés dans l'outil :&#x20;

{% file src="../.gitbook/assets/20221215 ICV bio moyen ecobalyse (2).xlsx" %}

* Nécessité de créer **plusieurs variantes d'ingrédients "transformés"** (viandes ou ingrédients industriels) à partir de différents inventaires "sortie de ferme" ⇒ remplacement d'un ICV par un autre à l'intérieur d'un procédé.&#x20;

Exemple : plusieurs variantes de farines sont créées à partir :

. de la farine Agribalyse (Farine FR)

. des 3 blés tendres 'sortie de ferme' disponibles dans Agribalyse (blé tendre bio, blé tendre UE, blé tendre par défaut)&#x20;

\= en plus de la Farine FR, on obtient ainsi 3 farines supplémentaires : Farine bio, Farine UE, Farine par défaut&#x20;



* Nécessité de créer un **procédé manuellement** à partir d'un travail réalisé par un responsable méthode.&#x20;

### `Ecobalyse_manual_lcia`

Pour ces procédés :&#x20;

* Le champs `Commentaire` contient normalement un résumé succinct des transformations effectuées&#x20;
* ainsi qu'une référence de type `corr#`  (par exemple [`corr1`](https://fabrique-numerique.gitbook.io/ecobalyse/textile/correctifs-donnees/corr1-coton-recycle)) renvoyant à une page de documentation dédiée détaillant les raisons et la méthodologie du correctif appliqué.

