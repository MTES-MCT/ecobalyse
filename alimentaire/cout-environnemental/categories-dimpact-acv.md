---
icon: sigma
---

# Catégories d'impact ACV

## Indicateurs ACV et correctifs&#x20;

### Impacts agrégés et impacts détaillés

Ecobalyse permet de visualiser **2 impacts agrégés**, c'est à dire regroupant différents impacts après normalisation et pondération :&#x20;

* le **coût environnemental**, qui traduit le calcul d'impacts selon la méthode de l'Etat français ; donc en ajustant les pondérations PEF et en ajoutant quelques indicateurs complémentaires.&#x20;
* un **score "pondération PEF"** tel que défini dans la [recommandation de la Commission européenne du 16 décembre 2021](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=PI_COM%3AC%282021%299332) sur l'utilisation des méthode d'évaluation des empreintes environnementales. Ce score applique uniquement les indicateurs PEF avec leurs pondérations initiales. A noter qu'il n'a pas été possible d'utiliser les données EF à ce stade pour des raisons de propriété intellectuelle.

**Le détail des catégories d'impacts ACV** peut également être consulté :&#x20;

* Les 16 catégories d'impacts de la méthode PEF
* La catégorie d'impact corrigée relative à l'écotoxicité

Les coefficients de normalisation et de pondération mobilisées pour la construction de ces scores agrégés sont détaillés dans l'explorateur d'Ecobalyse alimentation : [https://ecobalyse.beta.gouv.fr/#/explore/food](https://ecobalyse.beta.gouv.fr/#/explore/food)

{% hint style="info" %}
A terme, deux autres catégories d'impact ACV, relatives à la biodiversité marine et terrestre ("à la parcelle") sont susceptibles d'être introduites.
{% endhint %}

Pour l'affichage des résultats par "sous-scores", les impacts sont ensuite agrégés suivant la **règle de l'affectation unique** introduite dans le rapport du Conseil scientifique. Chaque catégorie d'impacts est ainsi rattachée à la catégorie à laquelle elle contribue le plus.

<figure><img src="../../.gitbook/assets/Mono-affectation.png" alt=""><figcaption><p>Répartition des catégories suivant la règle de l'affectation unique</p></figcaption></figure>

### Normalisations et pondérations

Les calculs de la partie ACV coût environnemental et du score PEF s'effectuent à partir d'une somme pondérée des catégories d'impacts, chacune étant préalablement normalisée.

$$
ImpactAgrégé =\sum (Pondération_i * \frac{Impact_i}{Normalisation_i})
$$

Les niveaux de normalisation et de pondération sont détaillés dans l'[explorateur des impacts pour l'alimentaire d'Ecobalyse](https://ecobalyse.beta.gouv.fr/#/explore/food).

Pour la construction du coût environnemental, **les mêmes coefficients de normalisation que ceux du score PEF** sont appliqués.

Pour la **pondération**, la méthode de l'affichage environnemental établit que : &#x20;

* la pondération du changement climatique est maintenue à 21,06% ;
* la pondération de l'écotoxicité eau douce est réhaussée à 21,06% ;
* les pondérations des indicateurs de toxicité humaine cancer et non-cancer sont fixées à zéro, ce qui revient à supprimer ces indicateurs du coût environnemental ;
* les autres pondérations sont proportionnelles aux pondérations PEF initiales, mais réduite afin que la somme des pondérations reste bien à 100% après l'introduction des trois modifications précédentes.

L'illustration ci-après montre les principales évolutions des coefficients de pondération en considérant :&#x20;

* la proposition initiale du JRC (2018), avant prise en compte du coefficient de robustesse (donc à partir des enjeux perçus)
* la pondération annexée à la recommandation PEF de la Commission européenne de décembre 2021
* la pondération présentée, en mars 2023, à l'occasion de la mise en ligne d'une version beta d'Ecobalyse
* la pondération exposée aujourd'hui dans Ecobalyse pour servir de support à une concertation technique

<figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

### Correctifs sur la toxicité et d'écotoxicité

La modélisation des impacts de toxicité humaine (toxicité humaine cancer et toxicité humaine non-cancer) dans la méthode PEF n'est aujourd'hui pas satisfaisante. Dans l'attente de consolider ces deux indicateurs, il est proposé de les supprimer dans le calcul du coût environnemental.

En revanche, l'indicateur d'écotoxicité (écotoxicité eau douce), est lui considéré comme plus robuste par la communauté scientifique, bien que partiel puisque ne prend pas en compte l'ensemble des impacts écotoxiques, notamment sur les milieux terrestres (polinisateurs par exemple). Par ailleurs, l'absence d'un indicateur de "biodiversité locale" dans le cadre ACV actuellement justifie de considérer temporairement cet indicateur d'écotoxicité comme un "proxy" de la biodiversité locale. Il est donc proposé de rehausser sa pondération à hauteur de 21%, c'est-à-dire au même niveau que l'impact changement climatique.

En outre, une différenciation est introduite entre les deux composantes de l'écotoxicité. Celle-ci vient de molécules organiques et de molécules inorganiques. Une écotoxicité corrigée est considérée dans le coût environnemental avec un doublement de l'impact des molécules organiques. Cette modification vient traduire le fait que le niveau de caractérisation et de quantification des effets écotoxiques des molécules organiques et inorgraniques est aujourd'hui différent. Les molécules inorganiques sont bien caractérisés et leurs effets écotoxiques bien quantifiés. Les molécules organiques sont souvent moins bien caractérisées, avec des effets écotoxiques qui sont aujourd'hui établis mais pas nécessairement pleinement quantifiés : effets cocktails, impacts sur les polinisateurs, perturbateurs endocriniens...

$$
EcotoxCorrigée = EcotoxInorganiques + 2* EcotoxOrganiques
$$

Pour respecter le cadre le facteur de normalisation a été recalculé pour bien couvrir l'ensemble de l'écotoxicité corrigée à l'échelle mondiale, après doublement de la contribution liée à l'écotoxicité organiques. Cette modification du facteur de normalisation permet que le doublement de la contribution des molécules organisques à l'écotoxicité ne constitue pas une augmentation masquée de la pondération de l'écotoxicité, mais plutôt une modification des parts relatives liées aux molécules organiques et inorganiques.

Le coefficents de pondération et de normalisation, y compris ceux de l'écotoxicité et de l'écotoxicité corrigée sont détaillés dans la rubrique "impacts" de l'explorateur : [https://ecobalyse.beta.gouv.fr/#/explore/food/impacts](https://ecobalyse.beta.gouv.fr/#/explore/food/impacts)
