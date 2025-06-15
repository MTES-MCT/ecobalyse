---
icon: bin-recycle
---

# Fin de vie

## Contexte &#x20;

### Les scénarios de fin de vie du produit

Les scénarios de fin de vie d'un produit peuvent être définis avec ces deux critères :&#x20;

* la capacité de la filière à collecter le produit en fin de vie (taux de collecte),
* la recyclabilité du produit (oui vs non).

Le schéma ci-dessous montre les scénarios possible. La mention "Scénario déchet" indique que le produit est traité au même titre que les ordures ménagères.

<figure><img src="../.gitbook/assets/image (356).png" alt=""><figcaption></figcaption></figure>

### Le recyclage des matériaux

Les métaux, ferreux (aciers) ou non ferreux (aluminium notamment), ont un taux de recyclage élevé quelle que soit la fin de vie du produit. En effet, même dans les ordures ménagères incinérées, des systèmes permettent d'extraire ces matériaux.

Si le produit est collecté et recyclable, les autres matériaux sont recyclé, incinéré ou mis en décharge selon des ratios spécifiques à chaque matériau.

## Méthode de calcul

{% hint style="info" %}
**Recyclage = Impact nul (approche cut-off)**

Ecobalyse utilise à ce stade l'approche cut-off pour allouer l'impact du recyclage des matériaux.

Dit autrement, l'impact du recyclage des matériaux est alloué 100% au produit utilisant ces matières recyclées. Ainsi, l'impact en fin de vie d'un meuble 100% recyclé serait nul.&#x20;
{% endhint %}

<mark style="color:red;">Formule modifiée avec :</mark>&#x20;

* [ ] prise en compte des métaux (deux formules séparées)
* [x] prise en compte TC
* [x] Prise en compte recyclabilité produit
* [x] alignement avec paramètres CFF



{% tabs %}
{% tab title="Niveau 0" %}
$$
I_{EoL} = \sum_i m_i*(I_{EoL,incineration,i}+I_{EoL,landfill,i})
$$
{% endtab %}

{% tab title="Niveau 1" %}
$$
I_{EoL,incineration,i} = (1-R_{2,i})*R_{3,i}*I_{ER.i}
$$

$$
I_{EoL,landfill,i} = (1-R_{2,i})*(1-R_{3,i})*I_{D,i}
$$
{% endtab %}

{% tab title="Niveau 2" %}
$$
R_{2,i, hors métaux}=TC*r_p*Rec(i)
$$

$$
R_{2,i,métaux}=Rec(i)
$$

$$
R_{3,i, hors métaux}=(1-TC*rp)*Inc(def)/(1-Rec(def))+TC*rp*Inc(i)/(1-Rec(i))
$$
{% endtab %}
{% endtabs %}

Avec :&#x20;

* `I_EoL` : l'impact environnemental du produit en fin de vie, dans l'unité de la catégorie d'impact analysée
* `m_i` : la masse relative à la famille de matériaux `i`, en kg
* `I_EoL,incineration,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_EoL,landfill,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `R_2,i` : le taux de recyclage en fin de vie des matériaux de la famille de matière `i`, en %
* `R_3,i` : le taux d'incinération en fin de vie des matériaux non recyclés de la famille de matière `i`, en %, dont le calcul est précisé dans la section suivante
* `I_ER,i` : l'impact environnemental de l’incinération (y compris transport et tri) d'un kg d'un matériau de la famille de matériaux `i`, dans l'unité de la catégorie d'impact analysée
* `TC` : le taux de collecte des produits, en %
* `r_p` : la recyclabilité du produit, égale à 1 si le produit est recyclable ou 0 s'il ne l'est pas
* `Rec(i)` : la part de recyclage du matériau (i) lorsque le produit est collecté et recyclable
* `Inc(i)` : la part d'incinération du matériau (i) lorsque le produit est collecté et recyclable
* `I_recyclingEol,i` : l'impact environnemental du recyclage d'un kg d'un matériau de la famille de matériaux `i`, dans l'unité de la catégorie d'impact analysée - non pris en compte, égal à zéro
* `I_EoL,rec,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée - non pris en compte, égal à zéro

## Paramètres retenus pour le coût environnemental&#x20;

### Taux de collecte `TC`

Un taux de collecte de 70% est appliqué par défaut pour l'ensemble des produits, sauf mention explicite contraire dans les pages sectorielles.&#x20;

### Recyclabilité produit `rp`&#x20;

La recyclabilité est définie pour chaque catégorie de produit selon des critères spécifiques à chaque secteur.&#x20;

### "Scénario Déchet"

Ce scénario est applicable aux matériaux des produits non collectés ou non recyclables, hors métaux.&#x20;

<table><thead><tr><th width="267">Matière</th><th>% recyclage</th><th>Inc(def) (% incinération) </th><th>Enf(def) (% enfouissement)</th></tr></thead><tbody><tr><td>Toutes</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

{% hint style="info" %}
Ce scénario est basé sur le scénario de fin de vie d'un mobilier meublant dont la recyclabilité du meuble est de 0% dans la dernière version du référentiel BPX30 _Meubles Meublants \_ FCBA (Novembre 2023)_
{% endhint %}

### Taux de recyclage et d'incinération spécifiques à chaque matière

Ces paramètres sont issus de la filière ameublement.&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Rec(i)</th><th>Inc(i)</th><th>Enf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>69%</td><td>31%</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>4%</td><td>94%</td><td>2%</td></tr><tr><td>Plastique*</td><td>92%</td><td>8%</td><td>0%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

&#x20;   \*Source : Filière REP EA _données 2022 (Bilan annuel 2023)_\
&#x20; _\*\*Source : Référentiel Mobilier Meublant  \__ scénarios emballages (FCBA-ADEME)

{% hint style="warning" %}
<mark style="color:red;">Liste à compléter/préciser (ex : latex, Mousse PU, etc.) = attente de retours précis de la filière</mark>
{% endhint %}

## Procédés utilisés pour le coût environnemental

`Ienf` = Treatment of municipal solid waste, sanitary landfill, RoW = 21 Pt / kg

`Iinc` = Treatment of municipal solid waste, municipal incineration, FR = 39 Pt / kg

#### Liste des procédés

Procédés utilisés pour modéliser le coût environnemental de la fin de vie des produits.  &#x20;

<table data-full-width="false"><thead><tr><th width="113.6666259765625">Matériau (i)</th><th width="166.66656494140625">Recyclage</th><th>Incinération</th><th>Enfouissement</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)</td><td>n/a (cut-off)</td><td>Treatment of waste wood, untreated, municipal incineration, CH</td><td>n/a</td></tr><tr><td>Métal</td><td>n/a (cut-off)</td><td>n/a</td><td>n/a</td></tr><tr><td>Rembourré / Matelas</td><td>n/a (cut-off)</td><td>Treatment of waste polyurethane, municipal incineration FAE, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Plastique</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (without CH)</td><td>n/a</td></tr><tr><td>Emballage (carton)</td><td>n/a (cut-off)</td><td>Treatment of waste paperboard, municipal incineration, Europe (without CH)</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (plastique)</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration, Europe (without CH)</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (autre)</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Autres</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr></tbody></table>

#### Coût environnemental (Pt d'impact / kg)&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Irec(i)</th><th>Iinc(i)</th><th>Ienf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>0</td><td>2</td><td>n/a</td></tr><tr><td>Métal*</td><td>0</td><td>n/a</td><td>n/a</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>0</td><td>96</td><td>39</td></tr><tr><td>Plastique*</td><td>0</td><td>80</td><td>39</td></tr><tr><td>Emballage (carton)**</td><td>0</td><td>7</td><td>39</td></tr><tr><td>Emballage (plastique)**</td><td>0</td><td>80</td><td>39</td></tr><tr><td>Emballage (autres)**</td><td>n/a</td><td>21</td><td>39</td></tr><tr><td>Autres matières</td><td>n/a</td><td>21</td><td>39</td></tr></tbody></table>

<details>

<summary>Vision simplifiée des procédés spécifiques mobilisés</summary>

<figure><img src="../.gitbook/assets/Coût environnement (Pt _ kg) des scénarios de fin de vie (1).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/Tableau fin de vie.png" alt=""><figcaption></figcaption></figure>



</details>

## Exemples&#x20;

<mark style="color:red;">A actualiser</mark>

