---
hidden: true
---

# Draft - Paramétrage

La méthodologie exposée à travers l'outil Ecobalyse peut être utilisée en mobilisant des paramètres très différents : catégorie, matériaux, quantités (en masse ou autre), origines, type de transport

## Méthodes de calcul

Des données sont collectées sur les thématiques suivantes (les données obligatoires sont indiquées avec le symbole \*):

* Caractéristiques générales du véhicule\*
* Données sur les principaux composants du véhicule (poids, origine, matériaux selon les cas) :&#x20;
  * Châssis - carrosserie\*
  * Batterie
  * Moteur
  * Jantes\*
  * Pneumatiques\*
  * Assise\*
  * Cellules photovoltaïques
* Utilisation du véhicule\*

L'impact de la fabrication des composants est calculée à partir de l'identification du matériau (et d'un procédé / donnée ICV associé) et de sa quantité. Si l'unité du procédé utilisé n'est pas le kilogramme, une conversion est faite par Ecobalyse. Pour la batterie et cellules photovoltaïque, le poids est à renseigner en complément de la capacité et de la puissance respectivement.

Les caractéristiques générales du véhicule et les données sur les composants permettent de calculer automatiquement :

* [l'impact des composants non quantifiés directement](../cycle-de-vie/fabrication-des-composants/autres-composants-non-quantifies.md) (liste ci-dessus), par différence de poids entre la somme des poids des composants identifiés et le poids total du véhicule,
* [l'impact du transport des composants](../../pages-en-cours-de-revue/transport/), à partir de l'origine de chaque composants et du lieu d'assemblage du véhicule,
* [l'impact du transport des véhicules](../../pages-en-cours-de-revue/transport/transport-vehicules.md), à partir du lieu d'assemblage du véhicule.

## Unité de calcul du coût environnemental

Le coût environnemental est calculé en premier lieu par véhicule, puis par kilomètre parcouru sur le cycle de vie, en divisant le cout environnemental par véhicule par la durée de vie du véhicule en kilomètres.

Une durée de vie par défaut est calculée en fonction de la catégorie de véhicule, et modifiable par l'utilisateur.

Le coût environnemental pourra également être calculé par tonne.km ou par passager.km.

## Enjeu de comparaison des véhicules

La comparaison de véhicules-types de catégories différentes sur la base du coût environnemental par kilomètre nécessite des précautions. En effet, les kilométrages par défaut sont plus élevés pour les véhicules les plus lourds, ce qui est de nature à réduire significativement leur coût environnemental en comparaison des véhicules plus légers. Cependant, pour un usage donné, un véhicule plus léger aura en général un cout environnemental plus faible, et devrait être privilégié.

Deux véhicules, quelle que soit leurs tailles respectives, devraient donc se comparer avec un kilométrage identique et un remplacement de composants lié à ce kilométrage.

## Approche technique, des valeurs par défaut majorantes

**Au plan purement technique**, différents types de paramètres sont à distinguer :&#x20;

* des paramètres sans lesquels il est impossible de modéliser un coût environnemental ;
  * Catégorie de produit \[Attention : dans l'outil web, le choix de la catégorie de produit se fait nécessairement à partir du choix initial d'un exemple de produit relevant de la même catégorie que le produit que l'on souhaite modéliser]
  * Masse de produit fini
  * Matières premières (répartition et nature)
* des paramètres qui permettent de préciser la modélisation mais qui ne sont pas indispensables à la modélisation d'un coût environnemental
  * L'ensemble des autres paramètres sont donc caractérisées par des valeurs par défaut qui découlent des 3 paramètres mentionnés ci-dessus :&#x20;
    * La définition de la catégorie de produit vient préciser de nombreux paramètres par défaut : titrage, grammage, tissage/tricotage, délavage, stocks dormants, type de teinture, type de confection, taux de perte en confection, nombre de jours de porté de référence, nombre d'utilisation entre chaque cycle d'entretien, procédés d'entretien, prix par défaut, coût de réparation, type d'entreprise, durée de commercialisation, nombre de référence, affichage de la traçabilité... (cf. paramètres par défaut attachés détaillés dans l'[explorateur de produits](https://ecobalyse.beta.gouv.fr/#/explore/textile/products))  &#x20;
    * Le choix de chaque matière permet de préciser : l'origine par défaut des matières en question ainsi que le paramètre "matières" nécessaire au calcul de la durabilité ([lien](https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite#matieres))
    * Par défaut, le pays ou la région dans laquelle sont réalisées chaque étape de transformation peut être fixé à la valeur "Inconnu (par défaut)". Ce paramétrage est lié au mix électrique et au mix de chaleur les plus impactants (cf. [explorateur de pays](https://ecobalyse.beta.gouv.fr/#/explore/textile/countries)) . La part de transport aérien depuis l'atelier de confection découle quant à elle du pays (ou de la région) retenu pour cette étape \[_et potentiellement du coefficient de durabilité - cf. sectio_ [_part du transport aérien_](https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/transport#part-du-transport-aerien) _de la page transport de la documentation_].

{% hint style="info" %}
Les choix proposés de valeurs par défaut conduisent, très majoritairement, à appliquer des valeurs majorantes par défaut. Par exemple, par défaut, un véhicule est transformé dans un pays "inconnu" qui a le mix électrique le plus impactant.

**Dès lors, chaque nouveau paramètre précisé à partir des valeurs par défaut doit conduire à réduire le coût environnemental modélisé.**
{% endhint %}

