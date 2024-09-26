# 🧱 Autres composants

## Généralités

Contrairement aux [Composants en bois](composants-en-bois.md), la plupart des autres composants (ex : vis, tube en acier, objet plastique, etc.) ne sont pas directement disponibles dans Ecoinvent sous la forme d'un procédé.&#x20;

Dès lors, une infinité de composants et de procédés peuvent être proposés par Ecobalyse afin de répondre aux différents cas d'usage. &#x20;

Les ressources d'Ecobalyse étant limitées, nous nous concentrons sur la mise à disposition de composants génériques permettant de couvrir un large éventail de scénarios. &#x20;

<details>

<summary>Illustration</summary>

De nombreux objets sont constitués de polyethylene (plastique) tels que des sacs de congélation, des jouets pour enfants tels que les LEGO, des tuyaux d'arrosage, de la vaisselle réutilisable, etc.&#x20;

Pour modéliser ces composants constitués de polyethylene, Ecobalyse a créé un composant générique ayant les caractéristiques suivantes :&#x20;

* Nom = Composant plastique (PE) :flag\_fr: / Plastic frame (PE) :flag\_gb:
* Détails =&#x20;
  * Production de 1,06 kg de billes de plastique (PE) \
    (_procédé Ecoinvent = market for polyethylene, high density, granulate, GLO_)\
    \+
  * Thermorformage et Extrusion de 1kg de feuilles de plastique \
    (_procédé Ecoinvent = market for extrusion of plastic sheets and thermoforming, inline, GLO_)

</details>

{% hint style="info" %}
Vous souhaitez proposer un nouveau composant ou préciser les composants actuellement proposés dans Ecobalsye ?&#x20;

Faite nous part de vos contributions dans le canal "Ameublement" de la plateforme d'échange [Mattermost](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) ou par mail[^1].&#x20;
{% endhint %}

## Modélisation Ecobalyse

### Composants <=> Procédé

&#x20;Ecobalyse permet de modéliser différents **composants** spécifiques à une industrie (ex : un pied de chaise pour l'industrie du meuble) grâce à la mise à disposition de nombreux **procédés** (ex : m3 de bois de feuillus, kg d'acier laminé à chaud, etc.).&#x20;

Les procédés disponibles dans Ecobalyse peuvent être : &#x20;

* issus d'un procédé Ecoinvent inchangé (Exemple : Mousse PUR -rigide-),
* créés par Ecobalyse (Exemple : Composant en plastique -PE-).

Pour connaître l'ensemble des composants/procédés disponibles dans Ecobalyse, cf. l'Explorateur de procédés (<mark style="color:orange;">lien à ajouter</mark>)&#x20;

{% hint style="info" %}
Par défault, Ecobalyse priorise la mise à disposition de procédés Ecoinvent. S'il n'existe pas, un procédé est créé par Ecobalyse.
{% endhint %}

<details>

<summary>Mieux comprendre le choix des procédés</summary>

Une infinité de procédés pourraient être disponibles dans Ecobalyse car les pratiques des industries sont variées. Deux principaux paramètres expliquent cette multitude de scénarios :&#x20;

* des **origines** diverses pour un même procédé/composant (ex : produir une pièce métallique en acier en Chine ou en France engendre des impacts environnementaux significativement différents du fait des mix énergétiques nationaux),
* &#x20;des **procédés/techniques** diverses (ex : produit une pièce métallique en acier laminé à chaud, laminé à froid ou extrudé engendre des impacts environnementaux significativement différents du fait d'étapes de production différentes). &#x20;

Dès lors, Ecobalyse se concentre sur la mise à disposition de "procédés génériques" reflétant les principales pratiques constatées sur une industrie donnée.&#x20;

**Vous souhaitez contribuer** sur la création/enrichissement de tels procédés ?   N'hésitez pas à partager vos retours :&#x20;

* sur la plateforme [Mattermost](https://fabrique-numerique.gitbook.io/ecobalyse/communaute),
* directement par mail[^2].&#x20;

</details>

### Procédés créés par Ecobalyse

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

<summary>Pièce plastique (polypropylene)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : P_olypropylene production, granulate, RER_\
  Unité : kg\
  Quantité : 1,01\
  Pertes : non applicable
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  I_njection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<details>

<summary>Pièce plastique (polyethylene)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : Polyethylene production, high density, granulate_, RER_\
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

<summary>Pièce en aluminium</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : Aluminium production, primary, ingot**,** IAIA Area, EU27 & EFTA\
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

<summary>Tissu</summary>

A compléter

</details>

<details>

<summary>Pièce en polyurethane</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée\
  Procédé Ecoinvent : P_olyurethane production, flexible foam, MDI-based, RER_\
  Unité : kg\
  Quantité : 1,02\
  Pertes : non applicable

<!---->

* Etape de transformation additionnelle\
  Procédé Ecoinvent : _Extrusion, plastic pipes, RER_\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 2%

</details>

<details>

<summary>Pièce en plastique (ABS) </summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformé\
  Procédé Ecoinvent : A_crylonitrile-butadiene-styrene copolymer production, RER_\
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

<summary>Pièce en caoutchouc</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformée => 1 kg de matière plastique \
  Procédé Ecoinvent => _Synthetic rubber production, RER_\
  Quantité => 1kg
* Etape de transformation additionnelle => thermoformage\
  Procédé Ecoinvent => I_njection moulding, RER_\
  Quantité => 1kg

</details>

<details>

<summary>Pièce en plastique (polystyrène)</summary>

Procédé créé à partir de 2 procédés Ecoinvent : &#x20;

* Matière transformé\
  Procédé Ecoinvent : Polystyrene production, expandable_, RER_\
  _Unité : kg_\
  _Quantité : 1,01_\
  _Pertes : non applicable_
* Etape de transformation additionnelle\
  Procédé Ecoinvent :  _Injection moulding,_ RER\
  Unité : kg\
  Quantité : 1kg\
  Pertes : 1%

</details>

<mark style="color:red;">**A compléter**</mark>

### Coût environnemental des composants dans Ecobalyse :&#x20;

cf. l'Explorateur pour accéder à la liste des composant en bois disponibles dans Ecobalyse.&#x20;



<figure><img src="../../../.gitbook/assets/Coût environnemental (uPts _ kg) (1).png" alt=""><figcaption></figcaption></figure>

<mark style="color:red;">**A actualiser**</mark>

[^1]: alban.fournier@beta.gouv.fr

[^2]: alban.fournier@beta.gouv.fr
