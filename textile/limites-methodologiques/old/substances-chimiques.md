---
description: >-
  Enrichissement d'inventaires de subtances chimiques pour une dizaine de
  procédés/hotspots intervenant lors des étapes d'ennoblissement.
---

# 💦 Substances chimiques

## De quoi parle-t-on ?&#x20;

L'évaluation environnementale des substances chimiques utilisées lors des étapes de production est non satisfaisante du fait de limites en termes d'inventaires de flux et de caractérisation d'impacts.

## Pourquoi enrichir les inventaires ?

La majorité des ACV et référentiels existants tels que le projet de PEFCR Apparel & Footwear (v1.3) n'intègrent pas d'inventaires représentatifs des pratiques de l'industrie concernant les substances chimiques utilisées lors des étapes d'ennoblissement.&#x20;

Cela est problématique car les impacts sous-jacents (Ecotoxicité aquatique et Toxicité Humaine notamment) sont sous-estimés. &#x20;

La Banque Mondiale ([source](https://www.worldbank.org/en/news/feature/2019/09/23/costo-moda-medio-ambiente)) et le Parlement Européen ([source](https://www.europarl.europa.eu/news/en/headlines/society/20201208STO93327/the-impact-of-textile-production-and-waste-on-the-environment-infographics)) estiment que près de 20% de la pollution aquatique mondiale provient des étapes d'ennoblissement (teinture et apprêts chimiques notamment) de l'industrie Textile.

<details>

<summary>En savoir plus</summary>

Les problématiques concernent :&#x20;

* les inventaires de flux \
  (quelles substances sont utilisées ? en quelle quantité ? sont-elles détruites lors de leur utilisation ? se retrouvent-elles sur le vêtement, dans les eaux usées, dans l'air ? etc.),
* la caractérisation de l'impact des substances chimiques\
  (quels sont les impacts des substances émises dans l'eau, l'air et le sol?).

Ces problématique s'expliquent pour différentes raisons dont :&#x20;

* un manque de transparence lié au secret industriel des solutions chimiques utilisées dans l'industrie,
* une quantification complexe des flux et impacts des substances chimiques (une double expertise est effectivement nécessaire => écotoxicologie  + textile),
* des innovations régulières de l'industrie chimiques rendant difficile l'évaluation en temps réel des substances utilisées sur le marché.&#x20;

</details>

{% hint style="info" %}
Différentes publications scientifiques mettent en avant l'absence de prise en compte de ces enjeux dans les référentiels/ACV existants.

Extrait d'une publication en date de 2017 à ce sujet :&#x20;

_"A recent literature review of LCA studies of textile products showed that textile chemicals were included in the LCI in only 7 out of 58 published studies (Roos 2015). In addition, in three of these seven studies, no matching with CFs to assess potential toxicity impacts of the textile chemicals was done. Thus, in 54 out of 58 relevant studies, the potential toxicity impact of textile chemicals was not included in the reported toxicity impact potential of the product. In addition, it was found that the exclusion of textile chemicals in these 54 studies was made tacitly, which means that the exclusion is not explicitly stated to the reader (Roos 2015)."_
{% endhint %}

<details>

<summary>Focus PEFCR Apparel &#x26; Footwear (v. 1.3)</summary>

Au niveau européen, les problématiques susmentionnées sont partagées.

La réponse apportée à ce problème consiste à diminuer l'impact des trois indicateurs directement impactés : Ecotoxicité Aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérgiène.&#x20;

Un coefficient de robustesse (_robustness factor_) de x0,17 est en effet introduit lors de la pondération de ces trois indicateurs dans le score global du vêtement. En plus de sous-estimer les flux de subtances chimiques mobilisées sur le cycle de vie d'un vêtement, l'impact de ces 3 indicateurs est ainsi divisé par 6 (!).



_Extrait du rapport publié par le_ [_JRC_](#user-content-fn-1)[^1] _en 2018 (p. 9/146)_ &#x20;

![](<../../../.gitbook/assets/image (6).png>)

</details>

## Matérialité du complément

Des inventaires ont été créés sur les principaux hotspots des étapes de fabrication du vêtement :&#x20;

* blanchiment,
* teinture,&#x20;
* impression,
* apprêts chimiques.

Ces inventaires ont été construits de telle sorte que leurs impacts puissent être affinés selon des données primaires accessibles par les marques (ex : pays où a lieu le procédé, intensité de la couleur, obtention d'un label/certification, etc.). Ces paramètres et scénarios sont présentés dans la section suivante.&#x20;

Les travaux de Sandra Roos effectués dans le cadre du projet Mistra Future Fashion (Suède) ont servi de base de travail ([source 1](https://link.springer.com/article/10.1007/s11367-018-1537-6), [source 2](https://research.chalmers.se/publication/246361)). Ces travaux ont par ailleurs été repris aux Etats-Unis par la Sustainable Apparel Coalition (SAC) au sein de leur outil Higg Index.

Des compléments ont été apportés suite aux différents travaux menés dans le cadre de la mise en place de l'affichage environnemental.&#x20;

## Scénarios de référence

### Scénarios transverses

#### Pays <=> Taux de pollution aquatique (%)

Un taux de "polution aquatique" est utilisé afin d'estimer quelle part des substances relarguées dans les eaux usées lors d'un procédé d'ennoblissement ne sont pas éliminées et se retrouvent donc dans les écosystèmes aquatiques (Paramètre 4 des inventaires).&#x20;

Deux paramètres, exprimés en %,  permettent de définir le taux de pollution aquatique :&#x20;

1\) le taux de raccordement (R) du site industriel à un centre de traitement des eaux usées,\
2\) l'efficacité (E) du centre de traitement des eaux usées. &#x20;

Le taux de taux pollution aquatique (P) d'un site industriel se calcul ainsi :&#x20;

$$P = 1-(R*E)$$

Ecobalyse a catégorisé les pays selon 3 groupes afin de préciser le calcul &#x20;

<table><thead><tr><th width="298">Pays d'ennoblissement</th><th>R</th><th>E</th><th>P</th></tr></thead><tbody><tr><td>Rang 1 (Europe + Amérique du Nord + Inde + Japon)</td><td>100%</td><td>90%</td><td>10%</td></tr><tr><td>Rang 2 (Maghreb + Asie Occidentale + Asie Sud Est)</td><td>95%</td><td>90%</td><td>15%</td></tr><tr><td>Autres pays</td><td>50%</td><td>80%</td><td>60%</td></tr></tbody></table>

<details>

<summary>Aller plus loin</summary>

**Paramètre 1 = Taux de raccordement des sites industriels**

Des travaux menés au sein de l'ONU dans le cadre de la cible 6.3 (Progrès relatifs au traitement des eaux usées) servent de base aux taux de raccordement moyens utilisés ([source](https://sdg6data.org/fr/indicator/6.3.1)). Des données précises existent pour le raccordement des eaux usées d'origine ménagère, tandis que peu existent pour celles d'origine industrielles.&#x20;

_Taux de raccordement des eaux usées d'origine ménagères par région_

&#x20;![](<../../../.gitbook/assets/Évolution de l’indicateur 6.3.1 Pourcentage des eaux usées traitées (sans danger) \_ Ménagères.png>)

**Paramètre 2 = Efficacité du traitement des eaux usées**&#x20;

Les principaux référentiels existants (ex : Base Impacts, Ecoinvent, PEFCR A\&F) ainsi que le dernier rapport BAT[^2] (version 2023) publié par le JRC[^3] proposent un taux de traitement moyen des eaux usées de 90%.&#x20;



**Pour aller plus loin**

Des paramètres additionnels permettent de préciser ce taux de pollution aquatique tels que la présence d'un centre de traitement des eaux usées sur le site industriel, la mise en place de boucles fermées permettant de limiter la quantité d'eaux usées relarguée dans l'environnement, etc. Cependant, le niveau de détails actuellement proposé est jugé suffisant. Ecobalyse permet un calcul de Niveau 1 tandis que le niveau de maîtrise de ces enjeux par les marques est faible en 2023. Pour préciser ces paramètres, les marques qui le souhaitent peuvent détailler ces paramètres/hypothèses dans le cadre du Niveau2/3 permis par l'affichage environnemental.

</details>

### Scénarios spécifiques&#x20;

<details>

<summary>Blanchiment </summary>

**Hypothèses** : Blanchiment effectué au chlorite de sodium en discontinu sous forme de bains chauffés. Une concentration de 0,7% est définie (= 0,34kg de solution chimique pour 0,048m3 de solution aqueuse). Une corrélation linéaire est utilisée pour estimer la quantité de substances selon la quantité de bain (m3).  &#x20;

**Paramètres mobilisés** :&#x20;

* **Quantité de bain (m3)**\
  La quantité de bain, exprimée en m3, correspond au volume de bain (eau + substances chimiques) nécessaire pour réaliser l'opération sur 1 kg de textile. Cette valeur correspond au produit du nombre de bains nécessaires et du [rapport de bain](#user-content-fn-4)[^4] de la machine. \
  3 scénarios sont possibles sur Ecobalyse.\
  ![](../../../.gitbook/assets/image.png)

<!---->

* **Taux de pollution aquatique (%)** \
  Cf. section "Scénarios Transverses"&#x20;

</details>

## Calcul des nouveaux inventaires

Pour chaque inventaire, une cartographie des flux par défaut a été construite selon le schéma suivant.&#x20;

{% tabs %}
{% tab title="Cartographie" %}
![](https://lh5.googleusercontent.com/iA3fScBwhe88BOKXJxoEMnvoHMkkM9dwaB\_EuCuSOp4vG54kbDbtHoRMD8b444kXV5mhurN1HkdKUOyqKqvhCG21PZkAz0R5ay8PKvnk\_Yl1sSIYe0kXv-vOOqhtyMF-9tGla1eVyH3J\_jGvnF0mqegX\_g=s2048)
{% endtab %}

{% tab title="Détails" %}
**Paramètre 1**\
Inventaire des substances/émissions du procédé.\
Approche "time-integrated" = inventaire différent de la composition utilisée en début du procédé car une partie des substances sont détruites et/ou transformées\
Définition de l'approche "time-integrated" donnée par S. Roos : _the model is time-integrated, which means that all emissions as well as transformation into degradation products inthe environment is assumed to occur instantly -at time zero-_

**Paramètre 2**\
% des substances fixées sur le vêtement

**Paramètre 3**\
% des substances émises dans l'air &#x20;

**Paramètre 4** \
% des substances rejetées dans les eaux usées
{% endtab %}
{% endtabs %}

La manière dont ont été construits ces inventaires permet de faire varier les paramètres des inventaires selon les données renseignées par l'utilisateur (ex : présence d'un label, pays où a lieu l'étape d'ennoblissement, etc.).

Ensuite, les modèles de caractérisation préconisés par le PEF (EF 3.1) sont utilisés afin de calculer l'impact de ces inventaires sur les indicateurs : Ecotoxicité Aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérigène.

**Inventaires par défaut retenus**&#x20;

{% tabs %}
{% tab title="Blanchiment" %}
![](<../../../.gitbook/assets/image (27).png>)

**Illustration de résultats/scénarios**

![](<../../../.gitbook/assets/Comparaison - T-shirt 100% coton (170g) (2) (3).png>)
{% endtab %}

{% tab title="Teinture 1" %}

{% endtab %}

{% tab title="Teinture 2 " %}

{% endtab %}
{% endtabs %}



&#x20;&#x20;

[^1]: Joint Research Center\_Development of a weighting approach for the Environmental Footprint            &#x20;

[^2]: Best Available Technology &#x20;

[^3]: Joint Research Center

[^4]: MLR = Mass to Liquor Ratio = Rapport de bain.\


    Il s'agit du rapport de poids entre la matière sèche totale et la solution totale. Ainsi, par exemple, un rapport de bain de 1:10 signifie 10 litres de solution pour 1 kg de matière textile.&#x20;
