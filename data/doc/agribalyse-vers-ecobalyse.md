Petite synthèse des métadonnées nécessaires pour passer de **Agribalyse** à **Ecobalyse**,
et la façon dont elles sont déterminées.

Variante
========

ce n'est pas une métadonnée en soi, mais un choix de découpage des ingrédients qui vont donner lieu à plusieurs ingrédients : BIO, FR, UE, hors UE, origine inconnue.
Il y a donc un gros travail (de Gabrielle) sur le choix d'un procédé pour chaque ingrédient (choix de la base source, choix de proxy). cf [tableau](https://docs.google.com/spreadsheets/d/1aMHokiyPP2LNC-uJ99xzMREI5Z6vfxOLOiuwGulXujw/edit?gid=1257899740#gid=1257899740)

Groupe de culture
=================

Pour chaque nouvel ingrédient il faut déterminer à quel groupe de culture il appartient (sauf pour les productions animales) :

*   LEGUMES-FLEURS
*   VERGERS
*   RIZ
*   etc.......  cf [tableau](https://docs.google.com/spreadsheets/d/1aMHokiyPP2LNC-uJ99xzMREI5Z6vfxOLOiuwGulXujw/edit?gid=1257899740#gid=1257899740).

Individuellement ça se fait facilement à la main.  Mais dès qu'on commence à avoir un très grand nombre d'ingrédients, dont certains sont dans des bases annexes (WFLDB, GINKO, etc.), on commence à avoir envie de l'automatiser. Car le groupe de culture n'est pas explicitement renseigné dans les bases et doit être déterminé.

Scenario
========

le plus facile :

*   le scenario **reference** pour les productions en France
*   le scenario **organic** pour les produits bio
*   le scenario **import** pour les autres.

C'est utilisé pour le calcul des compléments. (voir tableau ci-dessus)

Origine par défaut
==================

se déduit directement de la variante (qui n'est pas une métadonnée, mais un ingrédient séparé) :

*   FR / BIO → France
*   UE → EuropeAndMaghreb
*   origine inconnue / hors UE → OutOfEuropeAndMaghreb

(Type d'ingrédient)
===================

Ce n'est pas une métadonnée utilisée directement par Ecobalyse, mais une plus élémentaire déterminée pour servir de base aux suivantes (catégorie d'ingrédient, densité, rapport cuit/cru, part non comestible)

*   fruit
*   grain
*   vegetable
*   etc...

(Catégorie NOVA)
================

C'est le groupe NOVA de brut (1) à ultra-transformé (4)
Sert aussi de base à d'autres metadonnées, car il y a des ingrédient transformés dans Agribalyse, et aussi parfois dans les ingrédients bruts d'Ecobalyse (ex : tapioca, fleur de sel).

Catégorie d'ingrédient
======================

Des catégories déterminées pour chaque produit :

*   grain\_raw
*   vegetable\_fresh
*   dairy\_product
*   etc.

Même difficulté que pour les groupes de culture. C'est une nomenclature propre, il faut le déterminer à la main pour chaque ingrédient/produit, ou bien l'automatiser par utilisation du type d'ingrédient et du groupe NOVA.
Une difficulté est que ça mélange le type d'ingrédient et le niveau de transformation.

Transport réfrigéré
===================

Utilisé pour l'impact du transport :

*   aucun
*   toujours
*   après transformation

C'est aussi inféré automatiquement à partir du groupe NOVA et avec des mots-clés (frozen, canned, etc...) et d'autres heuristiques.

Part non comestible
===================

Dans le fichier « Méthodologie Alimentation Annexes\_AGB 3.2.xlsx » de la doc Agribalyse,
il y a un onglet « 3\. Inedible part » et un autre « 4.Fish&seafood inedible & proxy »  qui contiennent des infos, ainsi qu'un lien vers le papier de recherche d'origine.
Ces valeurs sont reportées dans des fichiers de références pour l'automatisation. [Un](https://github.com/MTES-MCT/ecobalyse-method-tooling/blob/main/food/metadata/reference/agb_inedible.csv) qui reprend les valeurs de la doc, et un [autre](https://github.com/MTES-MCT/ecobalyse-method-tooling/blob/main/food/metadata/reference/inedible_part.csv) qui complète avec des valeurs supplémentaires.
Ces valeurs ne sont pas dans les données SimaPro de la base ACV Agribalyse, et ne le sont de toute façon pas quand un proxy est choisi.
Donc pour chaque ingrédient il faut déterminer une valeur, et c'est encore fait de manière automatique en se basant sur les fichiers de référence, et met zéro si c'est un ingrédient transformé.

Densité
=======

Même difficulté et même solution que pour la part non comestible : l'info est en partie dans la doc Agribalyse 3.1, mais pas 3.2 ni dans la base elle-même. La source est [FAO density](https://www.fao.org/fileadmin/templates/food_composition/documents/density_DB_v2_0_01.pdf).
Donc il y a des fichiers de référence : [celui](https://github.com/MTES-MCT/ecobalyse-method-tooling/blob/main/food/metadata/reference/fao_density.csv) issu des infos FAO et [celui](https://github.com/MTES-MCT/ecobalyse-method-tooling/blob/main/food/metadata/reference/density.csv) avec des valeurs additionnelles, ensuite ça marche avec de la similarité sémantique pour retrouver la bonne valeur...

Rapport cuit/cru
================

Même difficulté, il y a un petit tableau dans la doc Agribalyse, et les données proviennent de la base de données CIQUAL.
Donc il y a un [fichier](https://github.com/MTES-MCT/ecobalyse-method-tooling/blob/main/food/metadata/reference/cooked_to_raw.csv) de référence et un autre par type d'ingrédients, puis ça utilise de la proximité sémantique.
