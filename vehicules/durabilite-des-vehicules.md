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

### Véhicules intermédiaires

Un coefficient de durabilité physique `C_physique` est établi à partir à partir d'une grille d'analyse comportant de nombreux critères, listé dans le tableau ci-dessous.

Pour l'instant, le calcul du coefficient de durabilité n'est pas inclut dans Ecobalyse. Il doit être réalisé séparément avec la grille d'analyse disponible ici : [https://wikixd.fabmob.io/wiki/GT\_Label,\_ACV\_et\_score\_environnemental](https://wikixd.fabmob.io/wiki/GT_Label,_ACV_et_score_environnemental).

<table><thead><tr><th width="86"></th><th width="538">Leviers pour améliorer la réparabilité des produits</th></tr></thead><tbody><tr><td></td><td><strong>Je favorise une longue durée de vie et la confiance dans la 2ème main</strong></td></tr><tr><td>A1</td><td>J'installe un compteur kilométrique sur mon véhicule </td></tr><tr><td>A2</td><td>Je mets à disposition un passeport digital de mes produits, intégrant :<br>- documentation technique du véhicule<br>- carnet d'entretien et maintenance<br>- empreinte environnementale</td></tr><tr><td>A3</td><td>Je mets à disposition des consommateurs des informations permettant de jauger l'état de santé de mes batteries </td></tr><tr><td>A4</td><td>Je garantie une longue durée de vie pour la batterie, pour une capacité restante de 70% ou plus</td></tr><tr><td></td><td><strong>Je favorise la réparabilité et le remplacement de la batterie</strong></td></tr><tr><td>B1</td><td>J'affiche des informations sur la chimie des batteries </td></tr><tr><td>B2</td><td>J'assure la disponibilité de la documentation technique </td></tr><tr><td>B3</td><td>Je permets le retrait de la batterie </td></tr><tr><td>B4</td><td>Je peux intégrer une batterie d'un autre constructeur </td></tr><tr><td>B5</td><td>Je  facilite le démontage du couvercle de la batterie, et le remplacement de ses composants</td></tr><tr><td>B6</td><td>Je permets le remplacement des cellules à l'intérieur d'un module </td></tr><tr><td>B7</td><td>Je dispose d'un réseau de garages habiltés pour la réparation des batteries </td></tr><tr><td></td><td><strong>Je favorise la réparabilité globale de mon véhicule</strong></td></tr><tr><td>C1</td><td>J'assure la disponibilité de la documentation technique </td></tr><tr><td>C2</td><td>Je permets le remplacement des pièces endommagées sur mes véhicules </td></tr><tr><td>C3</td><td>Je facilite la démontabilité du véhicule </td></tr><tr><td>C4</td><td>J'assure la disponibilité des pièces détachées dans le temps (hors batterie) </td></tr><tr><td>C5</td><td>Je facilite la disponibilité des pièces détachées (hors batterie) </td></tr><tr><td>C6</td><td>Je dispose d'un réseau de garages habilité pour la réparation du véhicule </td></tr></tbody></table>

### Vélos à assistance électrique

Le coefficient de durabilité physique `C_physique` est calculé en fonction de l'indice de réparabilité (à paraitre en 2026) :&#x20;

$$
C_{Durabilité} = Coef_{min}+I_{Durabilité} * \frac{Coef_{max}-Coef_{min}}{10}
$$

### Voitures

Le calcul du coefficient de durabilité pourra se baser sur un indice de réparabilité à venir, si celui-ci est pertinent au regard des besoins d'Ecobalyse.

A court terme, il est proposé de fixer le coefficient de durabilité physique `C_physique` par défaut à 1 et de le corriger comme suit, sans pouvoir être inférieur à `Coef_min` :

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

### Pondération entre durabilité physique et non-physique

La variable de pondération `x` entre le coefficient de durabilité physique `C_physique` et le coefficient de durabilité non-physique `C_nonPhysique` est pour l'instant fixée à 0 pour tous les véhicules :&#x20;

$$
C_{Durabilité} = x*C_{Physique} + (1-x)*C_{NonPhysique} = C_{Physique}
$$

Il pourra être modifié pour certaines catégories de véhicules.

### Coefficients de durabilité minimum et maximum :&#x20;

Les coefficient minimum et maximum sont fixés comme suit pour tous les secteurs :&#x20;

* `Coef_min` = 0.5
* `Coef_max` = 1.5

Ces coefficients pourront être modifiés pour certaines catégories de véhicules.

## Exemple d'application

_En cours de rédaction._
