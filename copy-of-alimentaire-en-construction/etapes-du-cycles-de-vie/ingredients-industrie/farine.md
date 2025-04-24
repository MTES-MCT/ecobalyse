# 🍞 Farine

{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient industrie à partir d'ingrédients agricoles

Si l'on exclue la farine utilisée pour l'alimentation animale (animal feed), un procédé est proposé dans Agribalyse pour la farine :&#x20;

* Wheat flour, at industrial mill

$$
FarineREF
$$

Ce procédé est construit à partir :&#x20;

* d'un [blé tendre](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/ingredients-agricoles/ble-tendre) \[at farm] --> Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate

$$
BléREF
$$

* d'opérations industrielles : mouture (milling), réception, prélavage, stockage.&#x20;

<figure><img src="../../../.gitbook/assets/Image collée à 2022-11-9 17-42.png" alt=""><figcaption><p>Arborescence du procédé Wheat flour at industrial mill</p></figcaption></figure>

On construit différents procédés de farine **(N)**, sur la base du procédé de référence (Wheat flour at industrial mill), en appliquant les opérations industrielles à différents procédés de blé tendre **(N)**.

$$
ImpactFarine_N = (ImpactFarineREF - ImpactBléREF )+ImpactBlé_N
$$

## Procédés retenus

| Label / Origine        | France                                                                                                                                                                                                                            | Autres pays                                                                                                                                                                                                                       |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p>                                                                     | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p>                                                                     |
| Agriculture biologique | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : procédé construit pour le <a href="../../../alimentaire/etapes-du-cycles-de-vie/ingredients-agricoles-hors-viande/ble-tendre.md">blé tendre bio</a></p> | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : procédé construit pour le <a href="../../../alimentaire/etapes-du-cycles-de-vie/ingredients-agricoles-hors-viande/ble-tendre.md">blé tendre bio</a></p> |

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => origine par défaut : FRANCE
2. Ingrédient très majoritairement produit en Europe/Maghreb (>95%) => transport par défaut : EUROPE/MAGHREB&#x20;
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : PAYS TIERS
4. Ingrédient spécifique (ex. Haricots et Mangues)&#x20;

**Farine => catégorie 2 : EUROPE/MAGHREB** (source : FranceAgriMer)&#x20;

