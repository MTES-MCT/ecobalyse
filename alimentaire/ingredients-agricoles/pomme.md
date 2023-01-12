# 🍏 Pomme

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), la pomme est modélisée à travers les procédés suivants :&#x20;

| Label / Origine        | France                                                                   | Autres pays                                                              |
| ---------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| Conventionnelle        | 'Apple, conventional, national average, at orchard' (kilogram, FR, None) | 'Apple, conventional, national average, at orchard' (kilogram, FR, None) |
| Agriculture biologique | 'Apple, organic, national average, at orchard' (kilogram, FR, None)      | 'Apple, organic, national average, at orchard' (kilogram, FR, None)      |

Les procédés retenus sont des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer 14 inventaires de cycle de vie pour la carotte.&#x20;

L'analyse comparée des impacts donne :&#x20;

{% hint style="info" %}
**Axes de progrès ?**

Les données ICV disponibles dans Agribalyse permettraient potentiellement d'introduire une distinction suivant :&#x20;

* L'origine géographique par région française (Aquitaine, Basse Normandie...)
* La saisonnalité (early, fall, main season, winter)
{% endhint %}

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => transport par défaut : _160 km de camion ?_
2. Ingrédient très majoritairement produit en Europe/_pourtour méditerranéen_ (>95%) => transport par défaut : _2500 km en camion ?_
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : _18 000 km en bateau ?_
4. Ingrédient spécifique (ex. Haricots et Mangues) => transport par défaut : _y km en avion_

**Pomme => catégorie 2** (source : Agreste, Synthèses et conjoncture n°370, AVRIL 2021) ****&#x20;

