---
hidden: true
---

# Matériaux d'emballage

## Contexte

### Matériaux proposés

Les emballages doivent par défaut être modélisés par l'un des emballages complets modélisés dans le cadre du projet PACK\_AGB. Si nécessaire, Ecobalyse met également à disposition des matériaux d'emballage :&#x20;

* Aluminium
* Acier
* Carton
* Plastique PEBD (Polyéthylène basse densité)
* Plastique PEHD (Polyéthylène haute densité)
* Plastique PET
* Plastique PP (Polypropylène)
* Plastique PS (Polystyrène)
* Plastique PVC
* Verre

### Rappel du périmètre à prendre en compte

L'ensemble des emballages suivants, définis à l'Article L.543-43 du code de l'environnement, doivent être pris en compte :&#x20;

* Emballage de vente ou emballage primaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un article destiné à l'utilisateur final ou au consommateur.
  * Egalement appelé emballage de vente ou emballage unité de vente consommateur (terme retenu dans PACK\_AGB).
* Emballage groupé ou emballage secondaire, c'est-à-dire l'emballage conçu de manière à constituer, au point de vente, un groupe d'un certain nombre d'articles, qu'il soit vendu à l'utilisateur final ou au consommateur, ou qu'il serve seulement à garnir les présentoirs aux points de vente. Il peut être séparé des marchandises qu'il contient ou protège sans en modifier les caractéristiques
  * Egalement appelé emballage de regroupement (terme retenu dans PACK\_AGB).
* Emballage de transport ou emballage tertiaire, c'est-à-dire l'emballage conçu de manière à faciliter la manutention et le transport d'un certain nombre d'articles ou d'emballages groupés en vue d'éviter leur manipulation physique et les dommages liés au transport. L'emballage de transport ne comprend pas les conteneurs de transport routier, ferroviaire, fluvial, maritime ou aérien.

## Méthodes de calcul

Pour chacun de ces matériaux, des procédés dédiés sont construits par Ecobalyse à partir des méthodes du projet PACK\_AGB.

Pour modéliser un emballage avec ces données, il faut modéliser l'ensemble des emballages :&#x20;

* Emballage unité de vente consommateur
* Emballage de regroupement
* Emballage de transport

## Procédés utilisés pour le coût environnemental

Les procédés sont construits en sommant toutes les étapes du cycle de vie des emballages.

Sauf mention explicite contraire, les procédés retenus et leur quantités sont ceux identifiés dans PACK\_AGB

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

