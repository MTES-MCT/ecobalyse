# 🚚 Transport

## Etapes de transport

## Modes de transports

3 types de transport sont considérés :

* terrestre
* maritime
* aérien
* ferroviaire





### Procédés utilisés

Sauf indication contraire spécifique, les modes de transport ci-dessus sont modélisés par les procédés Ecoinvent suivants :

| Type de transport | Procédé                                      |
| ----------------- | -------------------------------------------- |
| Terrestre         | transport, freight, lorry, unspecified, RoW  |
| Maritime          | transport, freight, sea, container ship, GLO |
| Aérien            | transport, freight, aircraft, long haul, GLO |
| Ferroviaire       | transport, freight train, GLO                |

<figure><img src="../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

## Distances

### Calcul de distances entre deux pays

<mark style="color:yellow;">500 km \*2 route + maritime</mark>

<mark style="color:yellow;">ou aérien</mark>

<mark style="color:yellow;">ou distance route</mark>

<mark style="color:yellow;">si inconnu : 18000 PEF</mark>

### Cas de la distribution

Pour la distribution, il est considéré une distance par défaut de 500 km, effectuée en camion entre un entrepôt situé quelque part en France et un magasin ou point de retrait plus proche du consommateur.

Cette hypothèse est conforme à la méthodologie ADEME pour le textile (cf. méthodologie d'évaluation des impacts environnementaux des articles d'habillement - section A.2.b.2 p30).&#x20;

## Calcul du coût environnemental

À chaque étape, l'impact de chaque mode de transport est le produit suivant :

$$
ImpactModeTransport=MasseTransportée (tonnes)∗Distance(km)∗ImpactProcedeTransport
$$

{% hint style="info" %}
La masse transportée s'exprime en **tonnes**. Une conversion est donc à prendre en compte par rapport à la masse, considérée en kg dans les autres parties des calculs.
{% endhint %}

## &#x20;<a href="#distribution" id="distribution"></a>







## Modélisation Ecobalyse

Le transport des composants peut représenter un enjeu significatif du coût environnemental d'un véhicule.&#x20;

L'utilisateur a la possibilité de préciser dans le Ecobalyse :&#x20;

* l'origine des composants entrant dans la composition de son produit,\
  (ex : l'origine du chassis aluminium)
* le lieu d'assemblage du produit.

### Étapes considérées <a href="#distribution" id="distribution"></a>

Les étapes de transport prisent en compte dans le coût environnemental du produit sont :&#x20;

* le transport des ingrédients, matériaux ou composants tout au long de la chaine de production modélisée dans Ecobalyse
* Le transport du produit fini vers la France, le cas échéant
* La distribution du produit en France.

### Modes de transport <a href="#procedes" id="procedes"></a>



### Calcul des distances <a href="#distribution" id="distribution"></a>

La répartition des deux types de transport (terrestre et maritime) est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

Des scénarios par défaut sont proposés pour répondre aux différents cas d'usage rencontrés :&#x20;

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

## &#x20;<a href="#distribution" id="distribution"></a>





Véhicules et ameublement :&#x20;

Il est retenu comme hypothèse que tous les composants sont transportés par voie terrestre ou terrestre + maritime.

Alim et textile : ratio de transport aérien
