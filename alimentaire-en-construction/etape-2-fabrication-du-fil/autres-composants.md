# ⚙️ Autres composants

## Généralités

Une infinité de composants peuvent être proposés par Ecobalyse pour faciliter la modélisation d'objets (exemple de composants : vis, roulette en plastique, scotch, tissu en coton, etc.).&#x20;

Ce travail étant infini, Ecobalyse se concentre sur la mise à disposition de composants simplifiés destinés à couvrir un large éventail de scénarios.&#x20;

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

Dès lors, Ecobalyse crée et enrichi au fil de l'eau la liste de composants génériques proposée dans l'outil.&#x20;

{% hint style="info" %}
Vous êtes un professionnel de l'ACV et/ou de l'Ameublement ?&#x20;

\
Rdv sur rdv sur le canal "Ameublement" de la plateforme d'échange [Mattermost](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) pour nous faire part de vos retours afin d'enrichir cette liste de composants.
{% endhint %}

## Modélisation Ecobalyse

### Des composants de différente nature

Tout composant proposé dans Ecobalyse est soit issu :

* d'un procédé Ecoinvent inchangé\
  ex : "Mousse PUR (rigide)"
* d'un procédé créé par Ecobalyse\
  ex : "Composant en plastique (PE)"

Par défault, Ecobalyse utilise un procédé Ecoinvent pour modéliser un composant lorsqu'il existe. &#x20;

{% hint style="info" %}
La majorité des composants proposés dans Ecobalyse nécessitent de la matière (ex : des billes de plastique) puis une ou plusieurs étapes de transformation (ex : thermoformage et extrusion de feuilles de plastique).&#x20;

Il est rare que Ecoinvent propose des procédés regroupant ces différentes étapes. modélisée les composants.

Ainsi, dans la majorité des cas, Ecobalyse crée des procédés en asssemblant différents procédés Ecoinvent.&#x20;
{% endhint %}

### Composants disponibles dans Ecobalyse :&#x20;

cf. l'Explorateur pour accéder à la liste des composant en bois disponibles dans Ecobalyse.&#x20;

<figure><img src="../../.gitbook/assets/Coût environnemental des composants autres que ceux en bois (uPts _ kg).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/Coût environnemental de tous les composants (uPts _ kg) (1).png" alt=""><figcaption><p>Les composants en bois (exprimés en uPts / m3) ont été convertiés en Upts / kg via une densité par défaut (cf. Explorateur)</p></figcaption></figure>
