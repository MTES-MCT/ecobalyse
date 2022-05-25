---
description: Comment effectuons nous la séparation des étapes matière et filature ?
---

# 💔 2 - Séparation Matière-Filature

Pour apporter plus de précision dans le calcul, en fonction du pays dans lequel la filature serait réalisée, des hypothèses sont faites pour évaluer l'impact de la filature, considéré comme un sous-ensemble du procédé "matière et filature".

L'estimation des impacts de la filature (`I_Filature`) permet ensuite, par soustraction, d'estimer l'impact des autres étapes couvertes dans le procédé "matière et filature", regroupées par simplification sous le terme "matière" (`I_Matière`).

$$
I_{Matière} = I_{Matière+Filature} - I_{Filature}
$$

Pour l'étape de filature nous faisons l'hypothèse que celle ci n'a besoin que d'électricité. Nous considérons que les autres impacts (machines, ...) sont négligeables. On a donc :

$$
I_{Filature} = Qté\_élec_{filature} * I_{élec}
$$

Avec&#x20;

* `Qté_élec_{filature}`, la quantité d'électricité nécessaire pour filer 1 kg de fil.Nous faisons l'hypothèse que `Qté_élec_{filature} = 3.21 kWh/kg fil` **pour toutes les matières.**

{% hint style="info" %}
Le choix du chiffre de 3.21 kWh pour produire 1 kg de fil pour la filature provient des données de l'ITMF International Production Cost Comparison 2014. Pour obtenir ce chiffre on fait le rapport du coût en électricité de produire 1 kg de fil pour un spinning ring divisé par le coût de l'électricité dans le pays concerné.&#x20;
{% endhint %}

* `I_élec` est l'impact de produire 1 kWh d'électricité dans le pays considéré. Cela dépend du lieu de la filature

{% hint style="danger" %}
Pour un certain nombre de matière (exclusivement des matières synthétiques) et pour certains impacts le résultat de I\_{Matière} = I\_{Matière+Filature} - I\_{Filature} est négatif. Dans ce cas nous faisons l'hypothèse que I\_{Matière} = 0. La liste des matières; trigramme\_impact concernées est la suivante :&#x20;

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

### Taux de perte lors des étapes de matières et filature

{% hint style="info" %}
A partir de données d'industriels, nous faisons l'hypothèse que les taux de perte pour la filature sont de 8% pour les matières naturelles et de 2% pour les matières synthétiques. Pour les matières recyclées, le taux de perte de la matière vierge (8% ou 2%) est appliqué.
{% endhint %}

Ainsi 100g de matière naturelle (du coton par ex) donnerons 92g de coton.

A partir de ces taux de perte nous calculons un taux de perte pour l'étape matière de manière à ce que

$$
Perte_{Matière} = Perte_{Matière+Filature} - Perte_{Filature}
$$

{% hint style="danger" %}
Pour un certain nombre de matière (exclusivement des matières synthétiques) le taux de perte calculé lors de l'étape matière est négatif. Dans ce cas nous faisons l'hypothèse que le taux de perte de l'étape matière est de 0%. La liste des matières concernées est la suivante :

* polyuréthane
* polytéréphtalate
* acrylique
* aramide
{% endhint %}
