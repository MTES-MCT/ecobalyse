# 🐑 Etape 1 - Matières

La modélisation de l'étape Matières est actuellement non satisfaisante et fera prochainement l'objet d'un enrichissement méthodologique dès que la base de données actuellement utilisée (Base Impacts) sera remplacée.&#x20;

A date, l'impact des Matières se base sur les procédés de la Base Impacts (cf. [Explorateur Matières](https://ecobalyse.beta.gouv.fr/#/explore/textile/materials))

<details>

<summary>Comprendre le calcul de l'impact des matières </summary>

Dans les données utilisées (Base Impacts), les étapes de matière et filature sont fusionnées. Elles ont donc forcément lieu dans le même pays et regroupent deux réalités disctintes (la production de la fibre et sa transformation en fil).&#x20;

**Estimation de l'impact de l'étape Filature**

Nous faisons l'hypothèse que celle ci n'a besoin que d'électricité. Nous considérons que les autres impacts (machines, ...) sont négligeables. On a donc :

$$I_{Filature} = Qté\_élec_{filature} * I_{élec}$$

Avec&#x20;

* `Qté_élec_{filature}`, la quantité d'électricité nécessaire pour filer 1 kg de fil. Nous faisons l'hypothèse que `Qté_élec_{filature} = 3.21 kWh/kg fil` **pour toutes les matières.**

Le choix du chiffre de 3.21 kWh pour produire 1 kg de fil pour la filature provient des données de l'ITMF International Production Cost Comparison 2014. Pour obtenir ce chiffre on fait le rapport du coût en électricité de produire 1 kg de fil (_spinning ring_) divisé par le coût de l'électricité dans le pays concerné.&#x20;

:warning: La modélisation de l'étape Filature a été enrichie en juin 2023. Ainsi, la méthode présentée ci-dessus est exposée afin de comprendre comment est calculé l'impact Matière.&#x20;

**Estimation de l'impact de l'étape Matière**

Une fois l'impact de la filature estimé  (`I_Filature`), on peut en déduire par soustraction, l'impact des autres étapes couvertes dans le procédé "matière et filature", regroupées par simplification sous le terme "matière" (`I_Matière`).

$$I_{Matière} = I_{Matière+Filature} - I_{Filature}$$

</details>
