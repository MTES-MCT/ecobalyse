---
hidden: true
---

# 🚢 Transport Textile

## Contexte

## Principales étapes de transport <a href="#distribution" id="distribution"></a>

Le transport considéré correspond à l'ensemble des transports mobilisés sur la chaîne de valeur du vêtement.

Entre chaque étape, la masse à considérer est ajustée en fonction des [Pertes et rebut](../precisions-methodologiques/pertes-et-rebus.md).

<table><thead><tr><th width="117">#Etape</th><th width="169">De</th><th width="213">Vers</th><th>Masse de produit considéré</th></tr></thead><tbody><tr><td>1.</td><td>Matière<br>Pays*</td><td>Filature<br>Pays*</td><td>Matière première</td></tr><tr><td>2.</td><td>Filature<br>Pays*</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td>Fil</td></tr><tr><td>3.</td><td><p>Tissage/tricotage</p><p>Pays*</p></td><td><p>Teinture</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>4.</td><td><p>Teinture</p><p>Pays*</p></td><td><p>Confection</p><p>Pays*</p></td><td>Etoffe</td></tr><tr><td>5.</td><td><p>Confection</p><p>Pays*</p></td><td><p>Entrepôt</p><p>Pays : France</p></td><td>Vêtement</td></tr><tr><td>6.</td><td><p>Entrepôt</p><p>Pays : France</p></td><td><p>Magasin ou Point de retrait</p><p>Pays : France</p></td><td>Vêtement</td></tr></tbody></table>

\*Pays paramétré directement dans le calculateur.

### Modes de transport

3 types de transport sont considérés :

* terrestre
* maritime
* aérien

La répartition des trois types de transport est ajustée en fonction des pays de départ et d'arrivée pour chaque étape de transport.

### **L'aérien est-il un mode de transport privilégié pour les acteurs de l'habillement ?**

Une récente [étude de l'ONG suisse "Public Eye" parue fin 2023 ](https://www.publiceye.ch/fr/thematiques/industrie-textile/en-mode-avion-zara-attise-la-crise-climatique)met en lumière l'importance du secteur Textile dans le fret aérien. De manière générale, peu de données précises sont disponibles sur ces pratiques car les entreprises Textile sont discrètes à ce sujet.

Quelques enseignements clés de l'étude :&#x20;

* le fret aérien est utilisé au sein même de l'UE alors que l'avantage en termes de temps reste faible (42 658 tonnes de vêtements transportées par avion au sein de l'UE en 2022 d'après les estimations de l'étude),
* Shein a signé un partenariat stratégique avec China Southern Airlines afin d'optimiser ses flux logistiques aériens,
* Le groupe espagnol Inditex (propriétaire de Zara) affrète près de 1,600 vols par an depuis l'aéroport de Saragosse.

## Méthodes de calcul

### Calcul de l'impact pour un mode de transport donné

<mark style="color:red;">**A reprendre : voie = mode de transport**</mark>

À chaque étape, le coût environnemental du transport pour une voie de transport i est calculé de la façon suivante :

$$
I_{v_i}=Masse*(D_{i,1}∗I_{m_1}+D_{i, 2}∗I_{m_2})
$$

Avec :&#x20;

* `I_v_i` : le coût environnemental par voie, exprimé en points d'impact Pts
* `Masse` : la masse de produit transporté, exprimée en tonnes. Une conversion est donc à prendre en compte par rapport à la masse en kg dans les autres parties des calculs. La masse transportée dépend de l'étape du cycle de vie à laquelle a lieu le transport.
* `D_i,j` : la distance parcourue par le mode de transport j pour la voie i, exprimée en km
  * `D_mer,bateau` , `D_terre,camion`,`D_air,avion` , `D_fer,train` sont des paramètres dont les valeurs sont indiquées dans la section "Paramètres retenus pour l’affichage environnemental".
  * Le calcul de `D_i,camion` est précisé dans la section suivante (hors voie terre)
  * Les autres distances ne sont pas applicables
* `I_m_j` : le coût environnemental du mode j, exprimé en Pts/t.km

### Transport au sein d'un même pays

Lorsque deux étapes successives sont réalisées dans un même pays, les distances concernées sont calculées comme suit :&#x20;

$$
D_{terre, camion}=D_{terre, camion,interne}
$$

$$
D_{air, avion}=D_{air, avion,interne} ;D_{air,camion}=(D_{terre, camion,interne})/2
$$

$$
D_{fer,train}=D_{fer,train,interne}
$$

Les distances non mentionnées ici ne s'appliquent pas pour le transport interne à un pays.

<mark style="color:red;">**Ajouter réparttiion entre voies de transport**</mark>

## Paramètres retenus pour le coût environnemental

### Distances entre pays

La distance pour chaque voie et mode de transport est calculés en fonction du pays d'origines et de destination pour chaque étape de transport considérée.

Le tableau suivant décrit les sources de données et le mode de calcul des distances pour dans la situation où l'utilisateur connais les pays d'origine et de destination, et ceux-ci sont proposés dans Ecobalyse (Situation 1).

<table><thead><tr><th width="170">Distances</th><th>Source</th></tr></thead><tbody><tr><td>D_terre</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par le PEF, <a href="https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf">Product Environmental Footprint Category Rules Guidance</a>, 7.14.3 From factory to final client)</td></tr><tr><td>D_mer</td><td>Distance calculée avec <a href="https://www.searates.com/services/distances-time/">https://www.searates.com/services/distances-time</a> (calculateur recommandé par la méthode PEF)</td></tr><tr><td>D_air</td><td>Distance à vol d'oiseau calculée avec geopy.distance, entre le centre de chaque pays.</td></tr></tbody></table>

[Toutes les distances entre pays (identifiés par leurs code alpha-2) sont visibles sur cette page](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/transports.json) (hors distances vers et depuis les ports et aéroports).

Si 2 étapes successives ont lieu dans un même pays, on fait l'hypothèse que le déplacement est fait à 100% par la voie terrestre avec une distance de 500 km.

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

Dans ce cas, les distances suivantes sont fixées par défaut, en cohérence avec la méthode PEF ([Product Environmental Footprint Category Rules Guidance](https://eplca.jrc.ec.europa.eu/permalink/PEFCR_guidance_v6.3-2.pdf), 7.14.3 From factory to final client) :&#x20;

* D\_mer, bateau = 18 000 km
* D\_mer, camion = D\_mer, camion, défaut
* D\_air, air = 10 000 km
* D\_air, camion = D\_air, camion, défaut
* D\_fer, fer = 10 000 km
* D\_fer, camion = D\_fer, camion, défaut
  * En pratique, le transport ferroviaire n'est pas mobilisé dans les scénarios par défaut.&#x20;

</details>

### Distances `D_i,camion` par défaut

Les autres distances sont paramétrées comme suit pour l'affichage environnemental :

* D\_mer,camion,défaut = 1000 km
* D\_air,camion,défaut = 1000 km
* D\_fer,camion,défaut = 0 km

### Distances de transport au sein d'un même pays

* D\_terre,interne = 500 km
* D\_air,avion,interne = 500 km
* D\_fer,train,interne = 500 km

### Répartition terrestre - maritime

La part du **transport terrestre (t)**, par rapport au transport "terrestre + maritime", est établie comme suit :&#x20;

| **Distance terrestre** | **t** |
| ---------------------- | ----- |
| <=500 km               | 100%  |
| 500 km <= 1000 km      | 90%   |
| 1000 km <= 2000 km     | 50%   |
| 2000 km <= 3000 km     | 25%   |
| > 3000 km              | 0%    |

Exemples :&#x20;

| t        | Turquie | France | Espagne | Portugal |
| -------- | ------- | ------ | ------- | -------- |
| Turquie  | 100%    |        |         |          |
| France   | 25%     | 100%   |         |          |
| Espagne  | 0%      | 90%    | 100%    |          |
| Portugal | 0%      | 50%    | 90%     | 100%     |

_"Pour un déplacement "Turquie-France", le transport terrestre-maritime sera fait de 25% de terrestre et de 75% de maritime"_

### Part du transport aérien

Une part de transport aérien est considérée, comme paramètre optionnel :

* Seulement pour le transport entre la confection et l'entrepôt (étape #5 ci-dessus)
* Cette part n'est considérée que lorsque la confection est réalisée hors Europe (ou Turquie). Pour mémo, il est considéré que l'entrepôt est en France (cf. [Distribution](distribution.md))

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" est considérée comme suit pour la **valeur par défaut**: &#x20;

**Si le coefficient de durabilité est > 1**

* 0% pour les pays situés en Europe ou Afrique,
* 33% pour les autres pays.

**Si le coefficient de durabilité est < 1**

* 0% pour les pays situés en Europe ou Afrique,
* 100% pour les autres pays.

{% hint style="info" %}
Un curseur permettant d'ajuster la part du transport aérien en sortie de confection est proposé dans Ecobalyse

Le curseur "part du transport aérien", proposé sous l'étape "confection" permet d'ajuster le paramètre `a`, en partant de l'hypothèse par défaut : 33% en provenance d'un pays hors Europe et hors-Afrique, 0% sinon.
{% endhint %}

## Procédés utilisés pour le coût environnemental

Les procédés utilisés, définissant les coûts environnementaux `I_m_j` , sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), et listés ci-dessous :&#x20;

<mark style="color:red;">**GRAPH a corriger, également pour page transverse**</mark>

<table><thead><tr><th width="230">Type de transport</th><th>Procédé (Source)</th></tr></thead><tbody><tr><td>Camion</td><td>market group for transport, freight, lorry, unspecified, GLO (Ecoinvent)</td></tr><tr><td>Bateau</td><td>market for transport, freight, sea, container ship, GLO (Ecoinvent)</td></tr><tr><td>Avion</td><td>market for transport, freight, aircraft, long haul, GLO (Ecoinvent)</td></tr></tbody></table>

<figure><img src="../../.gitbook/assets/image (314).png" alt=""><figcaption></figcaption></figure>

## Exemple d'application

{% hint style="info" %}
\[optionnel mais utile] Application à un exemple, pour permettre une meilleure compréhension au lecteur
{% endhint %}

