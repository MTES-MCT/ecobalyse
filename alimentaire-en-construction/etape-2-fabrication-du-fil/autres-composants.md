# ⚙️ Autres composants

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

### Deux types de composants/procédés sont proposés par Ecobalyse

Tout composant proposé dans Ecobalyse est soit issu d'un :&#x20;

{% tabs %}
{% tab title="Procédé Ecoinvent inchangé" %}
Exemple : Mousse PUR (rigide)

Pour connaître l'ensemble des composants/procédés disponibles dans Ecobalyse, cf. l'Explorateur de procédés (<mark style="color:orange;">lien à ajouter</mark>)&#x20;
{% endtab %}

{% tab title="Procédé créé par Ecobalyse" %}
Exemple : Composant en plastique (PE)

Pour connaître l'ensemble des composants/procédés disponibles dans Ecobalyse, cf. l'Explorateur de procédés (<mark style="color:orange;">lien à ajouter</mark>)&#x20;
{% endtab %}
{% endtabs %}

Par défault, Ecobalyse utilise un procédé Ecoinvent pour modéliser un composant lorsqu'il existe. &#x20;

{% hint style="info" %}
La majorité des composants proposés dans Ecobalyse nécessitent de la matière (ex : des billes de plastique) puis une ou plusieurs étapes de transformation (ex : thermoformage et extrusion de feuilles de plastique).&#x20;

Il est rare que Ecoinvent propose des procédés regroupant ces différentes étapes.&#x20;

Ainsi, dans la majorité des cas, Ecobalyse crée des procédés en asssemblant différents procédés Ecoinvent.&#x20;
{% endhint %}

### Composants disponibles dans Ecobalyse :&#x20;

cf. l'Explorateur pour accéder à la liste des composant en bois disponibles dans Ecobalyse.&#x20;

<figure><img src="../../.gitbook/assets/Coût environnemental des composants autres que ceux en bois (uPts _ kg).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/Coût environnemental de tous les composants (uPts _ kg) (1).png" alt=""><figcaption><p>Les composants en bois (exprimés en uPts / m3) ont été convertiés en Upts / kg via une densité par défaut (cf. Explorateur)</p></figcaption></figure>



## Focus techniques

<details>

<summary>Procédés de transformation</summary>

La grande majorité des composants en plastique ou métal sont créés en transformant de la matière grâce à un ou plusieurs procédés de transformation.&#x20;

Afin de proposer des modélisations précises et accessibles, Ecobalyse permet de préciser quel(s) procédé(s) de transformation sont utilisés pour obtenir un composant en plastique ou métal :&#x20;

* **Moulage** de pièces,\
  Consiste à couler du métal à l'état liquide dans un moule
* **Usinage** de pièces (fraisage, tournage, perçage, etc.),\
  Consiste à obtenir des surfaces fonctionnelles de bonne précision par enlèvement de matière&#x20;
* **Formage** de pièces (estampage, matriçage, filage, etc.),\
  Consiste à obtenir des pièces par des actions mécaniques appliquées à la matière

</details>

<details>

<summary>Procédés d'assemblage</summary>

Différents types d'assemblage existent (assemblage par sertissage, par rivetage, par soudage, par collage, etc.).&#x20;

Afin de proposer des modélisations précises et accessibles, Ecobalyse permet de préciser certains procédés d'assemblage :&#x20;

* Assemblage par soudage\
  Consiste à assembler deux ou plusieurs pièces par chauffage et/ou pression. Le soudage par chauffage est la méthode la plus courante.
* Assemblage par collage\
  Consiste à lier deux pièces par l'apport de matière adhésive (colle). &#x20;

</details>

<details>

<summary>Procédés de finition</summary>

Plusieurs procédés de finition sont utilisés :&#x20;

* **revêtement en poudre**,\
  Consiste à pulvériser de la poudre sèche sur la surface de l'objet métallique en utilisant de l'électricité pour fixer électrostatiquement la poudre à la surface. Les particules de poudre sont ensuite traitées à la chaleur ou à la lumière UV pour mieux couvrir la surface métallique.
* électrolytique,
* **anodisation**,\
  Consiste à forme une couche d'oxyde contrôlée à la surface de certains métaux grâce à un processus électrochimique.
* **polissage**,\
  Consiste à traiter la surface des métaux afin de rendre les surfaces métalliques plus lisses, plates et brillantes par des moyens mécaniques ou chimiques.

<!---->

* sablage abrasif,

</details>

[^1]: alban.fournier@beta.gouv.fr
