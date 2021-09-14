# Methodologie

## Un outil en phase de construction

**Le simulateur et les exemples qui en découlent sont des documents de travail et de réflexion. Ils ne sont pas validés, ni par l'ADEME, ni par le ministère de la Transition écologique.**

## Un outil adossé au référentiel méthodologique ADEME

Les pré-évaluations d'impacts environnementaux proposés par Wikicarbone s'appuient sur [le référentiel établit par l'ADEME](http://www.base-impacts.ademe.fr/) :

- procédés de la base Impacts (R)
- documentation sectorielle textile (`BASE IMPACTS® DATA DOCUMENTATION - SECTOR: TEXTILE - 1.09.208`)
- `METHODOLOGIE D’EVALUATION DES IMPACTS ENVIRONNEMENTAUX DES ARTICLES D’HABILLEMENT` (2016 rev 2017. Principes généraux pour l’affichage environnemental des produits de grande consommation – Partie 23 : méthodologie d’évaluation des impacts environnementaux des articles d’habillement. 47 p.)

Une ouverture à d'autres référentiels, en particulier le [référentiel PEF porté par la Commission Européenne](https://ec.europa.eu/environment/eussd/smgp/pdf/product-environmental-footprint-PEF-methode_fr.pdf), est envisagé, sous réserve d'accessibilité des données sous-jacentes.

## Un outil volontairement très incomplet à ce stade

En première approche, le simulateur est très incomplet :

- il ne couvre pas (encore) les phases d'utilisation et de fin de vie de l'ACV ;
- il n'affiche que les impacts en matière de changement climatique ;
- il ne propose pas toutes les options qui pourraient être mobilisées (choix de pays, de procédés, de traitements supplémentaires de l'étoffe…).

Dans une démarche *agile*, cette première version vise en priorité à recueillir des commentaires et des critiques des utilisateurs, dans le but d'orienter la suite des travaux dans les directions les plus importantes.

Tout retour est d'ailleurs le bienvenu [par email](mailto:pascal.dagras@beta.gouv.fr?Subject=wikicarbone).

## Comment sont faites les hypothèses ?

Pour proposer une pré-évaluation d'impacts très rapide, à partir de quelques critères simples (vêtement, matière, pays de teinture…), il est nécessaire de formuler un certains nombre d'hypothèses, de prendre des valeurs "secondaires" par défaut.

Les hypothèses seront progressivement détaillées, au sein même du simulateur, pour permettre à l'utilisateur de bien comprendre ce qu'il obtient.

Plusieurs types d'hypothèses peuvent être distinguées :

### Les hypothèses correspondant à des données secondaires au semi-spécifiques du référentiel ADEME

Exemples :

- mix électriques moyens de consommation par pays
- taux de perte lors de la confection, par catégorie de vêtement (cf. section c. p28 de la méthodologie ADEME)
- valeurs par défaut des grammages et duitages pour le tissage (cf. section d. p28 de la méthodologie ADEME)
- distance parcourue en camion pour la distribution, de l'entrepôt au point de vente ou de livraison
- …

### Les hypothèses adossées au projet de référentiel européen (PEFCR Apparel & Footwear)

Lorsque certaines hypothèses sont proposées dans le projet de document de référence européen (cf. projet de PEFCR Apparel & Footwear mis en consultation en juillet 2021), elles sont exploitées dans le calculateur. Par exemple :

- Distances de référence entre les différents pays tirés des deux calculateurs proposés dans le projet de PEFCR : [lien 1](https://www.searates.com/services/distances-time/) [lien 2](https://co2.myclimate.org/en/flight_calculators/new/)
- Masses par défaut des différents vêtements (`Table 39 Bill of materials for the apparel representative products with the share (%) of each material based on the average product weight`)
- …

### Les autres hypothèses qui doivent être confrontées à une expertise métier

Pour proposer une pré-évaluation, d'autres hypothèses doivent encore être formulées. Ces hypothèses, par nature réductive, conduise à ce que le résultat ne soit qu'une pré-évaluation, et non une évaluation à proprement parler.

Quelques exemples :

- Choix du tissage ou du tricotage pour chaque type de vêtement
- Technologie de teinture (sur étoffe par défaut) et caractéristique du procédé retenu en fonction de pays (plutôt représentatif ? plutôt majorant ?)…
- Source d'énergie utilisée pour la production de chaleur, en fonction du pays.
- Répartition des modes de transport entre deux pays. Pour le transport en avion, il est considéré par défaut qu'il ne peut concerner que le transport de produits finis / confectionnés et uniquement en provenance de pays hors Europe et Afrique du Nord. On retient par défaut une part de 30%, qui apparaît cohérente au regard des circuits géographiques introduits dans la méthodologie ADEME (cf. annexe A informative)
- …

L'intérêt de l'outil repose notamment sur la pertinence de ces hypothèses supplémentaires. Dans quelle mesure sont elles représentatives, ou majorantes, par rapport aux pratiques observées dans l'industrie (pour les phases de production et de fabrication) ?

Dans une logique de commun numérique, Wikicarbone cherche notamment à servir de support aux échanges technique qui permettraient de faire émerger des hypothèses par défaut pertinentes. En première approche, les remarques sont simplement collectées [par mail](mailto:pascal.dagras@beta.gouv.fr?Subject=wikicarbone). Des évolutions sont envisagées pour la suite pour chercher à recueillir les contributions directement sur l'outil.
