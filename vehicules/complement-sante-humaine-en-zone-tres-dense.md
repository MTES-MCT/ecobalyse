---
hidden: true
---

# 🏙️ Complément : santé humaine en zone très dense

## Contexte

La modélisation de la consommation de carburant inclut la modélisation des émissions de particules fines et autres polluants ayant un impact sur la santé humaine à une échelle locale.

Cette modélisation est réalisée en évaluant les émissions, et en appliquant les flux élémentaires correspondant (Particulate matter, <2.5pm, Nitrogen oxides,...), avec les compartiments et sous-compartiments "air, urban air close to ground". Ceci permet de prendre en compte une utilisation des véhicules dans des zones urbaines.

Cependant, la définition de zone urbaine correspond ici à une zone de plus de 400 personnes par km2 pour une suface de 12km2.

De





## Méthodes de calcul

{% hint style="info" %}
Cette partie se compose essentiellement de formules de calcul et de l’introduction des paramètres mobilisés. Elle est très voire exclusivement “mathématique”, sans chiffre.

Ci-dessous un exemple pour l'ennoblissement
{% endhint %}



$$
I_{ennoblissement} = m*\Big(\sum_{i} (e_i*t_i)*I_{elec}+\sum_{i} (c_i*t_i)*I_{chaleur}\Big)
$$

Avec :

* <mark style="color:red;">`I_ennoblissement`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l'ennoblissement, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`m`</mark> <mark style="color:red;"></mark><mark style="color:red;">la masse de tissu, exprimée en kg. Pour plus d'information sur la gestion des masses cf. la section</mark> [<mark style="color:red;">Pertes et rebut</mark>](../textile/precisions-methodologiques/pertes-et-rebus.md)<mark style="color:red;">.</mark>
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

