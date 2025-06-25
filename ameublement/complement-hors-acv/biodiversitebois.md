---
description: Présentation de la méthode de calcul du complément Biodiversité x Bois .
---

# 🌍 Biodiversité x Bois

## Contexte

Ce complément est introduit afin d'intégrer dans le coût environnemental des meubles l'impact sur la biodiversité de pratiques forestières participant à la dégradation des forêts.&#x20;

De manière plus précise, trois raisons expliquent la nécessité de proposer ce complément :&#x20;

<details>

<summary><strong>1)  Le cadre méthodologique ACV est limité</strong></summary>

Le cadre de l'analyse de cycle de vie (ACV) ne permet pas, à date, de différencier l'impact sur la biodiversité locale de différentes pratiques forestières. En effet les impacts sur la biodiversité sont quantifiés de manière incomplète avec les 16 indicateurs PEF existants. Ceux ci permettent principalement de couvrir les pressions globales pesant sur la biodiversité (ex: changement climatique, eutrophisation, artificalisation des terres...). Cependant les indicateurs actuels ne permettent pas de tenir compte de la composition des peuplements forestiers, de l'effet des coupes rases, du tassement du sol ou encore de la présence de bois mort dans les parcelles par exemple. Des travaux de recherche sont en cours afin d'améliorer les méthodes via l'intégration de nouveaux indicateurs (ex : EF4.0 et GLAM). En attendant la maturité scientifique et technique de ces outils, les compléments apportent une approche simple et pragmatique pour couvrir ces enjeux incontournables.&#x20;

</details>

<details>

<summary>2) L'importance des pratiques forestières </summary>

La dégradation et la déforestation des forêts progressent à une vitesse alarmante à travers le monde. La [FAO ](#user-content-fn-1)[^1]estime que 420 millions d’hectares de forêts (c. 10 % des forêts existantes = superficie plus vaste que l’Union européenne) ont disparu dans le monde entre 1990 et 2020.

La déforestation et la dégradation des forêts sont également des facteurs importants du réchauffement climatique et de la perte de biodiversité, les deux défis environnementaux les plus importants de notre époque.

Les pratiques de gestion forestière sont très différentes selon les exploitants et les zones géographiques. Certaines pratiques permettent de préserver la biodiversité, alors que d'autres sont néfastes. Il est nécessaire de pouvoir refléter cela dans le cout environnemental.&#x20;

_Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;

</details>

<details>

<summary>3) <strong>Le marché français : un débouché clé pour les filières bois</strong> </summary>

Plusieurs secteurs d'activité français (ameublement, construction, jouets, etc.) constituent un débouché pour les filières bois. L'Ameublement est un contributeur significatif de la consommation française de bois. Tout bois utilisé sur ce secteur peut provenir de forêts participant à leur dégradation ("gestion intensive").&#x20;

Concernant la déforestation, quelques approvisionnements en bois d'ameublement peuvent être concernés. Cependant il est à noter que la principale cause de déforestation à l'échelle mondiale est l'expansion de l'agriculture à hauteur de 90% (source[^2]).&#x20;

{% hint style="info" %}
Le bois fait partie des quelques produits de base consommés au sein de l'UE et participant à la déforestation. Il se classe 3ème (9% de la déforestation dont l'UE est responsable provient du bois) après l'huile de plame (34%) et le soja (33%)

_Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;
{% endhint %}

</details>

## Méthodes de calcul

$$
Comp =  \sum Ref(i) * Compo(i) * masse * (1-label)
$$

Avec :&#x20;

* `Comp` = l'impact environnemental du complément, exprimé en Pt d'impacts
* `Ref(i)` = l'impact biodiversité de chaque bois (`i`), exprimé en Pt d'impacts / kg&#x20;
* `Compo(i)` = la part du bois (`i`) entrant dans la composition du meuble, exprimée en % de `masse`
* `masse` = la masse du meuble, exprimée en kg&#x20;
* `label` =  l'intérêt d'une certification en terme de biodiversité, exprimé en %&#x20;

{% hint style="info" %}
1 bois (i) = 1 filière d'approvisionnement = 1 essence (ex : chêne) + 1 origine (ex : France). &#x20;
{% endhint %}

## Paramètres retenus

### &#x20;`Compo(i)` + `masse`

Ces deux paramètres sont facilement intelligibles (cf. formule de calcul) et ne nécessitent pas d'informations additionnelles.

`Ref(i)`&#x20;

Ce paramètre caractériser l'impact biodiversité (ref) d'un bois (i) et s'exprime en en  points d'impacts par kg de bois (Pt / kg de bois).

#### Liste des bois disponibles (i) et de leurs impacts biodiversité (Ref)&#x20;

<figure><img src="../../.gitbook/assets/image (1) (1) (1).png" alt=""><figcaption><p>Impact biodiversité des différents bois proposés dans le Niveau 1 de la méthode ( Ref(i) )</p></figcaption></figure>

<details>

<summary>Plus d'info sur les filières d'approvisionnement bois de l'ameublement français</summary>

La majorité du bois d'ameublement est importé (c. 67% du volume consommé en 2019).

Parmi ces importations :&#x20;

* près de la moitié concernent des achats directs de meubles,
* près d'un-tiers concernent des panneaux,
* le reste étant du bois d'oeuvre (majoritairement feuillus)

:bulb: Remonter à l'origine de la forêt pour les bois d'ameublement est difficile pour la majorité des metteurs sur le marché. Dès lors, proposer des scénarios par défaut permet d'intégrer dans le coût environnemental les enjeux biodiversité liés aux pratiques forestières les plus probables pour chaque bois. Pour un metteur de marché maîtrisant la traçabilité de son bois, le dispositif d'affichage environnemental est construit de telle sorte qu'il lui sera possible de préciser ces pratiques forestières, et donc l'impact du complément..&#x20;

![](<../../.gitbook/assets/Consommation de bois _ secteur Ameublement (2019) (4).png>)

Principales sources utilisées pour ces statistiques :&#x20;

* Etude Carbone 4 \_ [Scénario de convergence de filière](https://www.carbone4.com/article-scenario-carbone-foret-bois) (Décembre 2023)
* Données de la filère Bois-Ameublement

</details>

#### &#x20;Calcul des Ref (i) &#x20;

L'impact biodiversité de chaque bois est calculé à partir de deux paramètres :&#x20;

* un coefficient de Gestion forestière (GF)
* &#x20;un Indice de corruption (IC).

<details>

<summary>Coefficient de Gestion Forestière (GF)</summary>

_Unité = Points d'impact / kg de bois_

Ce paramètre caractérise le mode de gestion forestière de chaque bois (i) entrant dans la composition du meuble.&#x20;

3 mode de gestion forestière sont proposés :&#x20;

* Intensive = 10 Pts d'impact / kg de bois
* Mitigée = 5 Pts d'impact / kg de bois
* Raisonnée = 0 Pts d'impact / kg de bois

{% hint style="info" %}
**Focus \_ Gestion Forestière (GF)**

Pour chaque filière d'approvisionnement proposée (ex : Bois tropical \_ Asie du Sud-Est), le mode de gestion forestière (Intensive / Mitigée / Raisonnée) appliqué par défaut est basé sur une hypothèse majorant&#x65;_._ L'utilisation d'une telle hypothèse pénalisante, couplée à la possibilité de préciser ce scénario, permet de prendre en compte les pratiques vertueuses (ex : traçabilité jusqu'à la parcelle, utilisation de label, etc.)  tout en incitant à plus de traçabilité.&#x20;

Les valeurs par défaut se basent sur l'état de l'art compilé par Ecobalyse dans le cadre des travaux menés sur le premier semestre 2025. Concrètement, le mode de gestion forestière appliqué par défaut vise à distinguer les pratiques intensives (ex : forêts de plantation) de pratiques raisonnées (ex : futaire irrégulière). Un lien direct existe entre le mode de gestion forestière et la biodiversité au sein de tous les compartiments de l'ecosystème. &#x20;

Les principales sources utilisées pour estimer ces paramètre par origine sont :&#x20;

* des outils d'imagerie satellitaire permettant d'identifier les régions sylvicoles proposant une exploitation intensive des forêts ([carte 1](https://gfw.global/4kZ6RaB) de gains et pertes de couvert forestier entre 2000 et 2020 / [carte 2](https://gfw.global/41N4ujO) présentant les forêts de plantation),
* des ressources bibliographiques permettant de mieux comprendre les régions sylvicoles à risque concernant leur gestion des forêts,
* des entretiens et ateliers avec les filières Ameublement et Bois/Forêt (ex : atelier Sylviculture du 30/01/2025; support accessible [ici](https://miro.com/app/board/uXjVLn9pEjg=/?share_link_id=467200481479)).
{% endhint %}

</details>

<details>

<summary>Indice Corruption (IC) </summary>

_Unité = % (majoration de GF de +x%)_&#x20;

La réalité de la gestion forestière à l'échelle globale ne peut s'appréhender uniquement par les règlementations et les recommandations sylvicoles. En effet, une problématique avérée de la filière bois porte sur les mauvaises pratiques et le manque de traçabilité, avec des règlementations non respectées dans certains contextes et des risques élevés de corruption. Le risque de corruption aggrave le risque de mauvaises pratiques affectant des zones parfois particulièrement riches en termes de biodiversité. \
Ce paramètre vise donc à refléter les risques accrus en terme de biodiversité associés à des bois issus de zones soumises à des niveaux importants de corruption.&#x20;

&#x20;Le niveau de corruption est estimé grâce au _Corruption Perception Index (score CPI)_ développé par Transparency International (cf. ci-dessous).

3 niveaux de corruption sont proposés :&#x20;

* Elevé (score CPI inférieur à 30)

- Moyen (score CPI entre 30 et 59)

* Faible (score CP au moins égal à 60)

Pour chaque niveau, un **coefficient de corruption (COR)** est appliqué; ce dernier vient préciser l'impact Biodiversité (BIO) du bois :&#x20;

| Elevé | Moyen | Faible |
| ----- | ----- | ------ |
| +50%  | +25%  | 0%     |



**Détails**

Cet indice est basé sur le [Corruption Perceptions Index](https://www.transparency.org/en/cpi/2023) (CPI) de l'année 2023.&#x20;

Le CPI vise à mesurer les niveaux de corruption perçus dans le secteur public à travers le monde. Cet indice annuel est publié par Transparency International, une organisation non gouvernementale qui lutte contre la corruption.\
L'indice est basé sur des enquêtes et des évaluations d'experts qui portent sur divers aspects de la corruption, tels que l'abus de pouvoir public à des fins privées, les pots-de-vin, et la détournement de fonds publics.\
Les pays sont notés sur une échelle de 0 à 100, où 0 signifie un niveau de corruption perçu très élevé et 100 signifie un niveau très faible.

</details>

{% hint style="info" %}
Afin de couvrir toutes les configurations possibles, deux scénarios non spécifiques à une origine ont été intégrés dans la méthode :&#x20;

* **Origine inconnue** :  s'appliquer lorsque l'utilisateur ne connaît pas l'origine de la forêt ayant fourni le bois. Ce scénario présente des hypothèses majorantes afin d'inciter à plus de traçabilité.&#x20;
* **Autre origine** : s'appliquer lorsque l'origine du bois n'est pas proposée. Ce scénario reflète le fait que ce bois n'est pas concerné par une filière d'approvisionnement à risque.&#x20;
{% endhint %}

`label`&#x20;

Certains labels participent à réduire le risque qu'un bois soit issu de pratiques participant à la dégradation des forêts.&#x20;

Dès lors, la présence d'une des certifications suivantes permet de préciser l'impact biodiversité de bois en réduisant ce dernier de -50%.&#x20;

{% hint style="info" %}
**Logique clé**

Lorsque des enjeux clés du cycle de vie de produits sont difficilement quantifiables (ex : microfibres dans le Textilen biodiversité bois dans l'Ameublement, etc.), il est préférable de les întégrer dans le coût environnemental plutôt que de les exclure. &#x20;
{% endhint %}

<details>

<summary><mark style="color:orange;">Certifications / Label (optionnel / à creuser)</mark></summary>

Une piste envisagée est d'utiliser des certifications afin de valoriser des pratiques durables d'un point de vue gestion forestière <⇒ biodiversité. Une telle prise en compte se matérialiserait par une réduction de <mark style="color:red;">x%</mark> du coefficient GF (Gestion forestière).&#x20;

Les deux principaux labels utilisés sur le marché de l'ameublement sont FSC et PEFC.&#x20;

Nous étudions actuellement la fiabilité et la pertinence de ces derniers par rapport à l'objectif de ce complément.

</details>

## Exemple d'application

<mark style="color:red;">A compléter</mark>





[^1]: L’Organisation des Nations unies pour l’alimentation et l’agriculture

[^2]: _Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;
