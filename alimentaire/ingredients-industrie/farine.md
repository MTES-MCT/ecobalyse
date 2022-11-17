# 🍞 Farine

{% hint style="danger" %}
**Page en construction**
{% endhint %}

## Construction de l'ingrédient industrie à partir d'ingrédients agricoles

Si l'on n'exclue la farine utilisée pour l'alimentation animale (animal feed), un procédé est proposé dans Agribalyse pour la farine :&#x20;

* Wheat flour, at industrial mill

$$
FarineREF
$$

Ce procédé est construit à partir :&#x20;

* d'un blé tendre \[at farm] --> Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate

$$
BléREF
$$

* d'opérations industrielles : mouture (milling), réception, prélavage, stockage.&#x20;

<figure><img src="../../.gitbook/assets/Image collée à 2022-11-9 17-42.png" alt=""><figcaption><p>Arborescence du procédé Wheat flour at industrial mill</p></figcaption></figure>

On construit différents procédés de farine **(N)**, sur la base du procédé de référence (Wheat flour at industrial mill), en appliquant les opérations industrielles à différents procédés de blé tendre **(N)**.

$$
ImpactFarine_N = (ImpactFarineREF - ImpactBléREF )+ImpactBlé_N
$$

## Procédés retenus

| Label / Origine        | France                                                                                                                                                        | Autres pays                                                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> |
| Agriculture biologique | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : [Blé bio à définir]</p>                                                             | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : [Blé bio à définir]</p>                                                             |

{% hint style="danger" %}
XXX.
{% endhint %}

