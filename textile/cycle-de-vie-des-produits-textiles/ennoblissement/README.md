---
hidden: true
---

# 🌈 Etape 4 - Ennoblissement - ancienne page

L’ennoblissement consiste à donner aux tissus l'aspect visuel et les propriétés physiques et esthétiques exigées par les consommateurs. Il peut s'agir d'opérations mécaniques ou chimiques.

L’étape d’ennoblissement se décompose en 3 sous-étapes :

* Pré-traitement = Traitement et nettoyage des fibres,\
  (ces derniers peuvent être réalisés sur fil, sur étoffe ou sur article)
* Teinture et Impression = Application de colorants/pigments,
* Finition = Application d’apprêts.

Une description détaillée de ces sous-étapes est proposée en bas de page.

## Modélisation Ecobalyse

### Paramètres mobilisés

Un paramètre transverse et plusieurs paramètres spécifiques aux 3 sous-étapes (pré-traitements, teinture/impression et finition) constituant l'étape Ennoblissement sont mobilisés :

**Paramètre transverse**

* **Pays** (origine) où ont lieu les étapes d'ennoblissement

**Paramètres spécifiques**

<details>

<summary>Pré-traitements</summary>

* Nature des fibres (synthétique, naturelle d'origine animale, etc.),
* Type d'étoffe (tissée vs tricotée).

</details>

<details>

<summary>Teinture / Impression</summary>

* Nature des fibres (synthétique, naturelle d'origine animale, etc.),
* Présence de motifs imprimés (optionnel)\
  Si oui :\
  \- type de procédé (fixé-lavé ou pigmentaire)\
  \- surface imprimée (%)

</details>

<details>

<summary>Finition</summary>

Non applicable (un scénario par défaut applicable à tous les vêtements est proposé)

</details>

{% hint style="info" %}
Pour rappel, des inventaires enrichis ont été construits et intégrés dans le référentiel afin de mieux prendre en compte l'impact des substances chimiques mobilisées lors de l'étape Ennoblissement (cf. la section [Inventaires enrichis](inventaires-enrichis.md) pour plus de détails).
{% endhint %}

### Méthodologie de calcul

L'impact global de l''étape Ennoblissement se comprend comme la somme des impacts des procédés retenus pour chaque modélisation/vêtement.

#### Etape 1 = Modélisation des flux externes des procédés

L'impact de chaque procédé pris séparément correspond au produit de la masse "sortante" avec le coefficient d'impact considéré (cf. [Impacts considérés](../../pages-textiles-old/impacts-consideres.md)).

$$
ImpactProcédé = MasseSortante(kg) * CoefImpactProcédé
$$

Le CoefImpactProcédé correspond à la somme des impacts des flux externes mobilisés dans Ecobalyse :

* :zap:électricité (exprimé en kWh / kg),
* :fire: chaleur (exprimé en MJ / kg).

Pour plus d'information sur la gestion des masses cf. la section [Pertes et rebut](../../precisions-methodologiques/pertes-et-rebus.md).

#### Etape 2 = Ajout des inventaires enrichis (impacts Ecotox/Tox)

Lorsque des procédés mobilisés dans la modélisation d'un vêtement font l'objet d'inventaires enrichis (ex : Blanchiment), l'impact de ces inventaires enrichis sont intégrés (plus d'info [ici](inventaires-enrichis.md)).

{% hint style="info" %}
La modélisation des substances chimiques mobilisées sur les étapes d'ennoblissement (ainsi que leurs impacts) est aujourd'hui très difficile via la méthode ACV[^1] pour diverses raisons.

Ecobalyse propose de premiers scénarios afin de permettre aux acteurs Textile (industriels, fabricants de colorants, etc.) et scientifiques (écotoxicologues, experts ACV, etc.) de collaborer pour plus de transparence.
{% endhint %}

### Procédés mobilisés

<details>

<summary>Pré-traitement (3 procédés mobilisés)</summary>

* Dégraissage ou Débouillissage (scouring)\
  Consiste à éliminer les impuretés naturelles et graisses des fibres naturelles afin de rendre les fibres perméables au processus aval (blanchiment, teinture, etc.).
* Blanchiment (bleaching)\
  Consiste à éliminer les colorants naturels des fibres pour les rendre plus blanches et hydrophiles.
* Lavage (washing)\
  Consiste à éliminer les agents de préparation présentes sur le fil synthétique.

Les deux procédés suivants ne sont pas mobilisés dans la méthode de calcul

* Désencollage (desizing)\
  Consiste à apprêter les fibres avec des produits appropriés (amidon, agents mouillants et lubrifiants) avant l'étape de tissage, puis à les retirer après la réalisation du tissu.
* Mercerisage (mercerising)\
  Consiste à améliorer la résistance à la traction, la stabilité dimensionnelle et la brillance du coton. Permet aussi d'améliorer la montée du colorant lors de la teinture.

</details>

<details>

<summary>Teinture (3 procédés)</summary>

* teinture en discontinu (batch dyeing)\
  Egalement appelée teinture par épuisement ce procédé consiste à tremper la matière dans une solution aqueuse contenant des colorants et produits auxiliaires (bain de teinture) pendant une période allant de quelques minutes à quelques heures.
* teinture en continu (continuous dyeing)\
  Consiste à appliquer le bain de teinture soit par imprégnation (au moyen de foulards) soit en utilisant d'autres systèmes d'application. Permet d'obtenir des hauts rendements.
* teinture moyenne (average dyeing)\
  Cette teinture résulte de la moyenne entre les deux ci-dessus. Elle est mobilisée par défaut dans la calculette.

Pour plus d'info sur ces procédés, cf. la section ci-dessous En savoir plus sur l'ennoblissement.

</details>

<details>

<summary>Finition (1 procédé par défaut)</summary>

* Finition (apprêts chimiques, en continue)

</details>

<details>

<summary>Impression</summary>

* Impression pigmentaire,
* Impression fixé-lavé.

</details>

### Hypothèses par défaut

#### Procédés de Pré-traitements <=> Type de fibres (synthétique, naturelle origine animale, etc.)

* Blanchiment (bleaching)\
  Appliqué par défaut pour les matières autres que celles synthétiques.
* Dégraissage/Débouillissage (scouring)\
  Appliqué par défaut pour les matières naturelles.
* Lavage (washing)\
  Appliqué par défaut pour les matières synthétiques.

**Procédés de Teinture / Impression**

* Teinture moyenne (average dyeing) ⇒ Appliquée par défaut
* Teinture en discontinue (Batch dyeing) => Mobilisable en Niveau 2
* Teinture en continue (Continuous dyeing) => Mobilisable en _Niveau 2_
* Impression pigmentaire => Optionnelle (à ajouter par l'utilisateur)
* Impression fixé-lavé => Optionnelle (ajouter par l'utilisateur)

#### Consommations d'énergie (électricité et chaleur)

<table><thead><tr><th>Sous-étape</th><th width="138">Procédé</th><th>kWh / kg (électricité)</th><th>MJ / kg (chaleur)</th></tr></thead><tbody><tr><td>Pre-traitement</td><td>Désencollage</td><td>0,1</td><td>3,2</td></tr><tr><td>Pre-traitement</td><td>Dégraissage</td><td>0,3</td><td>13,5</td></tr><tr><td>Pre-traitement</td><td>Blanchiment</td><td>0,2</td><td>5,4</td></tr><tr><td>Pre-traitement</td><td>Lavage (fibres synt.)</td><td>0,2</td><td>10,8</td></tr><tr><td>Pre-traitement</td><td>Mercerisage</td><td>0,1</td><td>2,7</td></tr><tr><td>Teinture</td><td>Continu</td><td>0,8</td><td>16,2</td></tr><tr><td>Teinture</td><td>Discontinu</td><td>1,2</td><td>32,4</td></tr><tr><td>Teinture</td><td>Moyenne</td><td>1</td><td>24,3</td></tr><tr><td>Impression*</td><td>Pigmentaire</td><td>1,27</td><td>7,25</td></tr><tr><td>Impression*</td><td>Fixé-lavé</td><td>1,45</td><td>8,72</td></tr><tr><td>Finition</td><td>Apprêts chimiques (en continu)</td><td>0,6</td><td>13,5</td></tr></tbody></table>

{% hint style="info" %}
Les valeurs retenues sont issues du rapport [BAT 2023](#user-content-fn-2)[^2]\*.

Une vingtaine de sites industriels ont pargé leurs consommations annuelles par procédé sur 3 années (2016, 2017, 2018).

Les valeurs retenues par Ecobalyse ont été calculées ainsi :\
1\) Extraction manuelle des valeurs Min-Max-Average (cf. graphes ci-dessous / Partie _3.6 Specific water and energy consumption)._\
2\) Majoration de +50% appliquée sur la valeur "Average/Moyenne" car les sites ayant participé à l'étude sont considérés comme ce qui se fait de mieux en termes d'efficacité.<br>

\* Les consommations d'énergie des deux procédés d'impression sont reprises des _procédés représentatifs_ de la Base Impacts (ADEME).
{% endhint %}

<div><figure><img src="../../../.gitbook/assets/Consommation de chaleur (MJ _ kg)  (5).png" alt=""><figcaption></figcaption></figure> <figure><img src="../../../.gitbook/assets/Consommation d&#x27;électricité (kWh _ kg)  (3).png" alt=""><figcaption></figcaption></figure></div>

{% hint style="warning" %}
Après une série d'interviews auprès d'industriels et experts de l'ennoblissement, nous avons constaté que la consommation d'énergie n'est pas un paramètre maîtrisé par les industriels aujourd'hui. De plus, les premières estimations se basent généralement sur des consommations annuelles au niveau de l'usine ramenées à un produit sur la base de règles d'allocation grossières.

Nous ne permettons donc pas de modifier la quantité d'énergie afin d'assurer une comparabilité des résultats.
{% endhint %}

#### Impression <=> % étoffe

Deux types d'impression sont proposées (fixé-lavé et pigmentaire).\
La quantité de tissu imprimée est à spécifier par l'utilisateur (en % de la surface d'étoffe entrante). Cette donnée n'étant généralement pas maîtrisée par les metteurs sur le marché, cinq scénarios sont proposés (1%, 5%, 20%, 50% et 100%).

#### Taux de perte (%)

Aucune perte n'est appliquée lors de l'étape Ennoblissement.

## En savoir plus sur l'ennoblissement

### Pré-traitement

Les procédés de pré-traitement consistent à traiter et nettoyer le tissu, généralement en préparation de la teinture. Cependant, même si le tissu n’est pas teint, l’étape de pré-traitement est nécessaire pour le nettoyer. Plusieurs procédés peuvent être utilisés selon la matière traitée (lavage, désencollage, flambage, mercerisage, débouillissage, blanchiment, etc.). Le pré-traitement des fibres naturelles est en général plus complexe que celui des fibres synthétiques et artificielles.

<details>

<summary>En savoir plus sur les pré-traitements</summary>

Mercerisage : Consiste à améliorer la résistance à la traction, la stabilité dimensionnelle et la brillance du coton. Permet aussi d'améliorer la montée du colorant lors de la teinture.

Dégraissage / Débouillissage : Consiste à extraire les impuretés présentes sur la fibre (ex : pectines, graisses et cires, etc.).

Blanchiment : Consiste à éliminer les colorants naturels de la fibre pour la rentre plus blanche et hydrophyle.

Désencollage : Consiste à supprimer les produits d'encollage encore présents sur le tissu.

Lavage : Consiste à éliminer les agents de préparation présents sur le fil synthétique.

</details>

### Teinture / Impression

Les procédés de teinture et impression consistent tous les deux à appliquer un colorant sur le tissu. Toutefois, le procédé d’impression, au lieu de colorer l'ensemble du support, se concentre sur des zones définies afin d'obtenir le motif désiré.

Le calculateur permet de modéliser cette étape directement après la fabrication du tissu.

Dans certains cas, la teinture peut être effectuée en amont (sur fil) ou en aval (sur article). Ecobalyse permet aussi de modéliser ces configurations dans cette sous-étape “Teinture et Impression” afin de faciliter les comparaisons.

Deux procédés d'impression (pigmentaire et fixé-lavé) sont proposés. L'impression pigmentaire consiste à déposer des pigments colorés à la surface de l'étoffe et s'applique généralement aux fibres cellulosiques. L'impression fixé-lavé consiste à fixer des colorants sur la fibre comme une teinture (à l'inverse des pigments qui pénètrent moins dans la fibre).\
Les deux procédés sont basés sur une moyenne de trois techniques : impression à cadre plat, impression à cadre rotatif, impression au jet d'encre (digitale).

<details>

<summary>En savoir plus sur la teinture</summary>

Concernant la **teinture**, deux principaux procédés sont utilisés dans l’industrie : la teinture en discontinu et la teinture en continu (et semi-continu).

La teinture en **discontinu** (également appelée teinture par épuisement) consiste à tremper la matière dans une solution aqueuse contenant des colorants et produits auxiliaires pendant une période allant de quelques minutes à quelques heures. Un paramètre important en teinture en discontinu est le rapport de bain (MLR = Mass to Liquor Ratio). Il s'agit du rapport de poids entre la matière sèche totale et la solution totale. Ainsi, par exemple, un rapport de bain de 1:10 signifie 10 litres d'eau pour 1 kg de matière textile.

La teinture en **continu** consiste à appliquer le bain de teinture soit par imprégnation (au moyen de foulards), soit en utilisant d'autres systèmes d'application. Cette technique permet d'obtenir des hauts rendements. Dans ces procédés, le facteur dont il faut tenir compte est le taux d’emport ou taux d’exprimage (masse en grammes de solution absorbée pour 100 grammes d'étoffe sèche) et la concentration du colorant.

Les procédés de teinture en discontinu conduisent en général à des consommations d'eau et d'énergie plus élevées que les procédés continus. Cependant, bien que les procédés de teinture en continu consomment moins d'eau, ces derniers nécessitent une concentration plus élevée de colorant dans le bain d’imprégnation. (entre 10 et 100g/L vs entre 0,1 et 1g/L pour les procédés en discontinu). Ainsi, le rejet de cet effluent concentré peut entraîner une charge de pollution plus élevée qu’en teinture en discontinu.

**Colorants utilisés**

Différents colorants sont utilisés selon la nature des fibres à teindre :

Fibres cellulosiques => réactifs / directs / de cuve / souffre

Laine et soie => acides / chrome / métallièfres

Fibres synthétiques => dispersés / acides

Les fibres mélangées peuvent être teintes en une seule étape dans le même bain lorsque les colorants sont compatibles (ou en deux bains/phases successives si nécessaire).

</details>

<details>

<summary>En savoir plus sur l'impression</summary>

**L’impression** consiste systématiquement à préparer la pâte d’impression, appliquer la pâte au support en utilisant différentes techniques, fixer les colorants sur l’étoffe puis traiter/laver/sécher l’étoffe.

Deux techniques d'impression existent :\
\- l'impression avec des pigments qui n'ont aucune affinité pour la fibre (technique la plus utilisée aujourd’hui dans l’industrie),\
\- l'impression avec des colorants (réactifs, de cuve, dispersés, etc.).

Les machines/techniques d'impression les plus utilisées sont :\
\- impression au cadre plat\
\- impression au cadre rotatif\
\- impression digitale (par jet d'encre)\
\- impression numérique par sublimation (motif imprimé sur un papier support)

</details>

### Finition

Cette sous-étape regroupe les traitements qui servent à donner aux textiles les propriétés d'usage final souhaitées (les “apprêts”). Celles-ci peuvent inclure des propriétés relatives à l'effet visuel, au toucher et à des caractéristiques spéciales telles que l'imperméabilisation et d'ininflammabilité.

Les apprêts peuvent impliquer des traitements mécaniques/physiques et chimiques. Dans la majorité des cas, les apprêts chimiques sont appliquées sous la forme de solutions aqueuses au moyen de la technique de foulardage.

Certains apprêts sont spécifiques à certaines fibres (ex : les apprêts _easy care_ pour le coton) tandis que d'autres ont une application plus générale (ex : les adoucissants).

[^1]: Analyse du Cycle de Vie

[^2]: Best Available Techniques (BAT) Reference Document for the Textiles Industry \_ Joint Research Center.
