---
description: >-
  Si l’agriculture a des impacts sur l’environnement, certaines pratiques
  peuvent aussi avoir des externalités positives que l’ACV ne permet pas de
  prendre en compte.
---

# Compléments hors ACV



{% hint style="danger" %}
Page en cours de construction
{% endhint %}

### Les dimensions environnementales à prendre en compte hors de la métrique ACV&#x20;

Certaines pratiques agricoles peuvent avoir des externalités positives, telles que désignées dans l’[article 2 de la loi Climat et résilience](https://www.legifrance.gouv.fr/jorf/article\_jo/JORFARTI000043956979), que l’ACV ne permet pas de prendre en compte. C’est notamment le cas des pratiques qui contribuent à la résilience et à la biodiversité territoriales, ou encore, dans un registre différent, au bien-être des animaux d'élevage.

#### La biodiversité territoriale&#x20;

L’ACV, à travers notamment le nouvel indicateur de biodiversité locale, intègre une dimension biodiversité à l’échelle de la parcelle. Il ne permet cependant pas d’évaluer la contribution de certaines pratiques au maintien et à la préservation de la biodiversité à l'échelle territoriale : **continuités écologiques**, **limitation de la fragmentation des habitats**, **maintien et entretien des trames vertes** et des **zones refuges**, **régulation naturelle des ravageurs de cultures**, etc.

#### La résilience territoriale&#x20;

De la même manière, certaines pratiques agricoles contribuent à améliorer la résilience des territoires : **bouclage des cycles** et moindre dépendance à certains nutriments, **résilience face aux aléas climatiques**, **préservation des sols et lutte contre l’érosion**, **régulation naturelle des ravageurs de cultures**, etc.&#x20;

#### Les modes d'élevage

La question des modes d'élevage recoupe certains enjeux environnementaux. Cependant, la prise en compte des modes d'élevage ne peut se faire à l'intérieur du cadre ACV. Un bonus hors ACV favorisant certaines pratiques d'élevage peut ainsi être proposé.

### Les pratiques agricoles contribuant à la biodiversité et à la résilience territoriales, et au bien-être animal

La biodiversité et la résilience des territoires sont favorisées par :&#x20;

* La quantité (mais aussi la qualité) des [**infrastructures agroécologiques**](#user-content-fn-1)[^1] **** (haies, bosquets, arbres, mares, etc., mais aussi prairies) ;
* La **diversité agricole** : diversité des cultures dans l’espace (assolement diversifié) et dans le temps (rotations), et diversité des productions (présence de polyculture-élevage).

Quant aux modes d'élevage, certaines pratiques favorables au bien-être animal pourraient être valorisées dans le score d'impact, par exemple :

* la **surface de parcours** dont dispose les animaux,
* le **temps passé en extérieur**.

### Définition des bonus

Dans le cadre du niveau 1 de calcul (paramétrage par la recette, les labels, les origines des ingrédients et l'emballage), il est proposé de définir 3 compléments sous la forme de "bonus hors ACV" rendant compte :&#x20;

(1) de la quantité d’infrastructures agroécologiques (IAE) (ex. mètres linéaires de haies, part de prairies dans la SAU)

(2) d’un indice de diversité des productions,

(3) des modes d'élevage.

en fonction :&#x20;

* des **labels** de production,
* des **groupes de productions** (ex. cultures maraîchères, grandes cultures, élevages ruminants, monogastriques...)

Il est proposé de corréler ces bonus à la surface agricole mobilisée. En effet, les bénéfices de ces pratiques (ex. haies) sont proportionnels à la surface sur lesquelles elles sont mises en place. La surface agricole associée à un produit donné est approximée par son indicateur PEF "land use".

Pour un produit (p), le bonus peut donc s'écrire :&#x20;

$$
Bonus (p) = 𝑳𝒂𝒏𝒅𝑼𝒔𝒆(𝒑)×𝒄𝟏 ×𝑿(𝒑)
$$

Avec :&#x20;

* LandUse(p) = valeur du score d'impact "land use" pour le produit (p)
* c1 = le coefficient permettant de moduler l'ampleur du bonus
* X(p) = la valeur (1), (2) ou (3) (ex. quantité d'IAE moyenne associée à la production (p))



\


***



[^1]: NB : par souci de cohérence, il est proposé ici de considérer les prairies comme des infrastructures agroécologiques.
