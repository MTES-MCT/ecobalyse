# Indicateurs environnementaux - old

## Impacts agrégés et impacts détaillés

**2 impacts agrégés**, c'est à dire regroupant différents impacts après normalisation et pondération, sont proposés dans Ecobalyse Textile :&#x20;

* un **coût environnemental**, traduisant la version beta de méthodologie, en vue de l'établissement futur d'une méthodologie de calcul pour l'affichage environnemental réglementaire français (cf. [article L.541-9-12 du code de l'environnement](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000043959458)) ;
* un **score PEF** tel que défini dans la [recommandation de la Commission européenne du 16 décembre 2021](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=PI_COM%3AC%282021%299332) sur l'utilisation des méthode d'évaluation des empreintes environnementales.

La principale différence entre le Coût Environnemental et le Score PEF consiste en l'ajout de [compléments](../../../textile/complements-hors-acv/) afin de répondre aux limites de la v.1.3 du PEFCR Apparel & Footwear.

## Indicateurs mobilisés

{% tabs %}
{% tab title="Coût environnemental" %}
Les 16 indicateurs environnementaux du PEF sont modélisés dans le coût environnemental selon 3 logiques distinctes (dans l'attente du remplacement de la Base Impacts par une base de données enrichie) :&#x20;

**Logique 1** = modélisation des 12 indicateurs environnementaux du référentiel méthodologique Ademe .&#x20;

Ces 12 indicateurs correspondent à ceux du PEF (16 indicateurs) exception faite des 4 indicateurs suivants :&#x20;

| Indicateur                                          |
| --------------------------------------------------- |
| Ecotoxicité pour écosystèmes aquatiques d'eau douce |
| Epuisement des ressources en eau                    |
| Toxicité humaine, cancer                            |
| Toxicité humaine, non cancer                        |

**Logique 2** = modélisation de l'indicateur "Epuisement des ressources en eau"  à partir des données de la [base EP\&L de Kering](https://kering-group.opendatasoft.com/pages/material-intensities/),

**Logique 3** = modélisation des indicateurs Ecotoxicité et Toxicité Humaine (Cancer et Non Cancer) via l'introduction des[ Inventaires Enrichis](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/ennoblissement/inventaires-enrichis).&#x20;
{% endtab %}

{% tab title="Score PEF" %}
Les 16 indicateurs environnementaux du PEF sont modélisés dans le Score PEF.&#x20;

La liste de ces indicateurs est disponible dans l'[Explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile).
{% endtab %}
{% endtabs %}

Focus sur les 12 indicateurs du socle technique ADEME :&#x20;

<table><thead><tr><th width="211">Indicateur</th><th width="66" align="center">Ref</th><th width="285">UUID</th><th width="119" align="center">Unité</th><th align="center">Niveau de recommandat°</th></tr></thead><tbody><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379977/idVersion/32">Acidification</a></td><td align="center">acd</td><td><code>b5c611c6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">mol H+ eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379978/idVersion/32">Appauvrissement de la couche d'ozone</a></td><td align="center">ozd</td><td><code>b5c629d6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg CFC-11 eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379979/idVersion/32">Changement climatique</a></td><td align="center">cch</td><td><code>b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">kg CO2 eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379983/idVersion/32">Eutrophisation eaux douces</a></td><td align="center">fwe</td><td><code>b53ec18f-7377-4ad3-86eb-cc3f4f276b2b</code></td><td align="center">kg P eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379984/idVersion/32">Eutrophisation marine</a></td><td align="center">swe</td><td><code>b5c619fa-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg N eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379985/idVersion/32">Eutrophisation terrestre</a></td><td align="center">tre</td><td><code>b5c614d2-def3-11e6-bf01-fe55135034f3</code></td><td align="center">mol N eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379986/idVersion/32">Formation d'ozone photochimique</a></td><td align="center">pco</td><td><code>b5c610fe-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg NMVOC eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379987/idVersion/32">Particules</a></td><td align="center">pma</td><td><code>b5c602c6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">disease incidences</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379988/idVersion/32">Radiations ionisantes</a></td><td align="center">ior</td><td><code>b5c632be-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg Bq-U235 eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379989/idVersion/32">Utilisation de ressources fossiles</a></td><td align="center">fru</td><td><code>b2ad6110-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">MJ</td><td align="center">III</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379990/idVersion/32">Utilisation de ressources minérales et métalliques</a></td><td align="center">mru</td><td><code>b2ad6494-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">kg Sb eq</td><td align="center">III</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379991/idVersion/32">Utilisation des sols</a></td><td align="center">ldu</td><td><code>b2ad6890-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">pt</td><td align="center">III</td></tr></tbody></table>

Une synthèse des indicateurs mobilisés est présente dans l’onglet Explorateur (ici[^1]).

{% hint style="danger" %}
Deux correctifs sont appliqués temporairement par Ecobalyse  :&#x20;

1\) pour les **radiations ionisantes**, un correctif est appliqué sur les procédés Mix Electriques nationaux : une division par 4,5 du total.\
En effet, les données Base Impacts datent de 2010 et surestiment considérablement les radiations ionisantes liées aux déchets radioactifs générés par l'utilisation du nucléaire dans les mix électriques nationaux. Sur la base d'une analyse de sensibilité réalisée avec les données EF 2.0 (qui datent de 2018), un écart moyen de 4,5 est constaté.

2\) modélisation de l'indicateur "Epuisement des ressources en eau"  à partir des données de la [base EP\&L de Kering](https://kering-group.opendatasoft.com/pages/material-intensities/),
{% endhint %}

<details>

<summary>Données EP&#x26;L Kering</summary>

_Les données EP\&L considérées pour l'épuisement des ressources en eau ne concernent que l'étape "matières". Des travaux complémentaires sont nécessaires pour apprécier cet impact sur les autres étapes du cycle de vie._

_Toutefois, au regard notamment des RP studies publiées à l'été 2021 dans le cadre de la consultation publique sur le projet de PEFCR Apparel & Footwear, il apparaît que l'étape "matière" représente l'essentiel de l'impact en matière d'épuisement de la ressource en eau. Par exemple, pour le produit représentatif T-shirt (RP1), l'étape "matière" (LCS1) représente 91% de l'impact total (table 49 - ligne 1086)._

</details>

## **Niveaux de recommandation**

<table><thead><tr><th width="101">Niveau</th><th width="199">Description succincte</th><th>Description complète</th></tr></thead><tbody><tr><td>Niveau I</td><td>Qualité satisfaisante</td><td><ul><li>Il s’agit de la meilleure méthode disponible et dont la qualité a été jugée satisfaisante.</li><li>Elle peut être appliquée à tous types d’études basées sur des approches de cycle de vie.</li></ul></td></tr><tr><td>Niveau II</td><td>Qualité satisfaisante mais nécessitant des améliorations</td><td><ul><li>Il s’agit de la meilleure méthode disponible et dont la qualité a été jugée satisfaisante mais nécessitant des améliorations futures.</li><li>Elle peut être appliquée à tous types d’études basées sur des approches de cycle de vie.</li><li>Les résultats issus de cet indicateur doivent cependant être interprétés avec précaution notamment en cas de comparaison.</li></ul></td></tr><tr><td>Niveau III</td><td>Donnée incomplète à utiliser avec prudence</td><td><ul><li>Il s’agit de la meilleure méthode disponible mais à utiliser avec beaucoup de prudence compte tenu de la grande incertitude et du manque de complétude de la méthode.</li><li>Elle doit être utilisé avec réserve en cas de comparaison. Il est ainsi recommandé de présenter les résultats et discuter de la comparaison avec et sans cette méthode.</li></ul></td></tr><tr><td>N/A</td><td>Niveau affiché pour l'utilisation de ressource en eau</td><td></td></tr></tbody></table>

## Calcul des scores d'impact

Le calcul des du Coût Environnemental et du score PEF s'effectue à partir d'une somme pondérée des catégories d'impacts, chacune étant préalablement normalisée.



$$
ImpactAgrégé =\sum (Pondération_i * \frac{Impact_i}{Normalisation_i})
$$

Les niveaux de normalisation et de pondération sont détaillés dans l'[explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile).&#x20;

<details>

<summary>Focus Coût environnemental</summary>

Pour la construction du coût environnemental, **il est considéré les même niveaux de normalisation que pour le score PEF**.&#x20;

Pour la **pondération**, les coefficients appliqués au coût environnemental sont établis comme suit : &#x20;

* la pondération du changement climatique est maintenue à 21,06%, afin que le poids relatif de cet impact ne soit pas diminué par l'ajout d'impacts biodiversité ;
* les niveaux des 3 indicateurs de toxicité (écotoxicité, toxicité humaine cancer, toxicité humaine non cancer), [considérés dans leurs versions corrigées](impacts-consideres.md#indicateurs-de-toxicite-et-decotoxicite-corriges), sont réhaussés proportionnellement de façons à ce que la somme des 3 fasse 12,5% ;\
  &#xNAN;_&#x43;ette modification revient environ à doubler la pondération de ces 3 indicateurs (\*2,12)._
* les autres pondérations sont proportionnelles aux pondérations PEF initiales, mais réduite afin que la somme des pondérations reste bien à 100% après l'introduction des trois modifications précédentes.\
  &#xNAN;_&#x43;ette modification revient environ à réduire d'environ 6% la pondération des 12 indicateurs concernés_.

</details>

## Unité (micro-points)

Les scores ainsi calculés sont sans unité. Il sont exprimés en "Points".&#x20;

Comme la normalisation s'effectue à partir de l'impact annuel moyen d'un européen pour chaque indicateur, le total des points pour un vêtement est très faible. Une conversion en micro-points (1 mPt = 10^-6 Pt) est donc systématiquement appliquée dans l'outil Ecobalyse.

$$
1 mpt = 1 pt / 1 000 000
$$

[^1]: [https://ecobalyse.beta.gouv.fr/#/explore/textile](https://ecobalyse.beta.gouv.fr/#/explore/textile)
