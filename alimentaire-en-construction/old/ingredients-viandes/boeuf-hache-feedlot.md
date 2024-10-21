# 🐄 Boeuf haché - feedlot



{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient viande de boeuf haché - feedlot à partir de l'ingrédient boeuf haché

La viande de bœuf hachée correspond à l'ICV suivant :&#x20;

* 'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)

$$
BoeufHacheREF
$$

Ce procédé est construit à partir du procédé :&#x20;

* Beef cattle, national average, at farm gate

$$
BoeufREF
$$

* de procédés d'abattage : &#x20;

<figure><img src="../../../.gitbook/assets/beef (1).png" alt=""><figcaption></figcaption></figure>

On construit différents procédés de boeuf haché **(N)**, sur la base du procédé de référence ('Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None!), en appliquant les opérations d'abattage à différents procédés de boeuf **(N)**.

$$
ImpactBoeufHache_N = (ImpactBoeufHacheREF - ImpactBoeufREF )+ImpactBoeuf_N
$$

##

## Procédés retenus

| Label / Origine | France                                                                                                                                                                                                                                 | Autres pays                                                                                                                                                                                                                            |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Feedlot         | <p><strong>BoeufHacheREF</strong><br>'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)<br>Boeuf : Beef cattle, feedlot or intensive system, live weight, at farm {GB} - Adapted from WFLDB U</p> | <p><strong>BoeufHacheREF</strong><br>'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)<br>Boeuf : Beef cattle, feedlot or intensive system, live weight, at farm {GB} - Adapted from WFLDB U</p> |

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Boeuf, feedlot  => catégorie 3 : PAYS TIERS**&#x20;
