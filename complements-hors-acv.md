---
hidden: true
---

# Compléments hors ACV - old

Ces compléments hors ACV visent à prendre en compte les **externalités environnementales de certains modes de production** telles que désignées dans l’[article 2 de la loi Climat et résilience](https://www.legifrance.gouv.fr/jorf/article_jo/JORFARTI000043956979). Ces externalités ne sont aujourd'hui pas intégrées à l'ACV. Pourtant, elles sont essentielles pour appréhender au mieux l'impact systémique de l'agriculture, notamment à l'échelle des territoires. En effet, les pratiques agricoles façonnent grandement les écosystèmes et les paysages, que ce soit en termes de biodiversité (maintien de zones refuges, de corridors écologiques, d'une mosaïque paysagère diversifiée, etc.) ou en termes de résilience face aux aléas divers (préservation contre l'érosion des sols, bouclage des cycles et moindre dépendance à certains nutriments exogènes, régulation naturelle des ravageurs de cultures, etc.). Cinq compléments sont ainsi ajoutés pour prendre en compte ces effets.

## Introduction et formules de calcul

Les services écosystémiques sont attachées à la production agricole. Ils sont donc intégrés à l'étape "Ingrédients" du cycle de vie.

Pour chaque ingrédient, le coût environnemental est la somme de la composante ACV du coût environnemental (cf. [page dédiée](impacts-consideres.md)) et de chacun des 5 services écosystémiques introduits ci-après :&#x20;

$$
CoûtEnvironnemental = ComposanteACV + \sum_{1}^{5}ServicesEcosystémiques
$$

2 types de services écosystémiques sont à distinguer :&#x20;

* Les services écosystémiques "cultures", qui qualifient les productions végétales. Ces services écosystémiques s'appliquent également aux productions animales via les végétaux composant les rations (en intégrant également les prairies).
* Les services écosystémiques "élevages" qui ne s'appliquent qu'aux productions animales

| Service écosystémique  | Application                         | Valeur                                   |
| ---------------------- | ----------------------------------- | ---------------------------------------- |
| Haies                  | Cultures (et élevage via la ration) | Valeur toujours positive                 |
| Taille de parcelles    | Cultures (et élevage via la ration) | Valeur toujours positive                 |
| Diversité culturale    | Cultures (et élevage via la ration) | Valeur toujours positive                 |
| Prairies permanentes   | Elevages                            | Valeur toujours positive                 |
| Chargement territorial | Elevages                            | Valeur pouvant être positive ou négative |

### Rations animales

Les rations animales utilisées pour les calculs des compléments pour les productions animales sont détaillées dans l'onglet "animal-kg" de ce <mark style="color:red;">tableur</mark>.

### Services écosystémiques "cultures" / Groupes de culture

La modélisation des compléments hors ACV proposée (en "niveau 1") dans l'outil Ecobalyse rend compte des impacts et des services écosystémiques à partir de quelques paramètres simples caractérisant les ingrédients : nature de la culture, pays, label éventuel (Agriculture biologique par exemple).

Pour caractériser au mieux les différents ingrédients proposés dans Ecobalyse, chacun est rattaché à un **groupe de culture**.

Les 28 groupes de culture considérés sont ceux du [Registre Parcellaire Graphique](https://geoservices.ign.fr/ressource/194788) niveau 1 (parcelles totales, cultures principales par parcelle, France métropolitaine, millésime 2021) :&#x20;

<table><thead><tr><th width="270">Groupes de culture</th></tr></thead><tbody><tr><td>BLE TENDRE</td></tr><tr><td>MAIS GRAIN ET ENSILAGE</td></tr><tr><td>ORGE</td></tr><tr><td>AUTRES CEREALES</td></tr><tr><td>COLZA</td></tr><tr><td>TOURNESOL</td></tr><tr><td>AUTRES OLEAGINEUX</td></tr><tr><td>PROTEAGINEUX</td></tr><tr><td>PLANTES A FIBRES</td></tr><tr><td>SEMENCES</td></tr><tr><td>GEL (surfaces gelées sans production)</td></tr><tr><td>GEL INDUSTRIEL</td></tr><tr><td>AUTRES GELS</td></tr><tr><td>RIZ</td></tr><tr><td>LEGUMINEUSES A GRAIN</td></tr><tr><td>FOURRAGE</td></tr><tr><td>ESTIVES LANDES</td></tr><tr><td>PRAIRIES PERMANENTES</td></tr><tr><td>PRAIRIES TEMPORAIRES</td></tr><tr><td>VERGERS</td></tr><tr><td>VIGNES</td></tr><tr><td>FRUITS A COQUES</td></tr><tr><td>OLIVIERS</td></tr><tr><td>AUTRES CULTURES INDUSTRIELLES</td></tr><tr><td>LEGUMES-FLEURS</td></tr><tr><td>CANNE A SUCRE</td></tr><tr><td>ARBORICULTURE</td></tr><tr><td>DIVERS</td></tr></tbody></table>

Pour chacun de ces groupes de culture, 3 scénarios sont considérés en première approche

| Scénario  | Champ d'application                                                          |
| --------- | ---------------------------------------------------------------------------- |
| Référence | Cultures végétales (et prairies) en France et en agriculture conventionnelle |
| Bio       | Cultures végétales (et prairies) en France et en agriculture biologique      |
| Import    | Cultures végétales (et prairies) hors France                                 |

{% hint style="warning" %}
Les données mobilisées par l'OFB ou le service statistique du ministère de l'agriculture concernant uniquement les productions en France, des données par défaut sont utilisées pour les productions importées. En l'absence d'informations similaires, des données majorantes sont appliquées.
{% endhint %}

### Services écosystémiques "cultures" / application aux productions animales

Pour appliquer les services écosystémiques "cultures" (haies, tailles de parcelle et diversité culturale) aux ingrédients issus de l'élevage (produits laitiers ou viandes), une logique d'affectation similaire à celle appliquée pour les catégories d'impacts en ACV est appliquée :&#x20;

* L'élevage nécessite des cultures et des prairies pour l'alimentation animale
* Chaque culture (et prairie) mobilisée génère des services écosystémiques dont la modélisation est détaillé ci-après

### Formules de calcul

L'ensemble des formules de calcul implémentées pour le calcul de chacun des 5 services écosystémiques, en distinguant les services écosystémiques "cultures" et les services écosystémiques "élevages" sont détaillés dans le tableur suivant :&#x20;

[https://docs.google.com/spreadsheets/d/1wkwTva7ofeIHJorrlwmJuv-x0uB2jud4r6pqb7aJOwc/edit?usp=sharing](https://docs.google.com/spreadsheets/d/1wkwTva7ofeIHJorrlwmJuv-x0uB2jud4r6pqb7aJOwc/edit?usp=sharing)

## Complément "haies"&#x20;

### Approche globale

En l'absence de données de quantification des externalités positives liées aux haies, Ecobalyse approxime les externalités positives des haies par la quantité de haies (ml/ha)

* Niveau 1 ⇒ complément fonction du label x type de productions
* Label bio dans un premier temps, mais il est possible d'intégrer d'autres labels dès que des données sont disponibles&#x20;

⇒ Objectif : différencier le bio et le conventionnel selon la quantité de haies qui caractérise chacun de ces systèmes

### Données

Croisement entre :

* Registre Parcellaire Graphique (RPG) “conventionnel” x BD HAIE
* RPG Bio x BD HAIE

Par défaut on considère que RPG conventionnel = RPG (IGN) - RPG Bio (Agence Bio)<br>

<figure><img src="https://lh7-us.googleusercontent.com/slidesz/AGV_vUeyvyKVUTf9UE2rcirVXR-iJ-ki3mhvrHHbf3ARNEO1kjm_2hV2ZH16FI5D7J40vb_uBBFnbC19F7TL0To0WagWubP-bi8qa0XDcTbuXZzOVV-LCFMbLT2AtugXYzPTfOrCnbXHUheYp70W6KVzRapReLm7wGMF=s2048?key=EL5kZ_dddkIc8Ka_PGQ4sg" alt=""><figcaption></figcaption></figure>

#### Périmètre :

* Emprise géographique : France métropolitaine → données exhaustives et donc moyennes par culture et mode de production (bio / non bio) significatives
* Groupes de cultures : prise en compte de 22 des 24 groupes de cultures en vigueur dans le RPG\*
* Déclinaison des calculs : nationale (France métropolitaine), régionale, départementale (+ données détaillées par parcelle disponibles également)
* Millésime RPG : 2021

#### Sources des données mobilisées :&#x20;

* RPG niveau 1 (parcelles totales, cultures principales par parcelle, France métropolitaine, millésime 2021) :[ https://geoservices.ign.fr/ressource/194788](https://geoservices.ign.fr/ressource/194788)
* Agence bio (parcelles en AB) :[  https://www.data.gouv.fr/fr/datasets/616d6531c2951bbe8bd97771/](https://www.data.gouv.fr/fr/datasets/616d6531c2951bbe8bd97771/)  (National - année 2021)
* Dispositif de suivi des bocages - DSB de l'IGN/OFB (haies) :[ https://geoservices.ign.fr/bdtopo#telechargementshpreg](https://geoservices.ign.fr/bdtopo) (la BD HAIE est contenue dans la BD TOPO, dossier « Occupation du Sol »)

### Synthèse des résultats obtenus

<figure><img src="https://lh7-us.googleusercontent.com/slidesz/AGV_vUenk1JYQpMdM3wpNT0e201j0oWG7lM2KeZc3qJyrFki2cVgY5JeDcr2067QL16IRVT5S0ADGb9nsuKF_UKrfF8NPJl02vc95wJ-Ej1UWTo4m4k5iCth13E-rcIyRup1uv1GqdFIzqJ9FvbV_BonEE92DFDJ0ug=s2048?key=EL5kZ_dddkIc8Ka_PGQ4sg" alt=""><figcaption></figcaption></figure>

&#x20;Par rapport aux parcelles Non bio , les parcelles Bio présentent en moyenne :

* \+ de haies pour 15/20 groupes de cultures
* autant de haies  (- de 10% de différence) pour 5/20 gpes de cultures (Fourrage, Prairies permanentes, Prairies temporaires, Fruits à coque, Oliviers)

Quel que soit le mode de production, les groupes de cultures avec :

* le + de haies sont les prairies
* le - de haies sont les estives et landes (milieux ouverts)

Les + gros écarts entre Bio et Non bio concernent les groupes de cultures:

* Légumes/fleurs en valeur absolue (+ 46 ml/ha pour le bio)
* Autres cultures industrielles en valeur relative (+ 306% pour le bio)

## Complément "taille des parcelles"

### Approche globale

En l'absence de données données disponibles sur les IAE hors haies, on approxime les externalités positives des autres IAE par la taille des parcelles. La logique est que les plus petites parcelles génèrent plus de « bords de champs » et autres zones lisières

* Niveau 1 ⇒ complément fonction du label x type de productions
* Label bio dans un premier temps, mais besoin de données sur autres labels

⇒ Objectif : différencier le bio et le conventionnel selon la taille des parcelles qui caractérise chacun de ces systèmes

### Données

Etude de la taille des parcelles :

* RPG “conventionnel”
* RPG Bio (Agence bio)

Par défaut on considère que RPG conventionnel = RPG (IGN) - RPG Bio (Agence Bio)

#### Périmètre

* Emprise géographique : France métropolitaine → données exhaustives et donc moyennes par culture et mode de production (bio / non bio) significatives
* Groupes de cultures : prise en compte de 22 des 24 groupes de cultures en vigueur dans le RPG\*
* Déclinaison des calculs : nationale (France métropolitaine), régionale, départementale (+ données détaillées par parcelle disponibles également)
* Millésime RPG : 2021

#### Sources des données mobilisées :

* RPG niveau 1 (parcelles totales, cultures principales par parcelle, France métropolitaine, millésime 2021) :[ https://geoservices.ign.fr/ressource/194788](https://geoservices.ign.fr/ressource/194788)
* Agence bio (parcelles en AB) :[  https://www.data.gouv.fr/fr/datasets/616d6531c2951bbe8bd97771/](https://www.data.gouv.fr/fr/datasets/616d6531c2951bbe8bd97771/)  (National - année 2021)

### Synthèse des résultats obtenus

<figure><img src="https://lh7-us.googleusercontent.com/slidesz/AGV_vUd4bXE1OC1ZdqTv9ScUZO962BbhD8DGwu_hpRzn7jXCE1UsUgv_QofwlhKFi21n_hVPM6W5PqLcP1zuOZMkAihEyW0xTtOFSbP5zI8pTcGP2fGGGRrRcPyiBLcRQKNfu-vmNbHEi1981n10XSVk3Fz5nniTN6lK=s2048?key=EL5kZ_dddkIc8Ka_PGQ4sg" alt=""><figcaption></figcaption></figure>

&#x20;Par rapport aux parcelles Non bio , les parcelles Bio sont en moyenne :

* \+ petites pour 10/21 groupes de cultures (Blé tendre, Orge, Colza, Protéagineux, Riz, Estives et landes, Vergers, Fruits à coque, Autres cultures industrielles, Légumes ou fleurs)
* de même taille (- de 10% de différence) pour 6/21 groupes de cultures (Maïs grain et ensilage, Autres céréales, Tournesol, Prairies permanentes, Prairies temporaires, Vignes)
* \+ grandes pour 5/21 groupes de cultures (Autres oléagineux, Légumineuses à grains, Fourrage, Oliviers, Divers)

Les + gros écarts (hors Divers) entre Bio et Non bio concernent les Autres cultures industrielles (-4.5 ha soit -76% pour le Bio)

## Complément "diversité agricole"

### Approche globale

L'objectif de ce complément est de prendre en compte les services écosystémiques rendus par la diversité culturale en les approximant par la mesure de cette diversité à travers l'**indice de Simpson**.

* Calcul de l’indice de Simpson des Petites Régions Agricoles (PRA)
* Par groupe de cultures, calcul de la moyenne des indices de Simpson des PRA pondérée par la surface du groupe de cultures dans chaque PRA

### Données

* Surfaces conventionnelles/bio par cultures (227) et par PRA (750) (hors Outre-mer)
* Surfaces conventionnelles/bio par groupe de cultures et par PRA

### Synthèse des résultats obtenus

<figure><img src="https://lh7-us.googleusercontent.com/slidesz/AGV_vUfx__xgC6LRtFANKXoxKgRPvZsuSU6AYcy5U1eMpuD1PGdHxn0Bycot2RI3B331pkOUib0-DwqbwG8dCOIQPUghtk16PAHNeiYS23iWSL--gxk5_8osAMAR4sBJN83IE4XMI-rI8POsjTCVVqS3kJ339iQs_qaz=s2048?key=EL5kZ_dddkIc8Ka_PGQ4sg" alt=""><figcaption></figcaption></figure>

L’indice de Simpson des surfaces bio est plus élevé que celui des surfaces conventionnelles, hormis pour le riz, les vergers, vignes, fruits à coque, et oliviers.

## Complément "prairies"

### Approche globale et données mobilisées

Ce complément vise à prendre en compte les externalités positives produites par les prairies en les approximant par la quantité de prairies (ha), c'est-à-dire en isolant la valeur de surfaces de prairies dans chaque ICV.

### Exemple de résultats

<figure><img src="https://lh7-us.googleusercontent.com/slidesz/AGV_vUey4NG-7yWTq5NcNMO8w0gWG56y4E3Mr7F4NQlJAMbTP5JLWbseen-nV_x4SK-AJofqY4oc8tc8JCT_4l_CtcJkH8TIwd6qtY_V9zqV6b_bTZXZZjZvvE8Nviq8anufBIkhQYDRf00pZI9rYHa_LVkz5lUWR3M=s2048?key=EL5kZ_dddkIc8Ka_PGQ4sg" alt=""><figcaption></figcaption></figure>

## Complément "densité territoriale en élevage"

### Approche globale

### Données

## Formules

[Pascal Dagras](https://app.gitbook.com/u/pwxhh5Bm9BgOcSW4v6Dn3wqFG4C2 "mention") et [paul.boosz](https://app.gitbook.com/u/Qw2QhUIB0eTFNu36oXM9fYkEu1t2 "mention")

## Agrégation au coût environnemental

[Pascal Dagras](https://app.gitbook.com/u/pwxhh5Bm9BgOcSW4v6Dn3wqFG4C2 "mention") et [paul.boosz](https://app.gitbook.com/u/Qw2QhUIB0eTFNu36oXM9fYkEu1t2 "mention")

## Exemples de calcul des compléments



<details>

<summary>Analyse numérique</summary>

```

Bonus_diversité_agricole = 0.5 * 2.3 * 4.14 
Bonus_diversité_agricole = 4.76 µPts d'impacts


Bonus_infra_agro_écologique = 0.7 * 2.3 * 4.14 
Bonus_infra_agro_écologique = 6.67 µPts d'impacts

Bonus_cond_élevage = 0.3 * 1.5 * 4.14 
Bonus_cond_élevage = 1.86 µPts d'impacts


Bonus_total = Bonus_diversité_agricole + Bonus_infra_agro_écologique + Bonus_cond_élevage
Bonus_total = 4.76 + 6.67 + 1.86
Bonus_total = 13.3 µPts d'impacts

```

On a finalement :

```
Score d'impacts avant bonus = 97.04 µPts d'impact

Score d'impacts après bonus = Score d'impacts avant bonus - Bonus_total
Score d'impacts après bonus = 97.04 - 13.3
Score d'impacts après bonus = 83.74 µPts d'impact
```

</details>

