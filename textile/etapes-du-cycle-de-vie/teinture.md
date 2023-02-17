# 🌈 Etape 3 - Ennoblissement

## Description

L’ennoblissement consiste à donner aux tissus l'aspect visuel et les propriétés physiques et esthétiques exigées par les consommateurs. Il peut s'agir d'opérations mécaniques ou chimiques.

L’étape d’ennoblissement se décompose en 3 sous-étapes :&#x20;

* Pré-traitement = Traitement et nettoyage du tissu\
  (les procédés de pré-traitement des fibres sont rattachés à la filature)&#x20;
* Teinture et Impression = Application de colorants/pigments&#x20;
* Finition = Application d’apprêts

Une description détaillée de ces sous-étapes est proposée en bas de page.

## Modélisation Ecobalyse

### Paramètres mobilisés

<details>

<summary>Pré-traitement</summary>

Non applicable

_En l’absence de donnée suffisamment précise dans la Base Impacts, l’étape de Pré-traitement n’est pas paramétrable dans le calculateur. La mise en place d’une nouvelle base de données permettra de répondre à cette limite._&#x20;

</details>

<details>

<summary>Teinture / Impression</summary>

* Pays (obligatoire)
* Teinture (obligatoire)
  * support : fil, tissu, article
* Impression (optionnel)
  * procédé : fixé-lavé, pigmentaire
  * surface imprimée (%)\


_Prochainement disponibles :_ \
_=> Procédé de teinture (discontinu vs continu)_\
_=> Type de fibre teinte (cellulosique, laine, polyester, etc.)_\
_=> Colorants de teinture (dispersés, acides, réactifs, etc.)_\
_=> Source de chaleur paramétrable (gaz naturel, fuel, etc.)_

</details>

<details>

<summary>Finition</summary>

* Pays (obligatoire)

</details>

### Méthodologie de calcul

L'étape Ennoblissement est modélisée comme suit :&#x20;

|                                                                                                                                                  Teinture / Impression                                                                                                                                                 |                                                                                                                                                                 Finition                                                                                                                                                                |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   <p><em>procédé de teinture</em></p><p><em></em><img src="https://lh5.googleusercontent.com/jqLuWcT2QKxQbN-RCWaoRzgUVpRxDJMb6QLzsbnhNG9xh7ksarvEbYH0lhw2GBkGVDYm6jaRa-iItg2GxagVaqbQKcfrZgcj45tM2Q-spgIw7BQd5F8xHE8Y66df6YS1FKgq8NS6ZbGJJuGyE3wrGIrqThW6BVuMiVN1ALSdvbNlIvGCb2iM9JSATg" alt="Procédés Teinture"></p>  | <p><em>procédé de finition</em></p><p><em></em><img src="https://lh6.googleusercontent.com/OMLBrxTzLifDKI8-yBAht3NcDsMbGZzbAQvti-D33Pp__vKa_b6bKWed8P7FqoH7ZqbbPTXu1SmpIfWUQZUurSI6u6sRLKbdNpBaFnUODDx_1RcuA_W6znyWPgQmJ1zXW-mADTxdeKX9PWBsuy0KisNRSMbaQABm5G4mY-rd-gE1PHtMKuObW0Ha4A" alt="Procédés Finition (apprêts chimiques)"></p> |
| <p><em>prodédé d'impression</em></p><p><em></em><img src="https://lh6.googleusercontent.com/WFXgakkV04JekfM2Cn-vkgOLU2QJv7m96A_8SLg_DWYqx8ko7cblFcaNafhUgBvH4brkdVZ2lksYJbixn8Lx74VBwqObrmHx5iPT3sWc4Otg2jgHeRnAma71VWeuPN96VKC2ufIYsghG80M7eiWRxOZPDQ3GCFOVf3Df-s8cUSqo_NGYnqWsmYsrNQ" alt="Procédés Impression"></p> |                                                                                                                                                                                                                                                                                                                                         |

L'impact global de l'Ennoblissement se comprend donc comme résultant de la somme des impacts des :&#x20;

* procédés retenus \
  (cf. intérieur du _system boundaries_)
* flux externes devant être ajoutés à chaque procédé \
  ([chaleur](../parametres-transverses/chaleur.md) et/ou [électricité](../parametres-transverses/electricite.md))

L'impact de chaque procédé pris séparément correspond au produit de la masse "sortante" avec le coefficient d'impact considéré (cf. [Impacts considérés](../impacts-consideres.md)).

$$
ImpactProcédé = MasseSortante(kg) * CoefImpactProcédé
$$

Plus de détail sur la gestion des masses : [Pertes et rebut](../parametres-transverses/pertes-et-rebus.md).

### Procédés disponibles

<details>

<summary>Pré-traitement (0 procédé)</summary>

Non applicable

_En l’absence de donnée suffisamment précise dans la Base Impacts, l’étape de Pré-traitement n’est pas paramétrable dans le calculateur. La mise en place d’une nouvelle base de données permettra de répondre à cette limite._&#x20;

</details>

<details>

<summary>Teinture / Impression (5 procédés)</summary>

* teinture sur fil, procédé représentatif
* teinture sur tissu, procédé représentatif
* teinture sur article, procédé représentatif
* impression pigmentaire, procédé représentatif
* impression fixé-lavé, procédé représentatif

</details>

<details>

<summary>Finition (1 procédé par défaut)</summary>

* apprêt chimique, procédé représentatif

</details>

### Hypothèses par défaut

#### Support de teinture <=> Vêtement

Un procédé de teinture est appliqué par défaut selon la catégorie du produit modélisé (jean, jupe, t-shirt, etc.).

| Support de teinture |                                                Catégorie                                                |         Energie consommée par kg de produit         |
| :-----------------: | :-----------------------------------------------------------------------------------------------------: | :-------------------------------------------------: |
|         Fil         |                                                   jean                                                  | <p>électricité : 2,82 kWh<br>chaleur : 33,42 MJ</p> |
|        Tissu        | cape, châle, chemisier, débardeur, écharpe,  gilet, jupe, manteau, pantalon, pull, robe, t-shirt, veste | <p>électricité : 1,99 kWh<br>chaleur : 25,87 MJ</p> |
|       Article       |                                                                                                         | <p>électricité : 2,56 kWh<br>chaleur : 39,28 MJ</p> |

{% hint style="warning" %}
Après une série d'interviews auprès d'industriels et experts de l'ennoblissement, nous avons constaté que la consommation d'énergie n'est pas un paramètre maîtrisé par les industriels aujourd'hui.&#x20;

Nous ne permettons donc pas de modifier la quantité d'énergie.

Les quantités d'énergie par défaut proviennent de la Base Impacts.&#x20;
{% endhint %}

#### Finition

Un procédé d'apprêt chimique (_apprêt chimique anti-tâche, procédé représentatif_) est appliqué par défaut à chaque produit modélisé.&#x20;

L'utilisateur n'a, à ce stade, pas la possibilité de préciser cette sous-étape pour plusieurs raisons mentionnées ci-dessous.&#x20;

<details>

<summary>Plus d'info</summary>

* la majorité des textiles font l'objet d'au moins un apprêt chimique lors de la sous-étape Finition,
* les apprêts chimiques contribuent fortement à l'indicateur écotoxicité aquatique qui n'est actuellement pas pris en compte dans le calculateur (donc modéliser l'utilisation d'un ou plusieurs apprêts chimiques n'a actuellement aucun impact sur cet indicateur),
* la consommation d'énergie reste relativement stable quel que soit le nombre d'apprêts chimiques utilisés (anti-tâche, anti-acarien, etc.) car ils sont généralement appliqués lors d'un même bain,
* deux procédés d'apprêts mécaniques sont disponibles dans la Base Impacts mais ils s'appliquent uniquement à certaines fibres et ils consomment très peu d'énergie.

Des évolutions sont prévues dans les prochains mois pour répondre à cette limite.&#x20;

</details>

#### Grammage / Masse surfacique (g/m2)

Les données par défaut de grammage par catégorie de produits sont les suivantes :&#x20;

* Base Impacts : cape, châle, chemisier, écharpe, jean, jupe, manteau, pantalon, robe, veste
* Extrapolation Base Impacts par Ecobalyse : débardeur, gilet, pull, t-shirt

Le grammage est un paramètre clé pour les procédés d'impression (unité = m2) car il impacte la surface d'étoffe (m2) via la relation Poids (g) = grammage (g/m2) \* surface (m2)

#### Source de production de vapeur &#x20;

L'utilisateur a la possibilité de préciser la source de production de vapeur utilisée sur le site industriel des étapes d'ennoblissement.&#x20;

4 sources (gaz naturel, fuel lourd, fuel léger, charbon) et deux régions (Europe, Asie) sont disponibles.

Par défaut, un mix régional est appliqué selon le pays (cf. section [Chaleur](https://fabrique-numerique.gitbook.io/ecobalyse/textile/parametres-transverses/chaleur)).&#x20;

#### Impression <=> % étoffe &#x20;

Deux types d'impression sont proposées (fixé-lavé et pigmentaire). \
La quantité de tissu imprimée est à spécifier par l'utilisateur (en % de la surface d'étoffe entrante). Cette donnée n'étant généralement pas maîtrisée par les metteurs sur le marché, cinq scénarios sont proposés (1%, 5%, 20%, 50% et 100%).&#x20;

#### Fibre <=> Procédé de teinture (en cours)

Il n’est pas encore possible de différencier les procédés de teinture (continu ou discontinu) ni les colorants (dispersés, acides, réactifs, cationiques, de cuve) utilisés selon la fibre teinte (cellulosique, laine, mix de fibres, etc.).

Cela s’explique en partie par le manque de profondeur de la base de données utilisée (Base Impacts).

Ces paramétrages seront prochainement disponibles sur le calculateur.

## Limites

* Les indicateurs "Consommations d'eau" et "Ecotoxicité aquatique" ne sont pas modélisés,
* Les principaux procédés de Pré-Traitement du tissu ne sont pas encore disponibles,
* Les principaux procédés (continu vs discontinu) et colorants de teinture ne sont pas encore disponibles,

## En savoir plus sur l'ennoblissement

### Pré-traitement

Les procédés de pré-traitement consistent à traiter et nettoyer le tissu, généralement en préparation de la teinture. Cependant, même si le tissu n’est pas teint, l’étape de pré-traitement est nécessaire pour le nettoyer. Plusieurs procédés peuvent être utilisés selon la matière traitée (lavage, désencollage, flambage, mercerisage, débouillissage, blanchiment, etc.). Le pré-traitement des fibres naturelles est en général plus complexe que celui des fibres synthétiques et artificielles.

### Teinture / Impression

Les procédés de teinture et impression consistent tous les deux à appliquer un colorant sur le tissu. Toutefois, le procédé d’impression, au lieu de colorer l'ensemble du support, se concentre sur des zones définies afin d'obtenir le motif désiré.

Le calculateur permet de modéliser cette étape directement après la fabrication du tissu.&#x20;

Dans certains cas, la teinture peut être effectuée en amont (sur fil) ou en aval (sur article). Ecobalyse permet aussi de modéliser ces configurations dans cette sous-étape “Teinture et Impression” afin de faciliter les comparaisons.

Deux procédés d'impression (pigmentaire et fixé-lavé) sont proposés. L'impression pigmentaire consiste à déposer des pigments colorés à la surface de l'étoffe et s'applique généralement aux fibres cellulosiques. L'impression fixé-lavé consiste à fixer des colorants sur la fibre comme une teinture (à l'inverse des pigments qui pénètrent moins dans la fibre). \
Les deux procédés sont basés sur une moyenne de trois techniques : impression à cadre plat, impression à cadre rotatif, impression au jet d'encre (digitale). &#x20;

<details>

<summary>En savoir plus</summary>

Concernant la **teinture**, deux principaux procédés sont utilisés dans l’industrie : la teinture en discontinu et la teinture en continu (et semi-continu).&#x20;

La teinture en **discontinu** (également appelée teinture par épuisement) consiste à tremper la matière dans une solution aqueuse contenant des colorants et produits auxiliaires pendant une période allant de quelques minutes à quelques heures. Un paramètre important en teinture en discontinu est le rapport de bain (MLR = Mass to Liquor Ratio). Il s'agit du rapport de poids entre la matière sèche totale et la solution totale. Ainsi, par exemple, un rapport de bain de 1:10 signifie 10 litres d'eau pour 1 kg de matière textile.&#x20;

La teinture en **continu** consiste à appliquer le bain de teinture soit par imprégnation (au moyen de foulards), soit en utilisant d'autres systèmes d'application. Dans ces procédés, le facteur dont il faut tenir compte est le taux d’emport ou taux d’exprimage (masse en grammes de solution absorbée pour 100 grammes d'étoffe sèche) et la concentration du colorant.

Les procédés de teinture en discontinu conduisent en général à des consommations d'eau et d'énergie plus élevées que les procédés continus. Cependant, bien que les procédés de teinture en continu consomment moins d'eau, ces derniers nécessitent une concentration plus élevée de colorant dans le bain d’imprégnation. (entre 10 et 100g/L vs entre 0,1 et 1g/L pour les procédés en discontinu). Ainsi, le rejet de cet effluent concentré peut entraîner une charge de pollution plus élevée qu’en teinture en discontinu.

**L’impression** consiste systématiquement à préparer la pâte d’impression, appliquer la pâte au support en utilisant différentes techniques, fixer les colorants sur l’étoffe puis traiter/laver/sécher l’étoffe.&#x20;

Deux techniques d'impression existent : \
\- l'impression avec des pigments qui n'ont aucune affinité pour la fibre (technique la plus utilisée aujourd’hui dans l’industrie),\
\- l'impression avec des colorants (réactifs, de cuve, dispersés, etc.).

Les machines/techniques d'impression les plus utilisées sont : \
\- impression au cadre plat\
\- impression au cadre rotatif\
\- impression digitale (par jet d'encre)\
\- impression numérique par sublimation (motif imprimé sur un papier support)

</details>

### Finition

Cette sous-étape regroupe les traitements qui servent à donner aux textiles les propriétés d'usage final souhaitées (les “apprêts”). Celles-ci peuvent inclure des propriétés relatives à l'effet visuel, au toucher et à des caractéristiques spéciales telles que l'imperméabilisation et d'ininflammabilité.&#x20;

Les apprêts peuvent impliquer des traitements mécaniques/physiques et chimiques. Dans la majorité des cas, les apprêts chimiques sont appliquées sous la forme de solutions aqueuses au moyen de la technique de foulardage.&#x20;

Certains apprêts sont spécifiques à certaines fibres (ex : les apprêts _easy care_ pour le coton) tandis que d'autres ont une application plus générale (ex : les adoucissants).
