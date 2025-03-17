# Source des procédés

Le champs `Source`  visible dans l'[explorateur des procédés](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes) indique l'origine des données utilisées pour caractériser un procédé. Cette information est importante pour comprendre la provenance et la fiabilité des données.

\
Ce champs peut faire référence a des bases de données reconnues telles que :&#x20;

* Ecoinvent 3.9.1
* Base Impacts 2.01
* D'autres bases de données d'inventaires de cycle de vie (ICV)

Outre les bases de données standard, certaines sources particulières peuvent apparaître :

### `Ecobalyse`

Lorsque la source indique "Ecobalyse", cela signifie que le procédé a été construit par l'équipe Ecobalyse. Cette création intervient lorsqu'il n'existe pas d'ICV existante satisfaisante dans les bases de données standard.\
La création correspond soit à faire une moyenne d'ICV existantes, soit à effectuer des remplacements d'ICV à l'intérieur d'une ICV. Par exemple créé une farine bio à partir d'une farine conventionnel en remplaçant l'ICV blé conventionnel de la farine conventionnel par du blé bio.

Ces procédés construits sont spécifiés dans le fichier `activities_to_create.json` visible dans le repo [ecobalyse-data](https://github.com/MTES-MCT/ecobalyse-data/tree/main). Exemple de fichier [activities\_to\_create.json](https://github.com/MTES-MCT/ecobalyse-data/blob/main/food/activities_to_create.json) pour food.

### `Custom`

Le procédé est issue d'une création de procédé manuelle à partir d'un travail dans un tableur par un responsable méthode.&#x20;

Pour ces procédés :&#x20;

* Le champs `Commentaire` contient normalement un résumé succint des transformations effectués&#x20;
* ainsi qu'une référence de type `corr#`  (par exemple [`corr1`](https://fabrique-numerique.gitbook.io/ecobalyse/textile/correctifs-donnees/corr1-coton-recycle)) renvoyant à une page de documentation dédiée détaillant les raisons et la méthodologie du correctif appliqué.

