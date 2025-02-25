# 🚚 Choix des voies de transport

En pratique, pour une même chaine d'approvisionnement, plusieurs voies de transports sont utilisées, dans des proportions qui dépendent du type de produit, de la distance et de choix industriels :

* Plus la distance est faible, plus le transport se fait en 100% routier
* Les marques de textile fast-fashion privilégient l'avion pour distribuer plus rapidement leurs produits aux consommateurs
* Certains industriels font le choix du ferroviaire pour son faible impact environnemental, ou parce qu'ils ont une voie ferrée desservant directement le site de production ou de stockage.

## Modélisation du transport avec voie de transport non modifiable

Pour les étapes de transport utilisant cette modélisation, l'utilisateur ne peut pas choisir la voie de transport des ingrédients, matériaux ou composants. Sauf mention explicite dans la documentation spécifique métier, un mix de transports par voies terrestre et maritime est considéré.

La part du **transport terrestre (`t`)**, par rapport au transport "terrestre + maritime", est alors établie comme suit :

<table data-header-hidden><thead><tr><th width="297"></th><th></th></tr></thead><tbody><tr><td><strong>Distance terrestre</strong></td><td><strong>t</strong></td></tr><tr><td>&#x3C;=500 km</td><td>100%</td></tr><tr><td>500 km &#x3C;= 1000 km</td><td>90%</td></tr><tr><td>1000 km &#x3C;= 2000 km</td><td>50%</td></tr><tr><td>2000 km &#x3C;= 3000 km</td><td>25%</td></tr><tr><td>> 3000 km</td><td>0%</td></tr></tbody></table>

Le coût environnemental est calculé selon la formule suivante :

$$
CEtransport=t∗CEterrestre+(1−t)∗CEmaritime
$$

Avec :&#x20;

* `CEtransport` : le coût environnemental de l'étape de transport considérée, exprimé en points d'impact Pts
* `t` : la part de voie terrestre considérée, établie selon le tableau ci-dessus
* `CEterrestre` : le coût environnemental par voie terrestre, exprimé en points d'impact Pts (voir calcul ci-dessus)
* `CEmaritime` : le coût environnemental par voie maritime, exprimé en points d'impact Pts (voir calcul ci-dessus). Ceci inclut donc à la fois le transport par bateau et le transport par camion vers et depuis les ports.

### Cas d'application

* Transports de produits textile intermédiaires et d'accessoires
* Transport de composants
* Transport de certains ingrédients alimentaires

## Modélisation du transport avec part d'aérien ou de ferroviaire modifiable&#x20;

### Modélisation

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés.

Calcul avec paramétrage d'une part de voie aérienne :&#x20;

$$
CEtransport=a*CEaérienne+(1-a)*( t∗CEterrestre+(1−t)∗CEmaritime)
$$

Calcul avec paramétrage d'une part de voie ferroviaire :&#x20;

$$
CEtransport=f*CEferroviaire+(1-f)*( t∗CEterrestre+(1−t)∗CEmaritime)
$$

Avec :&#x20;

* `CEtransport` : le coût environnemental de l'étape de transport considérée, exprimé en points d'impact Pts
* `a` : la part de voie aérienne paramétrée
* `f` : la part de voie ferroviaire paramétrée
* `t` : la part de voie terrestre, par rapport aux voies terrestre+maritime combinées
* `CEaérienne` : le coût environnemental par voie aérienne, exprimé en points d'impact Pts (voir calcul ci-dessus)
* `CEferroviaire` : le coût environnemental par voie ferroviaire, exprimé en points d'impact Pts (voir calcul ci-dessus)
* `CEterrestre` : le coût environnemental par voie terrestre, exprimé en points d'impact Pts (voir calcul ci-dessus)
* `CEmaritime` : le coût environnemental par voie maritime, exprimé en points d'impact Pts (voir calcul ci-dessus)

### Cas d'application et déclinaison de la modélisation

* Transport d'ingrédients depuis un pays étrangers vers la France : option "aérien"
* Transports de produits finis textile depuis un pays étrangers vers la France : ratio a "aérien"
* Transport de véhicules depuis un pays étrangers vers la France : ratio f "ferroviaire"
* Transport de meubles depuis un pays étrangers vers la France : ratio f "ferroviaire"

