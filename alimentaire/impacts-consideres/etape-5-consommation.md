# 🍽️ Etape 5 : consommation

Les impacts considérés pour la phase de consommation sont cadrés dans la partie "3.7 Phase d'utilisation" de la méthodologie Agribalyse ([Méthodologie\_AGB\_3.1\_alimentation.pdf](https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971)).

Ils correspondent à :

* L'énergie mobilisée pour la cuisson, la congélation et le maintien au frais des produits
* L'impact lié à la fin de vie
  * des emballages
  * des parties non comestibles des aliments

Dans un premier temps, l'impact lié à la fin de vie des emballages et des parties non comestibles n'est pas pris en compte. Il sera à ajouter ultérieurement.

Dans le cas par exemple d'une pizza au thon, l'impact lié à la fin de vie du carton représente environ 0,08 microPts PEF, à comparer à plus de 31 microPts PEF pour l'énergie électrique mobilisée. Dans cet exemple, la fin de vie de l'emballage représenterait donc 0,25% de l'impact à l'étape de consommation.

## Energie mobilisée pour la cuisson, la congélation, la réfrigération... <a href="#energie-mobilisee-pour-la-cuisson-la-congelation-la-refrigeration" id="energie-mobilisee-pour-la-cuisson-la-congelation-la-refrigeration"></a>

Le principe général est l'ajout de différentes [techniques de préparation](https://fabrique-numerique.gitbook.io/sandbox/cycle-de-vie-des-produits-alimentaires/etape-5-consommation#techniques-de-preparation).

* L'ajout de ces techniques est **optionnel**, de sorte que l'étape de consommation peut être vide. Par exemple, une pomme peut être consommée telle quelle, sans nécessiter ni réfrigération, ni cuisson...
* L'ajout de **deux techniques de préparation** est possible. Par exemple, un plat surgelé peut être conservé au congélateur avant d'être cuit à la poêle.

### Energies mobilisables et procédés correspondants <a href="#energies-mobilisables-et-procedes-correspondants" id="energies-mobilisables-et-procedes-correspondants"></a>

2 types d'énergie peuvent être mobilisées dans les calculs :

* l'électricité (pour les congélateurs, réfrigérateurs, plaques électriques, fours, fours micro-ondes...)
* le gaz (pour les plaques de gaz)

Les procédés mobilisés sont les suivants :

* Électricité : Electricity, low voltage {FR}| market for | Cut-off, U ;
* Énergie thermique : Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, U .

### Techniques de préparation <a href="#techniques-de-preparation" id="techniques-de-preparation"></a>

En repartant des tableaux 41, 42 et 43 de la méthodologie Agribalyse ([lien](https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971)), 9 techniques de préparation sont proposées :&#x20;

<figure><img src="../../.gitbook/assets/image (2) (1) (1) (1) (2) (1).png" alt=""><figcaption></figcaption></figure>

Pour la **cuisson à la poêle**, la durée et la puissance de cuisson dépend de l'ingrédient (cf. tableau 42) :&#x20;

<figure><img src="../../.gitbook/assets/image (1) (1) (1) (1) (1) (1) (1) (1) (1) (1) (2) (1) (1).png" alt=""><figcaption></figcaption></figure>

{% hint style="warning" %}
**En première approche**, il est seulement considéré deux modes de cuisson :

* Cuisson à la poêle (viandes, poissons, fruits et légumes crus), qui consomme une énergie de 0,44 kWh (1,584 MJ). Cette énergie est indépendante de la masse qui est cuite.
* Réchauffage à la poêle (céréales, autres), qui consomme une énergie de 0,08 kWh (0,288 MJ). Cette énergie est indépendante de la masse qui est réchauffée.
* Le cas de la cuisson d'un oeuf mérite d'être regardé...
{% endhint %}

Pour la **cuisson à l'eau ou sous pression**, la durée de cuisson et la quantité d'eau à ajouter dépendent du type d'ingrédient :&#x20;

<figure><img src="../../.gitbook/assets/image (2) (1) (1) (1) (2) (1) (1).png" alt=""><figcaption></figcaption></figure>

{% hint style="warning" %}
Ces données étant insuffisantes pour déduire l'énergie nécessaire à la cuisson à l'eau ou sous pression, cette option n'est pas proposée dans un premier temps.

En première approche, différents cas particuliers identifiés dans la méthodologie Agribalyse ne sont pas intégrés :

* la réfrigération de l'eau en bouteille (0,0111 kWh/kg)
* l'ajout d'huile ou de matière grasse pour la friture ou la cuisson à la poêle
{% endhint %}

#### Masse considérée <a href="#masse-consideree" id="masse-consideree"></a>

Pour la cuisson à l'eau ou l'utilisation d'une bouilloire, la masse à considérer intègre (ou est remplacée par) une quantité d'eau qui doit être ajoutée.
