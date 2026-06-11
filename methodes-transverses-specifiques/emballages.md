# 📦 Emballages

## Contexte

### Choix de prise en compte des emballages dans Ecobalyse

Ecobalyse fait le choix de modéliser les emballage séparément des autres composants pour plusieurs raisons :&#x20;

* Calculer un poids net du produit hors emballage
* Dédier le [calcul de la fin de vie](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses-specifiques/fin-de-vie-des-composants) à la fin de vie du produit, la fin de vie des emballages ayant lieu dès le début de la vie du produit
* Intégrer facilement les solutions d'emballages alimentaires construits dans le cadre du projet PACK\_AGB (Voir la [page de documentation dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/etape-3-emballages).)

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

## Périmètre à prendre en compte

L'Article L.543-43 du code de l'environnement décrit l'ensemble des emballages suivants :&#x20;

* Emballage de vente ou emballage primaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un article destiné à l'utilisateur final ou au consommateur.
  * Egalement appelé emballage de vente ou emballage unité de vente consommateur (terme retenu dans PACK\_AGB).
* Emballage groupé ou emballage secondaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un groupe d'un certain nombre d'articles, qu'il soit vendu à l'utilisateur final ou au consommateur, ou qu'il serve seulement à garnir les présentoirs aux points de vente. Il peut être séparé des marchandises qu'il contient ou protège sans en modifier les caractéristiques
  * Egalement appelé emballage de regroupement (terme retenu dans PACK\_AGB).
* Emballage de transport ou emballage tertiaire, c'est-à-dire l'emballage conçu de manière à faciliter la manutention et le transport d'un certain nombre d'articles ou d'emballages groupés en vue d'éviter leur manipulation physique et les dommages liés au transport. L'emballage de transport ne comprend pas les conteneurs de transport routier, ferroviaire, fluvial, maritime ou aérien.

**A des fins de simplicité, seuls les emballages primaires doivent obligatoirement être pris en compte, excepté dans l'alimentaire (voir ci-dessous et documentation sectorielle).**

## Méthodes de calcul

L'impact des emballages est calculé comme suit :&#x20;

$$
I_{emballage} = Q_s*I_s+\sum_{i}(m_i * I_i)/1000
$$

Avec :

* `I_emballage` : l'impact environnemental de l'emballage, dans l'unité de la catégorie d'impact analysée
* `Q_s` : la quantité de la solution d’emballage `s`, exprimée en item
* `I_s` : l'impact environnemental de la solution d'emballage `s`, dans l'unité de la catégorie d'impact analysée par item
* `m_i` la masse du matériaux `i` utilisée pour l'emballage du produit évalué, exprimée en g
* `I_i` : l'impact environnemental du matériau d'emballage `i`, dans l'unité de la catégorie d'impact analysée, par kg

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

**Cout environnemental des matériaux d'emballage (en Pts/kg) :**

<figure><img src="../.gitbook/assets/image (395).png" alt=""><figcaption></figcaption></figure>

## Exemple d'application

Un produit a pour emballage une boite en carton de 100g et un papier bulle en polyéthylène basse de 50g.

$$
I_{emballage} = (m_{carton} * I_{carton} + m_{PEBD}*I_{PEBD})/1000
$$

$$
I_{emballage} = (100*123+50*348)/1000=29.7 Pts
$$

