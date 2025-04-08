---
description: Présentation de la méthode de calcul du complément Biodiversité x Bois .
---

# 🌍 Biodiversité x Bois

## Pourquoi introduire ce complément ?

Afin d'intégrer dans le coût environnemental des meubles l'impact sur la biodiversité des pratiques forestières participant à la dégradation des forêts.&#x20;

De manière plus précise, trois raisons expliquent la nécessité de proposer ce complément :&#x20;

<details>

<summary><strong>1)  Le cadre méthodologique ACV est limité</strong></summary>

Le cadre de l'analyse de cycle de vie (ACV) ne permet pas, à date, de différencier l'impact sur la biodiversité de différentes pratiques forestières. La biodiversité est difficilement quantifiable avec les indicateurs existants (16 indicateurs PEF) tandis que peu de données précises existent sur les différentes filières de production de bois d'ameublement.

</details>

<details>

<summary>2) L'importance des pratiques forestières </summary>

La dégradation et la déforestation des forêts progressent à une vitesse alarmante à travers le monde. La [FAO ](#user-content-fn-1)[^1]estime que 420 millions d’hectares de forêts (c. 10 % des forêts existantes = superficie plus vaste que l’Union européenne) ont disparu dans le monde entre 1990 et 2020.

La déforestation et la dégradation des forêts sont également des facteurs importants du réchauffement climatique et de la perte de biodiversité, les deux défis environnementaux les plus importants de notre époque.

_Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;

</details>

<details>

<summary>3) <strong>Le marché français : un débouché clé pour les filières bois</strong> </summary>

Plusieurs secteurs d'activité français (ameublement, construction, jouets, etc.) constituent un débouché pour les filières bois.&#x20;

L'Ameublement est un contributeur significatif de la consommation française de bois. Tout bois utilisé sur ce secteur peut provenir de forêts participant à leur dégradation ("gestion intensive"). Concernant la déforestation, quelques approvisionnements en bois d'ameublement peuvent être concernés. Cependant, il est à noter que le secteur de l'ameublement participe peu à la déforestation à l'échelle mondiale (90% de cette dernière provenant de l'expansion de l'agriculture / source[^2]).

{% hint style="info" %}
Le bois fait partie des quelques produits de base consommés au sein de l'UE et participant à la déforestation. Il se classe 3ème (9% de la déforestation dont l'UE est responsable provient du bois) après l'huile de plame (34%) et le soja (33%)

_Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;
{% endhint %}

</details>

## Paramètres mobilisés

<details>

<summary>Gestion Forestière (GF)</summary>

Ce paramètre caractérise le mode de gestion forestière de chaque bois entrant dans la composition du meuble.&#x20;

Un bois se caractérise par une essence (ex : bois exotiques, chêne, etc.) et une origine  (ex : Asie du Sud-Est, France, etc.).&#x20;

3 pratiques de gestion forestière sont proposées :&#x20;

* Intensive
* Mitigée
* Raisonnée

Pour chaque niveau, un **c**oefficient de gestion forestière (GF) est défini (exprimé en Pts d'impact / kg de bois) :&#x20;

| Intensive                          | Mitigée                           | Raisonnée                         |
| ---------------------------------- | --------------------------------- | --------------------------------- |
| <mark style="color:red;">10</mark> | <mark style="color:red;">5</mark> | <mark style="color:red;">0</mark> |

</details>

<details>

<summary>Indice Corruption (IC) </summary>

Ce paramètre vise pénaliser les pratiques forestières considérées pour chaque bois selon le niveau de corruption du pays. Ce paramètre est donc spécifique à une origine (pays ou région).

Plus le niveau de corruption est élevée, plus faible est la probabilité que le bois soit issu d'une forêt gérée durablement. Le niveau de corruption est estimé grâce au _Corruption Perception Index (score CPI)_ développé par Transparency International (cf. ci-dessous).

3 niveaux de corruption sont proposés :&#x20;

* Elevé (score CPI inférieur à 30)

- Moyen (score CPI entre 30 et 59)

* Faible (score CP au moins égal à 60)

Pour chaque niveau, un **coefficient de corruption (COR)** est appliqué; ce dernier vient préciser l'impact Biodiversité (BIO) du bois :&#x20;

| Elevé                                | Moyen                                | Faible                             |
| ------------------------------------ | ------------------------------------ | ---------------------------------- |
| <mark style="color:red;">+50%</mark> | <mark style="color:red;">+25%</mark> | <mark style="color:red;">0%</mark> |



**Détails**

Cet indice est basé sur le [Corruption Perceptions Index](https://www.transparency.org/en/cpi/2023) (CPI) de l'année 2023.&#x20;

Le CPI vise à mesurer les niveaux de corruption perçus dans le secteur public à travers le monde. Cet indice annuel est publié par Transparency International, une organisation non gouvernementale qui lutte contre la corruption.\
L'indice est basé sur des enquêtes et des évaluations d'experts qui portent sur divers aspects de la corruption, tels que l'abus de pouvoir public à des fins privées, les pots-de-vin, et la détournement de fonds publics.\
Les pays sont notés sur une échelle de 0 à 100, où 0 signifie un niveau de corruption perçu très élevé et 100 signifie un niveau très faible.

</details>

<details>

<summary>Certifications / Label (optionnel)</summary>

Les certifications FSC et PEFC permettent de préciser/réduire l'impact Biodiversité (BIO) du bois de <mark style="color:red;">-50%</mark>.&#x20;

</details>

## Scénarios de référence

### **Etape 1 = Cartographie des filières d'approvisionnement**    &#x20;

Les principales filières d'approvisionnement bois du marché français de l'ameublement sont proposées dans la méthode.&#x20;

{% hint style="info" %}
1 filière d'approvisionnement = 1 bois = 1 scénario = 1 essence (ex : chêne) + 1 origine (ex : France). &#x20;
{% endhint %}

Cf. liste complète dans la tableau ci-dessous.

<details>

<summary>Plus d'info sur les filières d'approvisionnement</summary>

Les statistiques du marché français du bois d'ameublement décomposent généralement les approvisionnements en 3 catégories :&#x20;

* bois rond,
* bois de sciage,
* Produits bois (achats directs de meubles ou produits intermédiaires tels que des panneaux)&#x20;

Par ailleurs, la majorité du bois d'ameublement est importé (principalement sous la forme de Produits bois, Panneaux et Bois de sciage).&#x20;

Ainsi, remonter à l'origine de la forêt pour les bois d'ameublement est aujourd'hui difficile pour la majorité des metteurs sur le marché. Dès lors, proposer des scénarios par défaut est nécessaire afin de refléter les enjeux biodiversité spécifiques à chaque bois.&#x20;

![](<../../.gitbook/assets/Consommation de bois _ secteur Ameublement (2019) (4).png>)

</details>

### **Etape 2 = Définition de scénarios**   &#x20;

Chacune de ces filières se voit attribuer deux valeurs par défaut :&#x20;

* un mode de Gestion forestière (GF) exprimé en Pts d'impacts / kg, selon l'état de l'art collecté par Ecobalyse dans le cadre des travaux méthodologiques du 1er semestre 2025,
* &#x20;un Indice de corruption (IC), exprimé en %, conformément à la méthode présentée précedemment.

{% hint style="info" %}
**Focus \_ Gestion Forestière (GF)**

Pour chaque filière d'approvisionnement proposée (ex : Bois tropical \_ Asie du Sud-Est), le mode de gestion forestière (Intensive / Mitigée / Raisonnée) appliqué par défaut est basé sur une hypothèse majorant&#x65;_._ L'utilisation d'une telle hypothèse pénalisante, couplée à la possibilité de préciser ce scénario, permet de prendre en compte les pratiques vertueuses (ex : traçabilité jusqu'à la parcelle, utilisation de label, etc.)  tout en incitant à plus de traçabilité.&#x20;

Les valeurs par défaut se basent sur l'état de l'art compilé par Ecobalyse dans le cadre des travaux menés sur le premier semestre 2025. Deux critères clés ont été utilisés pour identifier les pratiques forestière intensives/dégradantes : (i) l'intensité des coupes (ex : 80 m3 / ha), (ii) la durée de rotation (ex : 20 années).

Les principales sources utilisées pour estimer ces paramètre par origine sont :&#x20;

* des outils d'imagerie satellitaire permettant d'identifier les régions sylvicoles proposant une exploitation intensive des forêts ([carte 1](https://gfw.global/4kZ6RaB) de gains et pertes de couvert forestier entre 2000 et 2020 / [carte 2](https://gfw.global/41N4ujO) présentant les forêts de plantation),
* des ressources bibliographiques permettant de mieux comprendre les régions sylvicoles à risque concernant leur gestion des forêts,
* des entretiens et ateliers avec les filières Ameublement et Bois/Forêt (ex : atelier Sylviculture du 30/01/2025; support accessible [ici](https://miro.com/app/board/uXjVLn9pEjg=/?share_link_id=467200481479)).
{% endhint %}

<figure><img src="../../.gitbook/assets/image (351).png" alt=""><figcaption></figcaption></figure>

Afin de couvrir toutes les configurations possibles, deux scénarios non spécifiques à une origine ont été intégrés dans la méthode :&#x20;

* **Origine inconnue** : lorsque l'utilisateur ne connaît pas l'origine de la forêt ayant produit le bois, l'origine "Inconnue" est proposée . Ce scénario présente des hypothèses majorantes afin d'inciter à plus de traçabilité.&#x20;
* **Autre origine** : Lorsque l'origine du bois à modéliser n'est pas proposée, le scénario "Autre" est à utiliser. Ce scénario reflète le fait qu'un bois ne serait pas concerné par une filière d'approvisionnement à risque d'un point de vue biodiversité (car les filières à risque sont listées dans les scénarios par défaut). Dès lors, seul le mode de gestion forestière (GF) se voit attribué une valeur moyenne (Mitigée) car des pratiques forestières intensives peuvent avoir lieu dans n'importe quel pays.

### **Etape 3 = Introduction de certifications (optionnel)** &#x20;

Afin d'inciter à plus de traçabilité et pratiques forestières durables, l'obtention des certifications de référence permet de réduire la valeur du complément de -25%.&#x20;

Les certifications **FSC** et **PEFC** sont acceptées.&#x20;

{% hint style="info" %}
Vous souhaitez proposer des certifications additionnelles ou nous partager un autre retour ?&#x20;

Partagez votre retour sur le canal Ameublement de la plateforme Mattermost (inscription [ici](https://fabrique-numerique.gitbook.io/ecobalyse/communaute)) ou transmettez nous un mail[^3].
{% endhint %}

## Calcul du complément

$$
Comp =  \sum Ref(bois) * Compo(bois) * masse
$$

Avec : \
\- `Ref(bois)` = Pt d'impacts / kg = impact biodiversité de chaque bois (`bois`),\
\-  `Compo(bois)` = % = Part du bois (`bois`) entrant dans la composition du meuble, \
\-  `masse` = kg = masse du meuble,&#x20;



## Exemples de calcul&#x20;

<mark style="color:red;">A compléter</mark>





## <mark style="color:orange;">Old / Notes / brouillons</mark>



{% tabs %}
{% tab title="Bois tropicaux" %}
* Sont majoritairement exploités dans des forêts naturelles.\
  Les forêts de plantation restent très minoritaires et sont essentiellement exploitées pour la production de pâte à papier. (source[^4])
* Sont majoritairement exploités de mannière illégale.\
  50% à 90% des bois tropicaux seraient produits de manière illégale d'après un rapport datant de 2011 de UNEP et Interpol (source[^4]). L’illégalité prend des formes très diverses et souvent très complexes pour détourner les règles des législations forestières des pays concernés. Elle reste un obstacle majeur à la gestion durable des forêts tropicales, car elle représente une concurrence déloyale et très démotivante pour les exploitants soucieux de respecter la réglementation forestière en  \
  vigueur.
* Sont majoritairement exploités dans les régions Afrique-Asie-Brésil.\
  Principaux pays producteur (74% de la production mondiale  - source[^4] -) : Indonésie, Inde, Vietnam, Brésil, Thaïlande.
* Sont majoritairement consommés hors-Europe.\
  L'Europe importe c. 12% de la production mondiale de bois tropicaux (source[^4]). \
  Les bois tropicaux importés en Europe directemebt sous la forme de meubles ne sont pas inclus dans ce chiffre.
{% endtab %}

{% tab title="Forêts européennes" %}
* Proposent la plus grande proportion de forêts de plantation (30% de la superficie forestière, hors Russie)  (source[^4])
*
{% endtab %}

{% tab title="Forêts asiatiques" %}

{% endtab %}

{% tab title="Forêts de plantation" %}
Selon la FAO, les forêts de plantation sont inégalement présentes à travers le monde (% de la superficie forestière de la zone géographique) : &#x20;

Mondial = 7%&#x20;

Europe (hors Russie) = 30%

Afrique = 1%

Asie du Sud-Est et Caraïbes = 11%

Amérique du Sud et Centrale = 2%

&#x20;(source[^4])
{% endtab %}
{% endtabs %}



**Quelques définitions** (&#x53;_&#x6F;urce : Règlement européen du 31 mai 2023 relatif à la déforestation importée)_&#x20;

{% tabs %}
{% tab title="Déforestation" %}
La conversion, anthropique ou non, de la forêt pour un usage agricole.
{% endtab %}

{% tab title="Dégradation des forêts" %}
Les modifications structurelles apportées au couvert forestier, prenant la forme de la conversion :&#x20;

* de forêts primaires ou de forêts naturellement régénérées en forêts de plantation ou en d’autres surfaces boisées,
* de forêts primaires en forêts plantées.
{% endtab %}

{% tab title="Forêt primaire" %}
Une forêt naturellement régénérée d’essences d’arbres indigènes où aucune trace d’activité humaine n’est clairement visible et où les processus écologiques ne sont pas sensiblement perturbés.
{% endtab %}

{% tab title="Forêt plantée" %}
Une forêt à prédominance d’arbres établis par plantation et/ou par semis délibéré, et où les arbres plantés ou semés sont censés constituer plus de 50 % du matériel sur pied à maturité; sont inclus les taillis d’arbres originellement plantés ou semés.
{% endtab %}

{% tab title="Forêt de plantation" %}
Une forêt plantée soumise à une gestion intensive et qui, au moment de la plantation et de la maturité du peuplement, remplit tous les critères suivants: une ou deux essences, une structure équienne et un espacement régulier; s
{% endtab %}
{% endtabs %}

## Etat des lieux

Le bois est la principale matière utilisée sur le marché français de l'ameublement.

<figure><img src="../../.gitbook/assets/EA par matériau majoritaire (données 2022).png" alt=""><figcaption><p>Source : ADEME _ étude "REP Filière ameublement <em>Bilan annuel</em> 2022"</p></figcaption></figure>

Cette consommation français de bois d'ameublement se répartit ainsi ([unité ](#user-content-fn-5)[^5]/ source[^6]) :&#x20;

{% tabs %}
{% tab title="Vision simple" %}
<figure><img src="../../.gitbook/assets/Consommation de bois _ secteur Ameublement (2019) (2).png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
La majorité du bois d'ameublement consommé en France en 2019  (48%) sert à la fabrication de panneaux (bois d'industrie).&#x20;

Dans un tiers des cas (32%) , des meubles en bois sont directement importés sans précision sur l'origine/type/essence de bois.&#x20;

Enfin, le bois d'oeuvre représente le reste (20%).
{% endhint %}
{% endtab %}

{% tab title="Focus bois d'oeuvre" %}
<figure><img src="../../.gitbook/assets/Focus bois d&#x27;oeuvre.png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
Focus bois d'oeuvre transformé en France :&#x20;

* Les deux tiers du bois d'oeuvre (66%) sont importés,
* Les feuillus sont les essences les plus utilisées (88%).
{% endhint %}
{% endtab %}

{% tab title="Focus panneaux" %}
<figure><img src="../../.gitbook/assets/Origine des panneaux d&#x27;ameublement consommés en France.png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/Composition des panneaux.png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
* une part significative des panneaux sont importés (c. 45% du volume),
* les panneaux sont majoritairement constitués de bois d'industrie (bois de petite dimension inutilisable en bois d'oeuvre) (c. 75% du volume).
{% endhint %}
{% endtab %}

{% tab title="Vision détaillée" %}
<figure><img src="../../.gitbook/assets/Consommation de bois _ secteur Ameublement (2019) (3).png" alt=""><figcaption></figcaption></figure>
{% endtab %}
{% endtabs %}

<details>

<summary>Aller plus loin</summary>

Les scénarios d'export de vêtements hors Europe pourraient être détaillés : \
\=> par zone géographique : Afrique (46%), Asie (41%), Autre (13%) (données 2019 de [European Environment Agency](https://www.eea.europa.eu/publications/eu-exports-of-used-textiles/eu-exports-of-used-textiles)),\
\=> par scénarios de fin de vie (incinération, enfouissement, déchet sauvage, etc.),\
\=> par vêtement (jean, t-shirt, sous-vêtements, etc.).

Cependant, nous faisons face à un manque de données précises sur ces différentes géographies/scénarios ainsi que sur la disponibilité d'inventaires de cycle de vie (ICV).&#x20;

En l'absence d'inventaires de cycle de vie adaptés, un complément générique moyen est proposé.

</details>

## Matérialité du complément

Le complément, exprimé en points d'impacts (pt) par kg de vêtement, reflète l'impact de la fin de vie d'un vêtement qui terminerait sa vie sous forme de déchet hors Europe. &#x20;

<details>

<summary>Aller plus loin </summary>

Il n'existe pas encore suffisament de littérature scientifique permettant d'estimer, de manière quantitative, l'impact de la fin de vie des vêtements se retrouvant sous forme de déchets hors Europe.&#x20;

Cela s'explique notamment par des problématiques d'inventaires de flux (e.g. comment se décomposent dans le temps et l'espace les vêtements jetés dans la nature sous forme de déchets sauvages) et de caractérisation d'impacts (e.g. comment évaluer l'impact sur la biodiversité et/ou les organismes aquatiques des vêtements abandonnés dans la nature sous forme de déchets sauvages).

Trois grands scénarios se dessinent pour les  vêtements "déchets hors Europe" :&#x20;

1\) incinération informelle&#x20;

2\) décharge à ciel ouvert (incinération et/ou enfouissement)

3\) déchet sauvage (vêtement abandonné dans la nature)

Un nombre croissant d'études sont publiées sur les effets nocifs de ces scénarios sur l'environnement et l'Homme. C'est par exemple le cas de [travaux ](https://www.eionet.europa.eu/etcs/etc-ce/products/etc-ce-report-2023-4-eu-exports-of-used-textiles-in-europe2019s-circular-economy)parus en 2023 par la European Environment Agency qui stipulent : "Of the exports to Africa, a portion of the textiles are reused, but a significant amount ends up in either legal or illegal landfills, causing environmental problems. In other words, the textiles collected in and export from the EU are commodities, not charity.".

Ecobalyse se doit de les intégrer afin de refléter cet "hotspot" de la chaîne de valeur Textile.

</details>

Le coefficient "Export hors Europe" retenu est :

$$
CoefDechet = 5000microPts / kg = 0,005 Pts/kg
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde) terminant sa vie sous forme de déchets hors Europe, la fin de vie pèserait entre 43% et 50% de l'impact total du produit (hors compléments) selon sa composition.&#x20;

Cette illustration permet de comprendre la matérialité du complément dans un "worst-case scenario" théorique.

Pour calculer le complément sur un produit réel, il faut estimer sa probabilité de terminer sa fin de vie sous forme de déchet hors Europe (cf. ci-dessous).

![](<../../.gitbook/assets/Impact d'un jean terminant sa fin de vie sous forme de déchet Hors Europe (1).png>)

</details>

## Paramètre 1 : gestion intensive des forêts&#x20;

{% tabs %}
{% tab title="Europe" %}
* 10% des zones forestières européennes sont classées comme étant soumises à une gestion intensive
* moins de 5% des zones forestières européennes sont considérées comme non perturbées ou naturelles

Source : _Règlement européen du 31 mai 2023 relatif à la déforestation importée + Agence européenne pour l'Environnement_
{% endtab %}

{% tab title="Second Tab" %}

{% endtab %}
{% endtabs %}

[^1]: L’Organisation des Nations unies pour l’alimentation et l’agriculture

[^2]: _Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;

[^3]: alban.fournier@beta.gouv.fr

[^4]: Sist P., 2024. Exploiter durablement les forêts tropicales.    \
    Versailles, éditions Quæ, 100 p.

[^5]: Mm3 eq. bois rond sur écorce

[^6]: Etude Carbone 4 \_ Scénarios de converge de la filière Bois
