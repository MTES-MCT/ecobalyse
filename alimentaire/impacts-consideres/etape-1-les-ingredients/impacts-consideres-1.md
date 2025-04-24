---
description: >-
  Cette partie traite des opérations "au champ" (fertilisation, labour etc.) et
  s'arrête à la sortie de la ferme. Elle couvre les productions conventionnelles
  et sous label.
---

# 🍒 Ingrédients agricoles - inventaires mobilisés (impacts ACV)

Les impacts de la production des ingrédients agricoles sont issus de la base Agribalyse pour les productions françaises et des bases Ecoinvent et WFLDB pour les produits importés. Malgré la richesse de ces bases, elles sont loin de couvrir l’ensemble des pays de productions et des modes de production. Aussi une logique d'approximation par l'utilisation de proxy doit être mise en œuvre.

S’il est bien sûr souhaitable d’enrichir les bases de données à l’avenir, il est déjà possible de travailler de manière satisfaisante dans la majorité des situations.&#x20;

Les ingrédients sont définis selon la logique suivante, permettant à l’utilisateur de faire un choix clair :

\-          Production FR

\-          Production UE

\-          Production par défaut

\-          Production bio&#x20;



* &#x20;**Pour les productions françaises**, l’inventaire Agribalyse « national average » a été privilégié ; reflétant les conditions de productions standards.

_Ex : "Pomme FR" fait appel à l'ICV "Apple, conventional, national average, at orchard (FR) issue d'Agribalyse_&#x20;



* **Pour les productions européennes**, si un « mix de consommation » française existe dans Agribalyse ; c'est ce mix qui permet de déterminer l'ICV mobilisé pour la variante UE de l'ingrédient. **C'est l'ICV raisonnablement majorant de ce mix qui est retenu, de telle sorte à pénaliser l'absence d'information plus précise à ce stade, et de garantir que renseigner une origine plus précise sera valorisé. En l'absence de mix de consommation dans Agribalyse, l'ICV majorant européen est sélectionné parmi les ICV européens disponibles dans la base de données.**&#x20;

_Ex : Tomate UE = Tomato, fresh grade ES, in unheated greenhouse Ecoinvent._ &#x20;



* **Pour les productions qui ne sont ni françaises, ni européennes**, la variante "par défaut" doit être choisie par l'utilisateur. Elle est basée sur un ICV majorant sélectionné parmi l'ensemble des ICV disponibles dans Agribalyse.

_Ex : Soja par défaut = Soybean, BR (brésil), market for, Ecoinvent_



* **Pour les ingrédients biologiques.** Dans une logique de simplification et au regard du manque de données sur les produits bio, il est considéré que les conditions de productions biologiques sont similaires quelques soit le pays d'origine. Cet hypothèse se justifie en particulier du fait du cahier des charges AB harmonisé au niveau européen, et avec des équivalences internationales solides.&#x20;

Pour définir les ICV bio, nous avons procédé selon cette hiérarchie&#x20;

1. ICV bio directement issus d'Agribalyse (ex : wheat, organic, national average, at farm, agribalyse). Pour les ingrédients AB courants produits en France et les productions animales.
2. ICV AB issus d'un travail d'adaptation à partir des données conventionnelles menée par le cabinet Ginko pour le compte de l'ADEME. Ceci ne concerne que les productions végétales françaises et importées. Ces ICV seront inclus dans des futurs versions d'Agribalyse.&#x20;
3. ICV AB résultants de l'agrégation de différents cas type issus d'Agribalyse. Ceci a été nécessaire pour certaines productions animales, en particulier les ruminants, en l'absence d'autres données. Ces combinaisons ont été réalisées directement par l'équipe Ecobalyse.&#x20;

<mark style="background-color:orange;">Rapport gingko disponible prochainement</mark>

* **Autres labels**

Quelques données sous labels sont déjà disponibles dans Agribalyse et ont pu être intégrées dans ecobalyse, c'est le cas pour les oeufs "Bleu Blanc Coeur" par exemple. Il est tout à fait possible de rajouter dans écobalyse d'autres labels à l'avenir. Pour cela, les porteurs de labels sont invités à se [rapprocher de l'ADEME et des travaux Agribalyse](../../../impacts-consideres.md).&#x20;

{% file src="../../../.gitbook/assets/20221215 ICV bio moyen ecobalyse.xlsx" %}



L’ensemble des appariements entre ingrédients et ICV Agribalyse est visible dans l’explorateur, et en surbrillance dans l’interface ecobalyse.

<img src="../../../.gitbook/assets/image (4) (1).png" alt="" data-size="original">





