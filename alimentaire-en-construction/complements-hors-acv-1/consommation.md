# 🫕 Paramétrage de la conservation et de la transformation chez le consommateur (OLD: à vérifier)

Les impacts considérés pour la phase de consommation sont cadrés dans la partie "3.7 Phase d'utilisation" de la méthodologie Agribalyse ([Méthodologie\_AGB\_3.1\_alimentation.pdf](https://3613321239-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1\_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971)).&#x20;

Ils correspondent à :&#x20;

* L'énergie mobilisée pour la cuisson, la congélation et le maintien au frais des produits
* L'impact lié à la fin de vie
  * des emballages
  * des parties non comestibles des aliments

{% hint style="warning" %}
Dans un premier temps, l'impact lié à la fin de vie des emballages et des parties non comestibles n'est pas pris en compte. Il sera à ajouter ultérieurement.

Dans le cas par exemple d'une pizza au thon, l'impact lié à la fin de vie du carton représente environ 0,08 microPts PEF, à comparer à plus de 31 microPts PEF pour l'énergie électrique mobilisée.  Dans cet exemple, la fin de vie de l'emballage représenterait donc 0,25% de l'impact à l'étape de consommation.
{% endhint %}

## Energie mobilisée pour la cuisson, la congélation, la réfrigération...

Le principe général est l'ajout de différentes [techniques de préparation](consommation.md#techniques-de-preparation).

* L'ajout de ces techniques est **optionnel**, de sorte que l'étape de consommation peut être vide. Par exemple, une pomme peut être consommée telle quelle, sans nécessiter ni réfrigération, ni cuisson...
* L'ajout de **deux techniques de préparation** est possible. Par exemple, un plat surgelé peut être conservé au congélateur avant d'être cuit à la poêle.

### Energies mobilisables et procédés correspondants

2 types d'énergie peuvent être mobilisées dans les calculs :&#x20;

* l'électricité (pour les congélateurs, réfrigérateurs, plaques électriques, fours, fours micro-ondes...)
* le gaz (pour les plaques de gaz)

Les procédés mobilisés sont les suivants :&#x20;

* Électricité : Electricity, low voltage {FR}| market for | Cut-off, U ;
* Énergie thermique : Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, U .

### Techniques de préparation

En repartant des tableaux 41, 42 et 43 de la méthodologie Agribalyse ([lien](https://3613321239-files.gitbook.io/\~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1\_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971)), 9 techniques de préparation sont proposées :&#x20;

| Technique de préparation         | Electricité (kWh/kg)                                                                                     | Gaz (MJ/kg)                                                                                      |
| -------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Friture                          | 0,667 kWh/kg (100%)                                                                                      | (0%)                                                                                             |
| Cuisson à la poêle               | <p>0,44 kWh/kg (40%)<br><em><mark style="color:blue;">Extrapolation cf. ci-après</mark></em></p>         | <p>1,584 MJ/kg (60%)<br><em><mark style="color:blue;">Extrapolation cf. ci-après</mark></em></p> |
| Réchauffage à la poêle           | <p>0,08 kWh/kg (40%)<br><em><mark style="color:blue;">Extrapolation cf. ci-après</mark></em></p>         | <p>0,288 MJ/kg (60%)<br><em><mark style="color:blue;">Extrapolation cf. ci-après</mark></em></p> |
| Cuisson à l'eau ou sous pression | <mark style="color:red;">Info insuffisantes</mark> (40%)                                                 | <mark style="color:red;">Info insuffisantes</mark> (60%)                                         |
| Bouilloire                       | <p>0,127 kWh/kg (100%)<br><em><mark style="color:red;">Non proposé dans un premier temps</mark></em></p> | (0%)                                                                                             |
| Four                             | <p>0,999 kWh/kg (100%)<br><em><mark style="color:blue;">3000 W * 20')</mark></em></p>                    | (0%)                                                                                             |
| Four micro-ondes                 | <p>0,128 kWh/kg (100%)<br><em><mark style="color:blue;">1100 W * 7'</mark></em></p>                      | (0%)                                                                                             |
| Réfrigération                    | 0,0777 kWh/kg (100%)                                                                                     | (0%)                                                                                             |
| Congélation                      | 0,294 kWh/kg (100%)                                                                                      | (0%)                                                                                             |

Pour la **cuisson à la poêle**, la durée et la puissance de cuisson dépend de l'ingrédient (cf. tableau 42) :&#x20;

<table><thead><tr><th width="128.33333333333331">Ingrédient</th><th>Feu doux (600W)</th><th>Feux vif (3500W)</th><th>Energie consommée</th></tr></thead><tbody><tr><td>Viandes et poissons</td><td> 4 minutes</td><td>7 minutes</td><td>0,448 kWh</td></tr><tr><td>Fruits et légumes</td><td>3 minutes</td><td>7 minutes</td><td>0,438 kWh</td></tr><tr><td>Céréales</td><td>8 minutes</td><td>0</td><td>0,08 kWh</td></tr><tr><td>Autres</td><td>8 minutes</td><td>0</td><td>0,08 kWh</td></tr></tbody></table>

{% hint style="warning" %}
**En première approche**, il est seulement considéré deux modes de cuisson :&#x20;

* Cuisson à la poêle (viandes, poissons, fruits et légumes crus), qui consomme une énergie de 0,44 kWh (1,584 MJ). Cette énergie est indépendante de la masse qui est cuite.&#x20;
* Réchauffage à la poêle (céréales, autres), qui consomme une énergie de 0,08 kWh (0,288 MJ). Cette énergie est indépendante de la masse qui est réchauffée.
* Le cas de la cuisson d'un oeuf mérite d'être regardé...
{% endhint %}

Pour la **cuisson à l'eau ou sous pression**, la durée de cuisson et la quantité d'eau à ajouter dépendent du type d'ingrédient :&#x20;

| Ingrédient          | Temps de cuisson                                      | Eau ajoutée (L/kg) |
| ------------------- | ----------------------------------------------------- | ------------------ |
| Viandes et poissons | 120 minutes (<mark style="color:red;">**!!!**</mark>) | 0,2 L/kg           |
| Fruits et légumes   | 11 minutes                                            | 0,7 L/kg           |
| Céréales            | 15 minutes                                            | 1,5 L/kg           |
| Autres              | 5 minutes                                             | 5 L/kg             |

{% hint style="warning" %}
Ces données étant insuffisantes pour déduire l'énergie nécessaire à la cuisson à l'eau ou sous pression, cette option n'est pas proposée dans un premier temps.
{% endhint %}

{% hint style="warning" %}
En première approche, différents cas particuliers identifiés dans la méthodologie Agribalyse ne sont pas intégrés :&#x20;

* la réfrigération de l'eau en bouteille (0,0111 kWh/kg)
* l'ajout d'huile ou de matière grasse pour la friture ou la cuisson à la poêle
{% endhint %}

### Masse considérée

Pour la cuisson à l'eau ou l'utilisation d'une bouilloire, la masse à considérer intègre (ou est remplacée par) une quantité d'eau qui doit être ajoutée.

{% hint style="warning" %}
En première approche, la cuisson à l'eau et l'utilisation d'une bouilloire ne sont pas proposées
{% endhint %}

Pour les premières techniques de cuisson considérées, lorsqu'une masse est mobilisée dans le calcul de la quantité d'énergie à consommer, la masse considérée est le total des masses des ingrédients arrivant à l'étape de consommation. La masse de l'emballage n'est pas considérée.

{% hint style="warning" %}
En première approche, on ne prend pas en compte non plus le fait qu'une partie de la masse de certains ingrédients n'est pas comestible.
{% endhint %}

### Formules de calcul

Plusieurs techniques de préparation peuvent être considérées. Ainsi, un produit peut être conservé au réfrigérateur avant d'être cuit à la poêle par exemple.

$$
ImpactConso = ImpactTechnique1 + ImpactTechnique2
$$

Pour chaque technique, un ration élec / gaz est considéré. En pratique, il n'y a que pour la cuisson/réchauffage à la poêle ou la cuisson à l'eau que le gaz est considéré, à hauteur de 60%.

$$
ImpactTechnique = RatioElc * ImpactElec + RatioGaz * ImpactGaz
$$

{% hint style="warning" %}
Pour le gaz, l'unité considérée est le MJ et non le kWh

Les procédés à considérer pour le gaz et l'électricité sont introduits [supra](consommation.md#energies-mobilisables-et-procedes-correspondants).
{% endhint %}

Pour toutes les techniques, le calcul est proportionnel à la masse des ingrédients. Par exemple pour la congélation :&#x20;

$$
ImpactElecCongel = Masse (kg) * ElecCongel (kWh/kg) * ImpactProcedeElec
$$

<details>

<summary>Exemple de calcul : steak surgelé</summary>

Prenons le cas d'un steak de boeuf surgelé de masse m = 0.1 kg cuit au poêle, calculons l'impact sur la catégorie \`Changement Climatique\`.&#x20;

#### Impact Changement Climatique de la congélation :&#x20;

```markup
I_congélation = m * Qté_élec_congélation_par_kg * I_élec_par_kWh

I_congélation = 0.1 * 0.294 * 0.062
I_congélation = 0.0018 kgCO2e = 1.8 gCO2e 
```

#### Impact Changement Climatique de la cuisson au poêle :

{% code overflow="wrap" %}
```
I_cuisson = m * (part_élec * Qté_élec_poêle_par_kg * I_élec_par_kWh + part_gaz * Qté_gaz_poêle_par_kg * I_gaz_par_MJ)

I_cuisson = 0.1 * (0.4 * 0.44 * 0.062 + 0.6 * 1.584 * 0.076)
I_cuisson = 0.0083 kgCO2e = 8.3 gCO2e
```
{% endcode %}

</details>

### Masse finale

Suite à l'application des techniques d e préparation, la masse finale du produit (et donc des ingrédients) préparé peut avoir évolué. Il convient en effet de prendre en compte le [rapport cru/cuit](../impacts-consideres/rapport-cru-cuit.md).

C'est bien cette masse finale du produit, tel que consommé, qui doit ensuite être considérée dans le calcul de l'impact par kg.

{% hint style="warning" %}
En théorie, il est possible qu'une étape de cuisson soit appliquée aux étapes de [transformation](../impacts-consideres/transformation.md) ou de [consommation](consommation.md).
{% endhint %}

Dès lors :&#x20;

* le rapport cru/cuit ne doit être appliqué que si certaines techniques de préparation sont mobilisées ;
* si les ingrédients (ou un ingrédient ?) a déjà été cuit à l'étape de transformation, le rapport cru/cuit n'est pas appliqué une seconde fois. &#x20;

| Technique de préparation         | Application rapport cru/cuit                                   |
| -------------------------------- | -------------------------------------------------------------- |
| Friture                          | Oui - Sauf pour les ingrédients déjà cuits à la transformation |
| Cuisson à la poêle               | Oui - Sauf pour les ingrédients déjà cuits à la transformation |
| Réchauffage à la poêle           | Non                                                            |
| Cuisson à l'eau ou sous pression | Oui - Sauf pour les ingrédients déjà cuits à la transformation |
| Bouilloire                       | N/A                                                            |
| Four                             | Oui - Sauf pour les ingrédients déjà cuits à la transformation |
| Four micro-ondes                 | Oui - Sauf pour les ingrédients déjà cuits à la transformation |
| Réfrigération                    | Non                                                            |
| Congélation                      | Non                                                            |

{% hint style="warning" %}
Certains ingrédients ne sont pas consommés crus (viandes, oeufs, pommes de terre...). Pour ces ingrédients, une alerte pourrait être levée si une simulation est réalisée sans cuisson, ni à la transformation, ni à la consommation ?
{% endhint %}

## Fin de vie des emballages et des parties non comestibles

{% hint style="warning" %}
Partie non intégrée à ce stade.
{% endhint %}
