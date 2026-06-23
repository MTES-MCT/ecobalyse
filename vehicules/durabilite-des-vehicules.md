# 🔴 Durabilité des véhicules

Cette page vient préciser la [page transverse Durabilité](https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/bUCb5XokARXVhhZXF5Xd/def-cout-environnemental/durabilite), qui s'applique à tous les secteurs et précise comment la durabilité est prise en compte dans le calcul du coût environnemental.

{% hint style="warning" %}
Les méthodes indiquées ici ne sont qu'une première proposition, ayant pour vocation de servir de base de discussion pour une phase de co-construction avec les acteurs.
{% endhint %}

## Contexte

### Durabilité physique

La principale cause de fin de vie des véhicules est un coût de réparation trop élevé par rapport à la valeur résiduelle du véhicule.

Deux nouveautés majeures dans la conception des véhicules viennent impacter les coûts des réparations usuels des véhicules :&#x20;

* L'avènement des véhicules électriques et l'intégration d'une batterie, composant majeur des ces véhicules. La réparation de ces batteries peut être très couteuse, notamment en raison des choix de conception (facilité de remplacement de la batterie, capacité à remplacer des éléments de la batterie, voire des cellules)
* Le procédé du gigacasting (ou, dans une moindre mesure, le megacasting), consistant à fabriquer des grandes pièces de chassis par moulage, plutôt que de fabriquer puis d'assembler une multitude de pièces. Cela peut aller jusqu'à mouler le chassis en une seule pièce. Ceci augmente le coût de réparation, et peut même rendre une réparation impossible : là où il était possible de réparer ou remplacer un petit élément, il faut désormais réparer ou remplacer un élément de grande ou très grande taille.

Concrètement, les facteurs de durabilités des véhicules sont les suivants :&#x20;

* Démontabilité et réparabilité de la batterie
* Démontabilité du véhicule
* Capacité à accéder aux informations du véhicule (compteur fiable pour les véhicules les plus légers, Etat de santé de la batterie, diagnostic véhicule)...
* Garantie de disponibilité des pièces détachées
* Facilitation de l'usage de pièces de réemploi
* Possibilité de réparation hors réparateur agréé
* Capacité de fonctionnement sans dépendance "cloud", en particulier extra-européenne

L'importance de chacun de ces critères dépend des catégories de véhicules. Un coefficient de durabilité physique est donc à définir par secteur.

{% hint style="info" %}
Pour les véhicules légers intermédiaires, un indice de durabilité a été construit dans le cadre d'un groupe de travail dédié.
{% endhint %}

{% hint style="info" %}
Pour les vélos à assistance électrique, un indice de réparabilité réglementaire va voir le jour en 2026.
{% endhint %}

{% hint style="info" %}
Un indice de réparabilité automobile est en cours d'élaboration par un groupe de travail de l'association Mobilians ([voir article](https://www.auto-infos.fr/article/les-independants-posent-les-bases-d-un-futur-indice-de-reparabilite-automobile.286910)). France Assureur a également annoncé la création d'un indice de réparabilité automobile, dont la conception est confiée à l'association SRA, regroupant les entreprises d'assurance automobile ([voir communiqué](https://www.franceassureurs.fr/espace-presse/transition-vers-le-vehicule-electrique-quels-impacts-pour-lassurance-quelles-propositions-pour-preserver-une-assurance-automobile-accessible-a-tous/)).
{% endhint %}

### Durabilité non physique

Compte-tenu de la valeur des voitures, des deux-roues motorisés ou des véhicules intermédiaires, la propension à changer de véhicule pour un souhait de renouvellement ne se traduit pas par une mise à la casse du véhicule mais par une revente. Ainsi, la durée de vie des voitures tend à augmenter depuis plusieurs années.

Ecobalyse n'intègre donc pas de coefficient de durabilité non-physique pour ces véhicules.

L'intégration d'un coefficient de durabilité non-physique reste à l'étude pour les vélos.

## Méthodes de calcul

### Véhicules intermédiaires et vélos à assistance électrique

Un coefficient de durabilité physique `C_physique` est établi à partir à partir d'une grille d'analyse comportant de nombreux critères, listé dans le tableau ci-dessous.

Le calcul du coefficient de durabilité des velis n'est pas intégré dans la calculette Ecobalyse. Il doit être réalisé séparément avec la grille d'analyse ci-dessous, puis reportée dans la calculette :

{% file src="../.gitbook/assets/XD_Coefficient durabilité 20260622 v4.0.xlsx" %}

### Voitures

Ecobalyse ne mène aujourd'hui aucun projet de construction d'un coefficient de durabilité pour les voitures.

A court terme, il est proposé à titre exploratoire de fixer le coefficient de durabilité physique `C_physique` par défaut à 1 et de le corriger comme suit, sans pouvoir être inférieur à `Coef_min` :

| Caractéristique                                          | Correction de C\_physique |
| -------------------------------------------------------- | ------------------------- |
| Accès aux modules et aux cellules sans destruction       | +0.2                      |
| Réparation batterie complète uniquement                  | -0.2                      |
| Echange standard possible                                | -0.2                      |
| Ratio tarif de la batterie / prix du véhicule neuf > 45% | -0.2                      |
| Nombre de pièces constitutives du chassis < 5            | -0.2                      |
| Nombre de pièces constitutives du chassis entre 5 et 10  | -0.1                      |

Les indicateurs relatifs aux batteries sont fournis par l'association SRA dans une étude dédiée disponible à [ce lien](https://www.sra.asso.fr/wp-content/uploads/2025/10/Etude-SRA-batterie-VE-HEV-PHEV.pdf).

## Paramètres retenus pour le coût environnemental

### Coefficients de durabilité minimum et maximum :&#x20;

Les coefficient minimum et maximum sont fixés comme suit pour tous les secteurs :&#x20;

* `Coef_min` = 0.5
* `Coef_max` = 1.5

Ces coefficients pourront être modifiés pour certaines catégories de véhicules.

## Exemple d'application

_En cours de rédaction._
