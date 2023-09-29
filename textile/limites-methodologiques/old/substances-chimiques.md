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

<details>

<summary>Pays &#x3C;=> Taux de pollution aquatique (%)</summary>

Un taux de "polution aquatique" est défini pour pour les sites industriels réalisant les étapes d'ennoblissement. Ce paramètre estime quelle part des substances relarguées dans les eaux usées ne sont pas éliminées en aval. Cette valeur participe à la définition des inventaires de flux de chaque procédé et est équivalente au Paramètre 4 (cf. section _Calcul de nouveaux inventaires_).&#x20;

Deux paramètres sont utilisées pour définir le taux de pollution aquatique :&#x20;

1\) le taux de raccordement du site industriel à un centre de traitement des eaux usées,\
2\) l'efficacité du centre de traitement des eaux usées. &#x20;

Ces deux paramètres sont estimés selon le pays où ont lieu les étapes d'ennoblissement ainsi que la présence d'un label/certification.&#x20;

**Paramètre 1 = Taux de raccordement des sites industriels**

Sur la base des travaux menés au sein de l'ONU dans le cadre de la cible 6.3 (Progrès relatifs au traitement des eaux usées), des taux moyens de raccordement des eaux usées sont retenus par région ([source](https://sdg6data.org/fr/indicator/6.3.1)). En l'absence de suffisamment de données sur le raccordement des eaux usées d'origine industrielle, les données d'origine ménagère sont utilisées par Ecobalyse pour fixer les valeurs par défaut utilisées dans l'outil.&#x20;

_Taux de raccordement des eaux usées d'origine ménagères par région_

&#x20;![](<../../../.gitbook/assets/Évolution de l’indicateur 6.3.1 Pourcentage des eaux usées traitées (sans danger) \_ Ménagères.png>)

&#x20;Trois scénarios par défaut sont retenus :&#x20;

* 100% = pays UE + Amérique du Nord
* 75% = Asie (Est + Sud-Est + Occidentale) + Maghreb
* 50% = autres pays&#x20;

**Paramètre 2 = Efficacité du traitement des eaux usées**&#x20;

Sur la base des référentiels existants (ex : Base Impacts, Ecoinvent, PEFCR A\&F) ainsi que du dernier rapport BAT[^2] (version 2023) publié par le JRC[^3], un taux de traitement moyen des eaux usées de 90% est retenu.&#x20;

Si le site industriel possède une <mark style="color:red;">certification ...</mark>, ce taux passe à 95%.

**Illustration**&#x20;

![](../../../.gitbook/assets/image.png)



**Pour aller plus loin**

Des paramètres additionnels permettent de préciser ce taux de pollution aquatique tels que la présence d'un centre de traitement des eaux usées sur le site industriel, la mise en place de boucles fermées permettant de limiter la quantité d'eaux usées relarguée dans l'environnement, etc. Cependant, le niveau de détails actuellement proposé est jugé suffisant. Ecobalyse permet un calcul de Niveau 1 tandis que le niveau de maîtrise de ces enjeux par les marques est faible en 2023. Pour préciser ces paramètres, les marques qui le souhaitent peuvent détailler ces paramètres/hypothèses dans le cadre du Niveau2/3 permis par l'affichage environnemental.

</details>

### Scénarios spécifiques&#x20;

<details>

<summary>Blanchiment </summary>

**Hypothèses** : Blanchiment effectué au chlorite de sodium en discontinu sous forme de bains chauffés. Une concentration de 0,67% est définie (= 0,32kg de solution chimique pour 0,048m3 de solution aqueuse). Une corrélation linéaire est utilisée pour estimer la quantité de substances selon la quantité de bain (m3).  &#x20;

**Paramètres** :&#x20;

* **Quantité de bain (m3)**\
  Est directement fonction du nombre de bains et du [rapport de bain](#user-content-fn-4)[^4] de la machine.![](<../../../.gitbook/assets/image (1).png>) \
  Lors de la modélisation d'un vêtement, l'un des 3 scénarios est appliqué selon les règles décrites ci-dessous : \
  _BAT_ = site industriel labellisé <mark style="color:red;">xxx</mark>\
  _Average_ = Site industriel localisé en : Europe, Amérique du Nord, Maghreb, Asie (Est, Sud-Est, Occidencale) \
  _Worst_ = Autre&#x20;

<!---->

* **Taux de pollution aquatique (%)** \
  Cf. la section "Scénarios Transverses"&#x20;

**Illustration des scénarios possibles pour le blanchiment d'un vêtement**

![](<../../../.gitbook/assets/image (2).png>)

</details>

## Calcul des nouveaux inventaires

Pour chaque inventaire, une cartographie des flux par défaut a été construite selon le schéma suivant.&#x20;

{% tabs %}
{% tab title="Scéma" %}
![](https://lh5.googleusercontent.com/iA3fScBwhe88BOKXJxoEMnvoHMkkM9dwaB\_EuCuSOp4vG54kbDbtHoRMD8b444kXV5mhurN1HkdKUOyqKqvhCG21PZkAz0R5ay8PKvnk\_Yl1sSIYe0kXv-vOOqhtyMF-9tGla1eVyH3J\_jGvnF0mqegX\_g=s2048)
{% endtab %}

{% tab title="Détails" %}
**Paramètre 1**\
Définition de l'inventaire des émissions avec une approche "time-integrated" (the model is time-integrated, which means that all emissions as well as transformation into degradation products inthe environment is assumed to occur instantly -at time zero-).&#x20;

**Paramètre 2**\
% des substances fixées sur le vêtement

**Paramètre 3**\
% des substances émises dans l'air &#x20;

**Paramètre 4** \
% des substances rejetées dans les eaux usées
{% endtab %}
{% endtabs %}

Ensuite, les modèles de caractérisation préconisés par le PEF (EF 3.1) sont utilisés afin de calculer l'impact de ces inventaires sur les indicateurs : Ecotoxicité Aquatique, Toxicité Humaine Cancérigène, Toxicité Humaine Non Cancérigène.

{% tabs %}
{% tab title="Blanchiment" %}
1 kg de textile blanchi = 77 micro-pts

**Données par défaut**&#x20;

![](<../../../.gitbook/assets/image (27).png>)

**Illustration des résultats pour un t-shirt de 170g en 100% coton**

![](<../../../.gitbook/assets/image (4).png>)
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
