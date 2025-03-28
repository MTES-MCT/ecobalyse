# Choix des voies de transport

## Contexte

En pratique, pour une même chaine d'approvisionnement, plusieurs voies de transports sont utilisées, dans des proportions qui dépendent du type de produit, de la distance et de choix industriels :

* Plus la distance est faible, plus le transport se fait en 100% routier
* Les marques de textile fast-fashion privilégient l'avion pour distribuer plus rapidement leurs produits aux consommateurs
* Certains industriels font le choix du ferroviaire pour son faible impact environnemental, ou parce qu'ils ont une voie ferrée desservant directement le site de production ou de stockage.

## Méthodes de calcul

### Modélisation du transport avec une combinaison de voies non modifiable

Pour les étapes de transport utilisant cette modélisation, l'utilisateur ne peut pas choisir la voie de transport des ingrédients, matériaux ou composants. Sauf mention explicite dans la documentation spécifique métier, un mix de transports par voies terrestre et maritime est considéré.

Le coût environnemental est calculé selon la formule suivante :

$$
I_{transport}=t∗I_{terre}+(1−t)∗I_{mer}
$$

Avec :&#x20;

* `I_transport` : l'impact environnemental de l'étape de transport considérée, exprimé dans l'unité de la catégorie d'impact analysée
* `t` : la part de voie terrestre considérée, établie selon le tableau indiqué dans la partie "Paramètres retenus pour l’affichage environnemental
* `I_terre` : le coût environnemental par voie terrestre, exprimé dans l'unité de la catégorie d'impact analysée
* `I_mer` : le coût environnemental par voie maritime, exprimé dans l'unité de la catégorie d'impact analysée. Ceci inclut donc à la fois le transport par bateau et le transport par camion vers et depuis les ports

#### Cas d'application

* Transports de produits textile intermédiaires et d'accessoires
* Transport de composants
* Transport de certains ingrédients alimentaires

### Modélisation du transport avec part d'aérien ou de ferroviaire modifiable&#x20;

Ce modèle permet à l'utilisateur de définir une part de transport aérien ou de transport ferroviaire, selon le type de produit évalué.

L'impact du transport sur chaque étape se calcule comme une pondération des trois types de transport considérés.

Calcul avec paramétrage d'une part de voie aérienne :&#x20;

$$
I_{transport}=a*I_{air}+(1-a)*( t∗I_{terre}+(1−t)∗I_{mer})
$$

Calcul avec paramétrage d'une part de voie ferroviaire :&#x20;

$$
I_{transport}=f*I_{fer}+(1-f)*( t∗I_{terre}+(1−t)∗I_{mer})
$$

Avec :&#x20;

* `I_transport` : le coût environnemental de l'étape de transport considérée, exprimé dans l'unité de la catégorie d'impact analysée
* `a` : la part de voie aérienne paramétrée
* `f` : la part de voie ferroviaire paramétrée
* `t` : la part de voie terrestre, par rapport aux voies terrestre+maritime combinées
* `I_air` : le coût environnemental par voie aérienne, exprimé dans l'unité de la catégorie d'impact analysée
* `I_fer` : le coût environnemental par voie ferroviaire, exprimé dans l'unité de la catégorie d'impact analysée
* `I_terre` : le coût environnemental par voie terrestre, exprimé dans l'unité de la catégorie d'impact analysée
* `I_mer` : le coût environnemental par voie maritime, exprimé dans l'unité de la catégorie d'impact analysée

#### Cas d'application et déclinaison de la modélisation

* Transport d'ingrédients depuis un pays étrangers vers la France : option "aérien"
* Transports de produits finis textile depuis un pays étrangers vers la France : ratio a "aérien"
* Transport de véhicules depuis un pays étrangers vers la France : ratio f "ferroviaire"
* Transport de meubles depuis un pays étrangers vers la France : ratio f "ferroviaire"

## Paramètres retenus pour l’affichage environnemental

### Part de voie terrestre (répartition terrestre - maritime)

La part de **voie terrestre (`t`)**, par rapport au transport "terrestre + maritime", est établie comme suit :

<table><thead><tr><th width="297">Distance terrestre</th><th>t</th></tr></thead><tbody><tr><td>&#x3C;=500 km</td><td>100%</td></tr><tr><td>500 km &#x3C;= 1000 km</td><td>90%</td></tr><tr><td>1000 km &#x3C;= 2000 km</td><td>50%</td></tr><tr><td>2000 km &#x3C;= 3000 km</td><td>25%</td></tr><tr><td>> 3000 km</td><td>0%</td></tr></tbody></table>

Exemples :&#x20;

<table><thead><tr><th>t (% terrestre)</th><th>Turquie</th><th>France</th><th width="120">Espagne</th><th>Portugal</th></tr></thead><tbody><tr><td>Turquie</td><td>100%</td><td></td><td></td><td></td></tr><tr><td>France</td><td>25%</td><td>100%</td><td></td><td></td></tr><tr><td>Espagne</td><td>0%</td><td>90%</td><td>100%</td><td></td></tr><tr><td>Portugal</td><td>0%</td><td>50%</td><td>90%</td><td>100%</td></tr></tbody></table>

_"Pour un déplacement "Turquie-France", le transport sera fait de 25% de transport par voie terrestre et de 75% de transport par voie maritime (ce dernier incluant du transport par camion vers et depuis les ports concernés)"_

### Part de voie aérienne ou ferroviaire

La part de **voie aérienne (`a`) ou de voie ferroviaire (`f`)**, par rapport au transport "terrestre + maritime + aérienne" ou "terrestre + maritime + ferroviaire" respectivement, est définie en fonction du secteur étudié, et décrite dans les pages Transport sectorielles.

### Impact par voie de transport

L'impact par voie de transport `I_terre`, `I_mer`, `I_air` ou `I_fer` est calculé selon la méthode décrite dans la page [Coût environnemental par voie de transport](https://fabrique-numerique.gitbook.io/ecobalyse/transverse/transport/cout-environnemental-par-voie-de-transport).

