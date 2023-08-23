# Indicateurs d'impacts ACV

## Impacts agrégés et impacts détaillés

**2 impacts agrégés**, c'est à dire regroupant différents impacts après normalisation et pondération, sont proposés dans Ecobalyse alimentaire :&#x20;

* un **score d'impacts**, traduisant la version beta de méthodologie présentée aux partenaires le 27 mars 2023, en vue de l'établissement futur d'une méthodologie de calcul pour l'affichage environnemental réglementaire français (cf. [article L.541-9-12 du code de l'environnement](https://www.legifrance.gouv.fr/codes/article\_lc/LEGIARTI000043959458)) ;
* un **score PEF** tel que défini dans la [recommandation de la Commission européenne du 16 décembre 2021](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=PI\_COM%3AC%282021%299332) sur l'utilisation des méthode d'évaluation des empreintes environnementales.

**20 catégories d'impacts**, utilisées pour composer les impacts agrégés, sont également proposés :&#x20;

* les 16 catégories d'impacts de la méthode PEF ([lien](impacts-consideres.md#16-categories-dimpacts-pef))
* 1 catégorie d'impact "biodiversité locale" ([lien](impacts-consideres.md#indicateur-de-biodiversite-locale))
* 3 catégories d'impacts corrigées, relatives à la toxicité et à l'écotoxicité (l[ien](impacts-consideres.md#indicateurs-de-toxicite-et-decotoxicite-corriges))

{% hint style="info" %}
Une 21ème catégorie d'impact, relative à la biodiversité marine, est susceptible d'être introduite dans les prochains mois, en fonction des conclusions d'un groupe de travail dédié.
{% endhint %}

## Nomalisations et pondérations

Le calcul des du score d'impacts et du score PEF s'effectue à partir d'une somme pondérée des catéogories d'impacts, chacune étant préalablement normalisée.

$$
ImpactAgrégé =\sum (Pondération_i * \frac{Impact_i}{Normalisation_i})
$$

Les niveaux de normalisation et de pondération sont détaillés dans l'[explorateur des impacts pour l'alimentaire d'Ecobalyse](https://ecobalyse.beta.gouv.fr/#/explore/food).

Pour la construction du score d'impacts, **il est considéré les même niveaux de normalisation que pour le score PEF**. Un niveau de normalisation est introduit pour la [biodiversité locale](impacts-consideres.md#indicateur-de-biodiversite-locale).

Pour la **pondération**, les coefficients appliqués au score d'impacts sont établis comme suit : &#x20;

* la pondération du changement climatique est maintenue à 21,06%, afin que le poids relatif de cet impact ne soit pas diminué par l'ajout d'impacts biodiversité ;
* l'indicateur d'atteinte à la biodiversité locale est introduit avec une pondération double à la moyenne des 16 indicateurs PEF initiaux (12,5%) ;
*   les niveaux des 3 indicateurs de toxicité (écotoxicité, toxicité humaine cancer, toxicité humaine non cancer), [considérés dans leurs versions corrigées](impacts-consideres.md#indicateurs-de-toxicite-et-decotoxicite-corriges), sont réhaussés proportionnellement de façons à ce que la somme des 3 fasse 12,5% ;

    _Cette modification revient environ à doubler la pondération de ces 3 indicateurs (\*2,12)._
*   les autres pondérations sont proportionnelles aux pondérations PEF initiales, mais réduite afin que la somme des pondérations reste bien à 100% après l'introduction des trois modifications précédentes.

    _Cette modification revient environ à réduire de 26% la pondération des 12 indicateurs concernés_.

{% hint style="info" %}
Dans l'hypothèse où un nouvel indicateur, relatif à la biodiversité marine, serait introduit, celui-ci pourrait se voir appliqué un coefficient de pondération de 12,5%, identique à celui appliqué à la biodiversité locale (terrestre).

Dans cette hypothèse, la réduction homothétique de la pondération des 12 autres impacts devrait être plus importante, afin que la somme des pondérations reste à 100%. Elle serait alors de 43% (vs 26% dans la version beta de la méthodologie).
{% endhint %}

<figure><img src="../.gitbook/assets/chart (6).png" alt=""><figcaption><p>Bilan des évolutions de pondération entre le score d'impacts et le score PEF</p></figcaption></figure>

## Visualisation dans l'outil de comparaison

La fonction "Comparer" proposée dans Ecobalyse permet de comparer les **scores d'impacts** différentes simulations préalablement sauvegardées.&#x20;

![](<../.gitbook/assets/image (18).png>)

Dans un souci de simplification de la présentation des résultats, cette fonction propose une option "impacts groupés" qui permet de regrouper les 17 catégories d'impacts (+ les [3 bonus hors ACV](complements-hors-acv.md)) mobilisés pour construire le score d'impacts. Les regroupements sont présentés suivant la **règle de l'affectation unique** introduite dans le rapport du Conseil scientifique. Chaque catégorie d'impacts est ainsi rattachée à la catégorie à laquelle elle contribue le plus.

{% hint style="info" %}
Cette règle est une des deux options introduites dans le rapport du Conseil scientifique.
{% endhint %}

<figure><img src="../.gitbook/assets/Mono-affectation.png" alt=""><figcaption><p>Répartition des catégories suivant la règle de l'affectation unique</p></figcaption></figure>

## 16 catégories d'impacts PEF

Pour chacun des inventaires de cycle de vie mobilisés, les impacts relatifs aux 16 catégories PEF sont issus de la [base Agribalyse](https://agribalyse.ademe.fr/).

Les inventaires sélectionnés, notamment pour décrire chaque ingrédient, sont introduits dans les pages de la méthodologie relatives à chaque ingrédient.&#x20;

## Indicateur d'atteinte à la biodiversité locale

Les 16 indicateurs du PEF sont complétés afin de mieux prendre en compte l'impact sur la biodiversité locale (à la parcelle). Cet indicateur est calculé selon la méthodologie décrite dans cet article de recherche : [Lindner et al. 2019, Valuing Biodiversity in Life Cycle Impact Assessment](https://www.researchgate.net/publication/336523544\_Valuing\_Biodiversity\_in\_Life\_Cycle\_Impact\_Assessment).

Le calcul du BVI (biodiversity value increment), a été appliqué à chacun des inventaires de cycle de vie Agribalyse mobilisé dans Ecobalyse. Il mobilise des paramètres tels que :&#x20;

* la richesse initiale de la biodiversité à travers un facteur d'écorégion (forêts tropicales, forêts tempérées...) ;
* le niveau de dégradation de cette biodiversité, en intégrant des paramètres comme le travail du sol, la fertilisation ou encore l'écotoxicité.

Pour les produits d'origine animale, ce calcul prend bien en compte les hypothèses relatives à l'alimentation des animaux, telles que présentes dans les inventaires de cycle de vie Agribalyse.

Un facteur de normalisation est introduit (cf. [explorateur](https://ecobalyse.beta.gouv.fr/#/explore/food)). Il correspond au niveau de BVI calculé sur l'ensemble de la planète.

## Correctif des indicateurs de toxicité et d'écotoxicité

### Amplification des impacts de toxicité humaine et ecotoxicité organique

Pour la toxicité et l'écotoxicité, des impacts "corrigés" sont calculés pour prendre en compte les limites de connaissances non intégrées à ce jour dans les indicateurs PEF. Parmi ces limites, on peut notamment citer : les effets toxiques sur les pollinisateurs, la biodiversité des sols, les effets cocktails, les impacts des co-adjuvants et co-formulants, des métabolites...

Ces limites conduisent très vraisemblablement, en l'absence de correction, à sous-estimer les effets toxiques, en particulier pour les pesticides de synthèses.&#x20;

Les 3 impacts relatifs à la toxicité sont considérés : &#x20;

* Écotoxicité de l'eau douce
* Toxicité humaine - cancer
* Toxicité humaine - non-cancer&#x20;

Chacun de ses impacts toxicité est décomposé en 2 composantes : "organic" et "inorganic". La correction consiste à multiplier l'impact de la composante "organic" (liée à l'utilisation de pesticides de synthèse) par 2.

### Omission provisoire des impacts de toxicité humaine inorganique

De plus il existe des anomalies sur la partie inorganique des impacts de toxicité humaine. Pour ces raisons on fait pour l'instant le choix de négliger la partie inorganique des impacts toxicité humaine - cancer et toxicité humaine - non-cancer.

On observe en effet que les métaux lourds représentent un impact très important pour les produits biologique sur les impacts de toxicité humaine et non sur l'écotoxicité, comme on peut le voir sur les graphiques ci-dessous.

<figure><img src="../.gitbook/assets/image (19).png" alt="" width="375"><figcaption><p>Impact sur la toxicité humaine cancer du blé conventionnel et bio, décomposé par substance</p></figcaption></figure>

<figure><img src="../.gitbook/assets/Screenshot 2023-08-23 at 18.05.16.png" alt="" width="375"><figcaption><p>Impact sur la toxicité humaine non cancer du blé conventionnel et bio, décomposé par substance</p></figcaption></figure>

<figure><img src="../.gitbook/assets/Screenshot 2023-08-23 at 18.05.02 (1).png" alt="" width="375"><figcaption><p>Impact sur l'écotoxicité de l'eau douce du blé conventionnel et bio, décomposé par substance</p></figcaption></figure>

### Bilan&#x20;

En appliquant l'ensemble de ces correctifs on obtient les impacts corrigés suivant :&#x20;

```
htc = htc_organic + htc_inorganic  
htc_corrigé = 2 * htc_organic

htn = htn_organic + htn_inorganic  
htn_corrigé = 2 * htn_organic

etf = etf_organic + etf_inorganic  
etf_corrigé = 2 * etf_organic + etf_inorganic
```

## Correctif sur l'indicateur "consommation d'eau"

Dans les ICV d'Agribalyse les flux de consommation d'eaux étaient des flux mondiaux, même pour des produits Français. Etant donné que l'impact de la consommation d'1L d'eau mondial est plus impactant (42.95) que la consommation d'1L d'eau en France (6.98), cela surestime les impacts des produits faits en France.

Pour corriger cela nous avons appliqué un patch (imaginé par WeLoop) sur la méthode de caractérisation : en modifiant l'impact des flux de consommations d'eaux mondiaux afin que cela corresponde à l'impact de la consommation d'eau en FR.

Ainsi les impacts de consommation d'eaux sont maintenant plus proche de la réalité pour les produits faits en France.

Limites : pour les produits importés utilisant de l'eau mondiale ({GLO}), les résultats sont faussés. Ce patch doit rester temporaire en attendant un correctif lors de la prochaine mise à jour des données par Agribalyse.

<figure><img src="../.gitbook/assets/image.png" alt=""><figcaption></figcaption></figure>
