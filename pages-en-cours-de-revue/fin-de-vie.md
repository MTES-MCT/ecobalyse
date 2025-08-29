---
icon: bin-recycle
---

# Fin de vie

## Contexte &#x20;

### Les scénarios de fin de vie du produit

Les scénarios de fin de vie d'un produit peuvent être définis avec ces deux critères :&#x20;

* la capacité de la filière à collecter le produit en fin de vie (taux de collecte), éventuellement décliné en une collecte pour traitement local d'une part et une collecte pour export d'autre part,
* la recyclabilité du produit (oui vs non).

Le schéma ci-dessous montre les scénarios possible de fin de vie :

<figure><img src="../.gitbook/assets/image (1) (1).png" alt=""><figcaption></figcaption></figure>

### Le recyclage des matériaux

Les métaux, ferreux (aciers) ou non ferreux (aluminium notamment), ont un taux de recyclage élevé quelle que soit la fin de vie du produit. En effet, même dans les ordures ménagères incinérées, des systèmes permettent d'extraire ces matériaux.

Si le produit est collecté et recyclable, les autres matériaux sont recyclés, incinérés ou mis en décharge selon des ratios spécifiques à chaque matériau.

## Méthode de calcul

{% hint style="info" %}
**Recyclage = Impact nul (approche cut-off)**

Ecobalyse utilise à ce stade l'approche cut-off pour allouer l'impact du recyclage des matériaux.

Dit autrement, l'impact du recyclage des matériaux est alloué 100% au produit utilisant des matières recyclées. Ainsi, l'impact en fin de vie d'un meuble 100% recyclé serait nul.&#x20;
{% endhint %}

{% tabs %}
{% tab title="Niveau 0" %}
$$
I_{EoL} = I_{EoL, Spécifique}+I_{EoL, DechetsDivers}+I_{EoL, Export}
$$

{% include "../.gitbook/includes/fdv-tcmimpc+-1-tc-mimpnc.md" %}
{% endtab %}

{% tab title="Niveau 1" %}
Impact des scénarios en fin de vie \
(S = Spécifique matière / D = Déchets divers)

$$
I_{EoL,S}=TC*r_p*\sum_i m_i*(R_{S,Inc,i}*I_{EoL,incineration,i}+(1-R_{S,Rec,i}-R_{S,Inc,i})*I_{EoL,landfill,i})
$$

$$
I_{EoL,D}=(1-TC*r_p-TE)*\sum_i m_i*(R_{D,Inc,i}*I_{EoL,incineration,i}+(1-R_{D,Rec,i}-R_{D,Inc,i})*I_{EoL,landfill,i})
$$

Impact de la fin de vie pour le scénario Export :

$$
I_{EoL,Export}=TE*\sum_i m_i*(1-R_{E,Rec,i})*I_{EoL,openlandfill,i})
$$
{% endtab %}
{% endtabs %}

Avec :&#x20;

* `I_EoL` : l'impact environnemental du produit en fin de vie, dans l'unité de la catégorie d'impact analysée
* `m_i` : la masse relative à la famille de matériaux `i`, en kg
* `I_EoL,incineration,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_EoL,landfill,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_EoL,openlandfill,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `TC` : le taux de collecte des produits, en %
* `TE` : le taux de collecte pour export des produits, en %
* `r_p` : la recyclabilité du produit, égale à 1 si le produit est recyclable ou 0 s'il ne l'est pas
* `R_S,Rec,i` : la part de recyclage du matériau (i) lorsque le produit est collecté et recyclable
* `R_S,Inc,i` : la part d'incinération du matériau (i) lorsque le produit est collecté et recyclable
* `R_D,Rec,i` : la part de recyclage du matériau (i) lorsque le produit n'est pas collecté ou pas recyclable (fin de vie déchets divers)
* `R_D,Inc,i` : la part d'incinération du matériau (i) lorsque le produit n'est pas collecté ou pas recyclable (fin de vie déchets divers)
* `R_E,Rec,i` : la part de recyclage du matériau (i) lorsque le produit est exporté
* `I_recyclingEol,i` : l'impact environnemental du recyclage d'un kg d'un matériau de la famille de matériaux `i`, dans l'unité de la catégorie d'impact analysée - non pris en compte, égal à zéro
* `I_EoL,rec,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée - non pris en compte, égal à zéro

## Paramètres retenus pour le coût environnemental&#x20;

### Taux de collecte `TC`

Un taux de collecte de 70% est appliqué par défaut pour l'ensemble des produits, sauf mention explicite contraire dans les pages sectorielles.&#x20;

### Recyclabilité produit `rp`&#x20;

La recyclabilité de chaque produit est définie selon des règles spécifiques à chaque secteur. Se référerer aux pages sectorielles.&#x20;

### Taux de collecte pour export `TE`

Un taux de collecte pour export de 0% est appliqué par défaut pour l'ensemble des produits, sauf mention explicite contraire dans les pages sectorielles.&#x20;

{% tabs %}
{% tab title="Scénario "Déchets Divers"" %}
Ce scénario est applicablepar défaut pour les produits non collectés ou non recyclables :&#x20;

<table><thead><tr><th width="267">Matériau i</th><th>Recyclage (R_D,Rec,i)</th><th>Incinération (R_D,Inc,i)</th><th>Enfouissement (R_D,Enf,i)</th></tr></thead><tbody><tr><td>Tous matériaux (hors métaux)</td><td>0%</td><td>82%</td><td>18%</td></tr><tr><td>Métaux</td><td>90%</td><td>5%</td><td>5%</td></tr></tbody></table>

{% hint style="info" %}
Sources :&#x20;

* Tous matériaux (hors métaux) : données issues du scénario "meubles collectés non recyclables" de la filière Ameublement (cf. référentiel Meubles Meublants 2023/FCBA )
* Métaux : compromis entre les données FCBA (référence ci-dessus) et les données tous secteurs confondu (86% des emballages aciers et 37% des emballages aluminium sont recyclés (Citeo, 2023).
{% endhint %}
{% endtab %}

{% tab title="Scénario "Spécifique Matière"" %}
### Taux de recyclage + Incinération + Mise en décharge&#x20;

Ces paramètres sont définis secteur par secteur dans les pages Fin de vie sectorielles.
{% endtab %}
{% endtabs %}



## Procédés utilisés pour le coût environnemental

Les procédés utilisés sont identifiés dans l'Explorateur de procédé.&#x20;

Ils sont également détaillés ci-dessous.

<table data-full-width="false"><thead><tr><th width="113.6666259765625">Matériau (i)</th><th width="166.66656494140625">Recyclage</th><th>Incinération</th><th>Enfouissement</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)</td><td>n/a (cut-off)</td><td>Treatment of waste wood, untreated, municipal incineration, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Métal</td><td>n/a (cut-off)</td><td>Treatment of scrap steel, municipal incineration with fly ash extraction, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Rembourré / Matelas</td><td>n/a (cut-off)</td><td>Treatment of waste polyurethane, municipal incineration FAE, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Plastique</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration with fly ash extraction, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (carton)</td><td>n/a (cut-off)</td><td>Treatment of waste paperboard, municipal incineration with fly ash extraction, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (plastique)</td><td>n/a (cut-off)</td><td>Treatment of waste plastic, mixture, municipal incineration with fly ash extraction, CH</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Emballage (autre)</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr><tr><td>Autres</td><td>n/a</td><td>Treatment of municipal solid waste, municipal incineration, FR</td><td>Treatment of municipal solid waste, sanitary landfill, RoW</td></tr></tbody></table>

#### Coût environnemental (Pt d'impact / kg)&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Irec(i)</th><th>Iinc(i)</th><th>Ienf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>0</td><td>2</td><td>25</td></tr><tr><td>Métal*</td><td>0</td><td>2</td><td>25</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>0</td><td>100</td><td>25</td></tr><tr><td>Plastique*</td><td>0</td><td>80</td><td>25</td></tr><tr><td>Emballage (carton)**</td><td>0</td><td>6</td><td>25</td></tr><tr><td>Emballage (plastique)**</td><td>0</td><td>79</td><td>25</td></tr><tr><td>Emballage (autres)**</td><td>n/a</td><td>21</td><td>25</td></tr><tr><td>Autres matières</td><td>n/a</td><td>21</td><td>25</td></tr></tbody></table>

## Exemples&#x20;

<mark style="color:red;">A actualiser</mark>

