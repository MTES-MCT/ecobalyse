---
hidden: true
---

# 🔴 Durabilité

{% hint style="warning" %}
Mise à jour importante de cette page le 14/07/2025 pour intégrer les derniers ajustements sur les définitions, notamment pour la largeur de gamme, suite à la phase de consolidation qui a suivi le webinaire du mois de mai 2025. Les derniers modifications apportées sont \*_en italique pour les ajouts_\* et \*~~barré pour les suppressions~~\*.
{% endhint %}

{% hint style="info" %}
<mark style="color:blue;background-color:green;">**Plus un vêtement est porté, plus son impact est faible**</mark>
{% endhint %}

La prise en compte de la durabilité doit permettre d'introduire une estimation du nombre de portées de chaque vêtement dans la modélisation du coût environnemental.

## Contexte

### Quelles sont les dimensions de la durabilité ?&#x20;

Deux principales dimensions sont généralement considérées pour apprécier la durabilité d'un vêtement :&#x20;

* sa durabilité physique (capacité du vêtement à résister à l'usure physique liée à son utilisation et son entretien)
* sa durabilité non physique (propension qu'aura le vêtement à être porté plus longtemps en fonction d'autres critères : réparabilité, attachement...)

Ces deux dimensions sont mises en avant dans différents travaux et notamment à l'échelle européenne avec le PEFCR A\&F:

> PEFCR APPAREL & FOTTWEAR
>
> "Product lifetime is estimated by assessing:
>
> i. The intrinsic durability of a product – product-specific attributes that contribute> \
> to its potential lifetime (e.g. physical toughness and design features);
>
> ii. Extrinsic durability attributes - external factors that influence the likelihood of a> \
> product reaching its potential lifetime;
>
> iii. The repairability potential of the product."

&#x20;Dans un premier temps, seule la durabilité non physique est considérée dans le cadre du mode réglementaire.

{% hint style="info" %}
**Travaux sur la durabilité physique**\
Les travaux sur la durabilité physique sont inclus dans le  [PEFCR Apparel & Footwear](https://pefapparelandfootwear.eu/wp-content/uploads/2025/05/AFW_PEFCR_v3.1_final.zip) qui s'appuie notamment sur les résultats du projet [Durhabi](https://www.ifth.org/services/durhabi/) piloté par l'[IFTH](https://www.ifth.org/) et qui a associé de nombreux acteurs français.\
Afin de préparer l'intégration future de la durabilité physique dans le mode réglementaire, celle-ci est intégrée, par anticipation, dans le mode exploratoire d'Ecobalyse. Elle est proposé à partir d'un sélecteur de valeur du coefficient qui peut aller de 0,67 à 1,45, soit la plage de valeurs prévue pour l'IQM (Intrinsic Quality Multiplier) dans le PEFCR Apparel & Footwear.&#x20;

\
Pour combiner les deux dimension de la durabilité, la formule suivante est considérée en première approche :\
**Durabilité\_Holistique = min (Durabilité\_Physique ; Durabilité\_NonPhysique)**\
\
Cette formule traduit l'idée qu'un vêtement arrive en fin de vie, soit pour une cause d'usure physique soit pour une cause non physique. C'est donc bien la dimension la plus limitante qui définirait la durée moyenne d'utilisation modélisée.\
&#xNAN;_&#x43;ette proposition est une simple base de travail qui appelle des échanges au sein de groupe de travail qui doit être mis en place._
{% endhint %}

## Méthode de calcul&#x20;

### Calcul du coût environnemental

Pour chaque vêtement, un **coefficient de durabilité** $$C_{Durabilité}$$ est établi. Sa valeur est comprise entre **0.67** pour les produits les moins durables et **1.45** pour les produits les plus durables.

Le coût environnemental est établi comme suit :&#x20;

$$
CoûtEnvironnemental = \frac{Somme des Impacts}{C_{Durabilité}}
$$

Avec :&#x20;

* $$SommedesImpacts$$ : Somme des impacts du vêtement considéré sur l'ensemble de son cycle de vie. Pour la phase d'utilisation, on considère un nombre de portés et un nombre de cycles d'utilisation proportionnels au coefficient de durabilité. Plus un vêtement est durable, plus il est porté, plus il est entretenu, plus la somme des impacts qu'il génère est importante (sur une durée d'utilisation plus longue).
* $$Coût environnemental$$ : Le coût environnemental ainsi considéré revient à considérer une unité fonctionnelle "utilisation du vêtement sur une durée de X jours", où X est la durée moyenne d'utilisation considérée pour la catégorie de vêtement considérée (cf. nombre de portés et d'utilisation avant lavage spécifiés dans l'[explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products), en s'appuyant sur les données du PEFCR Apparel & Footwear lorsqu'elles sont disponibles).

Exemple :&#x20;

* Si $$C_{Durabilité} = Coef_{min}=0.67$$, le coût environnemental est augmenté.&#x20;
* Si $$C_{Durabilité} = Coef_{max}=1.45$$, le coût environnemental est diminué.&#x20;

### Calcul du coefficient de durabilité $$C_{Durabilité}$$

Le coefficient de durabilité est établi à partir de 2 critères avec les $$Poids_{critère}$$ comme suit :&#x20;

<table><thead><tr><th width="374">Critère</th><th>Poids_{critère}</th></tr></thead><tbody><tr><td>Incitation à la réparation</td><td>50%</td></tr><tr><td>Largeur de gamme</td><td>50%</td></tr></tbody></table>

{% hint style="info" %}
Chacun des 2 critères, pris indépendamment, ne suffit pas à qualifier la durabilité non physique d'un vêtement et peut présenter des effets de bord. En revanche, la prise en compte des 2 critères ensemble permet de qualifier un positionnement marque/produit avec une incidence sur le nombre d'utilisation des vêtements, donc leur durabilité.
{% endhint %}

Chacune des 2 composantes s'exprime à travers un indice (I) compris entre 0 et 1 et pouvant donc être exprimé en pourcentage (%). En intégrant les pondérations mentionnées ci-dessus, et les valeurs minimale (Coefmin) et maximale (Coefmax) du coefficient de durabilité $$C_{durabilité}$$ , la formule permettant de l'établir est :&#x20;

$$
C_{Durabilité} = Coef_{min} + (Coef_{max}-Coef_{min})*\sum_{critère}^{} Poids_{critère}*I_{critère}
$$

Ou aussi&#x20;

$$C_{Durabilité} = 0.67 + (1,45-0,67)*( 0.5*I_{incitation réparation} +  0.5*I_{largeur de gamme} )$$

### <mark style="color:red;">Largeur de gamme</mark>

#### Définition

**La largeur de gamme désigne le nombre maximal de références \***_**de produits neufs y compris remanufacturés\***_**&#x20;proposées par une marque sur le segment de marché de la référence de produits considérée**.

Précisions :&#x20;

* **Le canal de vente considéré est le site internet de la marque**. En l'absence de vente en ligne sur le site de la marque \*~~(ou si le site est un canal de vente artificiel)~~\*, un canal de vente doit être choisi parmi les principaux.
* Par exception, dans le cas d'une **marque qui serait principalement distribuée via une plateforme \***_**en ligne, sa largeur de gamme est fixée à la valeur par défaut de 100 000 références** (cf._ [_paramétrage_](https://fabrique-numerique.gitbook.io/ecobalyse/textile/parametrage)_)_\* \*~~, de sorte que les consommateurs identifient plus la plateforme que la marque, c'est le nombre total de références proposées du segment sur la plateforme qui doit être considéré~~\*. \*_Une marque est considérée comme étant principalement distribuée via une plateforme en ligne dès lors que cette dernière constitue son canal de vente principal, c’est-à-dire le canal via lequel la marque effectue la majorité de ses ventes_\*.
*   \*_Si une **marque commercialisée sur un site multi-marques** s’est acquittée elle-même de ses obligations en matière de responsabilité élargie du producteur et dispose à ce titre d’un identifiant unique et si elle n’est pas vendue à titre principal sur ce site, c’est le nombre de références de la marque sur son site internet propre et non celui du site multi-marques qui est comptabilisé._

    _Si cette marque ne dispose pas d’identifiant unique, sa largeur de gamme est fixée à la valeur par défaut de 100 000 références (cf._ [_paramétrage_](https://fabrique-numerique.gitbook.io/ecobalyse/textile/parametrage)_)_\*\*~~Lorsqu'une marque est proposée au sein d'un **site internet multi-marques**, mais qu'elle y est bien identifiée et que l'essentiel des autres produits proposés sur ce site internet sont également proposés sur le site internet de leur marque propre, c'est alors le nombre de référence de chaque marque qui est considéré~~\*.
* Les **5 segments de marché** considérés sont : femme, homme, enfant, bébé, sous-vêtements. L'introduction de ces 5 segments de marché vise à éviter un effet de distorsion qui pénaliserait une marque couvrant l'ensemble des segments de marché par rapport à une autre marque qui ne couvrirait \*_qu'un ou plusieurs segments_\*par exemple que le prêt à porter femme. A l'intérieur de ces segments de marché, ne sont pas considérés les références qui ne s'adresseraient qu'à un sous-ensemble spécifique des clients potentiels. Il s'agit par exemple des références spécifiques aux grandes tailles, aux femmes enceintes, aux personnes en situation de handicap, ... L'objectif est d'approximer le choix proposé à chaque consommateur : homme, femme, enfant ou bébé.&#x20;

#### Exemples de produits ayant fait l'objet de demandes de précision [sur le forum Ecobalyse](https://fabrique-numerique.gitbook.io/ecobalyse/communaute) :&#x20;

| A comptabiliser                                                                                                                                    | A ne pas comptabiliser                                                                                                                                                                                                                                                                                                                                                   |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <ul><li>Chemises en soie (non couvert par le cadre réglementaire en l'absence de données pour la soie)</li><li>*<em>Soutien gorges</em>*</li></ul> | <ul><li>Accessoires non majoritairement textiles : casquettes, chapeaux, serre-têtes, lanières</li><li>Autres accessoires : gants, bonnets, écharpes</li><li>Vêtements pour animaux</li><li><em>*les références qui ne s'adresseraient qu'à un sous-ensemble spécifique des clients potentiels (femmes enceintes, personnes handicapées, grande taille…)*</em></li></ul> |

{% hint style="info" %}
Exemple : Le site C.fr commercialise la marque A (2000 références), la marque B (3000 références) et la marque C (4000 références). La marque A et la marque B disposent par ailleurs de leur site internet propre. La marque A propose 2500 références sur A.fr. La marque B propose 3500 références sur B.fr.\
Les largeurs de gamme à considérer sont alors (cf. tableau ci-dessous) :\
\- 2500 références pour la marque A\
\- 3500 références pour la marque B\
\- 4000 références pour la marque C
{% endhint %}

|               | Marque A  | Marque B  | Marque C      | Total         |
| ------------- | --------- | --------- | ------------- | ------------- |
| **Site A.fr** | 2500 réf. |           |               | **2500 réf.** |
| **Site B.fr** |           | 3500 réf. |               | **3500 réf.** |
| **Site C.fr** | 2000 réf. | 3000 réf. | **4000 réf.** | 9000 réf.     |

* Par "référence", on entend généralement une suite de lettres ou de chiffres figurant sur la page produit, et correspondant à une couleur donnée d’un produit donné. Ce terme peut correspondre à la notion d'unité de gestion de stock (UGC ou SKU pour Stock Keeping Unit) ou encore de **référence couleur**.&#x20;
* **Une référence peut être déclinée en plusieurs tailles**. On compte alors bien une seule référence pour l'ensemble des tailles proposées. Certaines références peuvent concerner spécifiquement certaines tailles. C'est par exemple le cas pour les grandes tailles. Sur l'illustration ci-après, chaque ligne correspond à une référence, indépendamment de la gamme de tailles couvertes.

|              | XS à XL | XXL à XXXXL |
| ------------ | ------- | ----------- |
| Référence #1 | Oui     | Oui         |
| Référence #2 | Oui     | Non         |
| Référence #3 | Non     | Oui         |

* **Seules les références correspondant à du textile d'habillement doivent être comptabilisées**. Les chaussures ou les sacs, par exemple, ne doivent pas être comptabilisés. Les références correspondant à du **textile d'habillement** mais qui pourraient ne pas être couvertes par le cadre réglementaire (ex : un pull en cachemire) doivent bien être comptabilisées.
* Le nombre de références à renseigner doit être le **nombre maximum de références commercialisées un même jour sur l'ensemble de l'année civile**. Ainsi, en cas de contrôle à une date donnée, il doit toujours être observé un nombre de références commercialisées inférieur à la valeur renseignée pour calculer l'indice "largeur de gamme". Il n'est pas attendu de la marque qu'elle déclare le nombre exact de références, lequel n'est connu qu'à la fin de l'année. Elles proposent un nombre en s'engageant à ne pas commercialiser simultanément plus de références. Si une marque n'est pas en capacité d'anticiper précisément le nombre de références qu'elle pourrait  commercialiser sur l'année, elle doit donc considérer une marge qu'il lui revient de choisir. Deux illustrations sont proposées ci-après.

<figure><img src="../.gitbook/assets/image (312).png" alt=""><figcaption></figcaption></figure>

<figure><img src="../.gitbook/assets/image (313).png" alt=""><figcaption></figcaption></figure>

#### Formule de calcul

L'indice "largeur de gamme" prend les valeurs suivantes :&#x20;

* 100% lorsque le nombre de références est inférieur à 1 000
* 50% pour 7 000 références
* 0% lorsque le nombre de références est supérieur à 16 000
* Entre ces différents points, l'évolution de l'indice est linéaire (cf. schéma ci-après)



<figure><img src="../.gitbook/assets/image (18).png" alt=""><figcaption></figcaption></figure>

### <mark style="color:red;">Incitation à la réparation</mark>

#### Incitation à la réparation (1/2)

#### Définition

**L'incitation à la réparation, pour sa première composante, s'appuie sur le rapport entre le coût moyen de réparation et un prix de vente de référence.** Ce paramètre est spécifique à chaque produit.

{% hint style="info" %}
Un lien est observé entre la propension qu'a un produit à être réparé et le rapport entre son prix de réparation et son prix neuf. S'il est aussi cher de réparer un produit que de le racheter, celui-ci a peu de chances d'être réparé.\
[Etude Ademe 2022 sur le fonds réemploi-réutilisation et réparation de la filière TLC](https://librairie.ademe.fr/economie-circulaire-et-dechets/5323-fonds-reemploi-reutilisation-et-reparation-de-la-filiere-tlc.html)  : "_Les études sur les freins et leviers au recours à la réparation ont mis en évidence le frein financier du montant de la réparation. Le consommateur arbitre principalement entre le coût de réparation et le coût d’achat d’un produit neuf.”_"
{% endhint %}

Précisions :&#x20;

* Le prix de vente considéré est celui proposé sur le canal de vente de référence, tel que défini dans la section relative à l'indice "largeur de gamme".
* Le coût moyen de réparation considéré, pour chaque catégorie de produit, est précisé dans l'[explorateur Ecobalyse](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/products). Il s'appuie sur l'[Etude Ademe 2022 sur le fonds réemploi-réutilisation et réparation de la filière TLC](https://librairie.ademe.fr/economie-circulaire-et-dechets/5323-fonds-reemploi-reutilisation-et-reparation-de-la-filiere-tlc.html).

{% hint style="info" %}
Des précisions seront prochainement apportées sur la définition du prix de vente à considérer. \
\*_Les seuils ont été définis par rapport à la perception du consommateur. Ils se rapportent donc à un prix de vente TTC. En revanche, pour des besoins opérationnels de contrôle, la prise en compte du prix HT pourrait être justifiée, à l'instar des modalités de calcul de l'indice de réparabilité ou de durabilité (cf._ [_Notice - § relatif au calcul du ratio pour le critère prix_](https://www.ecologie.gouv.fr/sites/default/files/documents/Notice_indice_reparabilite_FR_V3.0.pdf)_). Si une telle option se confirme, les seuils seront ajustés pour ne pas impacter les résultats de modélisation._\*&#x20;
{% endhint %}

| Catégorie de produit | Prix moyen de réparation |
| -------------------- | ------------------------ |
| Chemises             | 10€                      |
| T-shirts             | 10€                      |
| Pulls                | 15€                      |
| Vestes               | 31€                      |
| Pantalons            | 14€                      |
| Jupes                | 19€                      |
| Chaussettes          | 9€                       |
| Sous-vêtements       | 9€                       |
| Accessoires          | 9€                       |

#### Formule de calcul

L'indice "incitation à la réparation", pour sa première composante, prend les valeurs suivantes :&#x20;

* 100% si le coût de réparation représente moins de 33% du prix neuf de référence
* 0% si le coût de réparation représente plus de 100% du prix neuf de référence
* Entre ces deux points, l'évolution de l'indice est linéaire

Application au cas du T-shirt, avec un coût moyen de réparation de 10€ :&#x20;

<figure><img src="../.gitbook/assets/image (9) (1).png" alt=""><figcaption><p>Indice "incitation à la réparation" (partie 1/2) en fonction du prix de vente d'un Tshirt</p></figcaption></figure>

#### Incitation à la réparation (2/2)

#### Définition

* Ce critère n'est pas considéré pour les \*_références de produits neufs, y compris remanufacturés,_\* dont les marques sont des PME et TPE.&#x20;
* \*_Le critère « service de réparation » est considéré comme rempli dès lors qu’une marque propose un service de réparation, au moins pour ses produits, labellisé par un éco-organisme de la filière à responsabilité élargie des producteurs de textile, linge, chaussure (TLC)._\*
* Le canal de vente considéré est celui introduit dans la définition de l'indice "largeur de gamme".

Précisions :&#x20;

Outre le rapport entre le coût de réparation et le prix neuf, la mise à disposition d'un service de réparation est de nature à augmenter la probabilité qu'un vêtement soit réparé.

#### Formule de calcul

{% hint style="info" %}
**Qu'est-ce qu'une PME ?**\
La définition considérée est la [définition réglementaire du décret n°2008-1353 du 18 décembre 2008](https://www.economie.gouv.fr/cedef/definition-petites-et-moyennes-entreprises) : une **PME** est une entreprise dont l’effectif est inférieur à 250 personnes et dont le chiffre d’affaires annuel n'excède pas 50 millions d'euros ou dont le total de bilan n'excède pas 43 millions d'euros.&#x20;
{% endhint %}

Lorsqu'un vêtement est commercialisé par une marque qui n'est pas une PME ou une TPE, l'indice "incitation à la réparation" est composé :&#x20;

* à 66% de l'indice résultant de la partie 1/2, c'est à dire l'indice établi à partir du rapport entre le coût de réparation et le prix neuf
* à 33% à partir de la partie 2/2, c'est à dire la fourniture d'un service de réparation ou de garantie

Lorsqu'un vêtement est commercialisé par une marque qui est une PME ou une TPE, l'indice "incitation à la réparation" est composé :&#x20;

* à 100% de l'indice résultant de la partie 1/2, c'est à dire l'indice établi à partir du rapport entre le coût de réparation et le prix neuf

La partie 2/2 prend les valeurs suivantes :&#x20;

* 0% si la marque ne propose pas de service de réparation ou de garantie respectant les exigences minimales
* 100% si la marque dispose d’au moins un service de réparation en propre, labellisé par l’éco-organisme de la filière TLC dans le cadre du bonus réparation.

Formule résultante, lorsqu'un vêtement est commercialisé par une grande entreprise :&#x20;

$$
I_{incitationréparation} = 0,66 * I_{1/2} + 0,33 * I_{2/2}
$$

