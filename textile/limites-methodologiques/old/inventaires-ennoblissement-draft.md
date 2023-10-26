---
description: >-
  Enrichissement de différents inventaires d'ennoblissement (ex : blanchiment,
  teinture, etc.) afin de mieux prendre en compte les émissions de subtsances
  chimiques.
---

# 💦 Inventaires ennoblissement (draft)

{% hint style="danger" %}
Cette page est en cours de construction
{% endhint %}

## De quoi parle-t-on ?&#x20;

Les modèles d'émission utilisés dans les inventaires des procédés d'ennoblissement (ex: blanchiment, teinture, etc.) sont aujourd'hui non satisfaisants. Les modèles d'émission utilisés dans les principaux inventaires disponibles dans l'industrie (données EF, Base Impacts, Ecoinvent, etc.) sont soit inacessibles, incomplets ou les deux à la fois. De plus, des limites existent en termes de caractérisation des substances émises dans les différents compartiments (eau, air, sol).

{% hint style="info" %}
Différentes publications scientifiques mettent en avant l'absence de prise en compte des émissions de substances chimiques dans les référentiels/ACV existants.

Extrait d'une publication[^1] scientifique à ce sujet :&#x20;

_"A recent literature review of LCA studies of textile products showed that textile chemicals were included in the LCI in only 7 out of 58 published studies (Roos 2015). In addition, in three of these seven studies, no matching with CFs to assess potential toxicity impacts of the textile chemicals was done. Thus, in 54 out of 58 relevant studies, the potential toxicity impact of textile chemicals was not included in the reported toxicity impact potential of the product. In addition, it was found that the exclusion of textile chemicals in these 54 studies was made tacitly, which means that the exclusion is not explicitly stated to the reader (Roos 2015)."_
{% endhint %}

## Pourquoi enrichir les inventaires ?

La majorité des ACV et référentiels existants n'intègrent pas dans leurs inventaires des modèles d'émission de substances chimiques représentatifs des réalités industrielles lors des étapes d'ennoblissement. Cela est problématique car les impacts sous-jacents (Ecotoxicité aquatique et Toxicité Humaine notamment) sont sous-estimés. La Banque Mondiale ([source](https://www.worldbank.org/en/news/feature/2019/09/23/costo-moda-medio-ambiente)) et le Parlement Européen ([source](https://www.europarl.europa.eu/news/en/headlines/society/20201208STO93327/the-impact-of-textile-production-and-waste-on-the-environment-infographics)) estiment que près de 20% de la pollution aquatique mondiale provient des étapes d'ennoblissement (teinture et apprêts chimiques notamment) de l'industrie Textile.

<details>

<summary>En savoir plus</summary>

Les problématiques concernent :&#x20;

* les modèles d'émission utilisés dans les inventaires,\
  (quelles substances sont utilisées ? en quelle quantité ? sont-elles dégradées lors de leur utilisation ? quel pourcentrage reste sur le vêtement ? etc.),
* la caractérisation des substances émises dans l'environnement.\
  (quels sont les impacts des substances émises dans l'eau, l'air et le sol?).

Ces problématique s'expliquent pour différentes raisons dont :&#x20;

* un manque de transparence lié au secret industriel des solutions chimiques utilisées dans l'industrie,
* une quantification complexe des flux et impacts des substances chimiques (une double expertise est effectivement nécessaire => écotoxicologie  + textile),
* des innovations régulières de l'industrie chimiques rendant difficile l'évaluation en temps réel des substances utilisées sur le marché.&#x20;

</details>

<details>

<summary>Focus PEFCR Apparel &#x26; Footwear (v. 1.3)</summary>

Au niveau européen, les problématiques susmentionnées sont partagées.

La réponse apportée à cette limite consiste à **diviser par 3** l'impact des trois indicateurs (Ecotoxicité Aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérgiène) en appliquant un coefficient de robustesse (_robustness factor_).&#x20;

Ainsi, les enjeux de Toxicité/Ecotoxicité ne sont pas correctement reflétés dans la version actuelle du projet de référentiel car leur modélisation est non satisfaisante (cf. Robustness factor) tandis que leur pondération est adaptée en conséquence (les 3 indicateurs susmentionnés contribuent finalement seulement à hauteur de 5,9% de l'impact total du produit).&#x20;

_Extrait du rapport publié par le_ [_JRC_](#user-content-fn-2)[^2] _en 2018 (p. 9/146)_ &#x20;

![](<../../../.gitbook/assets/image (6).png>)

</details>

## Paramètres mobilisés

### &#x20;Paramètres transverses

#### Pays <=> Taux de pollution aquatique (%)

Un taux de "polution aquatique" est utilisé afin d'estimer quelle part des substances relarguées dans les eaux usées lors d'un procédé d'ennoblissement ne sont pas éliminées et se retrouvent donc dans les écosystèmes aquatiques (Paramètre 4 des inventaires).&#x20;

Deux paramètres, exprimés en %,  permettent de définir le taux de pollution aquatique :&#x20;

1\) le taux de raccordement (R) du site industriel à un centre de traitement des eaux usées,\
2\) l'efficacité (E) du centre de traitement des eaux usées. &#x20;

Le taux de taux pollution aquatique (P) d'un site industriel se calcul ainsi :&#x20;

$$P = 1-(R*E)$$

Ecobalyse a catégorisé les pays selon 3 groupes (reprise de travaux ONU \_ [source](https://sdg6data.org/fr/indicator/6.3.1)) afin de préciser le calcul  :

<table><thead><tr><th width="298">Pays d'ennoblissement</th><th>R</th><th>E</th><th>P</th></tr></thead><tbody><tr><td>Rang 1 (Europe + Amérique du Nord, Australie, Nouvelle-Zélande)</td><td>100%</td><td>90%</td><td>90%</td></tr><tr><td>Rang 2 (Maghreb + Asie Occidentale + Asie de l'Est + Asie du Sud-Est)</td><td>90%</td><td>90%</td><td>81%</td></tr><tr><td>Autres pays</td><td>50%</td><td>80%</td><td>40%</td></tr></tbody></table>

<details>

<summary>Aller plus loin</summary>

**Paramètre 1 = Taux de raccordement des sites industriels**

Des travaux menés au sein de l'ONU dans le cadre de la cible 6.3 (Progrès relatifs au traitement des eaux usées) servent de base aux taux de raccordement moyens utilisés ([source](https://sdg6data.org/fr/indicator/6.3.1)). Des données précises existent pour le raccordement des eaux usées d'origine ménagère, tandis que peu existent pour celles d'origine industrielles.&#x20;

_Taux de raccordement des eaux usées d'origine ménagères par région_

&#x20;![](<../../../.gitbook/assets/Évolution de l’indicateur 6.3.1 Pourcentage des eaux usées traitées (sans danger) \_ Ménagères.png>)

**Paramètre 2 = Efficacité du traitement des eaux usées**&#x20;

Les principaux référentiels existants (ex : Base Impacts, Ecoinvent, PEFCR A\&F) ainsi que le dernier rapport BAT[^3] (version 2023) publié par le JRC[^4] proposent un taux de traitement moyen des eaux usées de 90%.&#x20;



**Pour aller plus loin**

Des paramètres additionnels permettent de préciser ce taux de pollution aquatique tels que la présence d'un centre de traitement des eaux usées sur le site industriel, la mise en place de boucles fermées permettant de limiter la quantité d'eaux usées relarguée dans l'environnement, etc. Cependant, le niveau de détails actuellement proposé est jugé suffisant. Ecobalyse permet un calcul de Niveau 1 tandis que le niveau de maîtrise de ces enjeux par les marques est faible en 2023. Pour préciser ces paramètres, les marques qui le souhaitent peuvent détailler ces paramètres/hypothèses dans le cadre du Niveau2/3 permis par l'affichage environnemental.

</details>

## Liste des inventaires enrichis&#x20;

Deux bases de travail ont été utilisées pour batir ces inventaires enrichis :&#x20;

* les travaux de Sandra Roos effectués dans le cadre du projet Mistra Future Fashion (Suède, [source 1](https://link.springer.com/article/10.1007/s11367-018-1537-6), [source 2](https://research.chalmers.se/publication/246361)). Ces travaux ont par ailleurs été repris aux Etats-Unis par la Sustainable Apparel Coalition (SAC) au sein de leur outil Higg Index.
* les inventaires désagrégés de la base de données EIME (créés en partenariat avec l'[ENSAIT](https://www.ensait.fr/en/home/)).

### Inventaire #1 = Blanchiment / Bleaching

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : _Bleaching cotton tricot with optical brightener in jet machine_

**Contexte**\
Blanchiment effectué au peroxyde d'hydrogène en discontinu sous forme de bains chauffés.&#x20;

**Paramètre(s) mobilisé(s)**

* 60 litres d'eau / 0,34kg de produits chimiques
* Concentration des sustances : 4,3 g / litre de bain de blanchiment&#x20;
* taux de pollution aquatique selon la zone géographique (pays) où a lieu le procédé\
  (2 paramètres = taux raccordement & efficacité centre traitement eaux usées)&#x20;
* modèle d'émission spécifique au procédé

<div align="left">

<figure><img src="../../../.gitbook/assets/image (37).png" alt=""><figcaption><p>Paramètres clés mobilisés</p></figcaption></figure>

</div>
{% endtab %}

{% tab title="Modèle d'émissions" %}
<div align="left">

<figure><img src="../../../.gitbook/assets/image (35).png" alt=""><figcaption><p>Produits et substances chimiques utilisés en début de procédé</p></figcaption></figure>

</div>

<figure><img src="../../../.gitbook/assets/image (34).png" alt=""><figcaption><p>Modèle d'émissions (approche "time-integrated")</p></figcaption></figure>

<div align="left">

<figure><img src="../../../.gitbook/assets/image (36).png" alt=""><figcaption><p>Emissions par compartiments</p></figcaption></figure>

</div>
{% endtab %}

{% tab title="Impacts" %}
<figure><img src="../../../.gitbook/assets/image (38).png" alt=""><figcaption><p>Illustration sur les 3 scénarios</p></figcaption></figure>

<div align="left">

<figure><img src="../../../.gitbook/assets/image (32).png" alt=""><figcaption><p>Scénario "Best" détaillé</p></figcaption></figure>

</div>

xxxx

xxx


{% endtab %}
{% endtabs %}

### Inventaire #2 = Teinture (fibres cellulosiques)&#x20;

{% tabs %}
{% tab title="Scénario" %}
**Base de travail** \
Travaux de Sandra Roos 2018\
Procédé : _Pad-steam denim dyeing (mix)_

**Contexte**\
Teinture en continue utilisant des colorants de cuve (_VAT dyes_). 0,4 kg de solution chimique est utilisée au sein d'un bain de 50 litres (concentration = 8g/L). Un taux d'emport moyen de 85% est retenu. Le colorant utilisé est le Blue, Indigo _(CAS 000482-89-3)_.
{% endtab %}
{% endtabs %}

[^1]: _USEtox characterisation factors for textile chemicals based on a transparent data source selection strategy_\
    \
    _(2017 / author : SandraRoos)_     &#x20;

[^2]: Joint Research Center\_Development of a weighting approach for the Environmental Footprint            &#x20;

[^3]: Best Available Technology &#x20;

[^4]: Joint Research Center
