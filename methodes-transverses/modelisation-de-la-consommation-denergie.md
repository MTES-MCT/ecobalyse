# ⚡ Modélisation de la consommation d'énergie

{% hint style="info" %}
**Le principe de modélisation décrit dans cette page peut s'appliquer aux processus des étapes de transformation des matériaux, d'assemblage, de distribution et à l'utilisation des produits.**
{% endhint %}

## Contexte

### Principe

Deux scénarios existent pour modéliser la consommation d'énergie des processus :&#x20;

**Scénario 1** : l'énergie est intégrée dans le procédé mobilisé (voir source et nom technique dans l'explorateur de procédés) en tant que Flux Interne,

**Scénario 2** : l'énergie est modélisée spécifiquement, avec des quantités et des mix géographiques dédiés. La quantité d'énergie est alors une information associée au procédé Ecobalyse en tant que Flux Externe. Une quantité d'électricité et/ou de chaleur par kg est alors indiquée dans les colonnes "Electricité" et "Chaleur" de l'Explorateur du secteur concerné, correspondant à ce Flux externe.

**Cette seconde approche permet de calculer l'impact environnement de la consommation d'énergie en fonction de la zone géographique où a lieu le processus. Elle est donc retenue autant que possible.**

**Cette page détaille le calcul dans le scénario 2.**

### Cas d'usages

* **Etapes de transformation** : la transformation d'un matériau nécessite 10MJ de chaleur par kg de matériau transformé. Ces 10MJ/kg sont modélisés comme flux externe, de façon à y appliquer le mix énergétique du pays ou de la région où a lieu de processus
* **Assemblage** : l'assemblage d'un produit nécessite 2kWh d'électricité par kg de produit. Ces 10MJ/kg sont modélisés comme flux externe, de façon à y appliquer le mix énergétique du pays ou de la région d'assemblage
* **Distribution** : la transformation d'un matériau nécessite 200kWh d'électricité par m3 de produit. Ces 200kWh/m3 sont modélisés comme flux externe, de façon à y appliquer le mix énergétique retenu pour la distribution
* **Utilisation** : l'utilisation d'un produit nécessite 3MJ de chaleur. Ces 3MJ/kg sont modélisés comme flux externe, de façon à y appliquer le mix énergétique du pays d'utilisation.

### Calcul de l'impact du processus

Le coût environnemental du processus est la somme de plusieurs composantes :&#x20;

* le cout environnemental de l'électricité, calculé à partir de la quantité d'électricité associée au procédé, et d'un procédé électricité sélectionné en fonction de la zone géographique concernée
* le coût environnemental de la chaleur, calculée selon le même principe
* le coût environnement du procédé hors électricité et chaleur. Celui-ci peut être nul (pas de procédé source associé).&#x20;
  * Exemples de cas où ce coût environnemental est à zéro :&#x20;
    * Procédés textile dégraissage, désencollage, mercerisage, teinture, tricotage
    * La plupart des transformation de métaux
    * Vente au détail (étape de distribution)
    * Cuisson d'aliment, repassage de vêtement
  * Exemples de cas où ce coût environnemental est non nul :&#x20;
    * Blanchiment, délavage chimique
    * Lavage des vêtements

### Unités

Dans Ecobalyse, la consommation d'électricité s'exprime en kilowatt.heures (kWh) et la chaleur en megajoules (MJ).

## Méthodes de calcul (Scénario 2 : Flux Externe)

$$
I_{EnergieTransformation} = M_{Sortante}* E_{Transformation}*I_{Energie}
$$

Avec :

* `I_EnergieTransformation` : le cout environnemental relatif à la consommation d'énergie en tant que Flux externe pour l'étape de transformation considérée, exprimée en Pts d'impact
* `Q` : la quantité appelée du processus (exemple : masse de produit transformé), exprimée en unité du processus
  * Pour les procédés des étapes de transformation, `Q` est la masse sortante de l'étape de transformation, exprimée en kg
* `E_Transformation` : l'énergie pour transformer la matière première en 1 kg de produit transformé, exprimé en kWh/unité pour l'électricité et en MJ/unité pour la chaleur
* `I_Energie` : le coût environnemental d'1 kWh d'électricité ou d'1 MJ de chaleur, exprimé en Pts/kWh ou Pts/MJ, et fonction du procédé retenu pour modéliser cette énergie.

Exemples :&#x20;

* Exemple 1 (Textile) :  0,5 kg d'étoffe en sortie de l'étape Ennoblissement ; 0,20 kWh / kg d'électricité et 5.40 MJ/kg de chaleur pour l'étape de pré-traitement _Blanchiment_.
* Exemple 2 (Véhicule) : véhicule de 1400kg ; 1 kWh/kg d'électricité et 3 MJ/kg de chaleur pour l'assemblage

## Procédés utilisés pour le coût environnemental

Le flux externe d'énergie est modélisé avec un procédé correspondant à la zone géographique sélectionnée par l'utilisateur.

<figure><img src="../.gitbook/assets/image (290).png" alt=""><figcaption><p>Illustration de la zone géographique à préciser par l'utilisateur</p></figcaption></figure>

Trois cas sont possibles :&#x20;

* Cas 1 : le pays de transformation n'est pas connu.\
  Lorsque l'utilisateur ne connaît pas le pays, il sélectionne la valeur "Inconnu" dans la liste de zones géographiques proposées. Dans ce cas, ce sont les procédés suivants qui sont retenus :&#x20;
  * Electricité : _market group for electricity, medium voltage, IN_ (Mix électrique de l'Inde, Ecoinvent)
  * Chaleur : _Heat mix (World)_ (Ecobalyse)
* Cas 2 : le pays de transformation est connu et est dans la liste proposée. \
  L'utilisateur sélectionne donc ce pays. Les pays proposés dépendent du secteur (textile, alimentaire...).
* Cas 3 : le pays de transformation est connu mais n'est pas dans la liste proposée.\
  Dans ce cas, l'utilisateur sélectionne la région dans laquelle se situe le pays. 8 régions sont proposées (cf. liste ci-dessous).

<table><thead><tr><th width="322.33331298828125">Régions (8)</th><th>Procédé électricité</th></tr></thead><tbody><tr><td>Europe de l'Ouest</td><td>electricity, medium voltage//[RER] market group for electricity, medium voltage</td></tr><tr><td>Europe de l'Est</td><td>electricity, medium voltage//[CZ] market for electricity, medium voltage</td></tr><tr><td>Asie</td><td>electricity, medium voltage//[RAS] market group for electricity, medium voltage</td></tr><tr><td>Moyen-Orient</td><td>electricity, medium voltage//[RME] market group for electricity, medium voltage</td></tr><tr><td>Afrique</td><td>electricity, medium voltage//[RAF] market group for electricity, medium voltage</td></tr><tr><td>Amérique Latine</td><td>electricity, medium voltage//[RLA] market group for electricity, medium voltage</td></tr><tr><td>Amérique du Nord</td><td>electricity, medium voltage//[RNA] market group for electricity, medium voltage</td></tr><tr><td>Océanie</td><td>electricity, medium voltage//[AU] market for electricity, medium voltage</td></tr></tbody></table>

Pour chaque secteur, la liste des zones géographiques proposées et les procédés associés à chaque zone pour modéliser l'électricité et la chaleur sont indiqués dans l'Explorateur.

NB : en l'absence de procédé ecoinvent 3.9.1 adapté, le mix électrique de l'Australie est utilisé pour modéliser la région Océanie, et celui de la République Tchèque pour l'Europe de l'Est.

{% hint style="info" %}
Choix des procédés retenus pour modéliser mon produit lorsque je ne connais pas l'une des zones géographique demandée :

Ecobalyse retient le choix d'un "majorant raisonnable" pour le cas où une information n'est pas connue, comme cela peut être le cas du pays ici. Ce choix permet d'encourager la traçabilité en défavorisant un utilisateur qui a recourt à la sélection "Inconnu", sans pour autant utiliser une valeur maximale qui serait très peu réaliste (exemple : mix électrique d'un petit pays insulaire)

* Pour l'électricité, le mix électrique de l'Inde est celui correspondant le mieux à ce principe : l'Inde est un grand pays industriel, et aucun pays de grande taille n'a un mix électrique à l'impact environnemental plus élevé que l'Inde.
* Pour la chaleur, le procédé "Monde" est retenu, puisqu'il n'y a pas de distinction pays par pays ici.
{% endhint %}

### Procédés de modélisation de l'Electricité, hors étape d'Utilisation

De manière générale, Ecobalyse utilise les procédés Ecoinvent moyenne tension des pays considérés (exemple pour la France : _market for electricity, medium voltage, FR_).

{% hint style="info" %}
Ce choix présente deux limites :&#x20;

* Ces procédés n'incluent pas la production d'électricité d'origine solaire photovoltaïque. Cette production est inclue par ecoinvent dans les procédés "low voltage". Les pays ayant une production significative d'électricité d'origine photovoltaïque sont donc susceptibles d'être pénalisés.
* Ce choix n'est pas forcément représentatif de tous les industriels (qui peuvent aussi être raccordés en basse tension voire haute tension).
{% endhint %}

<figure><img src="../.gitbook/assets/image (364).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/image (363).png" alt=""><figcaption></figcaption></figure>

### Procédés de modélisation de la chaleur, hors étape d'Utilisation

La base de données Ecoinvent ne propose pas de mix chaleur industrielle par zone géographique (ex : France, Europe, Asie, etc.).&#x20;

En l'absence de tels mix régionaux, Ecobalyse a construit deux procédés chaleurs, correspondant aux deux zones géographiques Europe et Reste du monde, au regard des sources de chaleurs utilisées sur ces zones (voir tableau ci-dessous), et à partir des déclinaisons géographiques des procédés suivants, chacun décliné en deux géographies :&#x20;

* Consommation de chaleur produite à partir de gaz naturel :
  * procédé = _Market group for heat, district or industrial, natural gas_
  * deux zones géographiques : RER (Europe) et GLO (Monde)
* Consommation de chaleur produite à partir d'autres sources :
  * procédé = _Market group for heat, district or industrial, other than natural gas_
  * deux zones géographiques : RER (Europe) et GLO (Monde)

<table><thead><tr><th width="138">Zone</th><th width="204">Procédé chaleur Ecobalyse</th><th width="170">Sources de chaleur</th><th>Géographie utilisée (Ecoinvent)</th></tr></thead><tbody><tr><td>Europe</td><td>Heat mix (Europe)<br>Mix chaleur (Europe)</td><td><a data-footnote-ref href="#user-content-fn-1">44% gaz naturel / <br>56% autres</a></td><td>RER (Europe)</td></tr><tr><td>Rest of the world</td><td><p>Heat mix (World)</p><p>Mix chaleur (Monde) </p></td><td><a data-footnote-ref href="#user-content-fn-2">23% gaz naturel / <br>77% autres</a></td><td>GLO (Monde)</td></tr></tbody></table>

Il en ressort que l'impact environnemental de la consommation de chaleur industrielle hors Europe est significativement plus élevée que celle en Europe (+73% en points d'impact).

### Procédés de modélisation pour l'étape d'Utilisation

* Ecobalyse utilise les procédés Ecoinvent basse tension du pays considérés, en l’occurrence la France : _market for electricity, low voltage, FR_
* Ecobalyse utilise un procédé Agribalyse 3.2 "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas)"
  * Appliqué uniquement à l'alimentaire à ce jour



[^1]: Source : Etude Reuters : [https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/](https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/)

[^2]: Article CarbonTrust (UK) : [https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat](https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat)
