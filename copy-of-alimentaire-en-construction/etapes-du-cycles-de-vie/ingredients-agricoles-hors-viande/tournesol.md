# 🌻 Tournesol

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), **le tournesol** est modélisée à travers les procédés suivants :&#x20;

| Label / Origine             | France                                             | Autres pays                                                  |
| --------------------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| Agriculture conventionnelle | Sunflower, at farm (WFLDB 3.1)/FR U                | <p>A venir : </p><p>Sunflower, at farm (WFLDB 3.1)/GLO U</p> |
| Agriculture biologique      | Sunflower grain, organic, system n°3, at farm gate | Sunflower grain, organic, system n°3, at farm gate           |

Les procédés retenus sont prioritairement des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

{% hint style="danger" %}
**XXX**
{% endhint %}

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer les inventaires de cycle de vie suivants.&#x20;

* **14 procédés** France "at farm" :&#x20;
  * Sunflower grain, average from 2 optimized case study, basis scenario, at farm gate
  * Sunflower grain, average from 2 optimized case study, protein crop scenario, at farm gate
  * Sunflower grain, average from 2 optimized case study, systematic covercropping scenario, at farm gate
  * ~~Sunflower grain, conventional, 9% moisture, national average, animal feed, at farm gate, production~~
  * ~~Sunflower grain, conventional, national average, animal feed, at farm gate~~
  * Sunflower grain, organic, Gers, at farm gate
  * Sunflower grain, organic, PaysDeLaLoire, at farm gate
  * Sunflower grain, organic, system n°1, at farm gate
  * Sunflower grain, organic, system n°2, at farm gate
  * Sunflower grain, organic, system n°3, at farm gate
  * Sunflower grain, organic, system n°4, at farm gate
  * Sunflower grain, organic, system n°5, at farm gate
  * ~~Sunflower, organic, animal feed, at farm gate~~
  * ~~Sunflower grain, conventional, national average, animal feed, at storage agency/ UA U~~
* Dont 3 moyennes nationales France dont la construction est explicitée dans le schéma ci-après
  * ~~Sunflower grain, conventional, 9% moisture, national average, animal feed, at farm gate, production~~
  * ~~Sunflower grain, conventional, national average, animal feed, at farm gate~~
  * ~~Sunflower grain, conventional, national average, animal feed, at storage agency/ UA U~~
* 5 procédés à préciser :
  * Sunflower, at farm (WFLDB 3.1)
  * Sunflower, at farm (WFLDB 3.1)
  * Sunflower, at farm (WFLDB 3.1)
  * Sunflower, at farm (WFLDB 3.1)
  * Sunflower, at farm (WFLDB 3.1)

{% hint style="info" %}
**Le procédé mobilisé pour l'ingrédient tournesol "at farm" est le procédé mobilisé pour la fabrication de l**[**'huile de tournesol**](../../../alimentaire/etapes-du-cycles-de-vie/ingredients-industrie/huile-de-tournesol.md) **(cf. graphe ci-dessous)**

En effet, le choix est fait d'exclure directement les procédés concernant le tournesol destiné à l'alimentation animale (dans un premier temps - niveau 1 de calcul - sont uniquement considérés les procédés susceptibles d'entrer directement dans la fabrication de produits alimentaires). De plus, le tournesol en tant qu'ingrédient intervient majoritairement pour la production d'huile.&#x20;
{% endhint %}

Le tournesol bio est déterminé par l'analyse des procédés bio présents dans Agribalyse listés ci-dessous :

* Sunflower grain, organic, Gers, at farm gate&#x20;
* Sunflower grain, organic, PaysDeLaLoire, at farm gate
* Sunflower grain, organic, system n°1, at farm gate
* Sunflower grain, organic, system n°2, at farm gate
* **Sunflower grain, organic, system n°3, at farm gate**
* Sunflower grain, organic, system n°4, at farm gate
* Sunflower grain, organic, system n°5, at farm gate

{% hint style="info" %}
**L'analyse des impacts de ces différents procédés permet de déterminer l'ICV bio à mobiliser : il correspond au procédé dont l'impact est le plus proche de la moyenne des impacts de tous les procédés bio.**
{% endhint %}

## Mix utilisé pour la production de l'huile de tournesol

Le procédé "Sunflower oil, at oil mill (WFLDB 3.1)/GLO U" mobilise un procédé "Sunflower, at farm (WFLDB 3.1)/GLO U" issu d'une moyenne de 3 procédés FR, HU et UA.

<figure><img src="../../../.gitbook/assets/sunflower.png" alt=""><figcaption></figcaption></figure>

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Tournesol => catégorie 3 : PAYS TIERS** (source : FranceAgriMer, chiffres et bilan 2021)&#x20;
