---
description: >-
  Cette partie traite des opérations "au champ" (fertilisation, labour etc.) et
  s'arrête à la sortie de la ferme. Elle couvre les productions conventionnelles
  et sous label.
---

# 🍒 Ingrédients agricoles - inventaires mobilisés (impacts ACV)

Les impacts de la production des ingrédients agricoles sont issus de la base Agribalyse pour les productions françaises et des bases ecoinvent et WFLDB pour les produits importés. Malgré la richesse de ces bases, elles sont loin de couvrir l’ensemble des pays de productions et des modes de production. Aussi une logique d'approximation par l'utilisation de proxy doit être mise en œuvre.

S’il est bien sûr souhaitable d’enrichir les bases de données à l’avenir, il est déjà possible de travailler de manière satisfaisante dans la majorité des situations. En effet, le critère géographique n’est pas forcément très discriminant pour l’étape agricole :  par exemple une tomate produite dans le sud de la France ne diffère pas fortement d’une tomate produite dans le nord de l’Espagne ou de l’Italie.

Les ingrédients sont définis selon l’arborescence suivante, permettant à l’utilisateur de faire un choix clair :

\-          Production conventionnelle FR,

\-          Production conventionnelle UE

\-          Production conventionnelle import hors UE

\-          Production bio, FR/UE/hors UE

* &#x20;**Pour les productions françaises**, l’inventaires Agribalyse « national average » a été privilégié ; reflétant les conditions de productions standards.

_Ex : "Pomme FR Conv" fait appel à l'ICV "Apple, conventional, national average, at orchard (FR) issue d'Agribalyse_&#x20;

_Dans les cas ou il n'y a pas d'inventaire francais disponible (ex : amande), le principal pays d'import est utilisé comme proxy pour la production francaise (amande US, at farm)_

* **Pour les productions européennes**, nous sommes repartis des « mix de consommation » français construits pour Agribalyse ; et qui reflètent les principaux produits importés. Parmi les principaux pays d'importations (identifié selon ces mix), nous avons retenu l'ICV du produit "import hors europe" la moins favorable. Ainsi, par défaut, les ingrédients UE correspondent à des produits courants sur le marché Français.

_Ex: Tomate, UE conv = Tomato, fresh grade ES, in unheated greenhouse Ecoinvent._&#x20;

Lorsque nous n’avons pas d’ICV disponible pour les pays européens, nous avons conservé l’ICV France. C’est le cas pour la pomme par exemple. &#x20;

_Ex : Pomme UE = Apple, national average FR_

* **Pour les imports « hors europe** », la même logique a été appliquée que pour les importations européennes. Parmi les principaux pays d'importations (identifiés selon les "consumptions mix" d'Agribalyse), l'ICV du produit "import hors europe" le moins favorable a été retenu.

_Ex : Soja Hors UE Conv  = Soybean, BR (brésil), market for, Ecoinvent_

* **Produits biologiques, FR, UE et hors UE**

Dans une logique de simplification et au regard du manque de données sur les produits bio, il est considéré que les conditions de productions biologiques sont similaires quelques soit le pays d'origine. Cet hypothèse se justifie en particulier du fait du cahier des charges AB harmonisé au niveau européen, et avec des équivalences internationales solides.&#x20;

Pour définir les ICV bio, nous avons procédé selon cette hiérarchie&#x20;

1. ICV AB directement issu d'Agribalyse (ex: wheat, organic, national average, at farm, agribalyse). Pour les ingrédients AB courants produits en France et les productions animales.
2. ICV AB issus d'un travail d'adaptation à partir des données conventionnelles menée par Ginko pour le compte de l'ADEME. Ceci ne concerne que les productions végétales françaises et importées. Ces ICV seront inclut dans des futurs versions d'Agribalyse.&#x20;
3. ICV AB résultants de l'agrégation de différents cas type issus d'Agribalyse.  Ceci a été nécessaire pour certaines productions animales, en particulier les ruminants, en l'absence d'autres données. Ces combinaisons ont été réalisées directement par l'équipe Agribalyse.&#x20;

<mark style="background-color:orange;">Rapport gingko disponible prochainement</mark>

* **Autres labels**

Quelques données sous labels sont déjà disponibles dans Agribalyse et ont pu être intégrées dans ecobalyse, c'est le cas pour les oeufs "Bleu Blanc Coeur" par exemple. Il est tout à fait possible de rajouter dans écobalyse d'autres labels à l'avenir. Pour cela, les porteurs de labels sont invités à se [rapprocher de l'ADEME et des travaux Agribalyse](../../../impacts-consideres/).&#x20;

{% file src="../../../.gitbook/assets/20221215 ICV bio moyen ecobalyse.xlsx" %}



L’ensemble des appariements entre ingrédients et ICV Agribalyse est visible dans l’explorateur, et en surbrillance dans l’interface ecobalyse.

<img src="../../../.gitbook/assets/image (4) (1).png" alt="" data-size="original">





