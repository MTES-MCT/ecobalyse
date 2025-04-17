# ⚡ Electricité

## Généralités

La consommation d'électricité s'exprime en kilowatt.heures (kWh).\
Certains procédés nécessitent l'utilisation de l'unité mégajoule (MJ) pour la quantité d'électricité; une conversion est alors appliquée (1 kWh = 3,6 MJ).&#x20;

Deux scénarios existent pour modéliser la consommation d'électricité des procédés mobilisés :&#x20;

**Scénario 1** :  l'électricité est déjà intégrée dans le procédé mobilisé en tant que Flux Interne,

**Scénario 2** : l'électricité n'est pas intégrée dans le procédé mobilisé et doit être intégrée en tant que Flux Externe (c'est par exemple le cas pour de nombreux procédés de l'étape Ennoblissement).

Dans ce cas précis, la quantité d'électricité nécessaire pour actionner le procédé mobilisé correspond au produit de la masse "sortante" du procédé mobilisé (ex : 0,5kg d'étoffe en sortie de l'étape Ennoblissement) avec le coefficient du flux externe d'électricité mobilisé (ex : 0,1 kWh / kg d'électricité pour le procédé de pré-traitement _Désencollage)_.&#x20;

Le flux externe d'électricité mobilisé correspond au mix électrique de la zone géographique sélectionnée par l'utilisateur.  &#x20;

<figure><img src="../../.gitbook/assets/image (290).png" alt=""><figcaption><p>Illustration de la zone géographique à préciser par l'utilisateur</p></figcaption></figure>

### Procédés mobilisés

La base de données Ecoinvent propose de nombreux mix électriques permettant de préciser la zone géographique.

Ecobalyse mobilise des Pays (exemple pour la France : _market for electricity, medium voltage, FR_) ainsi que des Region (exemple pour la région Afrique : _market group for electricity, medium voltag, RAF_) dans le choix de la zone géographique.

Au total, 20 scénarios sont proposés dans Ecobalyse afin de répondre aux différents niveaux de maturité des utilisateurs en terme de traçabilité :&#x20;

* Scénario 1 => origine inconnue (scénario par défaut)\
  Lorsque l'utilisateur ne connaît pas le pays, il sélectionne la zone géographique "Inconnu".&#x20;
* Scénario 2 => sélection d'un Pays (8 options) ou d'une Région (11 options)\
  Lorsque l'utilisateur connaît le pays, il sélectionne :&#x20;
  * le pays si ce dernier est disponible dans Ecobalyse (cf. liste ci-dessous),
  * la région lorsque le pays n'est pas disponible dans Ecobalyse (cf. liste ci-dessous).&#x20;

| Régions (8)       | Pays (11)  |
| ----------------- | ---------- |
| Europe de l'Ouest | France     |
| Europe de l'Est   | Inde       |
| Asie              | Chine      |
| Moyen-Orient      | Pakistan   |
| Afrique           | Turquie    |
| Amérique Latine   | Vietnam    |
| Amérique du Nord  | Cambodge   |
| Océanie           | Maroc      |
|                   | Tunisie    |
|                   | Bangladesh |
|                   | Myanmar    |

<figure><img src="../../.gitbook/assets/Coût environnemental des mix électriques mobilisés dans Ecobalyse (uPts _ kWh) (4).png" alt=""><figcaption><p>Mix électriques mobilisés dans Ecobalyse</p></figcaption></figure>

{% hint style="info" %}
Ces scénarios par défaut permettent de couvrir le Niveau 1 du dispositif d'affichage environnemental.&#x20;

Les entreprises qui souhaitent préciser le mix chaleur de tout ou partie des étapes de production peut le faire dans le cadre des Niveaux 2 et 3.&#x20;
{% endhint %}
