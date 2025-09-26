---
hidden: true
---

# ♻️ Etape 8 - Fin de vie

## Contexte

Trois scénarios de fin de vie sont identifiables pour les vêtements :

1. Traitement comme déchets ménagers (collecte pour incinération ou décharge)
2. Recyclage
3. Export hors Europe avec fin de vie inconnue

### Introduction d'un complément "Export hors Europe"

Le PEFCR Apparel & Footwear détaille bien les deux premiers scénarios (voir ci-dessous), mais considère que 100% des vêtements exportés sont réutilisés et ne génèrent aucun impact, ce qui ne correspond pas à la réalité et présente une limite à la méthode.

C'est pourquoi un complément hors ACV "Export hors Eurpoe" a été introduit par Ecobalyse en septembre 2023. Ce complément est détaillé dans une page spécifique [Export hors Europe](https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/export-hors-europe).&#x20;

### **Scénarios** PEFCR Apparel & Footwear

**Cette page décrit les méthodes pour la fin de vie incluent dans le PEFCR Apparel & Footwear v1.3, hors complément.**

<figure><img src="../../.gitbook/assets/image (379).png" alt=""><figcaption></figcaption></figure>

Le recyclage consiste essentiellement en du recyclage en chiffons (_wipers_) et en matériaux d'isolation (_insulation_). La prise en compte de ce recyclage se fait via la Circular Footprint Formula (CFF). [Nous avons estimé l'impact de ces circuits de recyclage et trouvé qu'il était négligeable sur cette page.](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/etape-1-matieres/circular-footprint-formula-cff-matiere-1)

Les étapes suivantes sont évaluées et détaillées dans cette page : Le traitement comme déchet municipal (_Municipal waste collection_) est évalué en prenant en compte les étapes suivantes :

* Transport en voiture par l'utilisateur du vêtement vers un point de collecte (_Recycling collection_)
* Transport en camion vers un site de traitement (_Municipal waste collection_ et _Recycling collection_)
* Incinération (Incineration)
* Mise en décharge (Landfill)

## Méthodes de calcul

### Calcul général

$$
I_{8} = I_{collection,car} + I_{collection, truck}+I_{incineration}+I_{landfill}
$$

Avec :

* `I_8` : l'impact environnemental de la fin de vie (hors complément hors ACV), dans l'unité de la catégorie d'impact analysée
* `I_collection,car` :  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée
* `I_collection,truck` :  l'impact environnemental du transport en camion, dans l'unité de la catégorie d'impact analysée
* `I_incineration` :  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée
* `I_landfill` :  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée

### Impact environnemental du transport en voiture

$$
I_{collection,car} =  \frac{m}{1000}* d_{recycling.collection}*r_{recycling}*r_{coffre}*I_{car}
$$

Avec :

* `I_collection,car` :  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée
* `m` : la passe du produit, en kg
* d\_recycling.collection : la distance parcourue en voiture pour déposer un vêtement dans un point de collecte, en km
* `r_recycling` : la part de produits allant en filière recyclage, sans unité
* `r_coffre` : la part du coffre occupée par le vêtement, sans unité
* `I_car` : l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée par km parcouru

### Impact environnemental de la collecte camion

$$
I_{collection,truck} = \frac{m}{1000}*(d_{m.waste} + d_{rec,collection>sorting}+d_{rec,sorting>recycling}+d_{rec,sorting>incineration})*I_{truck}
$$

$$
d_{m.waste} =d_{client>treatment}*r_{m.waste}
$$

Avec :

* `m` la masse du vêtement, exprimée en kg.
* `I_chaleur` : l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée.

## Paramètres retenus pour le coût environnemental

### Distances de transport

<figure><img src="../../.gitbook/assets/Capture d&#x27;écran 2025-09-25 171126.png" alt=""><figcaption></figcaption></figure>

### Part du coffre occupée par le vêtement `r_coffre`

Ces données sont directement issues du PEFCR Apparel & Footwear 3.1 (Table 44, colonne _Allocation_ voir ci-dessous).

Ces données sont calculées comme suit :

$$
r_{coffre} = \frac{V_{vetement}}{V_{coffre}}
$$

Avec :

* `r_coffre` : la part du coffre occupée par le vêtement
* `V_vetement` : le volume du vêtement étudié (colonne _Default product_ dans le tableau ci-dessous)
* `V_coffre` : le volume de coffre moyen d'une voiture, fixé à 0.2m3 (PEFCR Apparel & Footwear 3.1)

<figure><img src="../../.gitbook/assets/image (378).png" alt=""><figcaption></figcaption></figure>



{% hint style="info" %}
Les paramètres retenus pour l’affichage environnemental sont présentés dans une partie séparée des formules de calcul, de façon à identifier facilement ce qui relève de la structure et ce qui relève du paramétrage.\
Cette distinction devrait être en miroir de ce qui est dans le code.\
Ne pas hésiter à renvoyer vers des pages de code si le nombre de paramètres est important mais à faible enjeu.
{% endhint %}

### Paramètres spécifiques pour l'affichage environnemental réglementaire



## Procédés utilisés pour le coût environnemental

{% hint style="info" %}
A priori un renvoi vers l'explorateur suffit ici. Si des procédés spécifiques sont construits, ils peuvent être expliqués ici.
{% endhint %}

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), avec les noms utilisés dans cette page.

## Exemple d'application

{% hint style="info" %}
\[optionnel mais utile] Application à un exemple, pour permettre une meilleure compréhension au lecteur
{% endhint %}

