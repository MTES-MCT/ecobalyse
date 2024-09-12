# 🚚 Transport

## Modélisation Ecobalyse

Les étapes de transport d'un meuble constituent souvent un enjeu clé du coût environnemental du produit. Cela s'explique par le poids significatif du meuble à transporter.&#x20;

L'utilisateur a la possibilité de préciser l'origine de deux paramètres dans le calculateur :&#x20;

* l'origine des composants entrant dans la composition de son produit,\
  (ex : l'origine des 4 pieds de chaise d'une chaise de cuisine)
* le lieu d'assemblage du produit.

### Etapes considérées <a href="#distribution" id="distribution"></a>

Les étapes de transport prisent en compte dans le coût environnemental du produit sont :&#x20;

* le transport de chaque composant depuis son site de fabrication et le site d'assemblage du produit fini,
* le transpor du produit fini depuis le site d'assemblage jusqu'à sa fin de vie.&#x20;

### Modes de transport <a href="#procedes" id="procedes"></a>

4 modes de transport sont modélisables dans Ecobalyse. \
Chaque mode de transport correspond à un procédé Ecoinvent.&#x20;

| Type de transport | Procédé                                      |
| ----------------- | -------------------------------------------- |
| Terrestre         | transport, freight, lorry, unspecified, RoW  |
| Maritime          | transport, freight, sea, container ship, GLO |
| Aérien            | transport, freight, aircraft, long haul, GLO |
| Ferroviaire       | transport, freight train, GLO                |

<figure><img src="../../.gitbook/assets/image (115).png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
A date et pour les objets/meubles, seulement 2 modes de transport sont intégrés dans les scénarios : Terrestre et Maritime.&#x20;

Si vous considérez qu'il est souhaitable d'intégrer les modes de transport Aérien et Ferroviaire afin de refléter des pratiques de marché, n'hésitez pas à partager votre retour directement sur la plateforme d'échange [Mattermost ](https://fabrique-numerique.gitbook.io/ecobalyse/communaute)(canal _Ameublement_).&#x20;
{% endhint %}

### Calcul des distances <a href="#distribution" id="distribution"></a>

La répartition des deux types de transport (terrestre et maritime) est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Des scénarios par défaut sont proposés pour répondre aux différents cas d'usage rencontrés sur le cycle de vie d'un meuble :&#x20;

<details>

<summary>Je connais le pays d'où provient le composant</summary>

Option 1 => le pays est proposé dans Ecobalyse => je le sélectionne

Option 2 => le pays n'est pas proposé dans Ecobalyse => je sélectionne la région (ex : _Europe de l'Ouest_ pour _la Croatie_)

Afin de définir les distances et modes de transport utilisés pour chaque région, un pays est défini en arrière plan :

* Europe de l'Ouest = Espagne
* Europe de l'Est = République Tchèque
* Asie = Chine
* Afrique = Ethiopie
* Amérique du Nord = Etats-Unis
* Amérique latine = Brésil
* Océanie = Australie
* Moyen-Orient = Turquie

</details>

<details>

<summary>Je ne connais pas le pays d'où provient le composant</summary>

Je sélectionne l'option _Inconnu (par défaut)._

L'Inde est utilisé en arrière plan pour définir les distances et modes de transport utilisés pour cette option.

</details>

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :

| **Distance terrestre** | **t** |
| ---------------------- | ----- |
| <=500 km               | 100%  |
| 500 km <= 1000 km      | 90%   |
| 1000 km <= 2000 km     | 50%   |
| 2000 km <= 3000 km     | 25%   |
| > 3000 km              | 0%    |

### Calcul de l'impact environnemental du transport <a href="#distribution" id="distribution"></a>

À chaque étape, l'impact du transport se calcule comme une pondération des deux types de transport considérés :&#x20;

$$
ImpactTransportX=t∗ImpactTerrestre+(1−t)∗ImpactMaritime
$$

À chaque étape, l'impact de chaque mode de transport est le produit suivant :

$$
ImpactModeTransport=MasseTransportée (tonnes)∗Distance(km)∗ImpactProcedeTransport
$$

{% hint style="info" %}
La masse transportée s'exprime en **tonnes**. Une conversion est donc à prendre en compte par rapport à la masse, considérée en kg dans les autres parties des calculs.
{% endhint %}

### Etape Distribution <a href="#distribution" id="distribution"></a>

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur.

Cette hypothèse est conforme à la méthodologie ADEME (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).



## **OLD**&#x20;

Les scénarios par défaut retenus par Ecobalyse s'inspirent de ceux proposés par référentiel "Meubles Meublants ADEME-FCBA" mis à jour en novembre 2023.&#x20;

### Etapes d'approvisionnement (transport en amont du site assemblage)

<table><thead><tr><th>Scénario</th><th width="181">France</th><th>Europe</th><th>Afrique du Nord</th><th>Hors Europe</th></tr></thead><tbody><tr><td>France</td><td>1,000km en camion</td><td>2,000km en camion</td><td>2500km bateau<br>1000km camion</td><td>18000 km bateau<br>1500km camion</td></tr><tr><td>Europe</td><td>2,000km en camion</td><td>2,000km en camion</td><td>2500km bateau<br>1000km camion</td><td>18000 km bateau<br>1500km camion</td></tr><tr><td>Afrique du Nord</td><td>2500km bateau<br>1000km camion</td><td>2500km bateau<br>1000km camion</td><td>2,000km en camion</td><td>18000 km bateau<br>1500km camion</td></tr><tr><td>Hors Europe</td><td>18000 km bateau<br>1500km camion</td><td>18000 km bateau<br>1500km camion</td><td>18000 km bateau<br>1500km camion</td><td>5,000km en camion</td></tr></tbody></table>

### Etapes de distribution

<table><thead><tr><th width="123">Scénario</th><th width="129">France</th><th width="151">Europe</th><th>Afrique du Nord &#x3C;=> Europe</th><th>Hors Europe &#x3C;=> Europe </th></tr></thead><tbody><tr><td>France</td><td>1000 km camion</td><td>2000km camion</td><td>2500km bateau<br>1000km camion</td><td>18000 km bateau<br>1500km camion</td></tr></tbody></table>



