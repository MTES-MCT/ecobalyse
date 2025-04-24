---
description: >-
  Si l’agriculture a des impacts sur l’environnement, certaines pratiques
  peuvent aussi avoir des externalités positives que l’ACV ne permet pas de
  prendre en compte.
---

# Copy of Compléments hors ACV - données mobilisées



{% hint style="danger" %}
Page en cours de construction
{% endhint %}

## Les dimensions environnementales à prendre en compte hors de la métrique ACV&#x20;

Certaines pratiques agricoles peuvent avoir des externalités positives, telles que désignées dans l’[article 2 de la loi Climat et résilience](https://www.legifrance.gouv.fr/jorf/article\_jo/JORFARTI000043956979), que l’ACV ne permet pas de prendre en compte. C’est notamment le cas des pratiques qui contribuent à la résilience et à la biodiversité territoriales, ou encore, dans un registre différent, à de meilleures conditions de vie pour les animaux d'élevage.

### La biodiversité territoriale&#x20;

L’ACV intègre une dimension biodiversité à l’échelle de la parcelle. Il ne permet cependant pas d’évaluer la contribution de certaines pratiques au maintien et à la préservation de la biodiversité à l'échelle territoriale, dimensions pourtant essentielles pour évaluer de manière complète la durabilité des systèmes de productions agricoles : **continuités écologiques**, **limitation de la fragmentation des habitats**, **maintien et entretien des trames vertes** et des **zones refuges**, **régulation naturelle des ravageurs de cultures**, etc.

### La résilience territoriale&#x20;

De la même manière, certaines pratiques agricoles contribuent à améliorer la résilience des territoires : **bouclage des cycles** et moindre dépendance à certains nutriments, **résilience face aux aléas climatiques**, **préservation des sols et lutte contre l’érosion**, **régulation naturelle des ravageurs de cultures**, etc.&#x20;

### Les conditions d'élevage

La question des conditions d'élevage peut recouper certains enjeux environnementaux. Il s'agit bien d'une dimension non prise en compte dans l'ACV. Intégrer les bénéfices en termes de conditions d'élevage de certaines pratiques d'élevage au score d'impact est une possibilité, par exemple à travers un bonus dédié.&#x20;

## Les pratiques agricoles contribuant à la biodiversité et à la résilience territoriales, et à de meilleures conditions d'élevage

La biodiversité et la résilience des territoires sont favorisées par :&#x20;

* La quantité (mais aussi la qualité) des [**infrastructures agroécologiques**](#user-content-fn-1)[^1] (haies, bosquets, arbres, mares, etc., mais aussi prairies) ;
* La **diversité agricole** : diversité des cultures dans l’espace (assolement diversifié) et dans le temps (rotations), et diversité des productions (présence de polyculture-élevage).

Quant aux conditions d'élevage, certaines pratiques favorables pourraient être valorisées dans le score d'impact, par exemple :

* la **surface de parcours** dont dispose les animaux,
* le **temps passé en extérieur**.

## Définition des bonus

Dans le cadre du niveau 1 de calcul (paramétrage par la recette, les labels, les origines des ingrédients et l'emballage), il est proposé de définir 3 compléments sous la forme de "bonus hors ACV" rendant compte :&#x20;

(1) d’un indice de diversité des productions,

(2) de la quantité d’infrastructures agroécologiques (IAE) (ex. mètres linéaires de haies, part de prairies dans la SAU)

(3) des conditions d'élevage.

{% hint style="info" %}
Le bonus "conditions d'élevage" n'est actif que pour les produits d'origine animale. Il est fixé à 0 sinon.
{% endhint %}

en fonction :&#x20;

* des **labels** de production,
* des **groupes de productions** (ex. cultures maraîchères, grandes cultures, élevages ruminants, monogastriques...)

Il est proposé de corréler ces bonus à la surface agricole mobilisée. En effet, les bénéfices de ces pratiques sont proportionnels à la surface sur lesquelles elles sont mises en place (ex. plus les haies sont déployées sur une surface importante, plus les bénéfices environnementaux sont importants). La surface agricole associée à un produit donné est approximée par son indicateur PEF "land use".

### Formule

Pour un produit (p) (exemple : poulet bio), le bonus i peut donc s'écrire :&#x20;

$$
Bonus_i (p) = 𝑳𝒂𝒏𝒅𝑼𝒔𝒆(𝒑)×𝒄_i ×x_i(𝒑)
$$

Avec :&#x20;

* $$Bonus_i(p)$$: Bonus i (diversité agricole, infrastructures agro-écologiques, conditions d'élevage) du produit p (en µPts d'impact)
* $$LandUse(p)$$: valeur du score d'impact "land use" pour le produit (p) (en µPts d'impact)

{% hint style="warning" %}
Dans cette formule nous prenons la valeur normalisée et pondérée de l'impact Land Use dans le coût environnemental, et non la valeur brute.
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

$$Land-use = 4.14$$ µPts (valeur normalisée et pondérée dans le coût environnemental)

\
On fait les hypothèses (arbitraires) que pour le poulet bio :

* $$x_{diversité-agricole} (poulet - bio)= 0.5$$
* $$x_{infra-agro-écologique} (poulet - bio)= 0.7$$
*   $$x_{cond-élevage} (poulet - bio)= 0.3$$



Calculs des bonus :

$$Bonus_{diversité-agricole} (poulet - bio)=  x_{diversité-agricole}(poulet - bio) × c_{diversité-agricole} × Land-use (poulet - bio)$$

$$Bonus_{infra-agro-écologique} (poulet - bio)=  x_{infra-agro-écologique} (poulet - bio) × c_{infra-agro-écologique} × Land-use(poulet - bio)$$

$$Bonus_{cond-élevage} (poulet - bio)=  x_{cond-élevage} (poulet - bio)×c_{cond-élevage} × Land-use(poulet - bio)$$

***

<details>

<summary>Analyse numérique</summary>

```

Bonus_diversité_agricole = 0.5 * 2.3 * 4.14 
Bonus_diversité_agricole = 4.76 µPts d'impacts


Bonus_infra_agro_écologique = 0.7 * 2.3 * 4.14 
Bonus_infra_agro_écologique = 6.67 µPts d'impacts

Bonus_cond_élevage = 0.3 * 1.5 * 4.14 
Bonus_cond_élevage = 1.86 µPts d'impacts


Bonus_total = Bonus_diversité_agricole + Bonus_infra_agro_écologique + Bonus_cond_élevage
Bonus_total = 4.76 + 6.67 + 1.86
Bonus_total = 13.3 µPts d'impacts

```

On a finalement :

```
Score d'impacts avant bonus = 97.04 µPts d'impact

Score d'impacts après bonus = Score d'impacts avant bonus - Bonus_total
Score d'impacts après bonus = 97.04 - 13.3
Score d'impacts après bonus = 83.74 µPts d'impact
```

</details>



[^1]: NB : par souci de cohérence, il est proposé ici de considérer les prairies comme des infrastructures agroécologiques.
