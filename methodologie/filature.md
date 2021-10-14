---
description: Transformation des fibres de matière première brute en fils.
---

# Matière et filature

## Matières proposées

Les matières proposées dans le calculateur sont les matières des les impacts (couplés à la filature associée) sont modélisés dans la base Impacts de l'ADEME. 3 types de matières sont distinguées :

* matières naturelles
* matières synthétiques ou artificielles
* matières recyclées

{% hint style="danger" %}
En première approche, il n'est pas proposé de combiner des matières, que ce soit pour modéliser un vêtement multi-matières ou pour prendre en compte l'intégration partielle de matières recyclées (exemple : coton 50% recyclé). Ces points pourront faire l'objet de compléments ultérieurs.

D'autre part, matières et filatures sont des procédés indissociables dans la [base Impacts](http://www.base-impacts.ademe.fr).
{% endhint %}

| Matières naturelles            | UUID procédé                         | Géographie considérée (base Impacts) | Pays de filature considéré (cf. Transport) |
| ------------------------------ | ------------------------------------ | ------------------------------------ | ------------------------------------------ |
| Plume de canard                | d1f06ea5-d63f-453a-8f98-55ce78ae7579 | à préciser                           | Chine                                      |
| Fil de soie                    | 94b4b0e1-61e4-4f4d-b9b2-efe7623b0e68 | à préciser                           | Chine                                      |
| Fil de lin (filasse)           | e5a6d538-f932-4242-98b4-3a0c6439629c | à préciser                           | Chine                                      |
| Fil de lin (étoupe)            | fcef1a31-bb18-49e4-bdb6-e53dfe015ba0 | à préciser                           | Chine                                      |
| Fil de laine de mouton Mérinos | 4e035dbf-f48b-4b5a-94ea-0006c713958b | à préciser                           | Chine                                      |
| Fil de laine de mouton         | 376bd165-d354-41aa-a6e3-fd3228413bb2 | à préciser                           | Chine                                      |
| Fil de laine de chameau        | c191a4dd-5080-4eb6-9c59-b13c943327bc | à préciser                           | Chine                                      |
| Fil de jute                    | 72010874-4d26-4c7a-95de-c6987dfdedeb | à préciser                           | Chine                                      |
| Fil de coton conventionnel     | f211bbdb-415c-46fd-be4d-ddf199575b44 | Asie                                 | Chine                                      |
| Fil de chanvre                 | 08601439-f338-4f94-ac8c-538061b65d16 | à préciser                           | Chine                                      |
| Fil de cachemire               | 380c0d9c-2840-4390-bd3f-5c960f26f5ed | à préciser                           | Chine                                      |
| Fibres de kapok                | 36cdbfc4-3f48-47b0-8ae0-294bb6017df1 | à préciser                           | Chine                                      |



| Matières synthétiques                           | UUID procédé                         |
| ----------------------------------------------- | ------------------------------------ |
| Filament de viscose                             | 81a67d97-3cd9-44ef-9ee2-159364364c0f |
| Filament de polyuréthane                        | c3738500-0a62-4b95-b4a2-b7beb12a9e1a |
| Filament de polytriméthylène téréphtalate (PTT) | eca33573-0d09-4d79-9b28-da42bfcc7a4b |
| Filament de polytéréphtalate de butylène (PBT)  | 7f8bbfdc-fb65-4e3a-ac81-eda197ef17fc |
| Filament de polypropylène                       | a30cfbde-393a-40db-9263-ea00bfced0b7 |
| Filament de polylactide                         | f2dd799d-1b69-4e7a-99bd-696bbbd5a978 |
| Filament de polyéthylène                        | 088ed617-67fa-4d42-b3af-ee6cf39cf36f |
| Filament de polyester                           | 4d57c51d-7d56-46e1-acde-02fbcdc943e4 |
| Filament de polyamide 66                        | 182fa424-1f49-4728-b0f1-cb4e4ab36392 |
| Filament d'aramide                              | 7a1ccc4a-2ea7-48dc-9ef0-d57066ea8fa5 |
| Filament bi-composant polypropylène/polyamide   | 37396ac4-13a2-484c-9cc6-5b5a93ff6e6e |
| Feuille de néoprène                             | 76fefff3-3781-49a2-8deb-c12945a6b71f |

| Matières recyclées                                                                                                                                       |                                      |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
|  Production de filament de polyester recyclé (recyclage mécanique), traitement de bouteilles post-consommation                                           | 4072bfa2-1948-4d12-8de9-bbeb6cc628e1 |
|  Production de filament de polyester recyclé (recyclage chimique partiel), traitement de bouteilles post-consommation                                    | e65e8157-9bd1-4711-9571-8e4a22c2d2b5 |
|  Production de filament de polyester recyclé (recyclage chimique complet), traitement de bouteilles post-consommation                                    | 221067ba-5c2f-4dad-b09a-dd5af0a9ae31 |
|  Production de filament de polyamide recyclé (recyclage chimique), traitement de déchets issus de filets de pêche, de tapis et de déchets de production  | 41ee61c2-9a98-4eec-8949-9d9b54289bd0 |
|  Production de fil de viscose recyclé (recyclage mécanique), traitement de déchets de production textiles                                                | 9671ae26-d772-4bb1-aad5-6b826555d0cd |
|  Production de fil de polyamide recyclé (recyclage mécanique), traitement de déchets de production textiles                                              | af5d130d-f18b-438c-9f19-d1ee49756960 |
|  Production de fil de laine recyclé (recyclage mécanique), traitement de déchets de production textiles                                                  | 92dfabc7-9441-463e-bda8-7bc5943c0e9d |
|  Production de fil de coton recyclé (recyclage mécanique), traitement de déchets textiles post-consommation                                              | 4d23093d-1346-4018-8c0f-7aae33c67bcd |
|  Production de fil de coton recyclé (recyclage mécanique), traitement de déchets de production textiles                                                  | 2b24abb0-c1ec-4298-9b58-350904a26104 |
|  Production de fil d'acrylique recyclé (recyclage mécanique), traitement de déchets de production textiles                                               | 7603beaa-c555-4283-b9f8-4d5d231b8490 |
|  Production de fibres recyclées, traitement de déchets textiles post-consommation (recyclage mécanique)                                                  | ca5dc5b3-7fa2-4779-af0b-aa6f31cd457f |

## Schéma

Conformément à la documentation sectorielle textile de la [base Impacts](http://www.base-impacts.ademe.fr), le système "matière et filature", est schématisé comme suit (exemple de la fibre de laine de mouton et du filament de viscose) :

![](../.gitbook/assets/FibreLaine.PNG)

![](../.gitbook/assets/FilViscose.PNG)

Par conséquent, **pour les fibres naturelles**, le système "matière + filature" internalise les procédés externes, tels que l'énergie ou la chaleur. Ceux-ci ne sont donc pas paramétrables en fonction du contexte (pays notamment).

La formule suivante s'applique donc :

$$
ImpactMatière + ImpactFilature = ImpactProcédéMatièreFilature
$$

## Procédé de matière et filature

L'impact du procédé de confection retenu est le produit de la masse "entrante", en l'occurrence la matière première, avec le coefficient d'impact considéré (cf. [Impacts considérés](impacts-consideres.md)).

$$
ImpactProcédéMatièreFilature = MasseEntrante(kg) * CoefImpactProcédéMatièreFilature
$$

Les procédés correspondant aux différents choix de matières sont listés dans les 3 tableaux en haut de cette page méthodologique.

## Pertes et rebus

Les procédés de Matière et filature considérés prévoient qu'une partie de la matière première mobilisée soit perdue, comme cela est représenté sur les schémas "system boundaries" ci-dessus (Flux intermédiaire - Textile Waste - UUID: `1cc67763-7318-4077-af4a-bcd0ab5ef33f`).

Ces pertes sont prises en compte comme suit :

$$
MasseFilSortante(kg) = MasseMatièreEntrant(kg) + MassePertes(kg)
$$

Avec :

$$
MassePertes(kg) = MasseFilSortante(kg) * CoefPertesProcedeMatièreFilature
$$

Plus de détail sur la gestion des masses : [Pertes et rebus](pertes-et-rebus.md).

## Limites

A prévoir :

* Intégration de vêtements multi-matière
* Intégration d'une combinaison de matière, notamment une part de matière recyclée
* Prise en compte de la _Circular Footprint Formula_ du projet de _PEFCR Apparel & Footwear_
* Chercher à distinguer matières et filature pour pouvoir moduler ces deux étapes, et notamment la filature, en fonction du pays concerné
