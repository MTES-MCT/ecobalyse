---
description: >-
  Présentation de l'intégration d'un coefficient de durabilité dans la méthode
  de calcul
---

# ⏳ Durabilité

{% hint style="info" %}
Plus un vêtement est porté, plus son impact est faible
{% endhint %}

La prise en compte de la durabilité doit permettre d'introduire une estimation du nombre d'utilisation de chaque vêtement dans la modélisation du coût environnemental.

## Quelles sont les dimensions de la durabilité ? Lesquelles sont prises en compte ?

Deux principales dimensions sont généralement considérées pour apprécier la durabilité d'un vêtement :&#x20;

* sa durabilité physique (capacité du vêtement à résister à l'usure physique liée à son utilisation et son entretien)
* sa durabilité non physique (propension qu'aura le vêtement à être porté plus longtemps en fonction d'autres critères : réparabilité, attachement...)

Ces deux dimensions sont mises en avant dans différents travaux à l'échelle européenne

> Parlement Européen - Résolution sur la stratégie textile durable (juin 2023) : \
> "_Calls on the Commission and the Member States to ensure that the policy framework on textiles takes a holistic view of durability, including both the physical and the emotional durability of textile products put on the market, which describes the garment design that takes into account long-term relevance and desirability to consumers, as clothing represents a cultural value_"

> Secrétariat technique du PEFCR Apparel & Footwear (juin 2023) : \
> "_\[Acknowledges] that product lifetime in Apparel & Footwear is subject to three influences:_
>
> _a.the intrinsic durability of the product_\
> _b.the extrinsic durability and_\
> _c.the reparability of the product_"

Dans un premier temps, le coefficient de durabilité introduit dans la modélisation du coût environnemental intègre la dimension non physique de la durabilité. La durabilité physique fait par ailleurs l'objet de travaux dans le cadre du projet de PEFCR Apparel & Footwear, en s'appuyant notamment sur le projet Durhabi porté par l'IFTH, en lien avec de nombreux acteurs en France et avec le soutien de l'Ademe.

## Calcul du coût environnemental

Pour chaque vêtement, un **coefficient de durabilité** est établi. Sa valeur est comprise entre 0.5, pour les produits les moins durables, et 1.5 pour les produits les plus durables.

Le coût environnemental est établi comme suit :&#x20;

$$
CoûtEnvironnemental = Somme des Impacts / CoefficientDurabilité
$$

Avec :&#x20;

* SommedesImpacts : Somme des impacts du vêtement considéré sur l'ensemble de son cycle de vie. Pour la phase d'utilisation, on considère un nombre de portés et un nombre de cycles d'utilisation proportionnels au coefficient de durabilité. Plus un vêtement est durable, plus il est porté, plus il est entretenu, plus la somme des impacts qu'il génère est importante (sur une durée d'utilisation plus longue).
* Coût environnemental : Le coût environnemental ainsi considéré revient à considérer une unité fonctionnelle "utilisation du vêtement sur une durée de X jours", où X est la durée moyenne d'utilisation considérée pour la catégorie de vêtement considérée (cf. nombre de portés et d'utilisation avant lavage spécifiés dans l'[explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), en s'appuyant sur les données du projet de PEFCR Apparel & Footwear lorsqu'elles sont disponibles).

Exemple :&#x20;

* Pour un vêtement avec un coefficient de durabilité de 0.5, le coût environnemental est multiplié par 2 (+100%)
* Pour un vêtement avec un coefficient de durabilité de 1.5, le coût environnemental est divisé par 1.5 (-33%)

## Calcul du coefficient de durabilité

Le coefficient de durabilité est établi à partir de 5 critères avec les $$Poids_{critère}$$ comme suit :&#x20;

<table><thead><tr><th width="374">Critère</th><th>Poids_{critère}</th></tr></thead><tbody><tr><td>Incitation à la réparation</td><td>30%</td></tr><tr><td>Largeur de gamme</td><td>20%</td></tr><tr><td>Durée de commercialisation</td><td>20%</td></tr><tr><td>Matières</td><td>15%</td></tr><tr><td>Affichage de la traçabilité</td><td>15%</td></tr></tbody></table>



{% hint style="info" %}
Chacun des 5 critères, pris indépendamment, ne suffit pas à qualifier la durabilité non physique d'un vêtement et peut présenter des effets de bord. En revanche, la prise en compte des 5 critères ensemble permet de qualifier un positionnement marque/produit avec une incidence sur le nombre d'utilisation des vêtements, donc leur durabilité.
{% endhint %}

<figure><img src="../.gitbook/assets/image (4).png" alt="" width="375"><figcaption><p>Pondération des 5 composantes du coefficient de durabilité</p></figcaption></figure>

Chacune des 5 composantes s'exprime à travers un indice (I) compris entre 0 et 1 et pouvant donc être exprimé en pourcentage (%). En intégrant les pondérations mentionnées ci-dessus, et les valeurs minimale (0.5) et maximale (1.5) du coefficient de durabilité $$C_{durabilité}$$ , la formule permettant de l'établir est :&#x20;

$$
C_{Durabilité} = 0.5 + \sum_{critère}^{} Poids_{critère}*I_{critère}
$$

Ou aussi&#x20;

$$C_{Durabilité} = 0.5 +  0.3*I_{incitation réparation} +  0.2*I_{largeur de gamme} + 0.2*I_{durée commercialisation} + 0.15*I_{matière}  + 0.15*I_{affichage tracabilité}$$



La définition et la modélisation de chaque indice sont détaillées ci-après.

## Largeur de gamme

### Définition

**La largeur de gamme désigne le nombre de références proposées simultanément par une marque ou une plateforme**. Ce paramètre qualifie donc la marque ou la plateforme, et donc l'ensemble des références qu'elle propose.

Précisions :&#x20;

* Le canal de vente considéré est prioritairement le site internet de la marque, lorsque celui-ci représente une part non négligeable des ventes. En l'absence de vente en ligne sur le site de la marque, un canal de vente doit être choisi parmi les principaux.
* Dans le cas d'une marque qui serait distribuée majoritairement via une plateforme, au point que les consommateurs identifient plus la plateforme que la marque, c'est le nombre total de références proposées sur la plateforme qui doit être considéré.
* Par "référence", on entend généralement une suite de lettres ou de chiffres figurant sur la page produit, et correspondant à une couleur donnée d’un produit donné. Ce terme peut correspondre à la notion d'unité de gestion de stock (UGC ou SKU pour Stock Keeping Unit). Une référence peut être déclinée en plusieurs tailles. On compte alors bien une seule référence pour l'ensemble des tailles proposées.
* Le nombre de références à renseigner doit être le nombre maximum de références commercialisées un même jour sur l'ensemble de l'année. Ainsi, en cas de contrôle à une date donnée, il doit toujours être observé un nombre de références commercialisées inférieur à la valeur renseignée pour calculer l'indice "largeur de gamme"

### Formule de calcul

L'indice "largeur de gamme" prend les valeurs suivantes :&#x20;

* 100% lorsque le nombre de références est inférieur à 3000
* 80% pour 6000 références
* 25% pour 9000 références
* 0% lorsque le nombre de références est supérieur à 12000
* Entre ces différents points, l'évolution de l'indice est linéaire (cf. schéma ci-après)

<figure><img src="../.gitbook/assets/image.png" alt="" width="375"><figcaption><p>Indice "largeur de gamme" en fonction du nombre de références commercialisées</p></figcaption></figure>

{% hint style="info" %}
En première approche, une unique formule est appliquée quelle que soit la marque ou la plateforme qui commercialise le produit considéré. Au besoin, l'introduction d'échelles différenciées pourra être envisagée pour distinguer les marques qui ne couvriraient qu'une partie du marché (vêtements pour hommes, vêtements pour femme, vêtements pour enfants, vêtements de sport...).
{% endhint %}

## Durée de commercialisation

### Définition

**La durée de commercialisation désigne le nombre de jours, en moyenne, pendant lesquels les produits d'une marque ou d'une collection sont commercialisés**. Ce paramètre qualifie donc la marque ou la collection, et donc l'ensemble des références qu'elle propose ou qui la compose.

Précisions :&#x20;

* La définition considérée pour définir un produit (ou référence) est identique à celle présentée pour l'indice "largeur de gamme".
* Le canal de vente considéré est identique à celui considéré pour l'indice "largeur de gamme".
* Une marque peut faire le choix de différencier différentes collections ou gammes de produits, dès lors que celles-ci sont bien identifiables pour le consommateur. Elle peut par exemple dissocier : les produits d'une collection "intemporels" qui auront une durée de commercialisation moyenne élevée ; les produits de collection "tournantes" qui auront une durée de commercialisation moyenne plus courte. Ce choix éventuel, laissé à l'appréciation de la marque, peut donc conduire à augmenter l'indice "durée de commercialisation" de certains produits, et donc à augmenter leur coefficient de durabilité. Mécaniquement, cette augmentation de l'indice "durée de commercialisation" se traduit par une baisse de cet indice pour les autres produits de la marques.&#x20;
* La marque doit être en capacité de démontrer que la durée moyenne de commercialisation, observée sur le canal de vente considéré et pour les 12 derniers mois, est au maximum égale à la valeur déclarée.

### Formule de calcul

L'indice "durée de commercialisation" prend les valeurs suivantes :&#x20;

* 0% lorsque la durée moyenne de commercialisation est de 60 jours ou moins
* 100% lorsque la durée moyenne de commercialisation est de 180 jours ou plus
* &#x20;Entre ces deux points, l'évolution de l'indice est linéaire (cf. schéma ci-après)

<figure><img src="../.gitbook/assets/image (1).png" alt=""><figcaption><p>Indice "durée de commercialisation" en fonction du nombre moyen de jours de commercialisation</p></figcaption></figure>

## Incitation à la réparation (1/2)

### Définition

**L'incitation à la réparation, pour sa première composante, s'appuie sur le rapport entre le coût moyen de réparation et un prix de vente de référence.** Ce paramètre est spécifique à chaque produit.

{% hint style="info" %}
Un lien est observé entre la propension qu'a un produit à être réparé et le rapport entre son prix de réparation et son prix neuf. S'il est aussi cher de réparer un produit que de le racheter, celui-ci a peu de chances d'être réparé.\
Etude Ademe 2022 sur le fonds réemploi-réutilisation et réparation de la filière TLC ([lien](https://librairie.ademe.fr/dechets-economie-circulaire/5323-fonds-reemploi-reutilisation-et-reparation-de-la-filiere-tlc.html)) : "_Les études sur les freins et leviers au recours à la réparation ont mis en évidence le frein financier du montant de la réparation. Le consommateur arbitre principalement entre le coût de réparation et le coût d’achat d’un produit neuf.”_"
{% endhint %}

Précisions :&#x20;

* Le prix de vente considéré est celui proposé sur le canal de vente de référence, tel que défini dans la section relative à l'indice "largeur de gamme".
* Le coût moyen de réparation considéré, pour chaque catégorie de produit, est précisé dans l'[explorateur Ecobalye](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/products). Il s'appuie sur l'étude Ademe 2022 sur le fonds réemploi-réutilisation et réparation de la filière TLC

| Catégorie de produit | Prix moyen de réparation |
| -------------------- | ------------------------ |
| Chemises             | 10€                      |
| Tshirts              | 10€                      |
| Pulls                | 15€                      |
| Vestes               | 31€                      |
| Pantalons            | 14€                      |
| Jupes                | 9€                       |
| Chaussettes          | 9€                       |
| Sous-vêtements       | 9€                       |
| Accessoires          | 9€                       |

### Formule de calcul

L'indice "incitation à la réparation", pour sa première composante, prend les valeurs suivantes :&#x20;

* 100% si le coût de réparation représente moins de 33% du prix neuf de référence
* 0% si le coût de réparation représente plus de 50% du prix neuf de référence
* Entre ces deux points, l'évolution de l'indice est linéaire

Application au cas du Tshirt, avec un coût moyen de réparation de 10€ :&#x20;

<figure><img src="../.gitbook/assets/image (3).png" alt=""><figcaption><p>Indice "incitation à la réparation" (partie 1/2) en fonction du prix de vente d'un Tshirt</p></figcaption></figure>

## Incitation à la réparation (2/2)

### Définition

Outre le rapport entre le coût de réparation et le prix neuf, la mise à disposition de services de réparation ou de garantie est de nature à augmenter la probabilité qu'un vêtement soit réparé.

Précisions :&#x20;

* Ce critère n'est pas considéré pour les vêtements dont les marques sont des PME et TPE. Il est en effet considéré qu'il est plus difficile pour une PME ou une TPE de proposer un tel service et, par conséquent, que la réparation des vêtements devrait prioritairement être assurée par des tiers.
* Les exigences minimales attendues d'un service de réparation ou de garantie sont à préciser.
* Le canal de vente considéré est celui introduit dans la définition de l'indice "largeur de gamme".

### Formule de calcul

Lorsqu'un vêtement est commercialisé par une marque qui n'est pas une PME ou une TPE, l'indice "incitation à la réparation" est composé :&#x20;

* à 66% de l'indice résultant de la partie 1/2, c'est à dire l'indice établi à partir du rapport entre le coût de réparation et le prix neuf
* à 33% à partir de la partie 2/2, c'est à dire la fourniture d'un service de réparation ou de garantie

Lorsqu'un vêtement est commercialisé par une marque qui est une PME ou une TPE, l'incide "incitation à la réparation" est compoés :&#x20;

* à 100% de l'indice résultant de la partie 1/2, c'est à dire l'indice établi à partir du rapport entre le coût de réparation et le prix neuf

La partie 2/2 prend les valeurs suivantes :&#x20;

* 0% si la marque ne propose pas de service de réparation ou de garantie respectant les exigeances minimales
* 100% si la marque propose un tel service

Formule résultante, lorsqu'un vêtement est commercialisé par une grande entreprise :&#x20;

$$
I_{incitationréparation} = 0,66 * I_{1/2} + 0,33 * I_{2/2}
$$

## Matières

### Définition

La durabilité d'un vêtement dépend de l'attachement qu'il suscite en moyenne et du soin qui lui est apporté en moyenne. Cet aspect est multifactoriel et complexe à appréhender. Les matières qui composent un vêtement peuvent, en première approche et en moyenne, influencer l'aptitude qu'un produit aura à durer en fonction de l'attachement qu'il suscite et du soin dont il bénéficie.&#x20;

{% hint style="info" %}
Extrait de la note de la FHCM, Pour une vision holistique de la durabilité : \
“_Aussi peut-on considérer que l’aptitude d’un produit à durer dans le temps est fonction des substances qui le composent, de la solidité qui le caractérise, des sensations qu’il provoque, de la signature qui le marque, ce que l’on peut caractériser comme les 4 S de la durabilité_”
{% endhint %}

L'indice "matières" est donc établi directement à partir de la composition du vêtement renseigné dans l'étape "matières" du calculateur Ecobalyse.

### Formule de calcul

Trois catégories sont distinguées :&#x20;

* les vêtements composés à plus de 90% de matières naturelles d'origine animale qui bénéficient d'un indice "matières" de 100%
* les vêtements composés à plus de 90% de matières naturelles qui bénéficient d'un indice "matières" de 50%
* les autres vêtements, composés donc d'au moins 10% de matières synthétiques ou artificielles, dont l'indice "matières" est à 0%

{% hint style="info" %}
La catégorie de chaque matière (encore appelée "origine") est mentionnée dans l'[explorateur Ecobalyse](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/materials).
{% endhint %}

## Affichage de la traçabilité

### Définition

L'affichage de la traçabilité, c'est à dire sa présentation au consommateur au moment de l'acte d'achat, est de nature à augmenter l'attachement du consommateur pour le vêtement, et donc sa durabilité. L'affichage de la traçabilité est susceptible de différer suivant les produits, parfois au sein d'une même marque.

Précisions :&#x20;

* Les étapes considérées sont, a minima, la confection, l'ennoblissement (ou la teinture) et le tissage / tricotage.
* Le décret n° 2022-748 du 29 avril 2022 relatif à l'information du consommateur sur les qualités et caractéristiques environnementales de produits générateurs de déchets impose d'ores et déjà qu'une information relative au pays dans lequel ces trois étapes sont réalisées soit mise à disposition. Il ne couvre toutefois pas toutes les entreprises et il n'impose pas que l'information en question soit directement visible, par exemple sur l'étiquette du produit ou encore sur le site de e-commerce de référence.
* Pour ce paramètres, différents canaux de vente sont considérés : le site internet de la marque et le principal distributeur en ligne, les différents distributeurs physiques à travers l'étiquette qui peut être apposée sur le vêtement.&#x20;

### Formule de calcul

Deux situations sont distinguées :&#x20;

* si le produit bénéficie d'un affichage de sa traçabilité dans les conditions mentionnées ci-dessus, l'indice "affichage de la traçabilité" est de 100%
* dans le cas contraire, il est de 0%.
