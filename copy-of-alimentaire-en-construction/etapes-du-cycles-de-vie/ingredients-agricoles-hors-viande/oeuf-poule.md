# 🥚 Oeuf (poule)

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), l'oeuf de poule est modélisé à travers les procédés suivants :&#x20;

| Label / Origine        | France                                              | Autres pays                                                                                                                                                                               |
| ---------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | Egg, national average, at farm gate                 | <p>Egg, national average, at farm gate<br><mark style="color:red;">[Choix à reconsidérer suivant la biblio sur les modes de production moyens des pays exportateurs envers FR]</mark></p> |
| Agriculture biologique | Egg, organic, at farm gate                          | Egg, organic, at farm gate                                                                                                                                                                |
| Bleu blanc coeur       | Egg, Bleu Blanc Coeur, outdoor system, at farm gate | N/A                                                                                                                                                                                       |

Les procédés retenus sont prioritairement des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

{% hint style="danger" %}
Agribalyse ne dispose pas d'ICV œuf "autres pays". Le procédé à prendre en compte pour "autres pays" est donc à préciser selon les modes de production moyens des pays exportateurs d'œufs vers la France.&#x20;

Hypothèse actuelle : étant donné que le principal exportateur d'œufs est l'Espagne, le mix "autres pays" est égal au mix de consommation français.
{% endhint %}

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer plusieurs inventaires de cycle de vie pour les oeufs de poule.&#x20;

* 13 inventaires France "at farm" :&#x20;
  * **Egg, Bleu Blanc Coeur, outdoor system, at farm gate**
  * Egg, conventional, indoor production, cage 2012 rules, at farm gate
  * Egg, conventional, indoor system, cage, at farm gate
  * Egg, conventional, indoor system, non-cage, at farm gate
  * Egg, conventional, outdoor system, at farm gate
  * **Egg, national average, at farm gate**
  * **Egg, organic, at farm gate**
  * Egg, organic, system n°1, at farm gate
  * Egg, organic, system n°2, at farm gate
  * Organic egg production system, future reproductives, at farm
  * Organic egg production system, laying hens, at farm
  * Organic egg production, system n°1, laying hens, at farm gate
  * Organic egg production, system n°2, laying hens, at farm gate
* 1 moyenne nationale France tirée de <mark style="color:red;">XXXX</mark> (cf. schéma <mark style="color:red;">à intégrer</mark> ci-après)
  * **Egg, national average, at farm gate**

L'analyse comparée des impacts donne :&#x20;

<figure><img src="../../../.gitbook/assets/image (180).png" alt=""><figcaption><p>Conventionnel vs bio vs bleu blanc coeur - source: AGB3.0 via Simapro, EF3.0 (adapted)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (188).png" alt=""><figcaption><p>source: AGB3.0 via Simapro, EF3.0 (adapted)</p></figcaption></figure>

{% hint style="danger" %}
Un "dummy process" unshelling egg est proposé dans Agribalyse. Conviendrait-il de l'intégrer aux impacts d'un ingrédient "oeuf" ?
{% endhint %}

{% hint style="info" %}
**Axes de progrès ?**

Les données ICV disponibles dans Agribalyse permettraient potentiellement d'introduire une distinction suivant :&#x20;

* l'élevage en cage ou à l'air libre
* le type de poule (reproductives, laying hens, young hens, future reproductive...)
{% endhint %}

## Mix de consommation

L'oeuf de poule "mix de consommation" France (Chicken egg, raw, consumption mix) proposée dans Agribalyse s'appuie l'oeuf moyen de France.

Un transport de 160 km y est ajouté.

<figure><img src="../../../.gitbook/assets/image (165).png" alt=""><figcaption></figcaption></figure>

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Oeuf => catégorie 2 : EUROPE/MAGHREB** (source : FranceAgriMer, fiche filière Oeuf, janvier 2022)&#x20;

