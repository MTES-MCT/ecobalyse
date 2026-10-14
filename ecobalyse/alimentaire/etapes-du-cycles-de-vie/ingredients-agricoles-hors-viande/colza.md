# 🌼 Colza

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), le **colza** est modélisé à travers les procédés suivants :&#x20;

| Label / Origine             | France                                            | Allemagne                                                               | Etas-Unis                                                               | Canada                                                     | Autres pays                                                 |
| --------------------------- | ------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------- |
| Agriculture conventionnelle | Rape seed {FR} \| production \| Cut-off, S-Copied | <p>A venir : </p><p>Rape seed {DE} | production | Cut-off, S-Copied</p> | <p>A venir : </p><p>Rape seed {US} | production | Cut-off, S-Copied</p> | <p>A venir : </p><p>Rapeseed, at farm (WFLDB 3.1)/CA U</p> | <p>A venir : </p><p>Rapeseed, at farm (WFLDB 3.1)/GLO U</p> |
| Agriculture biologique      | Winter rapeseed, organic, at farm gate            | Winter rapeseed, organic, at farm gate                                  | Winter rapeseed, organic, at farm gate                                  | Winter rapeseed, organic, at farm gate                     | Winter rapeseed, organic, at farm gate                      |

Les procédés retenus sont prioritairement des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

{% hint style="danger" %}
**XXX**
{% endhint %}

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer les inventaires de cycle de vie suivants.&#x20;

* **7 procédés** France "at farm" :&#x20;
  * Rapeseed, average from 7 optimized case study, basis scenario, at farm gate
  * Rapeseed, average from 7 optimized case study, protein crop scenario, at farm gate
  * Rapeseed, average from 7 optimized case study, systematic covercropping scenario, at farm gate
  * ~~Rapeseed, conventional, 9% moisture, national average, animal feed, at farm gate, production~~
  * ~~Rapeseed, organic, animal feed, at farm gate~~
  * ~~Rapeseed, seed, conventional, national average, animal feed, at farm gate~~
  * **Winter rapeseed, organic, at farm gate**
* Dont 2 moyennes nationales France&#x20;
  * ~~Rapeseed, conventional, 9% moisture, national average, animal feed, at farm gate, production~~
  * ~~Rapeseed, seed, conventional, national average, animal feed, at farm gate~~
* 2 procédés :&#x20;
  * **Rapeseed, at farm (WFLDB 3.1)/GLO U**
  * Rapeseed, at farm (WFLDB 3.1)/CA U

{% hint style="info" %}
**Pour identifier le procédé colza "at farm" retenu, on se réfère au procédé colza mobilisé pour l'**[**huile de colza**](../../old/huile-de-colza.md)**.**

En effet, le colza est un ingrédient mobilisé quasi uniquement pour la production d'huile.

A priori, seront directement exclus les procédés colza "at farm" pour l'alimentation animale.&#x20;
{% endhint %}

{% hint style="info" %}
Le procédé mobilisé pour le colza bio est en attente des graphes d'analyse d'impacts des ICV ci-dessus.
{% endhint %}

## Mix utilisé pour la fabrication d'huile de colza

Le procédé " **Rapeseed oil, at oil mill (WFLDB 3.1)/GLO U**" proposé dans Agribalyse s'appuie sur les procédés suivants :

<figure><img src="../../../.gitbook/assets/rapeseed.png" alt=""><figcaption></figcaption></figure>

Un transport de <mark style="color:red;">XXX</mark> km en camion y est intégré.

Le procédé colza mobilisé pour la fabrication d'huile est donc Rapeseed, at farm (WFLDB 3.1)/GLO U, qui mobilise plusieurs procédés, dont un procédé Rape seed {FR}|production|Cut-off, S-Copied, qui peut être repris comme ICV colza FR.

Idem pour les colza CA, US et DE

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Colza => catégorie 3 : PAYS TIERS** (source : FranceAgriMer, chiffres et bilans 2022)&#x20;
