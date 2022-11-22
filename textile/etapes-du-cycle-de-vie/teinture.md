# 🌈 Etape 3 - Ennoblissement

## Description

L’ennoblissement consiste à donner aux tissus l'aspect visuel et les propriétés physiques et esthétiques exigées par les consommateurs. Il peut s'agir d'opérations mécaniques ou chimiques.

L’étape d’ennoblissement se décompose en 3 sous-étapes :&#x20;

* Pré-traitement = Traitement et nettoyage du tissu\
  (les procédés de pré-traitement des fibres sont rattachés à la filature)&#x20;
* Teinture et Impression = Application de colorants&#x20;
* Finition = Application d’apprêts

Une description détaillée de ces sous-étapes est proposée en bas de page.

## Modélisation Ecobalyse

### Paramètres mobilisés

<details>

<summary>Pré-traitement</summary>

Non applicable

_En l’absence de données suffisamment précises dans la Base Impacts, l’étape de Pré-traitement n’est pas paramétrable dans le calculateur. La mise en place d’une nouvelle base de données permettra de répondre à cette limite._&#x20;

</details>

<details>

<summary>Teinture / Impression</summary>

* Support de teinture (sur fil, tissu, article)
* Procédé d'impression (fixé-lavé, pigmentaire)
* Pays
* Quantité d'énergie consommée (électricité et chaleur)

Prochainement disponibles : \
\=> Procédé de teinture (discontinu, continu)\
\=> Colorants de teinture (dispersés, acides, réactifs, etc.)\
\=> Source de chaleur (gaz naturel, fuel, etc.)

</details>

<details>

<summary>Finition</summary>

* 1 procédé par défaut (application d'un apprêt chimique)
* Pays
* Quantité d'énergie consommée (électricité et chaleur)

</details>

### Méthodologie de calcul

L'étape Ennoblissement est modélisée comme suit :&#x20;

|                                                                                                                                                  Teinture / Impression                                                                                                                                                 |                                                                                                                                                                 Finition                                                                                                                                                                |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|   <p><em>procédé de teinture</em></p><p><em></em><img src="https://lh5.googleusercontent.com/jqLuWcT2QKxQbN-RCWaoRzgUVpRxDJMb6QLzsbnhNG9xh7ksarvEbYH0lhw2GBkGVDYm6jaRa-iItg2GxagVaqbQKcfrZgcj45tM2Q-spgIw7BQd5F8xHE8Y66df6YS1FKgq8NS6ZbGJJuGyE3wrGIrqThW6BVuMiVN1ALSdvbNlIvGCb2iM9JSATg" alt="Procédés Teinture"></p>  | <p><em>procédé de finition</em></p><p><em></em><img src="https://lh6.googleusercontent.com/OMLBrxTzLifDKI8-yBAht3NcDsMbGZzbAQvti-D33Pp__vKa_b6bKWed8P7FqoH7ZqbbPTXu1SmpIfWUQZUurSI6u6sRLKbdNpBaFnUODDx_1RcuA_W6znyWPgQmJ1zXW-mADTxdeKX9PWBsuy0KisNRSMbaQABm5G4mY-rd-gE1PHtMKuObW0Ha4A" alt="Procédés Finition (apprêts chimiques)"></p> |
| <p><em>prodédé d'impression</em></p><p><em></em><img src="https://lh6.googleusercontent.com/WFXgakkV04JekfM2Cn-vkgOLU2QJv7m96A_8SLg_DWYqx8ko7cblFcaNafhUgBvH4brkdVZ2lksYJbixn8Lx74VBwqObrmHx5iPT3sWc4Otg2jgHeRnAma71VWeuPN96VKC2ufIYsghG80M7eiWRxOZPDQ3GCFOVf3Df-s8cUSqo_NGYnqWsmYsrNQ" alt="Procédés Impression"></p> |                                                                                                                                                                                                                                                                                                                                         |

L'impact global de l'Ennoblissement se comprend donc comme résultant de la somme des impacts des :&#x20;

* procédé retenus \
  (cf. intérieur du _system boundaries_)
* flux externes devant être ajoutés à chaque procédé \
  ([chaleur](../parametres-transverses/chaleur.md) et/ou [électricité](../parametres-transverses/electricite.md))

L'impact de chaque procédé pris séparement correspond au produit de la masse "sortante" avec le coefficient d'impact considéré (cf. [Impacts considérés](../impacts-consideres.md)).

$$
ImpactProcédé = MasseSortante(kg) * CoefImpactProcédé
$$

Plus de détail sur la gestion des masses : [Pertes et rebut](../parametres-transverses/pertes-et-rebus.md).

### Procédés disponibles

<details>

<summary>Pré-traitement (0 procédé)</summary>

Non applicable

_En l’absence de données suffisamment précises dans la Base Impacts, l’étape de Pré-traitement n’est pas paramétrable dans le calculateur. La mise en place d’une nouvelle base de données permettra de répondre à cette limite._&#x20;

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

* apprêt chimique anti-tache, procédé représentatif

</details>

### Hypothèses par défaut

#### Support de teinture <=> Vêtement

Un procédé de teinture est appliqué par défaut selon la catégorie du produit modélisé (jean, jupe, t-shirt, etc.).

| Support de teinture |                                                Catégorie                                                |      Energie consommée par kg de produit teint      |
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

Un procédé d'apprêt chimique anti-tache est appliqué par défaut à chaque produit modélisé.&#x20;

L'utilisateur n'a, à ce stade, pas la possibilité de préciser le(s) apprêt(s) utilisés pour son produit.&#x20;

<details>

<summary>Plus d'info</summary>

La Base Impacts propose 4 apprêts chimiques (anti-bactérien, déperlant, grattage, etc.) et 2 apprêts mécaniques (grattage, rasage) supplémentaires. Cependant, il n'est à ce stade pas pertinent de permettre de modéliser tout ou partie de ces procédés car :&#x20;

* la Base Impacts ne permet pas de modéliser l'indicateur _Ecotoxicité aquatique_ (les apprêts chimiques contribuent fortement à cet indicateur),
* les apprêts chimiques sont généralement appliqués lors d'un même bain (donc la consommation d'énergie nécessaire pour actionner le procédé reste stable quelque soit le nombre d'apprêts utilisés),
* les deux procédés d'apprêts mécaniques sont spécifiques à certaines fibres et consomment très peu d'énergie,
* la liste des apprêts disponibles n'est pas exhaustive par rapport aux pratiques de l'industrie.

Des évolutions sont prévues dans les prochains mois pour permettre de détailler cette étape.&#x20;

</details>

#### Type de fibre <=> Consommation d'énergie&#x20;

La quantité d'énergie nécessaire pour actionner le procédé de teinture est pondérée selon le type de fibre.&#x20;

| Fibre             | Matières                                                                                      |           Energie consommée          |
| ----------------- | --------------------------------------------------------------------------------------------- | :----------------------------------: |
| cellulosique      | cotton, flax, chanvre, jute, lyocell, modal, viscose                                          | <p>Valeur par défaut</p><p>(Ref)</p> |
| synthétique       | acrylic, nylon, polyester, PU, PTT, PBT, PP, PLA, PE, PET, PA, acrylique, néoprène, aramide,  |               Ref -25%               |
| naturelle (autre) | laine, soie, lin, cachemire, angora, acetate triacetate, alpaca,                              |               Ref +25%               |
| mix               | non applicable                                                                                |               Ref +50%               |

{% hint style="warning" %}
Suite à différents travaux thématiques (interviews d'experts, revue bibliographique, analyse de sensibilité), nous avons constaté que le type de fibre (mélange de fibres, laine, polyester, etc.) sur lequel est appliqué la teinture a une influence directe sur la quantité d'énergie consommée.&#x20;

Par exemple, la teinture des mélanges prend toujours plus de temps et est une opération plus difficile que la teinture de fibres pures.

Nous proposons en première approche une classification des fibres teintes et une pondération de la consommation d'énergie.

:bulb: N'hésitez pas à nous partager votre retour d'expérience sur ce sujet par [mail](mailto:ecobalyse@beta.gouv.fr).&#x20;
{% endhint %}

#### Type de fibre <=> Procédé de teinture (en cours)

Il n’est pas encore possible de différencier les procédés de teinture (continu vs discontinu) ni les colorants (dispersés, acides, réactifs, cationiques, de cuve) utilisés.

Cela s’explique en partie par le manque de profondeur de la base de données utilisée (Base Impacts).

Ces paramétrages seront prochainement disponibles sur le calculateur.

#### Grammage / Masse surfacique (g/m2)

Les données par défaut de grammage par catégorie de produits sont les suivantes :&#x20;

* Base Impacts : cape, châle, chemisier, écharpe, jean, jupe, manteau, pantalon, robe, veste
* Extrapolation Base Impacts par Ecobalyse : débardeur, gilet, pull, t-shirt

## Limites

* Les indicateurs "Consommations d'eau" et "Ecotoxicité aquatique" ne sont pas modélisés
* Les principaux pocédés de Pré-Traitement du tissu ne sont pas encore disponibles
* Les principaux procédés (continu vs discontinu) et colorants de teinture ne sont pas encore disponibles

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

Concernant la **teinture**, deux principaux procédés sont utilisés dans l’industrie : la teinture en discontinue et la teinture en continue (et semi-continue).&#x20;

La teinture en **discontinu** (également appelée teinture par épuisement) consiste à tremper la matière dans une solution aqueuse contenant des colorants et produits auxiliaires pendant une période allant de quelques minutes à quelques heures. Un paramètre important en teinture discontinue est le rapport de bain (MLR = Mass to Liquor Ratio). Il s'agit du rapport de poids entre la matière sèche totale et la solution totale. Ainsi, par exemple, un rapport de bain de 1:10 signifie 10 litres d'eau pour 1 kg de matière textile.&#x20;

La teinture en **continu** consiste à appliquer le bain de teinture soit par imprégnation (au moyen de foulards), soit en utilisant d'autres systèmes d'application. Dans ces procédés, le facteur dont il faut tenir compte est le taux d’emport ou taux d’exprimage (masse en grammes de solution absorbée pour 100 grammes d'étoffe sèche) et la concentration du colorant.

Les procédés de teinture en discontinu conduisent en général à des consommations d'eau et d'énergie plus élevées que les procédés continus. Cependant, bien que les procédés de teinture à la continu consomment moins d'eau, ces derniers nécessitent une concentration plus élevée de colorant dans le bain d’imprégnation. (entre 10 et 100g/l vs entre 0,1 et 1g/l pour les procédés en discontinu). Ainsi, le rejet de cet effluent concentré peut entraîner une charge de pollution plus élevée qu’en teinture discontinue.

**L’impression** consiste systématiquement à préparer la pâte d’impression, appliquer la pâte au support en utilisant différentes techniques, fixer les colorants sur l’étoffe puis traiter/laver/sécher l’étoffe.&#x20;

Deux techniques d'impression existent : \
\- l'impression avec des pigments qui n'ont aucune affinité pour la fibre (technique la plus utilisée aujourd’hui dans l’industrie),\
\- l'impression avec des colorants (réactifs, de cuve, dispersés, etc.).

Les machines/techniques d'impression les plus utilisées sont : \
\- impression au cadre plat\
\- impression au cadre rotatif\
\- impression au rouleau\
\- impression digitale (par jet d'encre)\
\- impression par transfert numérique (la sublimation)&#x20;

</details>

### Finition

Cette sous-étape regroupe les traitements qui servent à donner aux textiles les propriétés d'usage final souhaitées (les “apprêts”). Celles-ci peuvent inclure des propriétés relatives à l'effet visuel, au toucher et à des caractéristiques spéciales telles que l'imperméabilisation et d'ininflammabilité.&#x20;

Les apprêts peuvent impliquer des traitements mécaniques/physiques et chimiques. Dans la majorité des cas, les apprêts chimiques sont appliquées sous la forme de solutions aqueuses au moyen de la technique de foulardage.&#x20;

Certais apprêts sont spécifiques à certaines fibres (ex : les apprêts _easy care_ pour le coton) tandis que d'autres ont une application plus générale (ex : les adoucissants).
