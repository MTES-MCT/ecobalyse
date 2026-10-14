# 🧪 Inventaires enrichis

Cette page présente l'enrichissement de certains procédés afin de mieux prendre en compte les émissions de substances chimiques. Elle complète la page [correctif](https://fabrique-numerique.gitbook.io/ecobalyse/textile/correctifs-donnees/corr2-inventaires-enrichis) associé à l'explorateur d'[Ecobalyse](https://ecobalyse.beta.gouv.fr/#/explore/textile).

## De quoi parle-t-on ?&#x20;

Les modèles d'émission utilisés dans les inventaires/procédés des étapes d'ennoblissement (blanchiment, teinture, impression) sont aujourd'hui non satisfaisants. En effet, dans la majorité des cas, ces inventaires sont soit inaccessibles, incomplets ou les deux à la fois. De plus, la caractérisation des substances chimiques est aussi limitée.

{% hint style="info" %}
Différentes publications scientifiques mettent en avant l'absence de prise en compte des émissions de substances chimiques dans les référentiels/ACV existants.



Extrait 1 d'une publication[^1] scientifique à ce sujet :&#x20;

_"A recent literature review of LCA studies of textile products showed that textile chemicals were included in the LCI in only 7 out of 58 published studies (Roos 2015). In addition, in three of these seven studies, no matching with CFs to assess potential toxicity impacts of the textile chemicals was done. Thus, in 54 out of 58 relevant studies, the potential toxicity impact of textile chemicals was not included in the reported toxicity impact potential of the product. In addition, it was found that the exclusion of textile chemicals in these 54 studies was made tacitly, which means that the exclusion is not explicitly stated to the reader (Roos 2015)."_



Extrait 2 du [rapport](https://www.eea.europa.eu/soer/publications/soer-2020) _The European Environment State and Outlook 2020_ publié par la European Environment Agency (EEA) :&#x20;

_"The main challenge in assessing the overall risk, is that the majority of substances in the chemical universe lack either a full hazard characterization and/or exposure estimates across ecosystems and in humans._"
{% endhint %}

## Pourquoi enrichir les inventaires ?

La majorité des ACV et référentiels existants n'intègrent pas dans leurs inventaires des modèles d'émission de substances chimiques représentatifs des réalités industrielles lors des étapes d'ennoblissement. Cela est problématique car les impacts sous-jacents (Ecotoxicité aquatique et Toxicité Humaine notamment) sont sous-estimés. La Banque Mondiale ([source](https://www.worldbank.org/en/news/feature/2019/09/23/costo-moda-medio-ambiente)) et le Parlement Européen ([source](https://www.europarl.europa.eu/news/en/headlines/society/20201208STO93327/the-impact-of-textile-production-and-waste-on-the-environment-infographics)) estiment que près de 20% de la pollution aquatique mondiale provient des étapes d'ennoblissement (teinture et apprêts chimiques notamment) de l'industrie Textile.

<details>

<summary>En savoir plus</summary>

Les problématiques concernent :&#x20;

* les modèles d'émission utilisés dans les inventaires,\
  (quelles substances sont utilisées ? en quelle quantité ? sont-elles dégradées lors de leur utilisation ? quel pourcentage reste sur le vêtement ? etc.),
* la caractérisation des substances émises dans l'environnement.\
  (quels sont les impacts des substances émises dans l'eau, l'air et le sol?).

Ces problématiques s'expliquent pour différentes raisons dont :&#x20;

* un manque de transparence lié au secret industriel des solutions chimiques utilisées dans l'industrie,
* une quantification complexe des flux et impacts des substances chimiques (une double expertise est effectivement nécessaire => écotoxicologie  + textile),
* des innovations régulières de l'industrie chimiques rendant difficile l'évaluation en temps réel des substances utilisées sur le marché.&#x20;

</details>

<details>

<summary>Focus PEFCR Apparel &#x26; Footwear</summary>

Au niveau européen, les problématiques liées à la caractérisation des substances chimiques sont partagées.

La réponse apportée à cette limite consiste à **diviser par 3** l'impact des trois indicateurs (Ecotoxicité Aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérgiène) en appliquant un coefficient de robustesse (_robustness factor_).&#x20;

Ainsi, les enjeux de Toxicité/Ecotoxicité ne sont pas pleinement reflétés dans le référentiel (cf. Robustness factor) tandis que leur pondération est adaptée en conséquence (les 3 indicateurs susmentionnés contribuent finalement seulement à hauteur de 5,9% de l'impact total du produit).&#x20;

_Extrait du rapport publié par le_ [_JRC_](#user-content-fn-2)[^2] _en 2018 (p. 9/146) :_&#x20;

![](<../../../.gitbook/assets/image (143).png>)

</details>

<details>

<summary>Substances caractérisées (tous secteurs)</summary>

Source : [Rapport](https://www.eea.europa.eu/soer/publications/soer-2020) 2020 (p. 240/499) publié par _European Environment Agency_ (EEA)

**Scope / Périmètre**\
Près de 100,000 substances chimiques sont utilisées sur le marché européen.\
Parmi elles, près 1/4 (c. 22,600) sont utilisées en quantité significative au sein de l'Union Européenne (+1 tonne par an).&#x20;

**Caractérisation**\
**-** 0,5% des substances sont correctement caractérisées (c. 500 substances),\
\- 10% des substances sont relativement bien caractérisées (c. 10,000 substances),\
\- 20% des substances sont caractérisées sur la base d'informations limitées (c. 20,000 substances)\
\- 70% des substances ne sont pas caractérisées de manière satisfaisante (c. 70,000 substances)

**Illustration**

![](<../../../.gitbook/assets/image (288).png>)

</details>

L'enrichissement des inventaires passe par la modélisation des paramètres suivants :&#x20;

![](https://lh7-us.googleusercontent.com/eq4OKzjEN0qAMb8VGotNHNzpBw5achG4WExM05OEl1siG1vEN5NRrVYoHTGoWsHubh_J1KFHPD4R5AbXFdIVUSYMr3t7-TepZdoqn835hvKgB9SDgYw5oxh6fnUmx5pqumdlUp7JTAlakou5tRouM-OIGw=s2048)



## Modélisation Ecobalyse

### &#x20;Paramètres mobilisés&#x20;

* Nature des fibres (synthétique, naturelle d'origine animale, etc.),

### Méthodologie de calcul

L'impact des inventaires enrichis correspond à la somme des impacts des inventaires enrichis mobilisés par le produit modélisé. Chaque produit modélisé appelle un ou plusieurs inventaires enrichis selon la méthodologie présentée ci-dessous.

L'impact de chaque inventaire enrichi pris séparément correspond au produit de la masse "sortante" de l'étape Ennoblissement avec les coefficients d'impact.

Seul l'écotoxicité aquatique est pris en compte dans les inventaires enrichis.&#x20;

$$
ImpactInventaireEnrichi= MasseSortante(kg) * CoefImpactInventaireEnrichi
$$

<table><thead><tr><th width="273">Résultats (Ecotoxicité = CTU / kg)</th><th width="96"></th></tr></thead><tbody><tr><td>Unité</td><td>CTUe</td></tr><tr><td>Teinture sur fibres synthétiques</td><td>289</td></tr><tr><td>Teinture sur fibres cellulosiques</td><td>758</td></tr><tr><td>Blanchiment</td><td>353</td></tr><tr><td>Impression (pigmentaire)</td><td>944</td></tr><tr><td>Impression fixé-lavé (colorants)</td><td>367</td></tr></tbody></table>

### Hypothèses par défaut

#### Inventaire enrichi <=> Type de fibres (synthétiques, naturelles, ...)

* Blanchiment (bleaching)\
  Appliqué par défaut pour les matières autres que celles synthétiques.&#x20;
* Teinture de fibres cellulosiques \
  Appliqué par défaut pour les matières autres que celles synthétiques.&#x20;
* Teinture de fibres synthétiques\
  Appliqué par défaut pour les matières synthétiques.
* Impression pigmentaire\
  Optionnel (lorsque l'utilisateur ajoute ce procédé d'impression)
* Impression fixé-lavé \
  Optionnel (lorsque l'utilisateur ajoute ce procédé d'impression)

#### Pays <=> Taux de pollution aquatique (%)

Un taux de "pollution aquatique" est utilisé afin d'estimer quelle part des substances relarguées dans les eaux usées lors d'un procédé d'ennoblissement ne sont pas éliminées et se retrouvent donc dans les écosystèmes aquatiques (Paramètre 4 des inventaires).&#x20;

Deux paramètres, exprimés en %,  permettent de définir le taux de pollution aquatique :&#x20;

1\) le taux de raccordement (R) du site industriel à un centre de traitement des eaux usées,\
2\) l'efficacité (E) du centre de traitement des eaux usées. &#x20;

Le taux de taux pollution aquatique (P) d'un site industriel se calcule ainsi :&#x20;

$$P = 1-(R*E)$$

Ecobalyse a catégorisé les pays selon 3 groupes sur la base des travaux de l'ONU ([source](https://sdg6data.org/fr/indicator/6.3.1)). Des taux de raccordement (R) et d'efficacité de traitement des eaux usées (E) sont proposés. Des retours de l'industrie sont attendus afin de préciser ces valeurs.&#x20;

<table><thead><tr><th width="298">Pays d'ennoblissement</th><th>R</th><th>E</th><th>P</th></tr></thead><tbody><tr><td><strong>Best case</strong><br> (Europe + Amérique du Nord, Australie, Nouvelle-Zélande)</td><td>100%</td><td>95%</td><td>5<strong>%</strong></td></tr><tr><td><strong>Average case</strong><br>(Maghreb + Asie Occidentale + Asie de l'Est + Asie du Sud-Est)</td><td>90%</td><td>90%</td><td><strong>19%</strong></td></tr><tr><td><strong>Worst case</strong><br>(Autres pays)</td><td>90%</td><td>70%</td><td><strong>37%</strong></td></tr></tbody></table>

<details>

<summary>Aller plus loin</summary>

**Paramètre 1 = Taux de raccordement des sites industriels**

Des travaux menés au sein de l'ONU dans le cadre de la cible 6.3 (Progrès relatifs au traitement des eaux usées) servent de base aux taux de raccordement moyens utilisés ([source](https://sdg6data.org/fr/indicator/6.3.1)). Des données précises existent pour le raccordement des eaux usées d'origine ménagère, tandis que peu existent pour celles d'origine industrielles.&#x20;

_Taux de raccordement des eaux usées d'origine ménagères par région_

&#x20;![](<../../../.gitbook/assets/Évolution de l’indicateur 6.3.1 Pourcentage des eaux usées traitées (sans danger) _ Ménagères.png>)

**Paramètre 2 = Efficacité du traitement des eaux usées**&#x20;

Les principaux référentiels existants (ex : Base Impacts, Ecoinvent, PEFCR A\&F) ainsi que le dernier rapport BAT[^3] (version 2023) publié par le JRC[^4] proposent un taux de traitement moyen des eaux usées de 90%.&#x20;

**Pour aller plus loin**

Des paramètres additionnels permettent de préciser ce taux de pollution aquatique tels que la présence d'un centre de traitement des eaux usées sur le site industriel, la mise en place de boucles fermées permettant de limiter la quantité d'eaux usées relarguée dans l'environnement, etc. Cependant, le niveau de détails actuellement proposé est jugé suffisant. Ecobalyse permet un calcul de Niveau 1 tandis que le niveau de maîtrise de ces enjeux par les marques est faible. La précision de ces paramètres pourra être détaillée dans le cadre du Niveau 2 en cours de construction.

</details>

Le taux de pollution est à appliquer aux inventaires enrichis.&#x20;

La formule est ainsi la suivante :\
taux de pollution aquatique du pays x inventaires enrichis/ taux de pollution average

`CoefImpactInventaireEnrichi= taux de pollution aquatique du pays x inventaires enrichis/ taux de pollution average`

#### Approche time-integrated

Ces inventaires sont bâtis selon une approche "time-integrated" (c'est à dire que l'ensemble des émissions et sous-produits de dégradation générés par le temps qui passe sont considérés comme intervenant instantanément).&#x20;

Pour estimer le devenir des substances dans le temps, différentes hypothèses sont proposées par Sandra Roos dont les principales sont :&#x20;

* 90% des substances réactives (_reactive substances_) sont dégradées durant les opérations de traitement humide (_wet processing_) => ainsi, la majorité des substances étant réactives, le flux sortant se base généralement sur 10% des substances utilisées en début de procédé,
* 95% des substances fonctionnelles (_property-lending substances_) restent sur le vêtement => ainsi, seulement 5% des substances de type Teinture/Colorant sont évalués,
* 0,1% des substances volatiles se retrouvent dans l'Air après la réalisation du procédé &#x20;

## Liste des inventaires enrichis&#x20;

Deux bases de travail ont été utilisées pour batir ces inventaires enrichis :&#x20;

* les travaux de Sandra Roos effectués dans le cadre du projet Mistra Future Fashion (Suède, [source 1](https://link.springer.com/article/10.1007/s11367-018-1537-6), [source 2](https://research.chalmers.se/publication/246361)). Ces travaux ont par ailleurs été repris aux Etats-Unis par la Sustainable Apparel Coalition (SAC) au sein de leur outil Higg Index.
* les inventaires désagrégés de la base de données EIME (créés en partenariat avec l'[ENSAIT](https://www.ensait.fr/en/home/)).

{% hint style="warning" %}
Plusieurs substances chimiques (CAS) ne sont pas caractérisables/évaluables du fait de l'absence de facteurs de caractérisation à date. Une collaboration avec l'INRAE est en cours afin d'obtenir rapidement les facteurs d'émission manquants. Des échanges ont aussi eu lieu avec les équipes du JRC (Commission Européenne) et de USETox pour obtenir de telles données mais cela n'est pas possible dans les délais impartis.
{% endhint %}

### Inventaire #1 = Blanchiment / Bleaching

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : _Bleaching cotton tricot with optical brightener in jet machine_

**Contexte**\
Blanchiment effectué au peroxyde d'hydrogène en discontinu.&#x20;

**Paramètre(s) mobilisé(s)**

* 0,34kg de produits chimiques utilisés dans 60 litres d'eau => concentration : 4,3 g / L&#x20;
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<figure><img src="../../../.gitbook/assets/image (50).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>
{% endtab %}

{% tab title="Substances / Emissions (Average scenario)" %}
**Flux entrants et sortants d'émissions**&#x20;

<figure><img src="../../../.gitbook/assets/image (279).png" alt=""><figcaption><p>Produits chimiques utilisés</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (58).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (83).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

**Flux sortants d'émissions (approche time-integrated) = émissions prise en compte dans le calcul d'impact**

<figure><img src="../../../.gitbook/assets/image (59).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (85).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>
{% endtab %}

{% tab title="Impacts" %}


<figure><img src="../../../.gitbook/assets/image (88).png" alt=""><figcaption><p>Illustration des résultats</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (89).png" alt=""><figcaption><p>Scénario "Average" détaillé</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (90).png" alt=""><figcaption><p>Décomposition de l'impact par compartiment (air, eau, non émises)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (46).png" alt=""><figcaption><p>Décomposition de l'impact par substances/produits chimiques</p></figcaption></figure>
{% endtab %}
{% endtabs %}

### Inventaire #2 = Teinture de fibres cellulosiques en continu

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : _Pad-steam denim dyeing (mix)_

**Contexte**\
Teinture en continue utilisant des colorants de cuve (_VAT dyes_). Le colorant utilisé pour le scénario _Average_ est le Blue, Indigo _(CAS 000482-89-3)._&#x20;

Les fibres cellulosiques peuvent être teintes avec différents types de colorants (réactifs, directs, de cuve).&#x20;

**Paramètres mobilisés**

* 0,38kg de produits chimiques utilisés dans 50 litres d'eau => concentration : 75 g / L&#x20;
* Un [taux d'emport](#user-content-fn-5)[^5] moyen de 85% est retenu&#x20;
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<figure><img src="../../../.gitbook/assets/image (51).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>
{% endtab %}

{% tab title="Substances / Emissions (Average scenario)" %}
**Flux entrants et sortants d'émissions** &#x20;

<figure><img src="../../../.gitbook/assets/image (277).png" alt=""><figcaption><p>Produits chimiques utilisés</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (54).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (267).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

**Flux sortants d'émissions (approche time-integrated) = émissions prise en compte dans le calcul d'impact**

<figure><img src="../../../.gitbook/assets/image (55).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (266).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>
{% endtab %}

{% tab title="Impacts" %}
<figure><img src="../../../.gitbook/assets/image (41).png" alt=""><figcaption><p>Illustration des résultats</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (42).png" alt=""><figcaption><p>Scénario "Average" détaillé</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (43).png" alt=""><figcaption><p>Décomposition de l'impact par compartiment (air, eau, non émises)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (45).png" alt=""><figcaption><p>Décomposition de l'impact par substances/produits chimiques</p></figcaption></figure>
{% endtab %}
{% endtabs %}

### Inventaire #3 = Teinture de fibres synthétiques en discontinu

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : Dyeing PES weave orange in beam dyeing machine (mix), S. Roos 2018

**Contexte**\
Teinture en discontinue utilisant des colorants dispersés (Disperse _dyes_). Deux colorants sont utilisés (_Terasil Yellow & Red_).&#x20;

**Paramètres mobilisés**

* 0,59kg de produits chimiques utilisés dans 60 litres d'eau => concentration : 4,9 g / L&#x20;
* 60 litres / 0,06m3 d'eau utilisés = 6 bains de teinture avec un &#x72;_&#x61;pport de bain (Mass to Liquor Ratio) de 1:10_
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<figure><img src="../../../.gitbook/assets/image (62).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>
{% endtab %}

{% tab title="Substances / Emissions (Average scenario)" %}
**Flux entrants et sortants d'émissions** &#x20;

<figure><img src="../../../.gitbook/assets/image (276).png" alt=""><figcaption><p>Produits chimiques utilisés</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (56).png" alt=""><figcaption><p>Flux entrant d'émissions</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (63).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

**Flux sortants d'émissions (approche time-integrated) = émissions prise en compte dans le calcul d'impact**

<figure><img src="../../../.gitbook/assets/image (57).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (65).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>
{% endtab %}

{% tab title="Impacts" %}
<figure><img src="../../../.gitbook/assets/image (66).png" alt=""><figcaption><p>Illustration des résultats</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (67).png" alt=""><figcaption><p>Scénario "Average" détaillé</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (69).png" alt=""><figcaption><p>Décomposition de l'impact par compartiment (air, eau, non émises)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (47).png" alt=""><figcaption><p>Décomposition de l'impact par substances/produits chimiques</p></figcaption></figure>
{% endtab %}
{% endtabs %}

### Inventaire #4 = Impression pigmentaire&#x20;

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : Pretreatment of PES before printing (average) + Dispersion print of PES weave on rotation printer, S. Roos 2018

**Contexte**\
Impression pigmentaire.

**Paramètres mobilisés**

* 500g de produits chimiques utilisés par kg de textile imprimé
* 25% de surface imprimée par t-shirt = 0,17m2 imprimé \
  (grammage 250g/m2)&#x20;
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<figure><img src="../../../.gitbook/assets/image (271).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>
{% endtab %}

{% tab title="Substances / Emissions (Average scenario)" %}
**Flux entrants et sortants d'émissions**&#x20;

<figure><img src="../../../.gitbook/assets/image (272).png" alt=""><figcaption><p>Produits chimiques utilisés</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (281).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (93).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

**Flux sortants d'émissions (approche time-integrated) = émissions prise en compte dans le calcul d'impact**

<figure><img src="../../../.gitbook/assets/image (280).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (95).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>
{% endtab %}

{% tab title="Impacts" %}
<figure><img src="../../../.gitbook/assets/image (286).png" alt=""><figcaption><p>Illustration des résultats (impression de 25% du vêtement)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (100).png" alt=""><figcaption><p>Scénario "Average" détaillé</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (79).png" alt=""><figcaption><p>Décomposition de l'impact par compartiment (air, eau, non émises)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (48).png" alt=""><figcaption><p>Décomposition de l'impact par substances/produits chimiques</p></figcaption></figure>
{% endtab %}
{% endtabs %}

### Inventaire #5 = Impression fixé-lavé (avec colorants)

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Base de données EIME\
Procédé : disperse-rotary-printing-CN\_V2

**Contexte**\
Impression avec des colorants dispersés.

**Paramètres mobilisés**

* 750g de produits chimiques utilisés par kg de textile imprimé
* 25% de surface imprimée par t-shirt = 0,17m2 imprimé \
  (grammage 250g/m2)&#x20;
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<figure><img src="../../../.gitbook/assets/image (273).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>
{% endtab %}

{% tab title="Substances / Emissions (Average scenario)" %}
**Flux entrants et sortants d'émissions**&#x20;

<figure><img src="../../../.gitbook/assets/image (274).png" alt=""><figcaption><p>Produits chimiques utilisés</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (283).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (74).png" alt=""><figcaption><p>Flux sortant d'émissions </p></figcaption></figure>

**Flux sortants d'émissions (approche time-integrated) = émissions prise en compte dans le calcul d'impact**

<figure><img src="../../../.gitbook/assets/image (282).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (73).png" alt=""><figcaption><p>Flux sortant d'émissions (approche "time-integrated")</p></figcaption></figure>
{% endtab %}

{% tab title="Impacts" %}
<figure><img src="../../../.gitbook/assets/image (287).png" alt=""><figcaption><p>Illustration des résultats (impression de 25% du vêtement)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (77).png" alt=""><figcaption><p>Scénario "Average" détaillé</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (78).png" alt=""><figcaption><p>Décomposition de l'impact par compartiment (air, eau, non émises)</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/image (284).png" alt=""><figcaption><p>Décomposition de l'impact par substances/produits chimiques</p></figcaption></figure>
{% endtab %}
{% endtabs %}



[^1]: _USEtox characterisation factors for textile chemicals based on a transparent data source selection strategy_\
    \
    _(2017 / author : SandraRoos)_     &#x20;

[^2]: Joint Research Center\_Development of a weighting approach for the Environmental Footprint            &#x20;

[^3]: Best Available Technology &#x20;

[^4]: Joint Research Center

[^5]: Proportion de bain emporté au foulardage
