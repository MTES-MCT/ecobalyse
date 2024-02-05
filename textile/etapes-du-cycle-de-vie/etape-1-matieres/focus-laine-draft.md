# Focus laine (draft)

énéralités

La fibre de laine représente 1,1% de la production mondiale de fibres textile en 2022 (source[^1]). Les principaux pays producteurs sont la Chine , l'Australie et la Nouvelle-Zélande.

<details>

<summary>Production mondiale par pays</summary>

![](<../../../.gitbook/assets/image (1) (1).png>)

</details>

La majorité de la laine utilisée aujourd'hui en Europe dans le secteur de l'habillement a été produite hors d'Europe.&#x20;

<details>

<summary>Focus laine française </summary>

La production française de moutons est majoritairement destinée à la production de viande et de lait. Ainsi, la production de laine n'est pas valorisée (1 kg de laine se vend quelques dizaines de centimes ne couvrant pas les frais de tonte autour de 1,5€ par mouton).&#x20;

Cet état de fait fait notamment suite à la désindustrialisation du secteur depuis les années 80 (à l'époque une filière existait dans le Tarn et le Nord principalement).  Les éleveurs se sont alors progressivement tournés depuis vers des races produisant principalement de la viande ou du lait.&#x20;

Cependant, différentes initiatives récentes participent à remonter une filière lainière destinée aux textiles d'habillement (cf. par exemple [LainesPaysannes](https://laines-paysannes.fr/) et [Collectif Tricolore](https://www.collectiftricolor.org/)).&#x20;

</details>

Afin de correctement valoriser la production de laine, il est nécessaire d'appréhender les enjeux autour de la valorisation des co-produits.

### Co-produits & Allocation (économique, bio-physique, etc.)

Lorsqu'un système génère plusieurs produits, les impacts environnementaux doivent être répartis entre les différents produits via une règle d'allocation.&#x20;

C'est le cas de l'élevage de moutons qui permet de produire de la viande, du cuir, de la laine, du lait, de la lanoline, etc.&#x20;

Plusieurs méthodes d'allocations existent; dont les deux principales utilisées pour le mouton sont présentées ci-dessous.&#x20;

Selon la méthode utilisée et la zone d'élevage, l'impact environnemental de laine peut varier d'un facteur 1 à 3.

{% tabs %}
{% tab title="Allocation économique" %}
L'allocation économique est recommandée par l'ADEME concernant l'évaluation environnementale de matières d'origine animale.

Cette allocation fluctue selon les prix et la structure du marché.&#x20;

**Focus Prix** \
Le marché de la laine est organisé par l'International Wool Trade Organization (IWTO). Le marché asiatique fixe les prix car cette région est le principal acheteur de laine pour la transformer.&#x20;

**Focus Structure**\
Cf. la section Généralités

:bulb: **Illustrations d'allocations économiques :**&#x20;

Selon une étude parue en 2015 et comparant différents systèmes/géographiques de production de laine (source [ici](https://link.springer.com/article/10.1007/s11367-015-0849-z)) : \
:flag\_gb: Royaume-Uni = 4% laine\
:flag\_nz:Nouvelle-Zélande (151 fermes) => 19% laine\
:flag\_au:Australie (3 fermes / laine merinos / région méridionale) => 47% laine\
:flag\_au:Australie (3 fermes / laine merinos ++ / région septentrionale) => 52% laine

Autres sources : \
:flag\_us: Etats-Unis (année 2007) => 23% laine (source[^2]) \
:flag\_nz:Nouvelle-Zélande (laine merinos) : 65% laine (source[^3])
{% endtab %}

{% tab title="Allocation biophysique" %}
Allocation en fonction du contenu en protéines de la laine et de la viande produites par le mouton.\
L'[IWTO](https://iwto.org/) recommande une allocation biophysique; la laine se voit alors attribuer 35% à 38% des impacts liés à l'élevage du mouton.&#x20;

Selon une étude parue en 2015 et comparant différents systèmes/géographiques de production de laine (source [ici](https://link.springer.com/article/10.1007/s11367-015-0849-z)) : \
:flag\_gb: Royaume-Uni = 22% laine\
:flag\_nz:Nouvelle-Zélande (151 fermes) => 43% laine\
:flag\_au:Australie (3 fermes / laine merinos région méridionale) => 50% laine\
:flag\_au:Australie (3 fermes laine merinos ++ / région septentrionale) => 45% laine

Autres sources : \
:flag\_au:Australie (52 fermes / 5 ans / 2 régions / laine merinos) : 47% (source[^4]) \
:flag\_nz:Nouvelle-Zélande (laine merinos) : 48% laine (source[^5])
{% endtab %}

{% tab title="Allocation massique" %}
:bulb: **Illustrations d'allocations massiques :**&#x20;

Selon une étude parue en 2015 et comparant différents systèmes/géographiques de production de laine (source [i](https://link.springer.com/article/10.1007/s11367-015-0849-z)[ci](https://link.springer.com/article/10.1007/s11367-015-0849-z)) : \
:flag\_gb: Royaume-Uni = 19% laine \
:flag\_nz:Nouvelle-Zélande (151 fermes) => 39% laine\
:flag\_au:Australie (3 fermes / laine merinos région méridionale) => 40% laine &#x20;

Autres sources : \
:flag\_nz:Nouvelle-Zélande : 20% laine (source[^6])\
:flag\_nz:Nouvelle-Zélande : 25% laine (source[^7])
{% endtab %}
{% endtabs %}

### Enjeux environnementaux

Les principaux enjeux environnementaux liés à la production de laine sont :&#x20;

* utilisation des sols,
* changement climatique,\
  La majorité des émissions proviennent du fait que ces ruminants relarguent du méthane lors du processus digestif ainsi que de l'énergie nécessaire sur l'ensemble du cycle de vie.
* consommation d'eau.

## Modélisation Ecobalyse

### Utilisation d'une allocation économique

En suivant les recommandations de l'ADEME, une allocation économique est utilisée.

Deux scénarios sont proposés :&#x20;

* Laine (par défaut) => allocation économique de 50% &#x20;
* Laine (nouvelle filière) => allocation économique de 10% \
  (permet de modéliser une laine provenant d'une filière en construction comme c'est le cas pour le marché français).&#x20;

Le procédé Ecoinvent utilisé est _Sheep production, for wool, RoW._&#x20;

### Comprendre les impacts environnementaux de la laine

<figure><img src="../../../.gitbook/assets/image (2).png" alt=""><figcaption><p>Extrait de l'impact de 1kg de laine depuis Ecobalyse </p></figcaption></figure>

**Principaux enseignements**

* 47% de l'impact de _Laine (par défaut)_ provient de l'indicateur Ecotoxicité de l'eau douce.\
  L'alimentation du mouton (12kg de soja / an ) explique la majeure partie de cet impact. Ce choix d'alimentation est proposé par Ecoinvent dans le cadre d'un scénario basé sur les pratiques du marché US (extrait de la documentation Ecoinvent : "This dataset is a copy dataset from the respective US geography and therefore might not represent fully the global situation"). \
  Un paramètre clé à préciser est l'alimentation moyenne des moutons utilisés pour la laine textile.
* Le complément Microfibres (570 uPts / kg de fibre naturelle d'origine animale) explique une part significative de l'impact de la laine (28% de _Laine (nouvelle filière)_ et 7% de _Laine (par défaut)_ ).&#x20;

[^1]: Textile Exchange (market report 2023)

[^2]: Travaux ENSAIT & EIME dans le cadre de la mise en place de la base de données EIME

[^3]: Etude parue en 2015 et commissionnée par la New-Zealand Merino Company => "LCA of wool apparel"

[^4]: Etude parue en 2020 : _Environmental impacts associated with the production, use, and end-of-life of a woollen garment_

[^5]: Etude parue en 2015 et commissionnée par la New-Zealand Merino Company => "LCA of wool apparel"

[^6]: Etude parue en 2015 et commissionnée par la New-Zealand Merino Company => "LCA of wool apparel"

[^7]: Etude parue en 2006 et commissionnée par la New-Zealand Merino Company => "LCA : New Zealand Merino Industry"
