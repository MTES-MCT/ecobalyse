# 📦 Matériaux d'emballage

## Contexte

### Matériaux d'emballage proposés, hors alimentaire

Ecobalyse met à disposition les matériaux d'emballage suivants :&#x20;

* Aluminium
* Acier
* Bois
* Carton
* Papier
* Plastique PEBD (Polyéthylène basse densité)
* Plastique PEHD (Polyéthylène haute densité)
* Plastique PET
* Plastique PP (Polypropylène)
* Plastique PS (Polystyrène)
* Plastique PVC
* Verre

{% hint style="info" %}
Dans l'alimentaire, les emballages proposés sont des solutions d'emballage complètes et non des matériaux. Voir la [page de documentation dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/etape-3-emballages).
{% endhint %}

### Périmètre à prendre en compte

L'Article L.543-43 du code de l'environnement décrit l'ensemble des emballages suivants :&#x20;

* Emballage de vente ou emballage primaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un article destiné à l'utilisateur final ou au consommateur.
  * Egalement appelé emballage de vente ou emballage unité de vente consommateur (terme retenu dans PACK\_AGB).
* Emballage groupé ou emballage secondaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un groupe d'un certain nombre d'articles, qu'il soit vendu à l'utilisateur final ou au consommateur, ou qu'il serve seulement à garnir les présentoirs aux points de vente. Il peut être séparé des marchandises qu'il contient ou protège sans en modifier les caractéristiques
  * Egalement appelé emballage de regroupement (terme retenu dans PACK\_AGB).
* Emballage de transport ou emballage tertiaire, c'est-à-dire l'emballage conçu de manière à faciliter la manutention et le transport d'un certain nombre d'articles ou d'emballages groupés en vue d'éviter leur manipulation physique et les dommages liés au transport. L'emballage de transport ne comprend pas les conteneurs de transport routier, ferroviaire, fluvial, maritime ou aérien.

A des fins de simplicité, seuls les emballages primaires doivent obligatoirement être pris en compte, excepté dans l'alimentaire (voir ci-dessous et documentation sectorielle).

## Méthodes de calcul

L'impact des emballages est calculé comme suit :&#x20;

$$
I_{emballage} = \sum_{i}(m_i * I_i)/1000
$$

Avec :

* `I_emballage` : l'impact environnemental de l'emballage, dans l'unité de la catégorie d'impact analysée
* `m_i` la masse du matériaux `i` utilisée pour l'emballage du produit évalué, exprimée en g
* `I_i` : l'impact environnemental du matériau d'emballage `i`, dans l'unité de la catégorie d'impact analysée

## Paramètres retenus pour le coût environnemental

La masse `m_i` de chaque matériau d'emballage est indiquée par l'utilisateur.

## Procédés utilisés pour le coût environnemental

### Cas de l'alimentaire

Les procédés ont été construits par Agribalyse dans le cadre du projet PACK\_AGB. Ils incluent les emballages primaires, secondaires et tertiaires.

Voir la [page de documentation dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/etape-3-emballages).

### Autres secteurs

Les procédés sont construits par Ecobalyse en sommant toutes les étapes du cycle de vie des emballages.

Sauf mention explicite contraire, les procédés retenus et leur quantités sont ceux identifiés dans la [documentation PACK\_AGB](https://doi.org/10.57745/ZTZUQR).

* Procédés de fabrication
  * Aucun procédé avec intégration de matière recyclée n'est retenue ici
* Procédés de transformation
  * "Injection moulding" pour les Plastiques (hors PVC)
* Transport du lien de fabrication au lien de vente
* Transport en fin de vie
  * quantité arrondie à 0.02L/kg pour tous les emballages
* Electricité pour le tri en fin de vie
* Enfouissement, incinération ou recyclage
  * L'énergie récupérée à l'incinération n'est pas modélisée à ce stade
  * Le recyclage est modélisé avec les [procédés de recyclage utilisés par ailleurs dans Ecobalyse](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses-specifiques/fin-de-vie-des-composants)

Ces procédés sont mis à disposition dans l'explorateur de chaque secteur.

## Exemple d'application

Un produit a pour emballage une boite en carton de 100g et un papier bulle en polyéthylène basse de 50g.

$$
I_{emballage} = (m_{carton} * I_{carton} + m_{PEBD}*I_{PEBD})/1000=(100*123+50*348)/1000=29.7 Pts
$$

