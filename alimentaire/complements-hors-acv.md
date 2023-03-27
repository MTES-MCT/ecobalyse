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

## Les dimensions environnementales à prendre en compte hors de la métrique ACV&#x20;

Certaines pratiques agricoles peuvent avoir des externalités positives, telles que désignées dans l’[article 2 de la loi Climat et résilience](https://www.legifrance.gouv.fr/jorf/article\_jo/JORFARTI000043956979), que l’ACV ne permet pas de prendre en compte. C’est notamment le cas des pratiques qui contribuent à la résilience et à la biodiversité territoriales, ou encore, dans un registre différent, au bien-être des animaux d'élevage.

### La biodiversité territoriale&#x20;

L’ACV, à travers notamment le nouvel indicateur de biodiversité locale, intègre une dimension biodiversité à l’échelle de la parcelle. Il ne permet cependant pas d’évaluer la contribution de certaines pratiques au maintien et à la préservation de la biodiversité à l'échelle territoriale : **continuités écologiques**, **limitation de la fragmentation des habitats**, **maintien et entretien des trames vertes** et des **zones refuges**, **régulation naturelle des ravageurs de cultures**, etc.

### La résilience territoriale&#x20;

De la même manière, certaines pratiques agricoles contribuent à améliorer la résilience des territoires : **bouclage des cycles** et moindre dépendance à certains nutriments, **résilience face aux aléas climatiques**, **préservation des sols et lutte contre l’érosion**, **régulation naturelle des ravageurs de cultures**, etc.&#x20;

### Les modes d'élevage

La question des modes d'élevage recoupe certains enjeux environnementaux. Cependant, la prise en compte des modes d'élevage ne peut se faire à l'intérieur du cadre ACV. Un bonus hors ACV favorisant certaines pratiques d'élevage peut ainsi être proposé.

## Les pratiques agricoles contribuant à la biodiversité et à la résilience territoriales, et au bien-être animal

La biodiversité et la résilience des territoires sont favorisées par :&#x20;

* La quantité (mais aussi la qualité) des [**infrastructures agroécologiques**](#user-content-fn-1)[^1] **** (haies, bosquets, arbres, mares, etc., mais aussi prairies) ;
* La **diversité agricole** : diversité des cultures dans l’espace (assolement diversifié) et dans le temps (rotations), et diversité des productions (présence de polyculture-élevage).

Quant aux modes d'élevage, certaines pratiques favorables au bien-être animal pourraient être valorisées dans le score d'impact, par exemple :

* la **surface de parcours** dont dispose les animaux,
* le **temps passé en extérieur**.

## Définition des bonus

Dans le cadre du niveau 1 de calcul (paramétrage par la recette, les labels, les origines des ingrédients et l'emballage), il est proposé de définir 3 compléments sous la forme de "bonus hors ACV" rendant compte :&#x20;

(1) d’un indice de diversité des productions,

(2) de la quantité d’infrastructures agroécologiques (IAE) (ex. mètres linéaires de haies, part de prairies dans la SAU)

(3) des conditions d'élevage.

{% hint style="info" %}
Le bonus "conditions d'élevage" n'est actif que pour les produits d'origine animal. Il est fixé à 0 sinon.
{% endhint %}

en fonction :&#x20;

* des **labels** de production,
* des **groupes de productions** (ex. cultures maraîchères, grandes cultures, élevages ruminants, monogastriques...)

Il est proposé de corréler ces bonus à la surface agricole mobilisée. En effet, les bénéfices de ces pratiques (ex. haies) sont proportionnels à la surface sur lesquelles elles sont mises en place. La surface agricole associée à un produit donné est approximée par son indicateur PEF "land use".

### Formule

Pour un produit (p) (exemple : poulet bio), le bonus i peut donc s'écrire :&#x20;

$$
Bonus_i (p) = -𝑳𝒂𝒏𝒅𝑼𝒔𝒆(𝒑)×𝒄_i ×x_i(𝒑)
$$

Avec :&#x20;

* $$Bonus_i(p)$$: Bonus i (diversité agricole, infra agro-écologique, conditions d'élevage) du produit p (en µPts d'impact)
* $$LandUse(p)$$: valeur du score d'impact "land use" pour le produit (p) (en µPts d'impact)

{% hint style="warning" %}
Dans cette formule nous prenons la valeur normalisé et pondéré de l'impact Land Use dans le score d'impacts, et non la valeur brut.
{% endhint %}

* $$c_i$$ : le coefficient permettant de moduler l'ampleur du bonus, il ne dépend pas du produit p. On a&#x20;
  * $$c_{diversité-agricole} = 2.3$$
  * $$c_{infra-agro-écologique} = 2.3$$
  * $$c_{cond-élevage} = 1.5$$
* $$x_i(p)$$: coefficient du produit p sur le bonus i. C'est un nombre compris entre 0 (bonus minimum) et 1 (bonus maximum). \
  Exemple arbitraire : $$x_{diversité-agricole}(poulet -bio) = 0.5$$

### Exemple de calcul

Prenons l'exemple de 100g de poulet bio.

Sans les bonus on a :

$$Score-d'impacts = 97.04$$ µPts

$$Land-use = 4.14$$ µPts (valeur normalisé et pondéré dans le score d'impacts)

\
On fait les hypothèses (arbitraires) que pour le poulet bio :

* $$x_{diversité-agricole} = 0.5$$
* $$x_{infra-agro-écologique} = 0.7$$
*   $$x_{cond-élevage} = 0.3$$



Calculs des bonus :

$$Bonus_{diversité-agricole} = - x_{diversité-agricole} × c_{diversité-agricole} × Land-use$$

$$Bonus_{infra-agro-écologique} =  -x_{infra-agro-écologique} × c_{infra-agro-écologique} × Land-use$$\
$$Bonus_{cond-élevage} =  -x_{cond-élevage} ×c_{cond-élevage} × Land-use$$

***

<details>

<summary><hr></summary>

```

Bonus_diversité_agricole = - 0.5 * 2.3 * 4.14 
Bonus_diversité_agricole = - 4.76 µPts d'impacts


Bonus_infra_agro_écologique = - 0.7 * 2.3 * 4.14 
Bonus_infra_agro_écologique = - 6.67 µPts d'impacts

Bonus_cond_élevage = - 0.3 * 1.5 * 4.14 
Bonus_infra_agro_écologique = - 1.86 µPts d'impacts


Bonus_total = Bonus_diversité_agricole + Bonus_infra_agro_écologique + Bonus_cond_élevage
Bonus_total = -4.76 - 6.67 - 1.86
Bonus_total = - 13.3 µPts d'impacts

```

On a finalement :

```
Score d'impacts avant bonus = 97.04 µPts d'impact
Score d'impacts après bonus = 83.74 µPts d'impact
```

</details>



[^1]: NB : par souci de cohérence, il est proposé ici de considérer les prairies comme des infrastructures agroécologiques.
