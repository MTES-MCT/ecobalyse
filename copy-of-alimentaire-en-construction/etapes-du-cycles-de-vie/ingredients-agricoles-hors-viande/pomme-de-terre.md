# 🥔 Pomme de terre

## Choix de procédés

Les procédés retenus sont prioritairement des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

Considérée comme un ingrédient agricole (at farm), **la pomme de terre** est modélisée à travers les procédés suivants :&#x20;

| Label / Origine             | France                                                                 | Autres pays                                                            |
| --------------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Agriculture conventionnelle | Ware potato, conventional, variety mix, national average, at farm gate | Ware potato, conventional, variety mix, national average, at farm gate |
| Agriculture biologique      | Ware potato, conventional, variety mix, national average, at farm gate | Ware potato, conventional, variety mix, national average, at farm gate |

{% hint style="info" %}
**Pour identifier le procédé agricole retenu, on se réfère au procédé mobilisé dans le "consumption mix" => cf. ci-dessous.**

En l'absence d'ICV "autres pays", c'est l'ICV de la pomme de terre FR qui est mobilisé.
{% endhint %}

{% hint style="danger" %}
Dans l'attente d'un ICV bio (en construction), c'est l'ICV conventionnelle qui s'applique.
{% endhint %}

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer les inventaires de cycle de vie suivants.&#x20;

* **6 procédés** France "at farm" :&#x20;
  * Potato starch, at farm gate
  * Ware potato, conventional, for fresh market, firm flesh varieties, at farm gate
  * Ware potato, conventional, for fresh market, other varieties, at farm gate
  * Ware potato, conventional, for industrial use, at farm gate
  * Starch potato, conventional, national average, at farm gate
  * **Ware potato, conventional, variety mix, national average, at farm gate**
* Dont 2 moyennes nationales France dont la construction est explicitée dans le schéma ci-après
  * Starch potato, conventional, national average, at farm gate
  * **Ware potato, conventional, variety mix, national average, at farm gate**

L'analyse comparée des impacts donne :&#x20;

<figure><img src="../../../.gitbook/assets/image (164).png" alt=""><figcaption><p>source: AGB3.0 via Simapro, EF3.0 (adapted)</p></figcaption></figure>

## Mix de consommation

Le procédé "**Potato, consumption mix"** France proposée dans Agribalyse s'appuie sur les procédés suivants.

Un transport de 160 km en camion y est intégré.

<figure><img src="../../../.gitbook/assets/image (168).png" alt=""><figcaption></figcaption></figure>

Ce graphique met en évidence que le procédé pris en compte pour le mix de consommation français est Ware potato, conventional, variety mix, national average, at farm gate. C'est donc l'ICV retenu pour calculer l'impact de la pomme de terre conventionnelle.

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Pomme de terre => catégorie 1 : FRANCE** (source : FranceAgrimer/dires d'experts)&#x20;
