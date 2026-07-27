# ◻️ Procédés Acier et Aluminium

## Contexte

L'acier et l'aluminium sont des matériaux largement utilisés dans tous types de produits.

Leur impact environnemental dépend fortement de deux paramètres :

* Le taux d'intégration de matière recyclée
* Les méthodes de fabrication de la matière première

Ces deux éléments dépendent du lieu de fabrication, et en conséquence du lieu de vente de ces matériaux.

Cependant, identifier le lieu de fabrication, le taux de recyclage et les méthodes de fabrication des matières est très difficile, voire impossible pour une grande partie des composants.

Pour les cas d'usage d'Ecobalyse, il est plus pertinent de travailler à partir du mix moyen se trouvant sur une zone géographique donnée.

{% hint style="info" %}
Par exemple : un fabricant français utilise une grande quantité d'acier dans la fabrication de ses produit. Il achète cet acier sous deux formes :&#x20;

* des pièces métalliques, qu'il va ensuite découper, plier et souder
* au sein de composants qu'il achète tous prêts auprès d'un fournisseur allemand

Dans les deux cas, il achète auprès d'industriels qui eux-même s'approvisionnent auprès d'un ensemble de fournisseurs d'acier.

Il lui est donc impossible de lister les origines géographiques et méthodes de fabrication de ses aciers.

Cependant, on peut prendre l'hypothèse que l'acier qu'il achète correspond au mix moyen que l'on trouve en France, et que l'acier dans les composants correspond au mix moyen de l'acier que l'on trouve en Allemagne.
{% endhint %}

## Procédés utilisés pour le coût environnemental

Des procédés Acier et Aluminium ont été construits pour plusieurs zones géographiques à partir des travaux menés par le Service Transport et Mobilité de l'ADEME.&#x20;

{% hint style="info" %}
Les travaux du Service Transport et Mobilité de l'ADEME ont permis la construction de facteurs d'émissions (impact sur le changement climatique uniquement) pour tous les pays producteurs de véhicules électriques (plus de 30) et trois zones géographiques complémentaires. A ce stade, à des fins de simplicité et de lisibilité pour l'utilisateur, seule une partie est construite dans Ecobalyse, représentative des résultats obtenus.
{% endhint %}

Pour Ecobalyse, les procédés suivants ont été créés :

* 5 procédés pour l'Acier :&#x20;
  * Acier vierge, acier recyclé, mix vierge + recyclé
  * 1 procédé pour l'acier vierge
  * 2 géographies pour l'acier recyclé et le mix : Europe (Pays de référence : France) et Reste du Monde (Pays de référence : Japon)
* 7 procédés pour l'aluminium :&#x20;
  * Aluminium vierge, Aluminium recyclé, mix vierge + recyclé
  * 3 géographies pour l'aluminium vierge : Europe (Pays de référence : France), Inde, Reste du Monde (Pays de référence : Corée du Sud)
  * 1 procédé pour l'aluminium recyclé
  * 3 géographies pour le mix : Europe (Pays de référence : France), Chine, Reste du Monde (Pays de référence : Corée du Sud).

Les procédés construits sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes).

<figure><img src="../../.gitbook/assets/image (385).png" alt=""><figcaption></figcaption></figure>

### Acier :&#x20;

Voir détail de la construction des mix marchés dans ce fichier :&#x20;

{% file src="../../.gitbook/assets/Mix marchés Acier - ADEME 20260702 avec ECS.xlsx" %}

Les procédés sont créés à partir des 4 procédés suivants :

* steel, unalloyed//\[RER] steel production, converter, unalloyed
* steel, unalloyed//\[RoW] steel production, converter, unalloyed
* steel, low-alloyed//\[RER] steel production, electric, low-alloyed
* steel, low-alloyed//\[RoW] steel production, electric, low-alloyed

### Aluminium :&#x20;

Voir détail de la construction des mix marchés dans ce fichier :&#x20;

{% file src="../../.gitbook/assets/Mix marchés Alu - ADEME 20260626 sans FE.xlsx" %}

Les procédés sont créés à partir des procédés suivants :

* aluminium, primary, ingot//\[RoW] aluminium production, primary, ingot
* aluminium, primary, ingot//\[CA] aluminium production, primary, ingot
* aluminium, primary, ingot//\[CN] aluminium production, primary, ingot
* aluminium, primary, ingot//\[UN-OCEANIA] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, Africa] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, EU27 & EFTA] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, South America] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, Gulf Cooperation Council] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, Asia, without China and GCC] aluminium production, primary, ingot
* aluminium, primary, ingot//\[IAI Area, Russia & RER w/o EU27 & EFTA] aluminium production, primary, ingot
* aluminium, cast alloy//\[RER] treatment of aluminium scrap, post-consumer, prepared for recycling, at refiner
* aluminium, cast alloy//\[RoW] treatment of aluminium scrap, post-consumer, prepared for recycling, at refiner

