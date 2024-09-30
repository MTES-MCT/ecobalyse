# 🚚 Transport des véhicules

Cette page porte sur le transport du véhicule (produit fini) depuis le site d'assemblage vers le lieu d'utilisation.

## Généralités

Le transport de véhicules assemblés est spécifique à ce secteur. En effet, dans la plupart des cas, le volume à transporter est conséquent par rapport au poids, ce qui implique un transport fortement sous-capacitaire en termes de poids transporté.&#x20;

Les véhicules les plus grands, à l'instar des voitures, sont transporté dans des moyens de transports spécifiques.

Le transport des composants vers le site d'assemblage est traité dans la [page précédente](transport-des-composants.md).

### Eléments sur l'impact environnemental du transport de véhicules



#### Transport maritine

Le transport de voitures s'effectue dans des navires dédiés.&#x20;

Comme tous les navires opérant en Europe, ces navire sont tenus de déclarer leur consommation de carburant, les émissions de gaz à effet de serre associées, ainsi que le tonnage moyen annuel.

Il en ressort des émissions essentiellement situées entre 20gCO2/tkm et 50gCO2e/tkm en 2022.

## Modélisation Ecobalyse

L'utilisateur a la possibilité de préciser le lieu d'assemblage du produit dans le calculateur.&#x20;

Le lieu d'utilisation est toujours considéré comme étant la France hexagonale.

### Modes de transport <a href="#procedes" id="procedes"></a>

Chaque mode de transport possible est a été modélisé sur la base d'un procédé Ecoinvent, et multiplié par un facteur multiplicatif permettant de rendre compte du caractère faiblement capacitaire voire spécifique du transport de véhicules.

<table><thead><tr><th width="199">Type de transport</th><th width="328">Procédé</th><th>Facteur multiplicatif</th></tr></thead><tbody><tr><td>Terrestre</td><td>transport, freight, lorry, unspecified, RoW</td><td>2.0</td></tr><tr><td>Maritime</td><td>transport, freight, sea, container ship, GLO</td><td>5.0</td></tr><tr><td>Ferroviaire</td><td>transport, freight train, GLO</td><td>2.0</td></tr></tbody></table>

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

