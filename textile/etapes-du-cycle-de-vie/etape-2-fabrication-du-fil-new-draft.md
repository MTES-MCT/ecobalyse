---
description: >-
  Une mise à jour est en cours => la méthode/documentation ci-dessous est en
  cours d'enrichissement.
---

# 🧶 Etape 2 - Fabrication du fil (new - draft)

## Description

La fabrication d’un fil consiste à assembler un ensemble de fibres (filé de fibres) ou filaments (fil continu) afin de le rendre utilisable pour la fabrication de produits textiles. Les propriétés recherchées sont nombreuses (élasticité, régularité, résistance, finesse, etc.) et dépendent de besoins métier eux aussi variés (habillement, ameublement, chaussures, etc.).

La fabrication d’un fil peut prendre deux formes :&#x20;

* la **filature** pour les fibres discontinues (staple yarn)
* le **filage** pour les fibres continues (filaments)

<details>

<summary>Focus Filature</summary>

La filature concerne la fabrication d'un fil constitué de fibres discontinues. Les fibres naturelles ou artificielles sont majoritairement des fibres discontinues.&#x20;

Le fil résultant de l’assemblage de fibres discontinues est un filé (spun yarn).

Les fibres discontinues sont de différentes **longueurs**, on distingue généralement :&#x20;

* les fibres courtes => longueur inférieure à 5cm (ex : coton),
* les fibres longues => longueur supérieure à 5cm (ex : laine).

De plus, la filature permet de fabriquer des fils plus ou moins **gros.** Plus un fil est fin, plus le fil nécessite des fibres de bonne qualité - donc longues -. La filature d'un fil fin nécessite généralement une étape supplémentaire dans la préparation du fil : le peignage.

En **synthèse**, les procédés de filature peuvent être appréhendés comme suit :&#x20;

![](<../../.gitbook/assets/Filature 2.png>)



Cinq principales **étapes** sont nécessaires pour la filature :&#x20;

1. Epurer et nettoyer les fibres afin d’enlever le maximum d’impuretés
2. Démêler les fibres et les isoler afin de les disposer sous la forme d’un ruban continu (tout en poursuivant l’épuration des éléments non souhaités)
3. Paralléliser les fibres constituant ce ruban et parfaire l’opération en éliminant complètement les poussières/duvets/débris/fibres très courtes
4. Régulariser et affiner progressivement le ruban de fibres parallélisées afin d’obtenir la grosseur et la régularité requise
5. Tordre sur elle-même cette mèche afin de donner la cohésion et solidité nécessaire au fil obtenu; puis l’enrouler sur un support&#x20;
6. Fabriquer le fil (filature)\
   Deux techniques existent : \
   \- Conventionnelle = filature à anneaux (ring spun)\
   \- Non conventionnelle = filature à bouts libérées (open-end)\
   Productivité : 5x à 10x plus élevée (ne permet cependant pas de fabriquer des fils aussi fins que la filature à anneaux (la limite étant autour de 50 Nm). \
   En moyenne, la filature conventionnelle permet de fabriquer des fils constitués de 50 fibres tandis que celle non conventionnelle nécessite à minima 80 fibres.&#x20;

</details>

<details>

<summary>Focus Filage</summary>

Le filage concerne la fabrication d'un fil constitué de filaments (fibres continues). Les fibres synthétiques sont des fibres continues.&#x20;

Un filament se caractérise par une très grande longueur. Le fil résultant du filage s’appelle un fil monofilamentaire ou multifilamentaire (si le fil est constitué de plusieurs filaments).

Les filaments peuvent aussi être découpés afin de devenir des fibres discontinues (par craquage ou convertissage) permettant de mélanger des fibres de nature différente.&#x20;

Plusieurs étapes sont nécessaires pour filer des filaments :&#x20;

1. Extrusion de la matière afin de former des filaments via le passage de la matière dans les orifices de la filière
2. Etirage des filaments pour former des fibres continues&#x20;
3. Filage des filaments afin d’obtenir un fil (3 options possibles)\
   \- à sec : les polymères en solution passent une filière qui se situe dans un courant d’air chaud qui solidifie les filaments\
   \- par voie humide : les polymères en solution sont immergés dans un bain coagulant qui solidifie les filaments\
   \- par fusion : les polymères fondus passent dans une filière qui se situe dans un courant d’air froid qui solidifie les filaments

A la sortie de la filière les multi-filaments obtenus sont soit étirés entre plusieurs rouleaux pour former des fils continus soit coupés en fibres discontinues.

</details>

<details>

<summary>Différents types de fil existent (filé, fil simple-retors-cablé-etc.)</summary>

Les principaux types de fil sont les suivants :&#x20;

* filé (de fibres) ou multifilament : fil composé de plusieurs filaments (fibres continues) avec ou sans torsion
* fil simple : fil sans torsion (thread yarn)
* fil retors : fil composé de plusieurs fils simples avec torsion (plied yarn)
* fil cablé (cabled yarn) : fil composé de plusieurs fils, dont au moins un retors
* fil assemblé : fil sans torsion composé de plusieurs fils simple/retors/câblé&#x20;
* fil fantaisie : fil avec un esthétisme différent
* fil guipé : fil composé d’un fil d’âme sur lequel on vient enrouler un autre fil afin de le recouvrir&#x20;

</details>

<details>

<summary>La notion de titrage (épaisseur) des fils</summary>

Le titrage indique la grosseur d’un fil textile. L'industrie textile se sert de fils de différentes grosseurs. Le titrage (ou titre) est un système qui identifie la finesse des fils. Il est représenté par le rapport entre le poids et la longueur de ce fil.

Il existe deux systèmes permettant d’exprimer le titrage : \
\- le système direct : plus le fil est fin, plus le numéro est petit (ex : Dtex)\
\- le système indirect : plus le fil est fin, plus le numéro est élevé (ex : Nm)

Ecobalyse permet de préciser le titrage selon les deux systèmes via des unités de référence : le Numéro Metric (Nm) et le Décitex (Dtex).

La majorité des fils utilisés dans l'industrie varient entre une épaisseur minimale (Nm 200) et maximale (Nm 9).

Une valeur par défaut est appliquée selon le type de vêtement (t-shirt, robe, etc.).&#x20;

L'utilisateur a la possibilité de préciser cette valeur par défaut.

Cf. l'onglet [Explorer](https://ecobalyse.beta.gouv.fr/#/explore/textile/products) pour les valeurs par défaut.

</details>

## Modélisation Ecobalyse

### Paramètres mobilisés

<details>

<summary>Type de fibre</summary>

Le choix des fibres/matières (laine, coton, mix, polyester, etc.) impacte directement les étapes de production du fil.&#x20;

Les paramètres directement impactés par le type de fibre sont :&#x20;

* le procédé de fabrication du fil (filature vs filage)
* la technique de filature (conventionnelle vs non conventionnelle)
* le procédé de filature (fil cardé vs peigné)

</details>

<details>

<summary>Filature : technique (conventionnelle vs non-conventionnelle)</summary>

Les deux principales techniques de filature sont disponibles dans l'outil :&#x20;

* ring / à bouts libérés (filature conventionnelle)
* open-end / à anneaux (filature non conventionnelle)&#x20;

La technique non-conventionnelle (open-end) est plus efficace mais plus contraignante (l'ensemble des propriétés permises par la filature conventionnelle ne le sont pas par la filature non-conventionnelle tandis que les fils fins ne peuvent pas être fabriqués par la technique non-conventionnelle).&#x20;

</details>

<details>

<summary>Filature : procédé (cardée vs peignée)</summary>

La filature peut être cardée ("carded") ou peignée ("worsted/combed") selon la longueur des fibres souhaitée dans le fil. Dans le second cas, une étape additionnel (peignage) est mise en place pour éliminer les fibres les plus courtes, optimiser leurs alignement et éliminer les impuretés.&#x20;

Les fibres courtes et longues peuvent être peignées. Cependant, le titrage du fil impact aussi le choix d'ajouter une étape de peignage. Plus le fil est fin, plus la préparation des fibres est poussée, plus l'étape de peignage est nécessaire.

</details>

<details>

<summary>Titrage </summary>

Le titrage du fil est mobilisé à double titre :&#x20;

* lors de l'étape **Tissage** : permet de calculer la densité de fils du tissu et donc la consommation d'électricité (kWh) de l'étape,
* lors de l'étape de **Fabrication du fil**  :  la consommation d'électricité moyenne de la filature/filage d'un kg de fil dépend directement de son titrage (plus le fil est fin, plus la quantité de matière à transformer est élevée pour produire la quantité de fil désirée).&#x20;

</details>

### Méthodologie de calcul

A compléter



### Hypothèses par défaut

<details>

<summary>Fibre &#x3C;=> Procédé (filature vs filage)</summary>

Fibres naturelles et artificielles (coton, laine, lin, viscose, etc.) = **Filature**

Matières synthétiques (acrylic, elastane, etc.) = **Filage**

Mix de matière = **Filature**

</details>

<details>

<summary>Filature (technique) </summary>

Par défaut, les fibres naturelles et artificielles sont fabriquées en filature conventionnelle (ring). L'utilisateur a la possibilité de modifier ce paramètre et de sélectionne la technique open-end (non-conventionnelle).&#x20;

</details>

<details>

<summary>Filature (procédé)</summary>

Les fibres naturelles et artificielles peuvent être de différentes longueur. Ecobalyse attribue par défaut chaque fibre discontinue en :&#x20;

* fibre courte (longueur <5 cm),
* fibre longue (longueur >5 cm).

Cf. [Explorateur Matières ](https://ecobalyse.beta.gouv.fr/#/explore/textile/materials)pour plus d'info.

Selon le titrage du fil, un procédé de filature (cardée vs peignée) est attribué par défaut : ![](<../../.gitbook/assets/image (11).png>)

L'utilisateur a la possibilité de modifier ce paramètre.

</details>

<details>

<summary>Consommation d'électricité (kWh / kg de fil)</summary>

La consommation d'électricité de la fabrication d'un fil dépend directement des paramètres susmentionnés  :&#x20;

* du procédé utilisé (filage vs filature),
* de la technologie de filature utilisée (conventionnelle vs non-conventionnelle),
* du type de filature (cardée vs peignée)
* du titrage du fil\
  (plus le fil est épais, plus la quantité de fil à produire est faible pour un poids donné).&#x20;

**Valeurs par défaut  (kWh / kg de fil)**&#x20;

![](../../.gitbook/assets/image.png)

Ces valeurs par défaut ont été définies par Ecobalyse sur la base des données moyennes collectées dans le cadre des travaux méthodologiques (plus d'info [ici](https://docs.google.com/presentation/d/1NKjkK9IiWRp7aMC\_lmG6cju2XWMgExHR5t-\_GTsq\_jY/edit?usp=sharing)).&#x20;

</details>

<details>

<summary>Titrage &#x26; Consommation d'électricité (kWh)/ kg de fil)</summary>

Une corrélation linéraire est appliquée par défaut entre le titrage du fil (Nm) et la consommation d'électricité (kWh).&#x20;

Par défaut, Ecobalyse considère que les consommations d'électricité pre-définies s'appliquent à un fil moyen dont le titrage est de 50 Nm / 200 Dtex.

_Illustration :_&#x20;

![](https://lh4.googleusercontent.com/VuoNnhNFXR6IPFHxgiVB-YFL6UEWKkbQz5GdqGbT\_BoS2UKbR1JsbYfYX8JKvOzmz\_Vxu\_0KwJ4stNIdrgcr1vEMdNz9tNotYCbpkRRy5Kk\_C0OSqdLMDtnyPUsEIo85pjHcqmBeki-lg-UM\_aqh30PBKw=s2048)

Toutes choses égales par ailleurs, plus le fil est fin, plus le nombre d'opérations à effectuer lors de la fabrication du fil est élevé pour produire une quantité de fil donnée. Une telle corrélation est mise en lumière dans différents travaux de la filière tandis que plusieurs réferntiels partagent ce constat. C'est par exemple le cas des référentiels _PEFCR A\&F_ et _HiggIndex_ qui déclinent différents procédés de filature selon différents titrages de fil.&#x20;

</details>

#### Taux de pertes (%)

Des taux de perte par défaut sont appliqués selon le type de fibres et la technique de filature.

<table><thead><tr><th width="227.33333333333331">Fibre</th><th width="354">Procédé</th><th>Taux de pertes (%)</th></tr></thead><tbody><tr><td>Naturelle &#x26; Artificielle</td><td>Filature non-conventionnelle (open-end)</td><td>10%</td></tr><tr><td>Naturelle &#x26; Artificielle</td><td>Filature conventionnelle (ring) </td><td>15%</td></tr><tr><td>Synthétique</td><td>Filage</td><td>2%</td></tr></tbody></table>

Ces valeurs par défaut ont été définies par Ecobalyse sur la base des données moyennes collectées dans le cadre des travaux méthodologiques (plus d'info [ici](https://docs.google.com/presentation/d/1NKjkK9IiWRp7aMC\_lmG6cju2XWMgExHR5t-\_GTsq\_jY/edit?usp=sharing)).

L'utilisateur a la possibilité de modifier ce paramètre.&#x20;

## Limites

<details>

<summary>Agents de préparation </summary>

Différents agents de préparation (ex : lubrifiants) sont appliqués sur les fibres tout au long des étapes de la fabrication d'un fil afin d'optimiser les étapes. L'inventaire de ces flux de substances chimiques ainsi que leurs caractérisation est aujourd'hui difficile à évaluer.&#x20;

&#x20;

**Illustration de paramètres modélisables :**&#x20;

![](<../../.gitbook/assets/image (12).png>)

</details>

