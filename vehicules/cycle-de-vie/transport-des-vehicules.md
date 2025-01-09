# 🚚 Transport des véhicules

Cette page porte sur le transport du véhicule (produit fini) depuis le site d'assemblage vers le site de distribution en France (le cas échéant), puis vers le consommateur final.

## Généralités

Le transport de véhicules assemblés est spécifique à ce secteur. En effet, dans la plupart des cas, le volume à transporter est conséquent par rapport au poids, ce qui implique un transport fortement sous-capacitaire en termes de poids transporté.&#x20;

Les véhicules les plus grands, à l'instar des voitures, sont transportés dans des moyens de transports spécifiques.

Le transport des composants vers le site d'assemblage est traité dans la [page précédente](../../documentation-transverse/transport.md).

### Éléments sur l'impact environnemental du transport de véhicules

#### Transport maritime de voitures

Le transport de voitures s'effectue dans des navires dédiés, dont la capacité est de 10 000 à 20 000 tonnes. Par comparaison, la capacité des portes-conteneur est de 7 000 à 300 000 t, avec une capacité moyenne de 64 000 tonnes (4600 EVP).

Comme tous les navires opérant en Europe, ces navires sont tenus de déclarer leur consommation de carburant, les émissions de gaz à effet de serre associées, ainsi que le tonnage moyen annuel.

Il en ressort des émissions essentiellement situées entre 20gCO2/tkm et 50gCO2e/tkm en 2022. Par comparaison, les émissions du transport de marchandise par conteneurs maritime sont de l'ordre de 10g/tkm.

#### Transport de vélos assemblés à 80%

Sur de grandes distances, les vélos sont transportés partiellement assemblés, dans des cartons. Par exemple, un vélo de 20kg sera emballé dans un carton de 0.25m3, soit 80kg/m3. Par comparaison, un conteneur est chargé en moyenne à hauteur de 200kg/m3.

## Modélisation Ecobalyse

L'utilisateur précise le lieu d'assemblage du produit dans Ecobalyse.&#x20;

Le lieu d'utilisation est toujours considéré comme étant la France hexagonale.

### Modes de transport <a href="#procedes" id="procedes"></a>

Chaque mode de transport possible est modélisé sur la base d'un procédé Ecoinvent, et multiplié par un facteur multiplicatif permettant de rendre compte du caractère faiblement capacitaire voire spécifique du transport de véhicules.

<table><thead><tr><th width="199">Type de transport</th><th width="328">Procédé</th><th>Facteur multiplicatif</th></tr></thead><tbody><tr><td>Terrestre</td><td>transport, freight, lorry, unspecified, RoW</td><td>2.0</td></tr><tr><td>Maritime</td><td>transport, freight, sea, container ship, GLO</td><td>5.0</td></tr><tr><td>Ferroviaire</td><td>transport, freight train, GLO</td><td>2.0</td></tr></tbody></table>

### Calcul des distances <a href="#distribution" id="distribution"></a>

La répartition des deux types de transport (terrestre et maritime) est ajustée en fonction du pays d'assemblage.

Des scénarios par défaut sont proposés pour répondre aux différents cas d'usage rencontrés :&#x20;

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

