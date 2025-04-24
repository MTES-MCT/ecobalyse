# 🐄 Ingrédients - cas des inventaires complexes construits par Ecobalyse

Les inventaires mobilisés pour certains ingrédients dits "complexes", c'est-à-dire qui interviennent dans des recettes sous une forme différente (transformée) par rapport à leur état en sortie de ferme, sont construits par Ecobalyse : &#x20;

* Les différentes variantes d'ingrédients "viandes" (ils ont subi au moins les étapes d'abattage/découpe). Ex. : boeuf haché.
* Les différentes variantes d'ingrédients "industrie" (ils ont subi au moins une transformation industrielle). Ex. : oignons déshydratés.

## Exemple de construction de l'ingrédient viande de boeuf hachée à partir du procédé agricole

La viande de bœuf hachée correspond à l'ICV suivant dans Agribalyse :&#x20;

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

### Procédés retenus

| Label / Origine        | France                                                                                                                                                                                  | Autres pays                                                                                                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>BoeufHacheREF</strong><br>'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)<br>Boeuf : Beef cattle, national average, at farm gate</p> | <p><strong>BoeufHacheREF</strong><br>'Ground beef, fresh, case ready, for direct consumption, at plant' (kilogram, FR, None)<br>Boeuf : Beef cattle, national average, at farm gate</p> |
| Agriculture biologique | <p><strong>BoeufHacheBio</strong><br>Procédé construit (cf. formule)<br>Boeuf : Cull cow, organic, national average, at farm gate/FR U*</p>                                             | <p><strong>BoeufHacheBio</strong><br>Procédé construit (cf. formule)<br>Boeuf : Cull cow, organic, national average, at farm gate/FR U*</p>                                             |

\*Le procédé boeuf bio mobilisé (1kg de **Cull cow, organic, national average, at farm gate/FR U)** est lui même construit (cf. [partie dédiée](broken-reference)). Il correspond à une moyenne pondérée des ICV du tableau suivant.&#x20;

<table><thead><tr><th width="319">ICV constitutifs de l'ICV moyen</th><th>Quantité de l'ICV dans l'ICV moyen</th></tr></thead><tbody><tr><td>Cull cow, organic, milk system n°1, at farm gate/FR U</td><td>0,088 kg</td></tr><tr><td>Cull cow, organic, milk system n°2, at farm gate/FR U</td><td>0,088 kg</td></tr><tr><td>Cull cow, organic, milk system n°3, at farm gate/FR U</td><td>0,157 kg</td></tr><tr><td>Cull cow, organic, milk system n°4, at farm gate/FR U</td><td>0,157 kg</td></tr><tr><td>Cull cow, organic, milk system n°5, at farm gate/FR U</td><td>0,157 kg</td></tr><tr><td>Suckler cull cow, organic, suckler cow system n°1, at farm gate/FR U</td><td>0,088 kg</td></tr><tr><td>Suckler cull cow, organic, suckler cow system n°2, at farm gate/FR U</td><td>0,088 kg</td></tr><tr><td>Suckler cull cow, organic, suckler cow system n°3, at farm gate/FR U</td><td>0,088 kg</td></tr><tr><td>Suckler cull cow, organic, suckler cow system n°4, at farm gate/FR U</td><td>0,088 kg</td></tr></tbody></table>

## Exemple de la construction de l'ingrédient industrie farine à partir du blé tendre

Le procédé proposé dans Agribalyse pour la farine est :&#x20;

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

| Label / Origine        | France                                                                                                                                                        | Autres pays                                                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Conventionnelle        | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> | <p><strong>FarineREF</strong><br>Wheat flour, at industrial mill<br>Blé : Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate</p> |
| Agriculture biologique | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : procédé construit pour le <a href="broken-reference">blé tendre bio</a></p>         | <p><strong>FarineBio</strong><br>Procédé construit (cf. formule)<br>Blé : procédé construit pour le <a href="broken-reference">blé tendre bio</a></p>         |

