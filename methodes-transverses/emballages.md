# 📦 Emballages

## Contexte

{% hint style="warning" %}
Pour le calcul du coût environnemental des vêtements, il n'est pas considéré d'emballage. Cette orientation, prise lors de la stabilisation d'une première méthode réglementaire en 2025, est requestionnée dans le cadre de la concertation ouverte en juin 2026 en vue de futures évolutions.
{% endhint %}

### Choix de prise en compte des emballages dans Ecobalyse

Ecobalyse fait le choix de modéliser les emballages séparément des autres composants pour plusieurs raisons :&#x20;

* Calculer un poids net du produit hors emballage.
* Dédier le [calcul de la fin de vie](https://fabrique-numerique.gitbook.io/ecobalyse/methodes-transverses-specifiques/fin-de-vie-des-composants) à la fin de vie du produit, la fin de vie des emballages ayant lieu dès le début de la vie du produit
* Intégrer facilement les solutions d'emballages alimentaires construits dans le cadre du projet PACK\_AGB (Voir la [page de documentation dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/etape-3-emballages).)

### Matériaux d'emballage proposés

Ecobalyse met à disposition tout ou partie des matériaux d'emballage suivants pour les secteurs concernés :&#x20;

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
I_{emballage} = \sum_{i}(Q_{d,i}*r_{d,i} * I_i)
$$

Avec :

* `I_emballage` : l'impact environnemental de l'emballage, dans l'unité de la catégorie d'impact analysée
* `Q_d,i` la quantité de l'emballage `i` utilisée pour le produit évalué, exprimée en fonction de l'unité d'affichage de l'emballage `i`&#x20;
  * _Pour les masses, l'unité est le gramme_
* `r_d,i` le ratio de conversion entre l'unité d'affichage de l'emballage `i` et l'unité du procédé de l'emballage `i`&#x20;
  * _Exemple : 0.001 si l'unité d'affichage est le gramme et l'unité du procédé est le kg_
* `I_i` : l'impact environnemental du matériau d'emballage `i`, dans l'unité de la catégorie d'impact analysée, par unité du procédé de l'emballage i
  * _Pour les emballages exprimés en masse, l'unité est le Pt/kg_

## Paramètres retenus pour le coût environnemental

La masse `m_i` de chaque matériau d'emballage est indiquée par l'utilisateur.

## Procédés utilisés pour le coût environnemental

### Cas de l'alimentaire

Les procédés ont été construits par Agribalyse dans le cadre du projet PACK\_AGB. Ils incluent les emballages primaires, secondaires et tertiaires.

Voir la [page de documentation dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/etape-3-emballages).

### Autres secteurs

Pour les emballages non alimentaires, les procédés ont été construits par l'équipe Ecobalyse en incluant toutes les étapes du cycle de vie des emballages (fabrication, transport, fin de vie).

L'approche est cohérente avec celle implémentée dans l'alimentaire. Les procédés utilisés en arrière-plan et les règles de modélisation sont autant que possible les mêmes pour tous les secteurs :

* Procédés de fabrication
  * Aucun procédé avec intégration de matière recyclée n'est pour l'instant utilisé. Ceci pour être amené à évoluer, notamment au regard des retours des parties prenantes.
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

