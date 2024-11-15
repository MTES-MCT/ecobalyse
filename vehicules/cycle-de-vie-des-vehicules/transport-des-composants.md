# 🚚 Transport des composants

## Modélisation Ecobalyse

Le transport des composants peut représenter un enjeu significatif du coût environnemental d'un véhicule.&#x20;

L'utilisateur a la possibilité de préciser dans le Ecobalyse :&#x20;

* l'origine des composants entrant dans la composition de son produit,\
  (ex : l'origine du chassis aluminium)
* le lieu d'assemblage du produit.

### Étapes considérées <a href="#distribution" id="distribution"></a>

Les étapes de transport prisent en compte dans le coût environnemental du produit sont :&#x20;

* le transport des composant depuis leur site de fabrication et le site d'assemblage du véhicule,
* le transport du véhicule (produit fini) depuis le site d'assemblage jusqu'à son lieu d'utilisation. Cette étape fait l'ojet d'une [page distincte](transport-des-vehicules.md).

### Modes de transport <a href="#procedes" id="procedes"></a>

Il est retenu comme hypothèse que tous les composants sont transportés par voie terrestre ou terrestre + maritime.

Ces modes de transport correspondent aux procédés Ecoinvent suivants :

| Type de transport | Procédé                                      |
| ----------------- | -------------------------------------------- |
| Terrestre         | transport, freight, lorry, unspecified, RoW  |
| Maritime          | transport, freight, sea, container ship, GLO |

<figure><img src="../../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

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

