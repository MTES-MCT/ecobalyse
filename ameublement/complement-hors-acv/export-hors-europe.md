---
description: Présentation de la méthode de calcul du complément Biodiversité x Bois .
---

# 🌍 Biodiversité x Bois

## Pourquoi introduire ce complément ?

Afin d'intégrer dans l'évaluation environnementale des meubles les enjeux biodiversité liés à certaines pratiques forestières participant à la dégradation des forêts et/ou à la déforestation.&#x20;

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

<summary>3) <strong>Le secteur de l'ameublement constitue un débouché des filières bois</strong> </summary>

Concernant la dégradation des forêts, tout bois utilisé dans l'Ameublement peut provenir de forêts participant à leur dégradation ("gestion intensive").&#x20;

Sur la déforestation, quelques approvisionnements en bois peuvent participer à la déforestation. Cependant, il est à noter que le secteur de l'ameublement participe peu à la déforestation à l'échelle mondiale (90% de cette dernière provenant de l'expansion de l'agriculture / source[^2]).

{% hint style="info" %}
Le bois fait partie des quelques produits de base consommés au sein de l'UE et participant à la déforestation. Il se classe 3ème (9% de la déforestation dont l'UE est responsable provient du bois) après l'huile de plame (34%) et le soja (33%)

_Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;
{% endhint %}

</details>

## Paramètres mobilisés

<details>

<summary>Indice Corruption (COR) </summary>

Ce paramètre vise à préciser la probabilité que le bois soit issu de pratiques forestières non durables. Ce paramètre est spécifique à une origine (pays ou une région).

Plus le niveau de corruption est élevée, plus faible est la probabilité que le bois soit issu d'une forêt gérée durablement.&#x20;

3 niveaux de corruption sont proposés :&#x20;

* Elevé (score CPI inférieur à 30)

- Moyen (score CPI entre 30 et 59)

* Faible (score CP au moins égal à 60)

Un **coefficient de corruption (COR)** est affecté à chaque niveau :&#x20;

| Elevé | Moyen | Faible |
| ----- | ----- | ------ |
| 100%  | 50%   | 0%     |



**Détails**

Cet indice est basé sur le [Corruption Perceptions Index](https://www.transparency.org/en/cpi/2023) (CPI) de l'année 2023.&#x20;

Le CPI vise à mesurer les niveaux de corruption perçus dans le secteur public à travers le monde. Cet indice annuel est publié par Transparency International, une organisation non gouvernementale qui lutte contre la corruption.\
L'indice est basé sur des enquêtes et des évaluations d'experts qui portent sur divers aspects de la corruption, tels que l'abus de pouvoir public à des fins privées, les pots-de-vin, et la détournement de fonds publics.\
Les pays sont notés sur une échelle de 0 à 100, où 0 signifie un niveau de corruption perçu très élevé et 100 signifie un niveau très faible.

</details>

<details>

<summary>Exploitation Forestière (EXP)</summary>

Ce paramètre vise aussi à préciser la probabilité que le bois soit issu de pratiques forestières non durables. Ce paramètre est spécifique à une origine (ex : Cameroun, Asie du Sud-Est, etc.) et une essence (ex : bois exotiques, chêne, etc.).&#x20;

3 niveaux d'exploitation forestière sont proposés :&#x20;

* Intensive
* Mitigée
* Raisonnée

Un **coefficient d'exploitation forestière (EXP)** est affecté à chaque niveau :&#x20;

| Intensive | Mitigée | Raisonnée |
| --------- | ------- | --------- |
| 100%      | 50%     | 0%        |



**Détails**

Le type d'exploitation forestière est estimé sur la base de deux critères :&#x20;

* l'intensité des coupes (ex : 80 m3 / ha) ,
* la durée de rotation (ex : 20 années).

Les principales sources utilisées pour ce paramètre sont :&#x20;

* des outils d'imagerie satellitaire permettant d'identifier les régions sylvicoles proposant une exploitation intensive des forêts ([carte 1](https://gfw.global/4kZ6RaB) de gains et pertes de couvert forestier entre 2000 et 2020 / [carte 2](https://gfw.global/41N4ujO) présentant les forêts de plantation),
* des ressources bibliographiques permettant de mieux comprendre les régions sylicoles à risque concernant leur gestion intensive des forêts (
* des entretiens et ateliers avec les filières Ameublement et Bois/Forêt (ex : atelier Sylvilcutre du 30/01/2025 piloté par Ecobalyse; support accessible [ici](https://miro.com/app/board/uXjVLn9pEjg=/?share_link_id=467200481479))

</details>

<details>

<summary>Certificat / Label (optionnel)</summary>



</details>

## Matérialité du complément

<mark style="color:red;">A définir lorsque le cyle de vie Ameublement sera modélisé</mark>

Un coefficient (`Coef`), exprimé en micropoints d'impacts par kg de bois (`microPts/kg`).

Ce coefficient reflète l'impact sur la biodiversité d'un bois issu d'un pays où :&#x20;

* la corruption est élevée (CPI < 30),
* les pratiques forestières sont majoritarirement intensives (c'est à dire ne permettant pas à la forêt de reconstituer naturellement le volume de bois prélevé). &#x20;

La valeur de ce coefficient est fixée à :&#x20;

$$
Coef = xxx microPts / kg = 0,001 Pts/kg
$$

Grâce à l'utilisation de scénarios de référence spécifiques à chaque type de bois (`bois`) , ce coefficient (`Coef`) permet de calcul le complément Biodiversité<=>Bois (`Comp`).

## Scénarios de référence

### **Etape 1 = Définition des scénarios** &#x20;

Les principales filières d'approvisionnement du marché français du bois d'ameublement ont été identifiées. Parmi ces dernières, celles à risque d'un point de vue Biodiversité ont été identifiés.&#x20;

1 approvisionnement = 1 bois = 1 essence de bois (ex : chêne) + 1 origine (ex : France). &#x20;

<details>

<summary>Plus d'info sur les filières d'approvisionnement du bois d'ameublement français</summary>

Les statistiques décomposent généralement les approvisionnements bois en 3 catégories :&#x20;

* bois rond,
* bois de sciage,
* Produits bois (achats directs de meubles ou produits intermédiaires tels que des panneaux)&#x20;

Détailler ces chaînes d'approvisionnement afin de remonter à l'origine des forêts ayant fourni ces bois n'est pas facile (notamment pour les imports de _bois de sciage_ & _produits bois_).&#x20;

La majorité du bois d'ameublement français est importé (principalement sous la forme de Produits bois, Panneaux et Bois de sciage).&#x20;

![](<../../.gitbook/assets/Consommation de bois _ secteur Ameublement (2019) (4).png>)

</details>

Ensuite, pour chaque approvisionnement à risque, des valeurs par défaut sont définies pour l'indice de corruption (COR) et le type d'exploitation forestière (EXP). Ces valeurs par défaut reflètent les pratiques auxquelles il faut s'attendre dans ces régions en l'absence de toute stratégie d'écoconception :&#x20;

<div align="left"><figure><img src="../../.gitbook/assets/image (338).png" alt=""><figcaption><p>Scénarios pour les approvisionnements listés et connus par l'utilisateur</p></figcaption></figure></div>

Afin de couvrir toutes les configurations possibles, deux scénarios additionnels sont proposés dans l'interface Ecobalyse :&#x20;

<div align="left"><figure><img src="../../.gitbook/assets/image (339).png" alt=""><figcaption><p>Autres scénarios  (origine Inconnue ou Non listée)</p></figcaption></figure></div>

* **Inconnue** : lorsque l'utilisateur ne connaît pas l'origine de la forêt ayant produit le bois, l'origine "Inconnue" est proposée . Ce scénario présente des hypothèses majorantes afin d'inciter à plus de traçabilité.&#x20;
* **Autres** : Lorsque l'origine n'est pas proposée, l'origine "Autre" est proposée. Etant donné que des pratiques forestières intensives peuvent avoir lieu dans n'importe quel pays, il est proposé par défaut un scénario "Mitigée" pour le paramètre EXP (Exploitation forestière).&#x20;

{% hint style="success" %}
**Votre bois est certifié / labellisé ?**

Si le bois bénéficie d'une certification faisant partie de la liste ci-dessous,  le paramètre Exploitation Forestière se voit attribuer la valeur "Raisonnée".  Ce scénario permet de refléter les démarches d'écoconception dans la méthode.

Liste des labels/certifications acceptées :&#x20;

<mark style="color:red;">\[A compléter]</mark>

![](<../../.gitbook/assets/image (340).png>)
{% endhint %}

### **Etape 2 = Pondération des paramètres**

Une pondération des paramètres (COR et EXP) est proposée.

<table data-full-width="false"><thead><tr><th width="159.22222900390625"></th><th>Indice de corruption (COR)</th><th>Exploitation forestière (EXP)</th></tr></thead><tbody><tr><td>Pondération</td><td>30%</td><td>70%</td></tr></tbody></table>

### **Etape 3 = Définition des valeurs de référence**&#x20;

Dès lors, chaque approvisionnement/bois (`bois`) peut se voit attribuer une valeur de référence (`Ref`) grâce aux coefficients COR (Indice de corruption) et EXP (Exploitation forestière) selon la formule suivante :&#x20;

$$
Ref (bois) = (0,3*COR + 0,7*EXP) / 100
$$

:bulb: _Plus la valeur de référence (Ref) est élevée, plus élevé sera l'impact Biodiversité du bois._&#x20;

<figure><img src="../../.gitbook/assets/image (342).png" alt=""><figcaption><p>Calcul des valeurs de référence (Ref) selon les différents approvisionnement (bois) proposés dans Ecobalyse</p></figcaption></figure>

## Calcul du complément

$$
Comp =  \sum Ref(bois) * Compo(f) * masse*Coef
$$

Avec : \
\- `Ref(bois)` = % = valeur de référence spécifique à chaque approvisionnement/bois (`appro`),\
\-  `Compo(bois)` = % = part du bois (`bois`) entrant dans la composition du meuble, \
\-  `masse` = kg = masse du meuble, \
\- `Coef` = micro-points = matérialité du complément (<mark style="color:red;">xxx</mark> micro-points)



## Exemples de calcul&#x20;

<mark style="color:red;">A compléter</mark>





## <mark style="color:orange;">Old / Notes / brouillons</mark>



{% tabs %}
{% tab title="Bois tropicaux" %}
* Sont majoritairement exploités dans des forêts naturelles.\
  Les forêts de plantation restent très minoritaires et sont essentiellement exploitées pour la production de pâte à papier. (source[^3])
* Sont majoritairement exploités de mannière illégale.\
  50% à 90% des bois tropicaux seraient produits de manière illégale d'après un rapport datant de 2011 de UNEP et Interpol (source[^3]). L’illégalité prend des formes très diverses et souvent très complexes pour détourner les règles des législations forestières des pays concernés. Elle reste un obstacle majeur à la gestion durable des forêts tropicales, car elle représente une concurrence déloyale et très démotivante pour les exploitants soucieux de respecter la réglementation forestière en  \
  vigueur.
* Sont majoritairement exploités dans les régions Afrique-Asie-Brésil.\
  Principaux pays producteur (74% de la production mondiale  - source[^3] -) : Indonésie, Inde, Vietnam, Brésil, Thaïlande.
* Sont majoritairement consommés hors-Europe.\
  L'Europe importe c. 12% de la production mondiale de bois tropicaux (source[^3]). \
  Les bois tropicaux importés en Europe directemebt sous la forme de meubles ne sont pas inclus dans ce chiffre.
{% endtab %}

{% tab title="Forêts européennes" %}
* Proposent la plus grande proportion de forêts de plantation (30% de la superficie forestière, hors Russie)  (source[^3])
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

&#x20;(source[^3])
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

Cette consommation français de bois d'ameublement se répartit ainsi ([unité ](#user-content-fn-4)[^4]/ source[^5]) :&#x20;

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









## Probabilité export hors Europe, valeurs par défaut

A partir des données moyennes compilées dans le cadre de nos travaux, la probabilité qu'un vêtement en fin de vie soit exporté hors Europe puis jeté est de 9%.&#x20;

{% hint style="info" %}
Trois hypothèses permettent de comprendre ce chiffre de 9% :&#x20;

* 38% des vêtements utilisés pour la première fois sont collectés et triés (source[^6])
* 49% des vêtements triés sont exportés hors Europe (source[^7] / ce chiffre de 49% cadre par ailleurs avec les [autres scénarios](#user-content-fn-8)[^8] de fin de vie post-tri),&#x20;
* dans 50% des cas, le vêtement est directement jeté sans avoir été réutilisé (source mentionnée précédemment / fourchette haute retenue par Ecobalyse).
{% endhint %}

<details>

<summary>Pourquoi les vêtements synthétiques seraient moins réutilisés ?  </summary>

Lorsqu'ils arrivent à destination, par exemple en Afrique, les vêtements sont généralement triés une seconde fois. Des observations, rapportées par différents échanges avec des spécialistes de la fin de vie et une revue de la bibliographie à ce sujet, font état d'une valeur perçue plus importante pour les vêtements en matières naturelles. Comparativement aux vêtements en matières synthétiques, ceux-ci ont plus de chance d'être revendus, repris, rapiécés, upcyclés. Ils ont donc moins de chances d'être directement jetés. \
\
Ce constat est notamment appuyé par :&#x20;

* les [travaux ](https://www.ifmparis.fr/en/faculty/andree-anne-lemieux)et différents échanges avec Andrée-Anne Lemieux (chaire Sustainability IFM-Kering),
* l'initiative [Fashion For Good](https://fashionforgood.com/) dans son rapport [Sorting For Circularity Europe](https://fashionforgood.com/our_news/sorting-for-circularity-europe-project-findings/). L'hypothèse que la perception des vêtements synthétiques par le consommateur pourrait être moindre (cf. extrait du rapport ci-dessous) est effectivement partagée : \
  "_The difference in fibre composition found could also reflect a preference from consumers in the focus countries for cotton products over polyester, or could be an effect of consumer disposal behaviour as they might regard polyester products as lower value and therefore, choose to dispose of them in household waste rather than giving it to charity for reuse_.",
* le retour d'expérience du principal marché secondaire de vêtements au Ghana (marché de Katamanto à Accra) via des échanges avec [_En Mode Climat_](https://www.enmodeclimat.fr/) et [_The Or Foundation_](https://theor.org/).&#x20;

</details>

On considère donc les probabilités suivantes (&#x50;_&#x72;obaDéchet_) pour la réutilisation des vêtements exportés hors Europe :&#x20;

<table><thead><tr><th width="233">Scénario</th><th width="199">Export hors Europe</th><th>Déchets</th><th>ProbaDéchet</th></tr></thead><tbody><tr><td>Moyenne</td><td>19% <br>(= 38% * 49%)</td><td>50%</td><td>9%</td></tr><tr><td>Vêtements synthétiques</td><td>cf. ci-dessus</td><td>65%</td><td>12%</td></tr><tr><td>Autres vêtements</td><td>cf. ci-dessus</td><td>27%</td><td>5%</td></tr></tbody></table>

{% hint style="info" %}
Les valeurs ProbaDéchet par type de fibre sont calculés sur la base de 3 hypothèses :&#x20;

1\) En moyenne, 50% des vêtements exportés hors Europe ne sont pas réutilisés,

2\) Les vêtements exportés hors Europe se composent à 61% de vêtements composés de fibres synthétiques vs 39% de vêtements composés d'autres matières (Source[^9] = marché mondial des fibres textile),

3\) les vêtements composés de matières synthétiques ont 60% de chance de ne pas être réutilisés (donc la probabilité des vêtements composés de matières non synthétiques d'être non réutilisés est de 34% afin de retrouver une probabilité moyenne de 50%). &#x20;
{% endhint %}

## Calcul du complément "Export hors Europe"

2 paramètres sont considérés pour calculer le complément :&#x20;

* la masse du vêtement (produit fini),
* sa probabilité de terminer sa fin de vie hors Europe sous forme de déchets, dont la valeur par défaut dépend de la classification du produit (matières synthétiques ou naturelles)&#x20;

{% hint style="warning" %}
On considère que le vêtement rentre dans la catégorie "matières synthétiques" dès lors que les matières synthétiques représentent plus de 50% de sa composition.\
Initialement, un seuil de 10% était appliqué dans la première version de la méthodologie mise en ligne au printemps 2024. Le seuil de 50% a été proposé pendant la concertation, en soulignant qu'il fait écho au seuil réglementaire à partir duquel une information sur la présence de microfibres plastiques doit être présentée. [décret n° 2022-748 du 29 avril 2022 relatif à l'information du consommateur sur les qualités et caractéristiques des produits générateurs de déchets](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000045726094)&#x20;
{% endhint %}

$$
ComplémentFDVHE (Pts) = ProbaDechet * Masse (kg) * CoefDechet (Pts/kg)
$$

<details>

<summary>Illustration</summary>

Dans le cas théorique d'un jean (poids 450g, fabrication Inde), l'impact de la fin de vie passerait de 0% (avant introduction du complément Fin de vie Hors Europe) à 4% ou 12% selon la composition du vêtement.&#x20;

<img src="../../.gitbook/assets/Comparaison - Jean 100% synthétique (450g).png" alt="" data-size="original"><img src="../../.gitbook/assets/Comparaison - Jean 100% cotton (450g).png" alt="" data-size="original">

</details>

## Affichage du complément "Export hors Europe"

A l'instar des autres compléments à l'analyse de cycle de vie, le complément "Export hors Europe" vient s'ajouter directement au score d'impacts exprimé en points.

Il est intégré au sous-score "Compléments" et à l'étape du cycle de vie "Fin de vie".

[^1]: L’Organisation des Nations unies pour l’alimentation et l’agriculture

[^2]: _Source : Règlement européen du 31 mai 2023 relatif à la déforestation importée_&#x20;

[^3]: Sist P., 2024. Exploiter durablement les forêts tropicales.    \
    Versailles, éditions Quæ, 100 p.

[^4]: Mm3 eq. bois rond sur écorce

[^5]: Etude Carbone 4 \_ Scénarios de converge de la filière Bois

[^6]: draft PERCR Apparel & Footwear v1.3 (p.90/197) &#x20;

[^7]: Rapport 2018 "Avenir Filière REP TLC" /  données 2015 (p. 49/98)&#x20;

    \
    \
    &#x20; &#x20;

[^8]: Recyclage (31%) +Réutilisation France = (10%) +  Déchets (2%) + Réutilisation Europe (8%)= 51% => le dernier débouché étant l'Export Hors Europe (1-51%=49%)                                  \
    &#x20;&#x20;

[^9]: Textile Exchange \_ The global fiber market 2021&#x20;
