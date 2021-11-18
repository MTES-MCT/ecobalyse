---
description: Transformation des fibres de matière première brute en fils.
---

# Matière et filature

## Matières proposées

Les matières proposées dans le calculateur sont les matières des les impacts (couplés à la filature associée) sont modélisés dans la [Base Impacts® de l'ADEME](https://www.base-impacts.ademe.fr).&#x20;

3 types de matières sont distinguées dans la base Impacts :

* Matières naturelles
* Matières synthétiques ou artificielles
* Matières recyclées

Les matières sont réparties en 2 listes dans Wikicarbone

* la liste principale, avec une sélection des matières les plus utilisées, proposées prioritairement
* une liste secondaire, avec les autres matières

## Liste principale

A chacune des matières de la liste principale correspond peut correspondre une matière recyclée.

{% hint style="danger" %}
Pour le coton, le polyester et le polyamide, plusieurs matières recyclées sont proposées dans la base Impacts. Par défaut, une seule de ces matières recyclées est proposée dans la liste principale. Les autres sont renvoyées à la liste secondaire.
{% endhint %}

| Matière naturelles  | UUID                                   | Matières recyclées                               | UUID                                   |
| ------------------- | -------------------------------------- | ------------------------------------------------ | -------------------------------------- |
| Chanvre             | `08601439-f338-4f94-ac8c-538061b65d16` | Non                                              | N/A                                    |
| Coton conventionnel | `f211bbdb-415c-46fd-be4d-ddf199575b44` | Coton recyclé à partir de déchets de production  | `2b24abb0-c1ec-4298-9b58-350904a26104` |
| Laine de mouton     | `376bd165-d354-41aa-a6e3-fd3228413bb2` | Laine recyclée à partir de déchets de production | `92dfabc7-9441-463e-bda8-7bc5943c0e9d` |
| Lin (étoupe)        | `fcef1a31-bb18-49e4-bdb6-e53dfe015ba0` | Non                                              | N/A                                    |
| Lin (filasse)       | `5a6d538-f932-4242-98b4-3a0c6439629c`  | Non                                              | N/A                                    |

{% hint style="danger" %}
Pour les matières synthétiques, les procédés considérés sont les procédés de production de filaments. Les procédés de production de fils, proposés comme alternative dans la base Impacts, ne sont pas intégrés à ce stade.
{% endhint %}

| Matières synthétiques | UUID                                   | Matières recyclées                                             | UUID                                   |
| --------------------- | -------------------------------------- | -------------------------------------------------------------- | -------------------------------------- |
| Acrylique             | aee6709f-0864-4fc5-8760-68cb644a002    | Acrylique recyclé à partir de déchets de production            | `7603beaa-c555-4283-b9f8-4d5d231b8490` |
| Polyamide             | `182fa424-1f49-4728-b0f1-cb4e4ab36392` | Polyamide recyclé à partir de déchets de production            | `af5d130d-f18b-438c-9f19-d1ee49756960` |
| Polyester             | `4d57c51d-7d56-46e1-acde-02fbcdc943e4` | Polyester recyclé à partir de bouteilles (recyclage mécanique) | `4072bfa2-1948-4d12-8de9-bbeb6cc628e1` |
| Viscose               | `81a67d97-3cd9-44ef-9ee2-159364364c0f` | Viscose recyclée à partir de déchets de production             | `9671ae26-d772-4bb1-aad5-6b826555d0cd` |

{% hint style="info" %}
En première approche, il n'est pas proposé de combiner des matières pour modéliser un vêtement multi-matières. En revanche, une part de matière recyclée peut être prise en compte pour les matières de la liste principale auxquelles des matières recyclées correspondent.

D'autre part, matières et filatures sont des procédés indissociables dans la [base Impacts](http://www.base-impacts.ademe.fr).
{% endhint %}

## Liste complète

La liste complète des matières est précisée ci-après. Les matières de la liste principales sont identifiées en <mark style="color:blue;">bleu</mark>.

En complément, il est précisé dans ce tableau (<mark style="color:red;">travail en cours à compléter</mark>) :&#x20;

* la géographie considérée pour le procédé (et plus précisément pour la filature), ce qui renvoie notamment au mix électrique sous-jacent ;
* le pays considéré, dans le simulateur, pour calculer ensuite la distance de transport vers l'étape suivante ;
* les informations disponibles dans la documentation sectorielle de la base Impacts concernant les technologies de filature mises en oeuvre.

{% hint style="warning" %}
Lorsqu'un mélange de matières primaire et recyclée est considéré, on ne retient qu'un seul pays pour l'origine du fil.
{% endhint %}

| Matières naturelles                                         | UUID procédé                           | Géographie considérée pour la filature (base Impacts) | Pays de filature considéré (hypothèse) | Technologie de filature (base Impacts) |
| ----------------------------------------------------------- | -------------------------------------- | ----------------------------------------------------- | -------------------------------------- | -------------------------------------- |
| Plume de canard                                             | `d1f06ea5-d63f-453a-8f98-55ce78ae7579` | Asie / Pacifique                                      | Chine                                  | Non précisé                            |
| Fil d'angora                                                | 29bddef1-d753-45af-9ca6-aec05e2d02b9   | Asie                                                  | Chine                                  | Ring spinning                          |
| Fil de soie                                                 | `94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68` | Asie\*                                                | Chine                                  | Non précisé                            |
| <mark style="color:blue;">Fil de lin (filasse)</mark>       | `e5a6d538-f932-4242-98b4-3a0c6439629c` | Asie                                                  | Chine                                  | wet spinning                           |
| <mark style="color:blue;">Fil de lin (étoupe)</mark>        | `fcef1a31-bb18-49e4-bdb6-e53dfe015ba0` | Asie                                                  | Chine                                  | specific dry spinning process          |
| Fil de laine de mouton Mérinos                              | `4e035dbf-f48b-4b5a-94ea-0006c713958b` | Asie / Pacifique                                      | Chine                                  | Non précisé                            |
| <mark style="color:blue;">Fil de laine de mouton</mark>     | `376bd165-d354-41aa-a6e3-fd3228413bb2` | Asie                                                  | Chine                                  | average spinning process for wool      |
| Fil de laine de chameau                                     | `c191a4dd-5080-4eb6-9c59-b13c943327bc` | Asie                                                  | Chine                                  | Traditionnal ring spinning             |
| Fil de jute                                                 | `72010874-4d26-4c7a-95de-c6987dfdedeb` | Asie                                                  | Chine                                  | Non précisé                            |
| <mark style="color:blue;">Fil de coton conventionnel</mark> | `f211bbdb-415c-46fd-be4d-ddf199575b44` | Asie                                                  | Chine                                  | average spinning process for cotton    |
| <mark style="color:blue;">Fil de chanvre</mark>             | `08601439-f338-4f94-ac8c-538061b65d16` | Asie                                                  | Chine                                  | Wet spinning                           |
| Fil de cachemire                                            | `380c0d9c-2840-4390-bd3f-5c960f26f5ed` | Asie                                                  | Chine                                  | Traditionnal ring spinning             |
| Fibres de kapok                                             | `36cdbfc4-3f48-47b0-8ae0-294bb6017df1` | Asie / Pacifique                                      | Chine                                  | Non précisé                            |

\*pour le fil de soie, la documentation sectorielle indique simplement une géographie mondiale (GLO), en précisant que celle-ci correspond à la production mondiale. Considérant que cette production est très majoritairement asiatique ([source](https://www.planetoscope.com/matieres-premieres/1731-production-mondiale-de-soie.html)), on retient par défaut une géographie asiatique.

| Matières synthétiques (filaments)                         | UUID procédé                           | Géographie concernée pour la filature (base Impacts) | Pays de filature considéré (hypothèse) | Technologie de filature (base Impacts)                                                                                                   |
| --------------------------------------------------------- | -------------------------------------- | ---------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| <mark style="color:blue;">Filament de viscose</mark>      | `81a67d97-3cd9-44ef-9ee2-159364364c0f` | Asie\*                                               | Chine                                  | Wet spinning                                                                                                                             |
| Filament de polyuréthane                                  | `c3738500-0a62-4b95-b4a2-b7beb12a9e1a` | Asie\*                                               | Chine                                  | Wet spinning                                                                                                                             |
| Filament de polytriméthylène téréphtalate (PTT)           | `eca33573-0d09-4d79-9b28-da42bfcc7a4b` | Asie / Pacifique                                     | Chine                                  | Pas de précision                                                                                                                         |
| Filament de polytéréphtalate de butylène (PBT)            | `7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc` | Asie / Pacifique                                     | Chine                                  | Pas de précision                                                                                                                         |
| Filament de polypropylène                                 | `a30cfbde-393a-40db-9263-ea00bfced0b7` | Europe                                               | Allemagne                              | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning  |
| Filament de polylactide                                   | `f2dd799d-1b69-4e7a-99bd-696bbbd5a978` | Asie\*                                               | Chine                                  | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning  |
| Filament de polyéthylène                                  | `088ed617-67fa-4d42-b3af-ee6cf39cf36f` | Europe                                               | Allemagne                              | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning. |
| <mark style="color:blue;">Filament de polyester</mark>    | `4d57c51d-7d56-46e1-acde-02fbcdc943e4` | Asie\*                                               | Chine                                  | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning. |
| <mark style="color:blue;">Filament de polyamide 66</mark> | `182fa424-1f49-4728-b0f1-cb4e4ab36392` | Europe                                               | Allemagne                              | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning  |
| Filament d'aramide                                        | `7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5` | Global - Asie\*                                      | Chine                                  | Wet spinning                                                                                                                             |
| <mark style="color:blue;">Filament d'acrylique</mark>     | aee6709f-0864-4fc5-8760-68cb644a0021   | Asie\*                                               | Chine                                  | Wet spinning                                                                                                                             |
| Filament bi-composant polypropylène/polyamide             | `37396ac4-13a2-484c-9cc6-5b5a93ff6e6e` | Europe                                               | Allemagne                              | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning  |
| Feuille de néoprène                                       | `76fefff3-3781-49a2-8deb-c12945a6b71f` | Global - Asie\*                                      | Chine                                  | Pas de précision                                                                                                                         |

\*La géographie "Asie" n'est pas explicitement pointée pour la filature dans la documentation sectorielle. C'est toutefois une hypothèse qui semble crédible au regard de la part des pays asiatiques dans la production mondiale ([lien](https://fr.wikipedia.org/wiki/Fibre\_synth%C3%A9tique)) et d'informations fournies par ailleurs dans la documentation, par exemple sur les étapes de texturisation, de thermofixation et de lavage qui sont généralement faites en Asie.

| Matières recyclées                                                                                                                                       |                                        | Géographie concernée pour la filature (base Impacts) | Pays de filature considéré (hypothèse)                                                      | Technologie de filature (base Impacts)                                                                                                                      |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  <mark style="color:blue;">Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation</mark>          | `4072bfa2-1948-4d12-8de9-bbeb6cc628e1` | Asie / Pacifique                                     | Chine (confirmé méta données base Impacts)                                                  | The melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning                         |
|  <mark style="color:blue;"></mark>Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation   | `e65e8157-9bd1-4711-9571-8e4a22c2d2b5` | Asie / Pacifique                                     | Chine (confirmé méta données base Impacts)                                                  | For the melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning                     |
|  Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation                                    | `221067ba-5c2f-4dad-b09a-dd5af0a9ae31` | Asie / Pacifique                                     | Chine (confirmé méta données base Impacts)                                                  | The melt spinning process, in the recycling plant. Two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning |
|  Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production  | `41ee61c2-9a98-4eec-8949-9d9b54289bd0` | Europe puis Asie                                     | Slovénie pour le recycling puis Asie pour le finishing (confirmé méta données base Impacts) | The melt spinning process, two technologies are used: Fully Oriented Yarn (FOY) spinning and Partially Oriented Yarn (POY) spinning                         |
|  <mark style="color:blue;">Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>               | `9671ae26-d772-4bb1-aad5-6b826555d0cd` | Asie / Pacifique                                     | Chine                                                                                       | The spinning, the statistics cover the following technologies: short-staple spindles, long-staple spindles and open-end rotors                              |
|  <mark style="color:blue;">Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>             | `af5d130d-f18b-438c-9f19-d1ee49756960` | Europe                                               | Allemagne                                                                                   | The spinning. The statistics cover the following technologies: short-staple spindles, long-staple spindles and open-end rotors                              |
|  <mark style="color:blue;">Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>                 | `92dfabc7-9441-463e-bda8-7bc5943c0e9d` | France                                               | France                                                                                      | The spinning process of the recycled wool fibres into a wool yarn (2.87 kWh per kg)                                                                         |
|  Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation                                              | `4d23093d-1346-4018-8c0f-7aae33c67bcd` | France                                               | France                                                                                      | Pas de précision                                                                                                                                            |
|  <mark style="color:blue;">Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>                 | `2b24abb0-c1ec-4298-9b58-350904a26104` | Recyclage en Espagne - Filature en France            | France                                                                                      | Pas de précision                                                                                                                                            |
|  <mark style="color:blue;">Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>              | `7603beaa-c555-4283-b9f8-4d5d231b8490` | Asie / Pacifique                                     | Chine                                                                                       | The statistics cover the following technologies: short-staple spindles, long-staple spindles and open-end rotors                                            |
|  Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique)                                                  | `ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f` | France                                               | France                                                                                      | mechanical recycling tearing the textiles into fibres (shredding)                                                                                           |

## Schéma

Conformément à la documentation sectorielle textile de la [base Impacts](http://www.base-impacts.ademe.fr), le système "matière et filature", est schématisé comme suit (exemple de la fibre de laine de mouton et du filament de viscose) :

![](../.gitbook/assets/FibreLaine.PNG)

![](../.gitbook/assets/FilViscose.PNG)

Par conséquent, le système "matière + filature" internalise les procédés externes, tels que l'énergie ou la chaleur. Ceux-ci ne sont donc pas paramétrables en fonction du contexte (pays notamment).

La formule suivante s'applique donc :

$$
ImpactMatière + ImpactFilature = ImpactProcédéMatièreFilature
$$

## Intégration d'une part de matière recyclée

Dans le cas où un pourcentage "r" de matière recyclée est introduit à partir du tableau des matières principales. le calcule de l'impact devient la combinaison des impacts des procédés "matière et filature" retenus pour la matière primaire et pour la matière recyclée :&#x20;

$$
ImpactMatière + Impact Filature = ImpactProcédéMFPrimaire +  ImpactProcédéMFRecyclée
$$

Pour calculer chacun de ces deux impacts, il faut distinguer la part de fil, en sortie de processus, qui provient de la matière primaire et celle qui provient de matières recyclée :  &#x20;

$$
MasseFilSortante (kg) = MasseFilMFPrimaire (kg) + MasseFilMFRecyclée (kg)
$$

Pour ce faire, on introduit le pourcentage "r" de matière recyclée, pourcentage qui s'applique à la masse de fil, en sortie donc de l'étape "matière et filature". Lorsqu'un choix de matière recyclée est proposé, ce pourcentage est représenté dans l'interface avec un curseur mobile.

{% hint style="danger" %}
Le pourcentage "r" de matière recyclée s'applique bien au fil (en sortie) et non à la matière première (en entrée). Les taux de perte étant différents pour la matière première et pour la matière recyclée, le ratio de matières premières serait différent.
{% endhint %}

En pratique, la masse de fil sortante est déterminée en premier, pour correspondre à la masse du produit fini qui est paramétrée (cf. [Pertes et rebut](filature.md#pertes-et-rebut), calcul des masses en remontant la chaîne de production).&#x20;

Chacun des deux masses de fil à déterminer pour calculer ensuite les impacts des procédés "matière primaire" et "matière recyclée", sont établies comme suit :&#x20;

$$
MasseFilMFPrimaire (kg) = (1-r) * MasseFilSortante (kg)
$$

$$
MasseFilMFRecyclée (kg) = r * MasseFilSortante (kg)
$$

Pour la suite du calcul, les formules ci-après s'applique, indépendemment pour la matière primaire et la matière recyclée afin de déterminer :&#x20;

* la masse entrante de matière première à partir des pertes propres à chacun des deux procédés ;
* l'impact de chacun des deux procédés.

## Procédé de matière et filature

L'impact du procédé de confection retenu est le produit de la masse "sortante", en l'occurrence le fil, avec le coefficient d'impact considéré (cf. [Impacts considérés](impacts-consideres.md)).

$$
ImpactProcédéMatièreFilature = MasseSortante(kg) * CoefImpactProcédéMatièreFilature
$$

Les procédés correspondant aux différents choix de matières sont listés dans les 3 tableaux en haut de cette page méthodologique.

## Pertes et rebut

Les procédés de Matière et filature considérés prévoient qu'une partie de la matière première mobilisée soit perdue, comme cela est représenté sur les schémas _System Boundaries_ ci-dessus (Flux intermédiaire - Textile Waste - UUID: `1cc67763-7318-4077-af4a-bcd0ab5ef33f`).

Ces pertes sont prises en compte comme suit :

$$
MasseFilSortante(kg) = MasseMatièreEntrant(kg) + MassePertes(kg)
$$

Avec :

$$
MassePertes(kg) = MasseFilSortante(kg) * CoefPertesProcedeMatièreFilature
$$

Plus de détail sur la gestion des masses : [Pertes et rebut](pertes-et-rebus.md).

## Limites

A prévoir :

* Intégrer les procédés de production de "fils" synthétiques, et non pas seulement les procédés de "filaments" synthétiques.
* Intégration de vêtements multi-matière
* Lorsqu'une part de matière recyclée peut être introduire, ouvrir la possibilité de distinguer l'origine de la matière primaire et de la matière recyclée
* Pour les matières qui peuvent être issues de différents types de recyclage, regrouper ces différentes sous-options dans le tableau principal
* Prise en compte de la _Circular Footprint Formula_ du projet de _PEFCR Apparel & Footwear_
* Chercher à distinguer matières et filature pour pouvoir moduler ces deux étapes, et notamment la filature, en fonction du pays concerné

## \[A venir] Calcul contextualisé de la filature

Pour apporter plus de précision dans le calcul, en fonction du pays dans lequel la filature serait réalisée, des hypothèses sont faites pour évaluer l'impact de la filature, considéré comme un sous-ensemble du procédé "matière et filature".

$$
ImpactFilatureEstimé = ImpactElecEstimé + ImpactChaleurEstimé
$$

L'estimation des impacts de la filature permet ensuite, par soustraction, d'estimer l'impact des autres étapes couvertes dans le procédé "matière et filature", regroupées par simplification sous le terme "matière".

$$
ImpactMatièreEstimée = ImpactProcédéMatièreFilature - ImpactFilatureEstimée(PaysParDéfaut)
$$

{% hint style="danger" %}
Pour calculer l'impact "matière", il convient de soustraire l'impact de la filature estimé pour la géographie de référence retenue dans la base Impacts. Pour chaque matière, la géographie de référence est précisée dans les 3 tableaux supra (colonne géographie ou pays de filature).

En revanche, l'impact de la filature peut bien être calculé pour différentes géographies (et donc différents mix électriques ou mix de chaleur), afin de rendre compte d'une filature qui serait réalisée sur un autre pays/géographie que celui de référence de la base Impacts.
{% endhint %}

Concernant le détail du calcul de l'impact filature, pour l'électricité :&#x20;

$$
ImpactElecEstimé = ElecConsommée (kWh) * ImpactProcédéElec
$$

$$
ElecConsommée (kWh) = MasseSortante (kg) * CoefElecFilature (kWh/kg)
$$

et pour la chaleur :&#x20;

$$
ImpactChaleurEstimé = ChaleurConsommée (MJ) * ImpactProcédéChaleur
$$

$$
ChaleurConsommée (kWh) = MasseSortante (kg) * CoefChaleurFilature (kWh/kg)
$$

{% hint style="danger" %}
Les coefficients sont ici définis en kWh/kg, et non en MJ/kg comme dans la base Impacts
{% endhint %}

Pour estimer l'impact de la filature, il convient donc, pour chaque matière, d'arrêter les paramètres suivants :&#x20;

| Matières naturelles                                         | UUID procédé                           | CoefElecFilature (kWh/kg) | CoefElecChaleur (kWh/kg) | Source / commentaire                                           |
| ----------------------------------------------------------- | -------------------------------------- | ------------------------- | ------------------------ | -------------------------------------------------------------- |
| Plume de canard                                             | `d1f06ea5-d63f-453a-8f98-55ce78ae7579` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil d'angora                                                | 29bddef1-d753-45af-9ca6-aec05e2d02b9   | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil de soie                                                 | `94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| <mark style="color:blue;">Fil de lin (filasse)</mark>       | `e5a6d538-f932-4242-98b4-3a0c6439629c` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| <mark style="color:blue;">Fil de lin (étoupe)</mark>        | `fcef1a31-bb18-49e4-bdb6-e53dfe015ba0` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil de laine de mouton Mérinos                              | `4e035dbf-f48b-4b5a-94ea-0006c713958b` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| <mark style="color:blue;">Fil de laine de mouton</mark>     | `376bd165-d354-41aa-a6e3-fd3228413bb2` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil de laine de chameau                                     | `c191a4dd-5080-4eb6-9c59-b13c943327bc` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil de jute                                                 | `72010874-4d26-4c7a-95de-c6987dfdedeb` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| <mark style="color:blue;">Fil de coton conventionnel</mark> | `f211bbdb-415c-46fd-be4d-ddf199575b44` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| <mark style="color:blue;">Fil de chanvre</mark>             | `08601439-f338-4f94-ac8c-538061b65d16` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fil de cachemire                                            | `380c0d9c-2840-4390-bd3f-5c960f26f5ed` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |
| Fibres de kapok                                             | `36cdbfc4-3f48-47b0-8ae0-294bb6017df1` | 10                        | 9                        | <p>Cycleco - 2011</p><p>Données pour les fibres naturelles</p> |



| Matières synthétiques (filaments)                         | UUID procédé                           | CoefElecFilature (kWh/kg) | CoefElecChaleur (kWh/kg) | Source / commentaire                                             |
| --------------------------------------------------------- | -------------------------------------- | ------------------------- | ------------------------ | ---------------------------------------------------------------- |
| <mark style="color:blue;">Filament de viscose</mark>      | `81a67d97-3cd9-44ef-9ee2-159364364c0f` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polyuréthane                                  | `c3738500-0a62-4b95-b4a2-b7beb12a9e1a` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polytriméthylène téréphtalate (PTT)           | `eca33573-0d09-4d79-9b28-da42bfcc7a4b` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polytéréphtalate de butylène (PBT)            | `7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polypropylène                                 | `a30cfbde-393a-40db-9263-ea00bfced0b7` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polylactide                                   | `f2dd799d-1b69-4e7a-99bd-696bbbd5a978` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament de polyéthylène                                  | `088ed617-67fa-4d42-b3af-ee6cf39cf36f` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| <mark style="color:blue;">Filament de polyester</mark>    | `4d57c51d-7d56-46e1-acde-02fbcdc943e4` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| <mark style="color:blue;">Filament de polyamide 66</mark> | `182fa424-1f49-4728-b0f1-cb4e4ab36392` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament d'aramide                                        | `7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| <mark style="color:blue;">Filament d'acrylique</mark>     | aee6709f-0864-4fc5-8760-68cb644a0021   | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Filament bi-composant polypropylène/polyamide             | `37396ac4-13a2-484c-9cc6-5b5a93ff6e6e` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |
| Feuille de néoprène                                       | `76fefff3-3781-49a2-8deb-c12945a6b71f` | 12                        | 0                        | <p>Cycleco - 2011</p><p>Données pour les fibres synthétiques</p> |



| Matières recyclées                                                                                                                                       | UUID                                   | CoefElecFilature (kWh/kg) | CoefElecChaleur (kWh/kg) | Source / commentaire                   |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- | ------------------------- | ------------------------ | -------------------------------------- |
|  Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation                                           | `4072bfa2-1948-4d12-8de9-bbeb6cc628e1` |                           |                          |                                        |
|  <mark style="color:blue;">Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation</mark>   | `e65e8157-9bd1-4711-9571-8e4a22c2d2b5` |                           |                          |                                        |
|  Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation                                    | `221067ba-5c2f-4dad-b09a-dd5af0a9ae31` |                           |                          |                                        |
|  Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production  | `41ee61c2-9a98-4eec-8949-9d9b54289bd0` |                           |                          |                                        |
|  <mark style="color:blue;">Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>               | `9671ae26-d772-4bb1-aad5-6b826555d0cd` |                           |                          |                                        |
|  <mark style="color:blue;">Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>             | `af5d130d-f18b-438c-9f19-d1ee49756960` |                           |                          |                                        |
|  <mark style="color:blue;">Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>                 | `92dfabc7-9441-463e-bda8-7bc5943c0e9d` | 2,87                      | 0                        | Base Impacts (méta données du procédé) |
|  Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation                                              | `4d23093d-1346-4018-8c0f-7aae33c67bcd` |                           |                          |                                        |
|  <mark style="color:blue;">Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>                 | `2b24abb0-c1ec-4298-9b58-350904a26104` |                           |                          |                                        |
|  <mark style="color:blue;">Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles</mark>              | `7603beaa-c555-4283-b9f8-4d5d231b8490` |                           |                          |                                        |
|  Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique)                                                  | `ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f` |                           |                          |                                        |

Le rapport de Cycleco pris comme référence est accessible sur [ce lien](https://textile.cycleco.eu/ecrans/references/cycleco\_proposition\_bdd\_semi\_specifiques\_06122011.pdf).
