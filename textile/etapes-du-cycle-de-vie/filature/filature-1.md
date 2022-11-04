---
description: Comment effectuons nous la séparation des étapes matière et filature ?
---

# 💔 2 - Séparation Matière-Filature

Dans les données utilisées (Base Impacts), les étapes de matière et filature sont fusionnées. Elles ont donc forcément lieu dans le même pays. Cela est limitant car dans de nombreux cas, la filature n'a pas lieu dans le pays de production de la matière.\
Nous avons donc tenté de séparer ces 2 étapes.

### Séparation des impacts des étapes matière et filature

Pour séparer les impacts des étapes de matière et filature nous commençons par estimer l'impact de la filature

#### Impact de la filature

Pour l'étape de filature nous faisons l'hypothèse que celle ci n'a besoin que d'électricité. Nous considérons que les autres impacts (machines, ...) sont négligeables. On a donc :

$$
I_{Filature} = Qté\_élec_{filature} * I_{élec}
$$

Avec&#x20;

* `Qté_élec_{filature}`, la quantité d'électricité nécessaire pour filer 1 kg de fil.Nous faisons l'hypothèse que `Qté_élec_{filature} = 3.21 kWh/kg fil` **pour toutes les matières.**

{% hint style="info" %}
Le choix du chiffre de 3.21 kWh pour produire 1 kg de fil pour la filature provient des données de l'ITMF International Production Cost Comparison 2014. Pour obtenir ce chiffre on fait le rapport du coût en électricité de produire 1 kg de fil (spinning ring) divisé par le coût de l'électricité dans le pays concerné.&#x20;
{% endhint %}

* `I_élec` est l'impact de produire 1 kWh d'électricité dans le pays considéré. Cela dépend du lieu de la filature

#### Impact de la matière

Une fois l'impact de la filature estimé  (`I_Filature`), on peut en déduire par soustraction, l'impact des autres étapes couvertes dans le procédé "matière et filature", regroupées par simplification sous le terme "matière" (`I_Matière`).

$$
I_{Matière} = I_{Matière+Filature} - I_{Filature}
$$

{% hint style="danger" %}
Pour un certain nombre de matière (exclusivement des matières synthétiques) et pour certains impacts le résultat de&#x20;

`I_{Matière} = I_{Matière+Filature} - I_{Filature}` est négatif. Dans ce cas nous faisons l'hypothèse que

`I_{Matière} = 0`

La liste des matières; trigramme\_impact concernées est la suivante :&#x20;

(avec IOR : IOnising Radiations, PMA : Particulate MAtter, SWE : SeaWater Eutrophisation, TRE : TeRrestrial Eutrophisation)

* polypropylène; ior
* polylactide; pma
* polyéthylène; ior
* polyamide 66; ior
* aramide; swe
* aramide; tre
* bi-composant polypropylène/polyamide; ior
* polyamide recyclé (recyclage chimique); ior
* polyamide recyclé (recyclage mécanique); ior
{% endhint %}

### Séparation des taux de perte des étapes matière et filature

#### Taux de perte de la filature

A partir de données d'industriels, nous faisons l'hypothèse que les taux de perte pour la filature sont de `8%` pour les matières naturelles et de `2%` pour les matières synthétiques. Pour les matières recyclées, le taux de perte de la matière vierge (8% ou 2%) est appliqué.

Ainsi 100g de matière naturelle (du coton par ex) donnerons 92g de coton.

#### Taux de perte de la matière

A partir de ces taux de perte nous calculons un taux de perte pour l'étape matière de manière à ce que

$$
Perte_{Matière} = Perte_{Matière+Filature} - Perte_{Filature}
$$

{% hint style="danger" %}
Pour un certain nombre de matière (exclusivement des matières synthétiques) le taux de perte calculé lors de l'étape matière est négatif. Dans ce cas nous faisons l'hypothèse que le taux de perte de l'étape matière est de `0%`. La liste des matières concernées est la suivante :

* polyuréthane
* polytéréphtalate
* acrylique
* aramide
{% endhint %}

### Séparation du transport des étapes matière et filature

Dans la donnée Base Impacts de l'impact {matière+filature}  est pris en compte le transport entre l'étape matière et filature, comme le montre cet extrait de la documentation du processus "fil de coton":&#x20;

> The transports from the raw fibre production plant to the spinning plant includes the following steps: 1) Inland transport (with trucks) from the center of the production country to its main seaport, 2) Maritime transport (with a freight ship) from the main seaport of the production country to the main seaport of the spinning country, 3) Inland transport (with trucks) from the main seaport of the spinning country to its center. The average transport distance was calculated considering each production country and each transformation country. These countries are respectively weighted by their percentage of the production

Néanmoins il n'est pas détaillé dans la documentation quelles sont les hypothèses précises de transport (distances, part modales). Ainsi nous ne pouvons pas soustraire l'impact du transport inclus dans la donnée Base Impacts originale {matière+filature}.

{% hint style="warning" %}
Après la séparation matière et filature, nous offrons la possibilité à l'utilisateur de paramétrer un lieu de filature différent du lieu de matière. Nous prenons en compte le transport entre ces lieux. Il y a donc un double compte du transport : 1 fois dans la donnée originale {matière+filature} et 1 fois dans notre nouvelle modélisation.

Etant donné que dans la donnée originale {matière+filature} ces 2 étapes ont lieu dans la même zone géographique (exemple : Asie-Pacifique), et que de manière général l'impact du transport est minoritaire, ce double compte paraît peu impactant.&#x20;
{% endhint %}
