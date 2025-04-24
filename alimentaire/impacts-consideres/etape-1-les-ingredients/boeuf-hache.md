# 🐄 Ingrédients - cas des ingrédients transformés construits par Ecobalyse

Les inventaires mobilisés pour certains ingrédients proposés dans l'outil sous une forme transformée sont construits par Ecobalyse : &#x20;

* Les différentes variantes d'ingrédients "viandes" (ils ont subi des étapes d'abattage, découpe, hachage...). Ex. : boeuf haché.
* Les différentes variantes d'ingrédients "industrie" (ils ont subi au moins une transformation industrielle). Ex. : farine.

{% hint style="info" %}
Les procédés construits par Ecobalyse font l'objet d'une [page dédiée](../../../def-cout-environnemental/source-des-procedes.md) présentant tous les cas de figure nécessitant la construction d'un inventaire, ainsi que le lien vers les détails du code pour la construction de ces inventaires.
{% endhint %}

## Exemple de construction de l'ingrédient viande de boeuf hachée à partir du procédé agricole

La viande de bœuf hachée correspond à l'ICV suivant dans Agribalyse :&#x20;

* 'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)

$$
BoeufHacheREF
$$

Cet ICV est construit à partir des procédés :&#x20;

* Beef cattle, national average, at farm gate

$$
BoeufREF
$$

* Ainsi que de procédés d'abattage et de hachage : &#x20;

<figure><img src="../../../.gitbook/assets/beef (1).png" alt=""><figcaption><p>Arborescence SimaPro du procédé <em>Ground beef, fresh, case ready, for direct consumption, at plant</em> </p></figcaption></figure>

On construit différents procédés de boeuf haché **(N)**, sur la base du procédé de référence ('Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None!), en appliquant les opérations d'abattage/hachage à différents procédés de boeuf **(N).**

$$
ImpactBoeufHache_N = (ImpactBoeufHacheREF - ImpactBoeufREF )+ImpactBoeuf_N
$$

### Procédés retenus

<table><thead><tr><th width="453.5">Variante de boeuf haché (BoeufHache(N))</th><th>Procédé sortie de ferme mobilisé</th></tr></thead><tbody><tr><td><p><strong>Boeuf haché FR</strong></p><p><code>BoeufHacheREF</code><br><em>Procédé Agribalyse</em> : 'Ground beef, fresh, case ready, for direct consumption, at plant' </p></td><td><p><code>BoeufREF</code></p><p>Beef cattle, national average, at farm gate</p></td></tr><tr><td><p><strong>Boeuf haché par défaut</strong></p><p><code>BoeufHacheDefaut</code><br><em>Procédé construit</em> : 'Ground beef, fresh, case ready, for direct consumption, at plant, constructed by Ecobalyse' </p></td><td><code>BoeufDefaut</code></td></tr><tr><td><p><strong>Boeuf haché bio</strong></p><p><code>BoeufHacheBio</code><br><em>Procédé construit</em> : 'Ground beef, fresh, case ready, for direct consumption, at plant, constructed by Ecobalyse' </p></td><td><p><code>BoeufBio</code></p><p>Cull cow, organic, national average, at farm gate/FR U, constructed by Ecobalyse*</p></td></tr></tbody></table>

\*Le procédé boeuf bio sortie de ferme mobilisé (Cull cow, organic, national average, at farm gate/FR U, constructed by Ecobalyse) est lui même construit (cf. [partie dédiée](impacts-consideres-1.md)). Il correspond à une moyenne pondérée de plusieurs ICV.&#x20;

## Exemple de la construction de l'ingrédient industrie farine à partir du blé tendre

Le procédé proposé dans Agribalyse pour la farine est :&#x20;

* Wheat flour, at industrial mill

$$
FarineREF
$$

Cet ICV est construit à partir des procédés :&#x20;

* Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate

$$
BléREF
$$

* d'opérations industrielles : mouture (milling), réception, prélavage, stockage.&#x20;

<figure><img src="../../../.gitbook/assets/Image collée à 2022-11-9 17-42.png" alt=""><figcaption><p>Arborescence SimaPro du procédé <em>Wheat flour at industrial mill</em></p></figcaption></figure>

On construit différents procédés de farine **(N)**, sur la base du procédé de référence (Wheat flour at industrial mill), en appliquant les opérations industrielles à différents procédés de blé tendre **(N)**.

$$
ImpactFarine_N = (ImpactFarineREF - ImpactBléREF )+ImpactBlé_N
$$

### Procédés retenus

<table><thead><tr><th width="453.5">Variante de farine (Farine(N))</th><th>Procédé blé sortie de ferme mobilisé</th></tr></thead><tbody><tr><td><p><strong>Farine FR</strong></p><p><code>FarineREF</code><br><em>Procédé Agribalyse</em> : 'Wheat flour, at industrial mill'</p></td><td><p><code>BléREF</code></p><p>'Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate'</p></td></tr><tr><td><p><strong>Farine par défaut</strong></p><p><code>FarineDefaut</code><br><em>Procédé construit</em> : 'Wheat flour, at industrial mill, constructed by Ecobalyse' </p></td><td><code>BléDefaut</code></td></tr><tr><td><p><strong>Farine bio</strong></p><p><code>FarineBio</code><br><em>Procédé construit</em> : 'Wheat flour, at industrial mill, constructed by Ecobalyse' </p></td><td><p><code>BléBio</code></p><p>'Wheat, organic, national average, at farm gate/FR U, constructed by Ecobalyse*'</p></td></tr></tbody></table>

\*Le procédé blé tendre bio sortie de ferme mobilisé (Wheat, organic, national average, at farm gate/FR U, constructed by Ecobalys&#x65;**)** est lui même construit (cf. [partie dédiée](impacts-consideres-1.md)). Il correspond à une moyenne pondérée de plusieurs ICV.&#x20;
