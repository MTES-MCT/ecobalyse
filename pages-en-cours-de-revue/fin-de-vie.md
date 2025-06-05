---
icon: bin-recycle
---

# Fin de vie

## Contexte &#x20;

### Les scénarios de fin de vie du produit

Les scénarios de fin de vie d'un produit peuvent être définis avec ces deux critères :&#x20;

* la recyclabilité du produit (oui vs non),
* la capacité de la filière à collecter le produit en fin de vie (taux de collecte),

<figure><img src="../.gitbook/assets/image (356).png" alt=""><figcaption></figcaption></figure>

### Le recyclage des matériaux

Les métaux ferreux et l'aluminium sont&#x20;

Si le produit est collecté est collecté et recyclable, les autres matériaux sont recyclé, incinéré ou mis en décharge selon des ratios spécifiques à chaque matériau.

## Méthode de calcul

{% hint style="info" %}
**Recyclage = Impact nul (approche cut-off)**

Ecobalyse utilise l'approche cut-off pour allouer l'impact du recyclage des matériaux.

Dit autrement, l'impact du recyclage des matériaux est alloué 100% au produit utilisant ces matières recyclées. Ainsi, l'impact en fin de vie d'un meuble 100% recyclé serait nul.&#x20;
{% endhint %}

<mark style="color:red;">Formule à modifier avec :</mark>&#x20;

* prise en compte des métaux
* prise en compte TC
* Prise en compte recyclabilité produit
* alignement avec paramètres CFF

{% tabs %}
{% tab title="Niveau 0" %}
$$
FDV = ImpactCollecté+ ImpactNonCollecté
$$
{% endtab %}

{% tab title="Niveau 1" %}
$$
ImpactCollecté = ImpactRecyclable + ImpactNonRecyclable
$$

$$
ImpactNonCollecté = ImpactScénarioDéchet
$$
{% endtab %}

{% tab title="Niveau 2" %}
$$
ImpactRecyclable =  \sum (i)  M* (Enf(i)*Ienf(i) + Inc(i)*Iinc(i) + Recy(i) *Irec(i))
$$

$$
ImpactNonRecyclable = ImpactScénario Déchet = M * (Inc*Iinc + Enf*Ienf)
$$

{% hint style="info" %}
Liste des variables mobilisées dans les formules ci-dessus :&#x20;

* M = kg = la masse de la partie du meuble spécifique au scénario modélisé &#x20;
* Enf(i) = % = la performance d'enfouissement du matériau (i) lorsque le meuble est collecté et recyclable\*
* Inc(i) = % = la performance d'incinération du matériau (i) lorsque le meuble est collecté et recyclable\*
* Rec(i) = % = la performance de recyclage du matériau (i) lorsque le meuble est collecté et recyclable\*
* Ienf(i) / Iinc(i) / Irec(i) = l'impact du procédé enfouissement/incinération/recyclage du matériau (i)
* Inc / Enf = % = scénario par défaut de Incinération et Enfouissement
* Iinc / Ienf = Pt / kg = coût environnemental des procédés par défaut Incinération et Enfouissement
{% endhint %}
{% endtab %}
{% endtabs %}

## Paramètres retenus pour le coût environnemental&#x20;

### Recyclabilité&#x20;

La recyclabilité est définie pour chaque catégorie de produit selon des critères spécifiques à chaque secteur.&#x20;

### Taux de collecte `TC`

Un taux de collecte de 70% est appliqué par défaut pour l'ensemble des produits, sauf mention explicite contraire dans les pages sectorielles.&#x20;

### Scénarios Déchet

Ce scénario est applicable aux matériaux des produits non collectés ou non recyclables (hors métaux).&#x20;

<table><thead><tr><th width="267">Matière</th><th>% recyclage</th><th>Inc (% incinération) </th><th>Enf (% enfouissement)</th></tr></thead><tbody><tr><td>Toutes</td><td>n/a</td><td>82%</td><td>18%</td></tr></tbody></table>

{% hint style="info" %}
Ce scénario est basé sur le scénario de fin de vie d'un mobilier meublant dont la recyclabilité du meuble est de 0% dans la dernière version du référentiel BPX30 _Meubles Meublants \_ FCBA (Novembre 2023)_
{% endhint %}

### Taux de recyclage et d'incinération spécifiques à chaque matière

Ces paramètres sont issus de la filière ameublement.&#x20;

<table><thead><tr><th width="267">Matériau (i)</th><th>Rec(i)</th><th>Inc(i)</th><th>Enf(i)</th></tr></thead><tbody><tr><td>Bois (massif &#x26; panneaux)*</td><td>69%</td><td>31</td><td>0%</td></tr><tr><td>Métal*</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse*</td><td>4%</td><td>94%</td><td>2%</td></tr><tr><td>Plastique*</td><td>92%</td><td>8%</td><td>0%</td></tr><tr><td>Emballage (carton)**</td><td>85%</td><td>11%</td><td>4%</td></tr><tr><td>Emballage (plastique)**</td><td>7%</td><td>68%</td><td>25%</td></tr><tr><td>Emballage (autres)**</td><td>0%</td><td>73%</td><td>27%</td></tr><tr><td>Autres matières</td><td>0%</td><td>82%</td><td>18%</td></tr></tbody></table>

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

