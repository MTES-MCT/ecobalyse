# ⚡ Energies des étapes de transformation

## Contexte

Deux scénarios existent pour modéliser la consommation d'énergie des procédés de transformation mobilisés :&#x20;

**Scénario 1** : l'énergie est intégrée dans le procédé mobilisé (voir source et nom technique dans l'explorateur de procédés) en tant que Flux Interne,

**Scénario 2** : l'énergie est modélisée spécifiquement, avec des quantités et des mix géographiques dédiés. La quantité d'énergie est alors une information associée au procédé Ecobalyse en tant que Flux Externe. Une quantité d'électricité et/ou de chaleur par kg est alors indiquée dans les colonnes "Electricité" et "Chaleur" de l'Explorateur du secteur concerné, correspondant à ce Flux externe.

Dans ce scénario 2, le coût environnemental de l'étape de transformation est la somme de plusieurs composantes :&#x20;

* le cout environnemental de l'électricité, calculé à partir de la quantité d'électricité associée au procédé, et d'un procédé électricité sélectionné en fonction de la zone géographique concernée
* le coût environnemental de la chaleur, calculée selon le même principe
* le coût environnement du procédé hors électricité et chaleur. Celui peut être nul (pas de procédé source associé).
  * exemples de cas où ce coût environnemental est à zero : procédés textile dégraissage, désencollage, mercerisage, teinture, tricotage
  * exemples de cas où ce coût environnemental est non nul : blanchiment, délavage chimique)

Cette page détaille le calcul dans le scénario 2.

### Unités

Dans Ecobalyse, la consommation d'électricité s'exprime en kilowatt.heures (kWh) et la chaleur en megajoules (MJ).

Lorsque c'est nécessaire, une conversion entre MJ et kWh est alors appliquée (1 kWh = 3,6 MJ).&#x20;

## Méthodes de calcul (Scénario 2 : Flux Externe)

$$
I_{EnergieTransformation} = M_{Sortante}* E_{Transformation}*I_{Energie}
$$

Avec :

* `I_EnergieTransformation` : le cout environnemental relatif à la consommation d'énergie en tant que Flux externe pour l'étape de transformation considérée, exprimée en Pts d'impact
* `M_Sortante` : la masse de produit après transformation, exprimée en kg
* `E_Transformation` : l'énergie pour transformer la matière première en 1 kg de produit transformé, exprimé en kWh/kg pour l'électricité ou en MJ/kg pour la chaleur
* `I_Energie` : le coût environnemental d'1 kWh d'électricité ou d'1 MJ de chaleur, exprimé en Pts/kWh ou Pts/MJ, et fonction du procédé retenu pour modéliser cette énergie.

Exemples :&#x20;

* Exemple 1 (Textile) :  0,5 kg d'étoffe en sortie de l'étape Ennoblissement ; 0,1 kWh / kg d'électricité et 3.2 MJ/kg de chaleur pour l'étape de pré-traitement _Désencollage_.&#x20;
* Exemple 2 (Véhicule) : véhicule de 1400kg ; 1 kWh/kg d'électricité et 3 MJ/kg de chaleur pour l'assemblage

## Procédés utilisés pour le coût environnemental

Le flux externe d'énergie est modélisé avec un procédé correspondant à la zone géographique sélectionnée par l'utilisateur.

<figure><img src="../.gitbook/assets/image (290).png" alt=""><figcaption><p>Illustration de la zone géographique à préciser par l'utilisateur</p></figcaption></figure>

Trois scénarios sont possibles :&#x20;

* Scénario 1 : le pays de transformation n'est pas connu.\
  Lorsque l'utilisateur ne connaît pas le pays, il sélectionne la zone géographique "Inconnu". Dans ce cas, ce sont les procédés retenus pour l'Inde qui sont utilisés, correspondant aujourd'hui à un majorant pertinent à l'échelle internationale :&#x20;
  * Electricité : _market group for electricity, medium voltage, IN_ (Ecoinvent)
  * Chaleur : _Heat mix (World)_ (Ecobalyse)
* Scénario 2 : le pays de transformation est connu et est dans la liste de pays proposés \
  L'utilisateur sélectionne donc ce pays. Les pays proposés dépendent du secteur (textile, alimentaire...).
* Scénario 3 : le pays de transformation est connu mais n'est pas dans la liste de pays proposés.\
  Dans ce cas, l'utilisateur sélectionne la région dans laquelle se situe le pays. 8 régions sont proposées.
  * la région lorsque le pays n'est pas disponible dans Ecobalyse (cf. liste ci-dessous).&#x20;

| Régions (8)       |
| ----------------- |
| Europe de l'Ouest |
| Europe de l'Est   |
| Asie              |
| Moyen-Orient      |
| Afrique           |
| Amérique Latine   |
| Amérique du Nord  |
| Océanie           |

Pour chaque secteur, la liste des pays proposés et les procédés associés à chaque pays pour modéliser l'électricité et la chaleur sont indiqués dans l'Explorateur.

### Procédés de modélisation de l'Electricité

De manière générale, Ecobalyse utilise les procédés Ecoinvent moyenne tension des pays considérés (exemple pour la France : _market for electricity, medium voltage, FR_).

{% hint style="info" %}
Ce choix présente deux limites :&#x20;

* Ces procédés n'incluent pas la production d'électricité d'origine solaire photovoltaïque. Cette production est inclue par ecoinvent dans les procédés "low voltage". Les pays ayant une production significative d'électricité d'origine photovoltaïque sont donc susceptibles d'être pénalisés.
* Ce choix n'est pas forcément représentatif de tous les industriels (qui peuvent aussi être raccordés en basse tension voire haute tension).
{% endhint %}

<figure><img src="../.gitbook/assets/image (364).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/image (363).png" alt=""><figcaption></figcaption></figure>

### Procédés de modélisation de la chaleur

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

[^1]: Source : Etude Reuters : [https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/](https://www.reuters.com/markets/commodities/industrial-heat-set-major-energy-source-overhaul-by-2050-2023-04-11/)

[^2]: Article CarbonTrust (UK) : [https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat](https://www.carbontrust.com/news-and-insights/insights/industrial-renewable-heat)
