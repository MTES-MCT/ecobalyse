---
description: >-
  Cette page décrit les méthodes pour le calcul du coût environnemental du
  châssis et de la carrosserie des véhicules.
hidden: true
---

# 🚙 Châssis & carrosserie

## Généralités

Le terme châssis et carrosserie inclut les cadres de cycles, ainsi que les moyeux.

Le châssis et la carrosserie des nouveaux véhicules intermédiaires peuvent être composés de matériaux très diversifiés : métaux, plastiques, bois, matériaux composites, verre...

### Composants et procédés disponibles

Ecobalyse intègre une bibliothèque de composants pertinents pour la fabrication des chassis et carosseries, construite sur la base de données d'ICV Ecoinvent.&#x20;

De nombreux composants ne sont cependant pas directement disponibles dans Ecoinvent sous la forme d'un procédé, et ont été construits par Ecobalyse. Dès lors, une infinité de composants et de procédés peuvent être proposés par Ecobalyse afin de répondre aux différentes conceptions de véhicules.

Les ressources d'Ecobalyse étant limitées, nous nous concentrons sur la mise à disposition de composants génériques permettant de couvrir un large éventail de conception de véhicules.

{% hint style="info" %}
Vous souhaitez proposer un nouveau composant ou préciser les composants actuellement proposés dans Ecobalsye ?&#x20;

Faite nous part de vos contributions dans le canal "VeLI/Véhicule" de la plateforme d'échange [Mattermost](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) ou par mail[^1].&#x20;
{% endhint %}

## Modélisation Ecobalyse

### Méthodologie de calcul <a href="#methodologie-de-calcul" id="methodologie-de-calcul"></a>

Le cout environnemental du châssis est la somme du coût environnemental des matériaux qui le composent.

L'utilisateur peut ajouter autant de matériaux qu'il le souhaite.

### Composants <=> Procédés

Ecobalyse permet de modéliser différents **composants** spécifiques à une industrie grâce à la mise à disposition de nombreux **procédés** (ex : kg d'acier laminé à chaud, m3 de bois de feuillus, etc.).&#x20;

Pour connaître l'ensemble des composants/procédés disponibles dans Ecobalyse, voir l'Explorateur de procédés.

Les procédés disponibles dans Ecobalyse peuvent être : &#x20;

* issus d'un procédé Ecoinvent inchangé (Exemple : Mousse PUR -rigide-),
* créés par Ecobalyse (Exemple : Composant en plastique -PE-).

{% hint style="info" %}
Par défault, Ecobalyse priorise la mise à disposition de procédés Ecoinvent. S'il n'existe pas, un procédé est créé par Ecobalyse.
{% endhint %}

<details>

<summary>Mieux comprendre le choix des procédés</summary>

Une infinité de procédés pourraient être disponibles dans Ecobalyse car les pratiques des industries sont variées. Deux principaux paramètres expliquent cette multitude de scénarios :&#x20;

* des **origines** diverses pour un même procédé/composant (ex : produire une pièce métallique en acier en Chine ou en France engendre des impacts environnementaux significativement différents du fait des mix énergétiques nationaux),
* &#x20;des **procédés/techniques** diverses (ex : produit une pièce métallique en acier laminé à chaud, laminé à froid ou extrudé engendre des impacts environnementaux significativement différents du fait d'étapes de production différentes). &#x20;

Dès lors, Ecobalyse se concentre sur la mise à disposition de "procédés génériques" reflétant les principales pratiques constatées sur une industrie donnée.&#x20;

**Vous souhaitez contribuer** sur la création/enrichissement de tels procédés ?   N'hésitez pas à partager vos retours :&#x20;

* sur la plateforme [Mattermost](https://fabrique-numerique.gitbook.io/ecobalyse/communaute),
* directement par mail[^1].&#x20;

</details>

### Procédés créés par Ecobalyses pour les véhicules

<details>

<summary>Pièce en acier inoxydable</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : _steel production, chromium steel 18/8, hot rolled, RER_\
  Unité : kg\
  Quantité : 1,3 kg\
  Pertes : non applicable
* Etape de transformation\
  Procédé Ecoinvent : _metal working, average for chromium steel product manufacturing, RER_\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 23%

</details>

<details>

<summary>Pièce en acier</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée : \
  Procédé Ecoinvent : Steel production, converter, unalloyed, RER \
  Unité : kg\
  Quantité : 1,3 kg\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent : Metal working, average for steel product manufacturing, RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 23%

</details>

<details>

<summary>Pièce an acier/nickel <mark style="color:orange;">(à préciser)</mark></summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée \
  Procédé Ecoinvent => Iron-nickel-chromium alloy production, RER\
  Unité : kg\
  Quantité : <mark style="color:orange;">1kg</mark>\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent => Metal working, average for metal product manufacturing, RER\
  Unité : kg\
  Quantité : 1 kg\
  Pertes : <mark style="color:orange;">à préciser</mark>

</details>

<details>

<summary>Pièce en aluminium</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : Aluminium production, primary, ingo&#x74;**,** IAIA Area, EU27 & EFTA\
  Unité : kg\
  Quantité : 1,3\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent : Metal working, average for aluminium product manufacturing, RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 23%

</details>

<details>

<summary>Pièce plastique (polypropylene)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : &#x50;_&#x6F;lypropylene production, granulate, RER_\
  Unité : kg\
  Quantité : 1,01\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  &#x49;_&#x6E;jection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Pièce plastique (polyethylene)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : Polyethylene production, high density, granulat&#x65;_, RER_\
  Unité : kg\
  Quantité : 1,01\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  _Injection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Pièce plastique (polyethylene terephthalate)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : _Polyethylene terephthalate production, granulate, amorphous, RER_\
  Unité : kg\
  Quantité : 1,01\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  _Injection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Tissu</summary>

A compléter

</details>

<details>

<summary>Pièce en polyurethane</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : &#x50;_&#x6F;lyurethane production, flexible foam, MDI-based, RER_\
  Unité : kg\
  Quantité : 1,02\
  Pertes : non applicable

- Etape de transformation additionnelle\
  Procédé Ecoinvent : _Extrusion, plastic pipes, RER_\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 2%

</details>

<details>

<summary>Pièce en plastique (ABS) </summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformé\
  Procédé Ecoinvent : &#x41;_&#x63;rylonitrile-butadiene-styrene copolymer production, RER_\
  _Unité : kg_\
  _Quantité : 1,01_\
  _Pertes : non applicable_
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  _Injection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Pièce en plastique (polystyrène)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformé\
  Procédé Ecoinvent : Polystyrene production, expandabl&#x65;_, RER_\
  _Unité : kg_\
  _Quantité : 1,01_\
  _Pertes : non applicable_
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  _Injection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Verre</summary>

Le verre utilisé pour les véhicules est généralement du verre trempé.\
Il est modélisé de la façon suivante :&#x20;

* Matériau transformé : Verre\
  Procédé Ecoinvent Flat glass, uncoated, RER (ecoinvent),\
  Unité : kg\
  Quantité : 1kg
*   Procédé de transformation : trempe du verre

    Tempering, flat glass, GLO (ecoinvent)\
    Unité : kg\
    Quantité : 1kg

</details>

<mark style="color:red;">**A compléter + uniformiser avec Ameublement**</mark>

[^1]: alban.fournier@beta.gouv.fr
