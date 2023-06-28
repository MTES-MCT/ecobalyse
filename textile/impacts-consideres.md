# Indicateurs environnementaux

## Indicateurs mobilisés

12 indicateurs environnementaux sont actuellement modélisés sur Ecobalyse, conformément au référentiel méthodologique de l’Ademe.&#x20;

Plus de 16 indicateurs seront disponibles d'ici fin 2023 suite à la finalisation de deux chantiers : \
\- enrichissement de la base de données (cf. travaux ADEME sur la Base Empreinte),\
\- travaux méthodologiques Alimentaire (ex : introduction de l'indicateur "Biodiversité locale"). \
\
A date, les 12 indicateurs utilisés dans l'outil sont :&#x20;

<table><thead><tr><th width="211">Indicateur</th><th width="66" align="center">Ref</th><th width="285">UUID</th><th width="119" align="center">Unité</th><th align="center">Niveau de recommandat°</th></tr></thead><tbody><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379977/idVersion/32">Acidification</a></td><td align="center">acd</td><td><code>b5c611c6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">mol H+ eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379978/idVersion/32">Appauvrissement de la couche d'ozone</a></td><td align="center">ozd</td><td><code>b5c629d6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg CFC-11 eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379979/idVersion/32">Changement climatique</a></td><td align="center">cch</td><td><code>b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">kg CO2 eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379983/idVersion/32">Eutrophisation eaux douces</a></td><td align="center">fwe</td><td><code>b53ec18f-7377-4ad3-86eb-cc3f4f276b2b</code></td><td align="center">kg P eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379984/idVersion/32">Eutrophisation marine</a></td><td align="center">swe</td><td><code>b5c619fa-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg N eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379985/idVersion/32">Eutrophisation terrestre</a></td><td align="center">tre</td><td><code>b5c614d2-def3-11e6-bf01-fe55135034f3</code></td><td align="center">mol N eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379986/idVersion/32">Formation d'ozone photochimique</a></td><td align="center">pco</td><td><code>b5c610fe-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg NMVOC eq</td><td align="center">I</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379987/idVersion/32">Particules</a></td><td align="center">pma</td><td><code>b5c602c6-def3-11e6-bf01-fe55135034f3</code></td><td align="center">disease incidences</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379988/idVersion/32">Radiations ionisantes</a></td><td align="center">ior</td><td><code>b5c632be-def3-11e6-bf01-fe55135034f3</code></td><td align="center">kg Bq-U235 eq</td><td align="center">II</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379989/idVersion/32">Utilisation de ressources fossiles</a></td><td align="center">fru</td><td><code>b2ad6110-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">MJ</td><td align="center">III</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379990/idVersion/32">Utilisation de ressources minérales et métalliques</a></td><td align="center">mru</td><td><code>b2ad6494-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">kg Sb eq</td><td align="center">III</td></tr><tr><td><a href="https://www.base-impacts.ademe.fr/personalspace/read-impact-category/id/379991/idVersion/32">Utilisation des sols</a></td><td align="center">ldu</td><td><code>b2ad6890-c78d-11e6-9d9d-cec0c932ce01</code></td><td align="center">pt</td><td align="center">III</td></tr></tbody></table>

En revanche, les 4 indicateurs suivants du référentiel européen PEF ne sont pas pris en compte.&#x20;

| Indicateur                                          |
| --------------------------------------------------- |
| Ecotoxicité pour écosystèmes aquatiques d'eau douce |
| Epuisement des ressources en eau                    |
| Toxicité humaine, cancer                            |
| Toxicité humaine, non cancer                        |

Une synthèse des indicateurs mobilisés est présente dans l’onglet Explorateur ([ici](https://ecobalyse.beta.gouv.fr/#/textile/explore/impacts)).

{% hint style="danger" %}
Deux correctifs sont appliqués temporairement par Ecobalyse  :&#x20;

1\) pour les **radiations ionisantes**, un correctif est appliqué sur les procédés Mix Electriques nationaux : une division par 4,5 du total.\
En effet, les données Base Impacts datent de 2010 et surestiment considérablement les radiations ionisantes liées aux déchets radioactifs générés par l'utilisation du nucléaire dans les mix électriques nationaux. Sur la base d'une analyse de sensibilité réalisée avec les données EF 2.0 (qui datent de 2018), un écart moyen de 4,5 est constaté.

2\) pour l'**épuisement des ressources en eau**, un impact est proposé, en construction, à partir des données de la [base EP\&L de Kering](https://kering-group.opendatasoft.com/explore/dataset/raw-material-intensities-2020/information/).
{% endhint %}

<details>

<summary>Données EP&#x26;L Kering</summary>

_Les données EP\&L considérées pour l'épuisement des ressources en eau ne concernent que l'étape "matières". Des travaux complémentaires sont nécessaires pour apprécier cet impact sur les autres étapes du cycle de vie._

_Toutefois, au regard notamment des RP studies publiées à l'été 2021 dans le cadre de la consultation publique sur le projet de PEFCR Apparel & Footwear, il apparaît que l'étape "matière" représente l'essentiel de l'impact en matière d'épuisement de la ressource en eau. Par exemple, pour le produit représentatif T-shirt (RP1), l'étape "matière" (LCS1) représente 91% de l'impact total (table 49 - ligne 1086)._

</details>

## **Niveaux de recommandation**

<table><thead><tr><th width="101">Niveau</th><th width="199">Description succincte</th><th>Description complète</th></tr></thead><tbody><tr><td>Niveau I</td><td>Qualité satisfaisante</td><td><ul><li>Il s’agit de la meilleure méthode disponible et dont la qualité a été jugée satisfaisante.</li><li>Elle peut être appliquée à tous types d’études basées sur des approches de cycle de vie.</li></ul></td></tr><tr><td>Niveau II</td><td>Qualité satisfaisante mais nécessitant des améliorations</td><td><ul><li>Il s’agit de la meilleure méthode disponible et dont la qualité a été jugée satisfaisante mais nécessitant des améliorations futures.</li><li>Elle peut être appliquée à tous types d’études basées sur des approches de cycle de vie.</li><li>Les résultats issus de cet indicateur doivent cependant être interprétés avec précaution notamment en cas de comparaison.</li></ul></td></tr><tr><td>Niveau III</td><td>Donnée incomplète à utiliser avec prudence</td><td><ul><li>Il s’agit de la meilleure méthode disponible mais à utiliser avec beaucoup de prudence compte tenu de la grande incertitude et du manque de complétude de la méthode.</li><li>Elle doit être utilisé avec réserve en cas de comparaison. Il est ainsi recommandé de présenter les résultats et discuter de la comparaison avec et sans cette méthode.</li></ul></td></tr><tr><td>N/A</td><td>Niveau affiché pour l'utilisation de ressource en eau</td><td></td></tr></tbody></table>

## Score PEF

En s'appuyant sur la documentation adossée au projet de PEFCR Apparel & Footwear, tel que mis en consultation à l'été 2021, un calcul d'un score PEF est réalisé, suite aux opérations suivantes :

* normalisation de chacun des impacts
* pondération des impacts normalisés pour obtenir le score

### Normalisation

$$
ImpactNormalisé = Impact / CoefNormalisation
$$

### Pondération

$$
ScorePEF = Somme (ImpactNormalisé * CoefPondération)
$$

### Valeurs numériques

Les valeurs numériques des coefficients de normalisation et de pondération sont précisés dans [l'explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile).

### Unité

Le score PEF ainsi calculé est sans unité. Il s'exprime en "Points".&#x20;

Comme la normalisation s'effectue à partir de l'impact annuel moyen d'un européen pour chaque indicateur, le total des points pour un vêtement est très faible. Une conversion en millipoints (mPt) est donc systématiquement appliquée dans l'outil Ecobalyse.

$$
1 mpt = 1 pt / 1 000
$$
