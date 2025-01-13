# ⚙️ Transformation / Finition

L'utilisateur a la possibilité de préciser la modélisation des composants proposés dans Ecobalyse.&#x20;

Par défaut, Ecobalyse modélise les composants proposés dans l'interface en appliquant sur la matière (ex : plastic granulate) une étape de transformation (ex : injection moulding).&#x20;

L'utilisateur a la possibilité de préciser et/ou ajouter les procédés listés ci-dessous.&#x20;

Ces procédés peuvent être de différentes natures : &#x20;

* procédés de **transformation,** \
  (ex : remplacer le procédé de transformation par défaut d'une pièce plastique de "moulage" par "extrusion")
* procédé de **finition.**\
  (ex : ajouter une étape de galvanisation sur sa pièce métallique en acier)

<details>

<summary>Généralités sur la transformation de matières </summary>

La grande majorité des composants en plastique ou métal sont créés en transformant de la matière grâce à un ou plusieurs procédés de transformation.&#x20;

Les trois principales familles de transformation de matières en composants sont :&#x20;

* **Moulage** de pièces,\
  Consiste à couler des matériaux (métal, plastique, etc.) à l'état liquide dans un moule
* **Usinage** de pièces (fraisage, tournage, perçage, etc.),\
  Consiste à obtenir des surfaces fonctionnelles de bonne précision par enlèvement de matière&#x20;
* **Formage** de pièces,\
  Consiste à obtenir des pièces par des actions mécaniques appliquées à la matière.&#x20;
  * laminage => le matériau passe à travers une paire de rouleaux,
  * extrusion => le matériau est poussé par un orifice,
  * matriçage => le matériau est pressé/estampé autour ou sur une matrice,
  * forgeage => le matériau est compressé localement,
  * poinçonnage => un outil est enfoncé dans le matériau,
  * calandrage => le matériau est pressé dans des rouleaux pour créer des feuilles/films&#x20;

</details>

### Pièces en bois

#### Procédés de finition

<details>

<summary>Mélaminé</summary>

Procédé Ecoinvent : non applicable

Procédé créé par Ecobalyse : Wood panel lamination, RER&#x20;

La modélisation de ce procédé repose sur une étude réalisée sur une usine turque de fabrication de panneaux MDF en 2003 (Source : [Study _\_Turkey \__ 2023](#user-content-fn-1)[^1]).&#x20;

Les paramètres clés retenus pour laminer 1m3 de panneau sont les suivants :&#x20;

* 43 kWh d'électricité,
* 5,6kg de résine Melamine-Urea-Formaldehyde (MUF),
* 6,7kg de résine Melamine Formaldehyde (MF).

Procédé détaillé de stratification d'un aggloméré/MDF :&#x20;

![](<../../../.gitbook/assets/image (324).png>)

</details>

### Pièces métalliques

#### Procédés de transformation&#x20;

<details>

<summary>Laminage (aluminium) </summary>

Procédé Ecoinvent : _Sheet rolling, aluminium, RER_\
_Unité : kg_\
_Pertes :  <mark style="color:orange;">A définir</mark>_

Le laminage est un procédé de déformation physique qui consiste à passer une pièce métallique entre une ou plusieurs rouleaux pour en modifier l'épaisseur. Le laminage peut être effectué à chaud ou à froid. Le laminage à froid nécessite des machines plus puissantes et procure un rendu plus précis.

![](<../../../.gitbook/assets/image (320).png>)

</details>

<details>

<summary>Laminage (acier)</summary>

Procédé Ecoinvent : _Sheet rolling, steel, RER_\
_Unité : kg_\
_Pertes : <mark style="color:orange;">A définir</mark>_

Le laminage est un procédé de déformation physique qui consiste à passer une pièce métallique entre une ou plusieurs rouleaux pour en modifier l'épaisseur. Le laminage peut être effectué à chaud ou à froid. Le laminage à froid nécessite des machines plus puissantes et procure un rendu plus précis.

![](<../../../.gitbook/assets/image (320).png>)

</details>

<details>

<summary>Laminage (acier inoxydable)</summary>

Procédé Ecoinvent : _Sheet rolling, chromium steel, RER_\
_Unité : kg_\
_Pertes : <mark style="color:orange;">A définir</mark>_

Le laminage est un procédé de déformation physique qui consiste à passer une pièce métallique entre une ou plusieurs rouleaux pour en modifier l'épaisseur. Le laminage peut être effectué à chaud ou à froid. Le laminage à froid nécessite des machines plus puissantes et procure un rendu plus précis.

![](<../../../.gitbook/assets/image (320).png>)

</details>

<details>

<summary>Extrusion métallique (aluminium)</summary>

Procédé Ecoinvent : &#x53;_&#x65;ction bar extrusion, aluminium, RER_\
_Unité : kg_\
_Pertes : <mark style="color:orange;">A définir</mark>_

Consiste à pousser la matière grâce à un piston à travers une filière pour lui donner la forme souhaitée. Pour les pièces métalliques, l'extrusion peut être faite à chaud ou à froid et permet d'obtenir des profilés, des barres, des tubes, etc.&#x20;

![](<../../../.gitbook/assets/image (319).png>)

</details>

<details>

<summary>Extrusion métallique (acier)</summary>

Procédé Ecoinvent : _Impact extrusion of steel, hot, 2 strokes,_ _RER_\
_Unité : kg_\
_Pertes : <mark style="color:orange;">A définir</mark>_

Consiste à pousser la matière grâce à un piston à travers une filière pour lui donner la forme souhaitée. Pour les pièces métalliques, l'extrusion peut être faite à chaud ou à froid et permet d'obtenir des profilés, des barres, des tubes, etc.&#x20;

![](<../../../.gitbook/assets/image (319).png>)

</details>

#### Procédés de finition

<details>

<summary>Galvanisation</summary>

Procédé Ecoinvent : _Zinc coating, pieces, RER_\
_Unité : m2_\
_Pertes : 0%_

La galvanisation consiste à recouvrir une pièce d'une couche de zinc dans le but de la protéger contre la corrosion.

</details>

<details>

<summary>Thermolaquage (aluminium) </summary>

Procédé Ecoinvent : _Powder coating, aluminium sheet, RER_\
_Unité : m2_\
_Pertes : 0%_

Consiste à déposer une peinture poudre à la surface de l'objet métallique en utilisant de l'électricité pour fixer électrostatiquement la poudre à la surface. \
Ce revêtement est très résistant et souvent utilisé par l'industrie.

</details>

<details>

<summary>Thermolaquage (acier) </summary>

Procédé Ecoinvent : _Powder coating, steel, RER_\
_Unité : m2_\
_Pertes : 0%_

Consiste à déposer une peinture poudre à la surface de l'objet métallique en utilisant de l'électricité pour fixer électrostatiquement la poudre à la surface. \
Ce revêtement est très résistant et souvent utilisé par l'industrie.

</details>

### Pièces plastiques

#### Procédés de transformation

<details>

<summary>Extrusion plastique</summary>

Procédé Ecoinvent : _Extrusion, plastic film, RER_\
_Unité : kg_\
_Pertes : 2%_

Consiste à faire fondre les granulés de plastique et à les compresser à travers une filière pour créer la forme souhaitée. Pour les pièces plastiques, l'extrusion permet d'obtenir une grande variété de produits tels que des tubesn feuilles, films, etc.

![](<../../../.gitbook/assets/image (322).png>)

</details>

<details>

<summary>Injection plastique</summary>

Procédé Ecoinvent : _Injection moulding, RER_\
_Unité : kg_\
_Pertes : 1%_

Aussi appelé moulage par injection, l'injection plastique consiste à chauffer et fondre des granulés plastique puis à les injecter dans un moule afin d'obtenir la forme souhaitée lorsque la matière refroidit et durcit.

![](<../../../.gitbook/assets/image (315).png>)

</details>

<details>

<summary>Thermoformage</summary>

Procédé Ecoinvent : _Thermoforming, with calendering, RER_\
_Unité : kg_\
_Pertes : 0%_

Consiste à chauffer une feuille plastique et à lui donner la forme souhaitée à l'aide d'un moule dès que la matière a refroidi.&#x20;

![](<../../../.gitbook/assets/image (323).png>)

</details>

#### Procédés de finition



### Autres procédés



[^1]: Environmental impact assessment of melamine coated medium density fiberboard (MDF-LAM) production and cumulative energy demand: A case study in Türkiye.
