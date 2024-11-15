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

* [l'impact des composants non quantifiés directement](../cycle-de-vie/fabrication-des-composants/autres-composants.md) (liste ci-dessus), par différence de poids entre la somme des poids des composants identifiés et le poids total du véhicule,
* [l'impact du transport des composants](../cycle-de-vie/transport-des-composants.md), à partir de l'origine de chaque composants et du lieu d'assemblage du véhicule,
* [l'impact du transport des véhicules](../cycle-de-vie/transport-des-vehicules.md), à partir du lieu d'assemblage du véhicule.

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
Les choix proposés de valeurs par défaut conduisent, très majoritairement, à appliquer des valeurs majorantes par défaut. Par défaut, un vêtement est transformé dans un pays "inconnu" qui a le mix électrique le plus impactant, les paramètres qui définissent le coefficient de durabilité (à l'exception des matières) caractérisent une mode de type "ultra fast fashion"...

2 exceptions :&#x20;

* CONFECTION -> le délavage, activé par défaut pour la catégorie "jeans" mais pas pour les autres catégories de produits
* ENNOBLISSEMENT -> l'impression, par défaut activée pour aucune catégorie de produit

Ces deux paramètres ne sont pas fixés, par défaut, sur des valeurs majorantes dans la mesure où ils peuvent être simplement constatés par l'observation du vêtement, sans avoir à recourir à des informations de traçabilité.

**Dès lors, à l'exception du délavage et de l'impression, chaque nouveau paramètre précisé à partir des valeurs par défaut doit conduire à réduire le coût environnemental modélisé.**
{% endhint %}

## Approche réglementaire

La méthodologie exposée dans Ecobalyse a vocation à donner accès au futur cadre méthodologique réglementaire relatif à l'affichage environnemental (article 2 de la loi Climat et résilience).

**Au plan réglementaire**, 3 types de paramètres sont à distinguer :&#x20;

* **Les paramètres obligatoires, nécessaires** au calcul du coût environnemental
* **Les paramètres optionnels**, pouvant être précisés dans le cadre du calcul du coût environnemental
* **Les paramètres figés**, ne pouvant pas être modifiés dans le cadre du calcul du coût environnemental, à tout le moins en se limitant au paramétrage de référence.

{% hint style="info" %}
Ecobalyse a vocation à évoluer pour bien / mieux faire apparaître le paramétrage de référence. Ce paramétrage de référence est un cadre limitatif, à respecter pour mettre en oeuvre un affichage environnemental sur une base déclarative, en tenant néanmoins bien les justificatifs permettant de justifier les paramétrages mobilisés. Un paramétrage plus précis reste possible mais dans un cadre devant faire l'objet d'un contrôle a priori. Ce paramétrage plus précis a parfois été désigné sous les termes de "niveau 2" ou de "niveau 3", par opposition au "niveau 1" qui correspond au paramétrage de référence.&#x20;
{% endhint %}

Statut envisagé pour les différents paramètres (base de travail au 04/04/2024)

<table><thead><tr><th width="220">Paramètre</th><th width="126">Statut</th><th>Commentaire</th></tr></thead><tbody><tr><td><ol><li>Catégorie de produit</li></ol></td><td>Obligatoire</td><td>Fixé dans le calculateur à partir du choix initial d'exemple</td></tr><tr><td><ol start="2"><li>Masse du produit fini</li></ol></td><td>Obligatoire</td><td></td></tr><tr><td><ol start="3"><li>Durabilité / catégorie de produit</li></ol></td><td>Figé</td><td>Paramètre découlant de la catégorie de produit</td></tr><tr><td><ol start="4"><li>Durabilité / nombre de références</li></ol></td><td>Optionnel</td><td>Valeur par défaut correspondant à la mode "ultra fast fashion"</td></tr><tr><td><ol start="5"><li>Durabilité / prix neuf</li></ol></td><td>Optionnel</td><td>Valeur par défaut correspondant à la mode "ultra fast fashion"</td></tr><tr><td><ol start="6"><li>Durabilité / durée de commercialisation</li></ol></td><td>Optionnel</td><td>Valeur par défaut correspondant à la mode "ultra fast fashion"</td></tr><tr><td><ol start="7"><li>Durabilité / entreprise</li></ol></td><td>Optionnel</td><td>Valeur par défaut correspondant à la mode "ultra fast fashion"</td></tr><tr><td><ol start="8"><li>Durabilité / traçabilité affichée</li></ol></td><td>Optionnel</td><td>Valeur par défaut correspondant à la mode "ultra fast fashion"</td></tr><tr><td><ol start="9"><li>Matières premières / natures des matières</li></ol></td><td>Obligatoire</td><td>Un seuil de coupure doit être arrêté pour définir les matières qui, en deçà d'un pourcentage de la masse ou de l'impact, n'ont pas nécessairement à être paramétrées.</td></tr><tr><td><ol start="10"><li>Matières premières / %</li></ol></td><td>Obligatoire</td><td></td></tr><tr><td><ol start="11"><li>Matières premières / origine géographique</li></ol></td><td>Optionnel ou figé (?)</td><td>En première approche, cette information, difficile à certifier (laine, coton...) pourrait être figée dans le paramétrage de référence. Elle pourrait en revanche être mobilisée, de manière optionnelle, par exemple pour les matières recyclées ou pour les matières agricoles produites localement (exemple : le lin)</td></tr><tr><td><ol start="12"><li>Matières premières / désactivation de l'étape</li></ol></td><td>Optionnel</td><td>L'étape peut être désactivée dans le cas d'une matière upcyclée (cf page de la documentation correspondante)</td></tr><tr><td><ol start="13"><li>Filature / origine géographique</li></ol></td><td>Optionnel</td><td>Par défaut, la valeur "Inconnu (par défaut)" est sélectionnée</td></tr><tr><td><ol start="14"><li>Filature / type de filature</li></ol></td><td>Figé</td><td>Le type de filature dépend des matières considérées</td></tr><tr><td><ol start="15"><li>Filature / titrage du fil</li></ol></td><td>Figé</td><td>Le titrage du fil découle de la catégorie de produit</td></tr><tr><td><ol start="16"><li>Filature / désactivation de l'étape</li></ol></td><td>Optionnel</td><td>L'étape peut être désactivée dans le cas d'une matière upcyclée (cf page de la documentation correspondante)</td></tr><tr><td><ol start="17"><li>Tissage tricotage / origine géographique</li></ol></td><td>Optionnel</td><td>Par défaut, la valeur "Inconnu (par défaut)" est sélectionnée</td></tr><tr><td><ol start="18"><li>Tissage tricotage / procédé</li></ol></td><td>Figé</td><td>Le procédé de tissage tricotage découle de la catégorie de produit (? opportunité de permettre a minima de distinguer les vêtements tissés et tricotés ?)</td></tr><tr><td><ol start="19"><li>Tissage tricotage / grammage</li></ol></td><td>Figé</td><td>Le grammage découle de la catégorie de produit</td></tr><tr><td><ol start="20"><li>Tissage tricotage / désactivation de l'étape</li></ol></td><td>Optionnel</td><td>L'étape peut être désactivée dans le cas d'une matière upcyclée (cf page de la documentation correspondante)</td></tr><tr><td><ol start="21"><li>Ennoblissement / origine géographique</li></ol></td><td>Optionnel</td><td>Par défaut, la valeur "Inconnu (par défaut)" est sélectionnée</td></tr><tr><td><ol start="22"><li>Ennoblissement / type de teinture</li></ol></td><td>Figé</td><td>Le type de teinture découle de la catégorie de produit</td></tr><tr><td><ol start="23"><li>Ennoblissement / impression </li></ol></td><td>Optionnel</td><td>A sélectionner pour les vêtements imprimés</td></tr><tr><td><ol start="24"><li>Ennoblissement / désactivation de l'étape</li></ol></td><td>Optionnel</td><td>L'étape peut être désactivée dans le cas d'une matière upcyclée (cf page de la documentation correspondante)</td></tr><tr><td><ol start="25"><li>Confection / origine géographique</li></ol></td><td>Obligatoire</td><td>Par défaut, la valeur "Inconnu (par défaut)" est sélectionnée mais ce paramètre devrait néanmoins bien être spécifié a minima.</td></tr><tr><td><ol start="26"><li>Confection / complexité</li></ol></td><td>Figé</td><td>La complexité de la confection découle de la catégorie de produit</td></tr><tr><td><ol start="27"><li>Confection / taux de perte</li></ol></td><td>Figé</td><td>Le taux de perte en confection découle de la catégorie de produit</td></tr><tr><td><ol start="28"><li>Confection / stocks dormants</li></ol></td><td>Figé</td><td>Le taux de stocks dormants découle de la catégorie de produit</td></tr><tr><td><ol start="29"><li>Confection / part de transport aérien</li></ol></td><td>Optionnel</td><td>La valeur par défaut découle de l'origine géographique de la confection [et du coefficient de durabilité]</td></tr><tr><td><ol start="30"><li>Confection / délavage</li></ol></td><td>Optionnel</td><td>A sélectionner pour les vêtements délavés (ou à désélectionner pour les jeans bruts)</td></tr><tr><td><ol start="31"><li>Confection / désactivation de l'étape</li></ol></td><td>Figé</td><td>La désactivation de l'étape de confection n'est pas possible, même dans le cas d'un upcycling dès lors que l'on considère que celui-ci relève d'un remanufacturage, avec une opération nécessaire de confection.</td></tr></tbody></table>
