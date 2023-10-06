# 🐑 Etape 1 - Matières

La modélisation de l'étape Matières est actuellement non satisfaisante et fera prochainement l'objet d'un enrichissement méthodologique dès que la base de données actuellement utilisée (Base Impacts) sera remplacée.&#x20;

A date, l'impact des Matières est calculé en deux étapes.

Etape 1 : sélection du procédé correspondant dans la Base Impacts (cf. [explorateur Matières](https://ecobalyse.beta.gouv.fr/#/explore/textile/materials)),

Etape 2 : calcul de l'impact Matières&#x20;

Avec l'impact de la filature défini (`I_Filature`), nous pouvons déduire par soustraction l'impact des autres étapes couvertes dans le procédé "matière et filature", regroupées par simplification sous le terme "matière" (`I_Matière)` .

$$I_{Matière} = I_{Matière+Filature} - I_{Filature}$$

{% hint style="warning" %}
Pour un certain nombre de matières (exclusivement des matières synthétiques) et pour certains impacts le résultat de&#x20;

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

