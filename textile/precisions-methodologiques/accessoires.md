# 🤐 Accessoires

Un article textile est essentiellement constitué de matières textiles résultant d'un processus agricole et industriel complet introduit dans les pages suivantes : matière, fabrication du fil, fabrication de l'étoffe, ennoblissement, confection.

Néanmoins, certains articles sont également composés d'accessoires. Il peut s'agir de boutons, de fermetures éclaires, de pièces rigides sur un soutien gorge...

Dans la mesure où ces accessoires représentent généralement une part minoritaire (voire minime) de la masse et de l'impact du produit fini, leur modélisation dans Ecobalyse est simplifiée. Ainsi, il est simplement demandé à l'utilisateur qu'il liste les accessoires présents sur son vêtement, sans possibilité de paramétrage plus précis (masse, origine, précisions sur la matière).

Quelques remarques complémentaires :&#x20;

* Il est possible, et même parfois nécessaire, de sélectionner plusieurs fois un même accessoire. Pour une chemise, 10 boutons plastiques peuvent par exemple être sélectionnés.
* &#x20;Pour les utilisateurs qui souhaiteraient modéliser de manière plus fine les accessoires, des travaux complémentaires peuvent être proposé en se projetant vers un niveau de calcul plus précis ("niveau 2"). cf. échanges en cours sur la [communauté Ecobalyse](https://fabrique-numerique.gitbook.io/ecobalyse/communaute).
* En l'absence de précision, des hypothèses plutôt pénalisantes sont retenues. Ainsi, les accessoires métaliques (boutton, zip) sont modélisés avec du laiton, un métal plus impactant que l'acier par exemple.

### Liste des accessoires proposés

La liste des accessoires proposés est accessible dans l'explorateur d'Ecobalyse, rubrique composants _**\[lien à ajouter après la mise en ligne]**_.

La première liste, introduite en janvier 2025, est reprise ci-après (rq : la liste de l'explorateur est bien la source principale de donnée à considérer).

| Nom                 | Masse    | Matière | ICV mobilisé                                                                   |
| ------------------- | -------- | ------- | ------------------------------------------------------------------------------ |
| Bouton en plastique | 0,001 kg | PET     | Ecoinvent - Polyethylene terephthalate production, granulate, amorphous \[RoW] |
| Bouton en métal     | 0,003 kg | Laiton  | Ecoinvent - brass//\[RoW] market for brass                                     |
| Zip court           | 0,01 kg  | Laiton  | Ecoinvent - brass//\[RoW] market for brass                                     |
| Zip long            | 0,05 kg  | Laiton  | Ecoinvent - brass//\[RoW] market for brass                                     |

### Perspectives

* Ajout de nouveaux composants / accessoires, afin notamment de pouvoir modéliser de nouveaux types de vêtements, par exemple des soutien gorges
* Association d'une liste de composants par défaut à chaque type de vêtement (ex : 1 jean ⇒ par défaut 1 zip court et 2 boutons en métal)
