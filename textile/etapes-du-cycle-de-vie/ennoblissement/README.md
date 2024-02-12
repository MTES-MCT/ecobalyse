# 🌈 Etape 3 - Ennoblissement

L’ennoblissement consiste à donner aux tissus l'aspect visuel et les propriétés physiques et esthétiques exigées par les consommateurs. Il peut s'agir d'opérations mécaniques ou chimiques.

L’étape d’ennoblissement se décompose en 3 sous-étapes :&#x20;

* Pré-traitement = Traitement et nettoyage des fibres,\
  (ces derniers peuvent être réalisés sur fil, sur étoffe ou sur article)
* Teinture et Impression = Application de colorants/pigments,
* Finition = Application d’apprêts.

Une description détaillée de ces sous-étapes est proposée en bas de page.

## Modélisation Ecobalyse

### Paramètres mobilisés

<details>

<summary>Pré-traitements</summary>

* Nature des fibres (synthétique, naturelle d'origine animale, etc.),
* Type d'étoffe (tissée vs tricotée).

</details>

<details>

<summary>Teinture / Impression</summary>

* Pays (obligatoire)
* Nature des fibres (synthétique, naturelle d'origine animale, etc.),
* Impression (optionnel)\
  Procédé : fixé-lavé, pigmentaire\
  Surface imprimée (%)

</details>

<details>

<summary>Finition</summary>

* Pays (obligatoire)

</details>

### Méthodologie de calcul

#### Etape 1 =  Modélisation des flux externes des procédés

L'impact global de l''étape Ennoblissement se comprend comme résultant de la somme des impacts des procédés retenus.&#x20;

L'impact de chaque procédé pris séparément correspond au produit de la masse "sortante" avec le coefficient d'impact considéré (cf. [Impacts considérés](../../impacts-consideres.md)).

$$
ImpactProcédé = MasseSortante(kg) * CoefImpactProcédé
$$

Le CoefImpactProcédé correspond à la somme des impacts des flux externes considérés :&#x20;

* :zap:électricité (exprimé en kWh / kg),
* :fire: chaleur (exprimé en MJ / kg),
* :blue\_circle: eau (exprimé en m3 / kg).&#x20;

Plus de détail sur la gestion des masses : [Pertes et rebut](../../parametres-transverses/pertes-et-rebus.md).

#### Etape 2 =  Ajout des impacts Ecotox/Tox via la construction d'inventaires enrichis&#x20;

Du fait de limites inhérentes à la Base Impacts (non prise en compte des indicateurs _Ecotoxicité Aquatique_, _Toxicité Humaine Cancérigène_, _Toxicité Humaine Non Cancérigène_) et à l'industrie Textile (absence de transparence/modélisation des substances chimiques utilisées lors des étapes d'ennoblissement), Ecobalyse propose des inventaires enrichis (plus d'info [ici](https://app.gitbook.com/o/-MMQU-ngAOgQAqCm4mf3/s/-MexpTrvmqKNzuVtxdad/\~/changes/774/textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis)). &#x20;

### Procédés mobilisés&#x20;

<details>

<summary>Pré-traitement (3 procédés)</summary>

* Blanchiment (Bleaching)\
  Consiste à éliminer les colorants naturels des fibres pour les rendre plus blanches et hydrophiles.

<!---->

* Dégraissage ou Débouillissage (Scouring)\
  Consiste à éliminer les impuretés naturelles et graisses des fibres naturelles afin de rendre les fibres perméables au processus aval (blanchiment, teinture, etc.).&#x20;

<!---->

* Désencollage (Desizing)\
  Consiste à apprêter les fibres avec des produits appropriés (amidon, agents mouillants et lubrifiants) avant l'étape de tissage, puis à les retirer après la réalisation du tissu.

</details>

<details>

<summary>Teinture (2 procédés)</summary>

* teinture en discontinue (pour les fibres synthétiques)
* teinture en continue (pour les autres fibres)&#x20;

</details>

<details>

<summary>Finition (1 procédé par défaut)</summary>

* Finition (apprêts chimiques, en continue)&#x20;

</details>

<details>

<summary>Impression</summary>

* Impression pigmentaire, procédé représentatif
* Impression fixé-lavé, procédé représentatif

</details>

### Hypothèses par défaut

#### Procédé <=> Type de fibre (synthétique, naturelle origine animale, etc.)

* Blanchiment (Bleaching)\
  Appliqué par défaut pour les matières autres que celles synthétiques.&#x20;
* Dégraissage/Débouillissage  (Scouring)\
  Appliqué par défaut pour les matières naturelles.&#x20;
* Désencollage (Desizing)\
  Appliqué par défaut pour toutes les étoffes tissées.&#x20;
* Teinture en discontinue (Batch dyeing)\
  Appliqué par défaut pour les fibres synthétiques
* Teinture en continue (Continuous dyeing)\
  Appliqué par défaut pour les autres fibres&#x20;

#### Consommations d'eau, d'énergie et de chaleur

<table><thead><tr><th>Sous-étape</th><th width="138">Procédé</th><th>m3 / kg (eau) </th><th>kWh / kg (électricité)</th><th>MJ / kg (chaleur)</th></tr></thead><tbody><tr><td>Pre-traitement</td><td>Désencollage</td><td>0,01</td><td>0,07</td><td>2,16</td></tr><tr><td>Pre-traitement</td><td>Dégraissage</td><td>0,04</td><td>0,2</td><td>7,2</td></tr><tr><td>Pre-traitement</td><td>Blanchiment</td><td>0,05</td><td>0,15</td><td>3,6</td></tr><tr><td>Teinture</td><td>Continue</td><td>0,1</td><td>0,3</td><td>7,2</td></tr><tr><td>Teinture</td><td>Discontinue (batch dyeing)</td><td>0,18</td><td>0,8</td><td>21,6</td></tr><tr><td>Finition</td><td>Apprès chimiques (en continue)</td><td>0,01</td><td>0,4</td><td>9</td></tr></tbody></table>

{% hint style="info" %}
Les valeurs retenues sont issues du rapport [BAT 2023](#user-content-fn-1)[^1] (données moyennes)\*.\
Une vingtaine de sites industriels ont pargé leurs consommations annuelles par procédé sur 3 années (2016, 2018, 2018). \
Ecobalyse a extrait des valeurs Min-Max-Average (cf. ci-dessous) sur la base des graphes de restitutions proposés dans la partie _3.6 Specific water and energy consumption_.&#x20;

\
\* Excepté le procédé _Finition - Par défaut_ qui est issu du procédé Base Impacts [_apprêt chimique anti-tâche, procédé représentatif_](#user-content-fn-2)[^2] _._ L'introduction d'un tel procédé permet d'estimer les consommations des apprêts chimiques car ces derniers (apprêt anti-tâche, anti-acarien, etc.) sont généralement appliqués lors d'un même bain.
{% endhint %}

<div>

<figure><img src="../../../.gitbook/assets/Consommation d&#x27;électricité (kWh _ kg)  (1) (1).png" alt=""><figcaption></figcaption></figure>

 

<figure><img src="../../../.gitbook/assets/Consommation d&#x27;eau (m3 _ kg)  (1) (1).png" alt=""><figcaption></figcaption></figure>

 

<figure><img src="../../../.gitbook/assets/Consommation de chaleur (MJ _ kg)  (2).png" alt=""><figcaption></figcaption></figure>

</div>

{% hint style="warning" %}
Après une série d'interviews auprès d'industriels et experts de l'ennoblissement, nous avons constaté que la consommation d'énergie n'est pas un paramètre maîtrisé par les industriels aujourd'hui. De plus, les premières estimations se basent généralement sur des consommations annuelles au niveau de l'usine ramenées à un produit sur la base de règles d'allocation grossières.&#x20;

Nous ne permettons donc pas de modifier la quantité d'énergie afin d'assurer une comparabilité des résultats.
{% endhint %}

#### Source de production de vapeur &#x20;

L'utilisateur a la possibilité de préciser la source de production de vapeur utilisée sur le site industriel des étapes d'ennoblissement.&#x20;

4 sources (gaz naturel, fuel lourd, fuel léger, charbon) et deux régions (Europe, Asie) sont disponibles.

Par défaut, un mix régional est appliqué selon le pays (cf. section [Chaleur](https://fabrique-numerique.gitbook.io/ecobalyse/textile/parametres-transverses/chaleur)).&#x20;

#### Impression <=> % étoffe &#x20;

Deux types d'impression sont proposées (fixé-lavé et pigmentaire). \
La quantité de tissu imprimée est à spécifier par l'utilisateur (en % de la surface d'étoffe entrante). Cette donnée n'étant généralement pas maîtrisée par les metteurs sur le marché, cinq scénarios sont proposés (1%, 5%, 20%, 50% et 100%).&#x20;

#### Taux de perte (%)

Aucune perte n'est appliquée lors de l'étape Ennoblissement.

## Limites

* Absence d'inventaires enrichis pour les principaux apprêts chimiques (procédés de finition) = sous-estimation des enjeux tox/ecotox
* Indicateur "consommation d'eau" non modélisé&#x20;
* Utilisation de scénarios moyen/average pour les inventaires enrichis => construction en cours de scénarios Best/Worst pour mieux différencier les pratiques

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

[^1]: Best Available Techniques (BAT) Reference Document for the Textiles Industry \_ Joint Research Center.

[^2]: UUID = 63baddae-e05d-404b-a73f-371044a24fe9
