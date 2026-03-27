# 🚢 Transport Textile

## Contexte

### Principales étapes de transport <a href="#distribution" id="distribution"></a>

Le transport considéré correspond à l'ensemble des transports mobilisés sur la chaîne de valeur du vêtement.

Entre chaque étape, la masse à considérer est ajustée en fonction des [Pertes et rebut](../precisions-methodologiques/pertes-et-rebus.md).

<table><thead><tr><th width="117">#Etape</th><th width="169">De</th><th width="213">Vers</th><th>Masse de produit considéré</th></tr></thead><tbody><tr><td>1.</td><td>Matière<br>Pays*</td><td>Filature<br>Pays*</td><td>Matière première</td></tr><tr><td>2.</td><td>Filature<br>Pays*</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td>Fil</td></tr><tr><td>3.</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td><p>Teinture</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>4.</td><td><p>Teinture</p><p>Pays*</p></td><td><p>Confection</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>5.</td><td><p>Confection</p><p>Pays*</p></td><td><p>Entrepôt</p><p>Pays : France</p></td><td>Vêtement</td></tr><tr><td>6.</td><td><p>Entrepôt</p><p>Pays : France</p></td><td><p>Magasin ou Point de retrait</p><p>Pays : France</p></td><td>Vêtement</td></tr></tbody></table>

\*Pays paramétré directement dans le calculateur.

### Voies de transport

3 voies de transport sont considérés. A chaque voie correspond un mode de transport unique :

* terrestre (camion)
* maritime (bateau)
* aérien (avion)

La répartition des trois voies de transport est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

#### **Focus : l'aérien est-il un mode de transport privilégié pour les acteurs de l'habillement ?**

Une [étude de l'ONG suisse "Public Eye" parue fin 2023 ](https://www.publiceye.ch/fr/thematiques/industrie-textile/en-mode-avion-zara-attise-la-crise-climatique)met en lumière l'importance du secteur textile dans le fret aérien. De manière générale, peu de données précises sont disponibles sur ces pratiques car les entreprises du secteur textile sont discrètes à ce sujet.

Quelques enseignements clés de l'étude :&#x20;

* le fret aérien est utilisé au sein même de l'UE alors que l'avantage en terme de temps reste faible (42 658 tonnes de vêtements transportées par avion au sein de l'UE en 2022 d'après les estimations de l'étude),
* Shein a signé un partenariat stratégique avec China Southern Airlines afin d'optimiser ses flux logistiques aériens,
* Le groupe espagnol Inditex (propriétaire de Zara) affrète près de 1,600 vols par an depuis l'aéroport de Saragosse.

## Méthodes de calcul

### Calcul de l'impact pour une voie de transport donnée

Pour chaque étape, le coût environnemental du transport pour une voie de transport _i_ est calculé de la façon suivante :

$$
I_{i}=\frac{m}{1000}*D_i∗I_{m_i}
$$

Avec :&#x20;

* `I_i` : le coût environnemental pour la voie _i_, exprimé en points d'impact Pts
* `m` : la masse de produit transporté, exprimée en kg. La masse à considérer est ajustée en fonction des [Pertes et rebut](https://fabrique-numerique.gitbook.io/ecobalyse/textile/precisions-methodologiques/pertes-et-rebus).
* `D_i` : la distance parcourue pour la voie de transport i, exprimée en km
  * Les valeurs des paramètres `D_mer` , `D_terre`,`D_air` sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".
* `I_m_i` : le coût environnemental du mode de transport correspondant à la voie _i_, exprimé en Pts/t.km

### Répartition entre voies de transport

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés :

$$
I_{transport}=a*I_{air}+(1-a)*( t∗I_{terre}+(1−t)∗I_{mer})
$$

Avec :&#x20;

* `I_transport` : le coût environnemental de l'étape de transport considérée, exprimé dans l'unité de la catégorie d'impact analysée
* `a` : la part de voie aérienne, par rapport aux voies terrestre + maritime + aérienne combinées, valeur sans unité entre 0 et 1 (100%)
* `t` : la part de voie terrestre, par rapport aux voies terrestre + maritime combinées, valeur sans unité entre 0 et 1 (100%)
* `I_air` : le coût environnemental par voie aérienne, exprimé dans l'unité de la catégorie d'impact analysée
* `I_terre` : le coût environnemental par voie terrestre, exprimé dans l'unité de la catégorie d'impact analysée
* `I_mer` : le coût environnemental par voie maritime, exprimé dans l'unité de la catégorie d'impact analysée

Les distances non mentionnées ici ne s'appliquent pas pour le transport interne à un pays.

## Paramètres retenus pour le coût environnemental

### Transport au sein d'un même pays

Si 2 étapes successives ont lieu dans un même pays, on fait l'hypothèse que le déplacement est fait à 100% par la voie terrestre avec une distance de 500 km :

* `a` = 0
* `t` = 1
* `D_mer` = 0
* `D_terre` = 500
* `D_air` = 0

Ceci est notamment applicable à l'étape Distribution. Cette étape fait l'objet d'[une page dédiée](https://fabrique-numerique.gitbook.io/ecobalyse/~/revisions/b1YpAFodoqmd8dFgR0qj/textile/cycle-de-vie-des-produits-textiles/etape-6-distribution-new) mais le calcul du coût environnemental est une application du modèle en application pour toutes les étapes de transport.

### Distances entre pays

La distance pour chaque voie de transport est calculée en fonction du pays d'origines et de destination pour chaque étape de transport considérée.

Le tableau suivant décrit les sources de données et le mode de calcul des distances pour dans la situation où l'utilisateur connais les pays d'origine et de destination, et ceux-ci sont proposés dans Ecobalyse (Situation 1).

<table><thead><tr><th width="170">Distances</th><th>Source</th></tr></thead><tbody><tr><td>D_terre</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par le PEF, <a href="https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf">Product Environmental Footprint Category Rules Guidance</a>, 7.14.3 From factory to final client)</td></tr><tr><td>D_mer</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_air</td><td>Distance à vol d'oiseau calculée avec geopy.distance, entre le centre de chaque pays.</td></tr></tbody></table>

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json).

### Situations où l'un des pays n'est pas connu ou pas proposé dans Ecobalyse

<details>

<summary>Situation 2 : je connais le pays mais il n'est pas proposé dans Ecobalyse</summary>

Dans ce cas, il faut choisir la région du pays.\
Exemple pour le pays _Allemagne ⇒_ je sélectionne la région _Europe de l'Ouest._

Afin de définir les distances et modes de transport utilisés pour chaque région, un pays est défini en arrière plan :

* Europe de l'Ouest = Espagne
* Europe de l'Est = République Tchèque
* Asie = Chine
* Afrique = Ethiopie
* Amérique du Nord = Etats-Unis
* Amérique latine = Brésil
* Océanie = Australie
* Moyen-Orient = Turquie

Le transport est ensuite calculé de la même façon que si ce pays était directement sélectionné.

</details>

<details>

<summary>Situation 3 : je ne connais pas le pays </summary>

Je sélectionne "Inconnu" ou "Inconnu (par défaut)"

Dans ce cas, l'Inde est utilisée en arrière-plan comme pays de référence pour définir les distances et voies de transport.&#x20;

</details>

### Répartition terrestre - maritime (`t`)

La part du **transport terrestre (`t`)**, par rapport au transport "terrestre + maritime", est établie comme suit :&#x20;

| **Distance terrestre** | **t** |
| ---------------------- | ----- |
| <=500 km               | 100%  |
| 500 km <= 1000 km      | 90%   |
| 1000 km <= 2000 km     | 50%   |
| 2000 km <= 3000 km     | 25%   |
| > 3000 km              | 0%    |

_Exemples :_&#x20;

<table><thead><tr><th width="196.98333740234375">t</th><th width="133">Turquie</th><th width="129.54998779296875">France</th><th width="128.9166259765625">Espagne</th><th>Portugal</th></tr></thead><tbody><tr><td>Turquie</td><td>100%</td><td></td><td></td><td></td></tr><tr><td>France</td><td>25%</td><td>100%</td><td></td><td></td></tr><tr><td>Espagne</td><td>0%</td><td>90%</td><td>100%</td><td></td></tr><tr><td>Portugal</td><td>0%</td><td>50%</td><td>90%</td><td>100%</td></tr></tbody></table>

_"Pour un déplacement "Turquie-France", le transport (hors avion) sera fait à 25% de transport par voie terrestre (camion) et de 75% par voie maritime (bateau)"_

### Part du transport aérien (`a`)

Une part de transport aérien (`a`) est considérée comme paramètre optionnel, seulement pour le transport entre la confection et l'entrepôt (étape #5 ci-dessus)

Ce paramètre est modifiable par l'utilisateur.

#### Valeurs par défaut

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit pour la **valeur par défaut**: &#x20;

**Si le coefficient de durabilité est > 1**

* 0% pour les pays situés en Europe et Turquie,
* 33% pour les autres pays.

**Si le coefficient de durabilité est < 1**

* 0% pour les pays situés en Europe et Turquie,
* 100% pour les autres pays.

## Procédés utilisés pour le coût environnemental

Les procédés utilisés, définissant les coûts environnementaux `I_m_i` , sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), et listés ci-dessous :&#x20;

<table><thead><tr><th width="230">Type de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Camion</td><td>market group for transport, freight, lorry, unspecified, GLO (Ecoinvent)</td></tr><tr><td>Bateau</td><td>market for transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Avion</td><td>market for transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr></tbody></table>

<figure><img src="../../.gitbook/assets/image (2) (1) (1) (1).png" alt=""><figcaption></figcaption></figure>



