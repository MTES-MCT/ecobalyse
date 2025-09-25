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

<figure><img src="../../.gitbook/assets/https___files.gitbook.com_v0_b_gitbook-x-prod.appspot.com_o_spaces_2F-MexpTrvmqKNzuVtxdad_2Fuploads_2F6rnYce06ym45GtOByKpW_2Fimage.avif" alt=""><figcaption></figcaption></figure>

Le recyclage consiste essentiellement en du recyclage en chiffons (_wipers_) et en matériaux d'isolation (_insulation_). La prise en compte de ce recyclage se fait via la Circular Footprint Formula (CFF). [Nous avons estimé l'impact de ces circuits de recyclage et trouvé qu'il était négligeable sur cette page.](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/etape-1-matieres/circular-footprint-formula-cff-matiere-1)

Les étapes suivantes sont évaluées et détaillées dans cette page : Le traitement comme déchet municipal (_Municipal waste collection_) est évalué en prenant en compte les étapes suivantes :

* Transport en voiture par l'utilisateur du vêtement vers un point de collecte (_Recycling collection_)
* Transport en camion vers un site de traitement (_Municipal waste collection_ et _Recycling collection_)
* Incinération (Incineration)
* Mise en décharge (Landfill)

## Méthodes de calcul

Calcul général

$$
I_{8} = I_{collection,car} + I_{collection, truck}+I_{incineration}+I_{landfill}
$$

$$
I_{8} = m*\Big(\sum_{i} (e_i*t_i)*I_{elec}+\sum_{i} (c_i*t_i)*I_{chaleur}\Big)
$$

$$
I_{8} = m*\Big(\sum_{i} (e_i*t_i)*I_{elec}+\sum_{i} (c_i*t_i)*I_{chaleur}\Big)
$$

Avec :

* <mark style="color:red;">`I_8`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de la fin de vie (hors complément hors ACV), dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`I_collection,car`</mark> <mark style="color:red;"></mark><mark style="color:red;">:  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`I_collection,truck`</mark> <mark style="color:red;"></mark><mark style="color:red;">:  l'impact environnemental du transport en camion, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`I_incineration`</mark> <mark style="color:red;"></mark><mark style="color:red;">:  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`I_landfill`</mark> <mark style="color:red;"></mark><mark style="color:red;">:  l'impact environnemental du transport en voiture, dans l'unité de la catégorie d'impact analysée</mark>

<mark style="color:red;">Impact environnemental du transport en voiture</mark>



* <mark style="color:red;">`m`</mark> <mark style="color:red;"></mark><mark style="color:red;">la masse de tissu, exprimée en kg. Pour plus d'information sur la gestion des masses cf. la section</mark> [<mark style="color:red;">Pertes et rebut</mark>](../precisions-methodologiques/pertes-et-rebus.md)<mark style="color:red;">.</mark>
* <mark style="color:red;">`e_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la quantité d'électricité nécessaire au procédé i pour 1 kg de tissu, en kWh/kg</mark>
* <mark style="color:red;">`a_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: Le taux d'application du procédé i pour le vêtement évalué, sans unité</mark>
  * <mark style="color:red;">Egal à 1 si le procédé est mobilisé pour ce vêtement</mark>
  * <mark style="color:red;">Egal à 0 si le procédé n'est pas mobilisé</mark>
  * <mark style="color:red;">Situé entre 0 et 1 pour l'impression (voir paragraphe dédié)</mark>
* <mark style="color:red;">`I_elec`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`c_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la quantité de chaleur nécessaire au procédé i pour 1 kg de tissu, en MJ/kg</mark>
* <mark style="color:red;">`I_chaleur`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'électricité pour le pays défini pour l'ennoblissement, dans l'unité de la catégorie d'impact analysée.</mark>

## Paramètres retenus pour le coût environnemental

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

