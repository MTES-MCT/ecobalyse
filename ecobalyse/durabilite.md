---
description: >-
  Présentation de l'intégration des coefficients de durabilité physique et
  non-physique dans la méthode de calcul.
hidden: true
---

# Durabilité

{% hint style="info" %}
Logique clé : Plus un meuble est durable, plus sa durée de vie estimée est élevé, plus faible est son impact.
{% endhint %}

<mark style="color:$warning;">Page a recalibrer pour retirer la partie transverse.</mark>&#x20;

## Quelles sont les dimensions de la durabilité ?

Deux principales dimensions sont généralement considérées pour apprécier la durabilité d'un produit :

* sa durabilité physique (capacité du produit à résister à l'usure physique liée à son utilisation),
* sa durabilité non physique (propension qu'aura le produit à être porté plus longtemps en fonction d'autres critères : réparabilité, attachement, etc.)

Prise dans ses différentes dimensions, la durabilité est dite "holistique".&#x20;

Ces différentes dimensions sont mises en avant dans différents travaux à l'échelle européenne :

> Parlement Européen - Résolution sur la stratégie textile durable (juin 2023) : "_Calls on the Commission and the Member States to ensure that the policy framework on textiles takes a holistic view of durability, including both the physical and the emotional durability of textile products put on the market, which describes the garment design that takes into account long-term relevance and desirability to consumers, as clothing represents a cultural value_"

> Secrétariat technique du PEFCR Apparel & Footwear (juin 2023) : "_\[Acknowledges] that product lifetime in Apparel & Footwear is subject to three influences:_
>
> _a.the intrinsic durability of the product_ \
> _b.the extrinsic durability and_\
> _c.the reparability of the product_"

## Calcul du coût environnemental&#x20;

Pour chaque meuble, deux coefficients de durabilité sont établis : &#x20;

* un coefficient de **durabilité physique**  $$C_{durabilitéPhysique}$$&#x20;
* un coefficient de **durabilité non-physique**  $$C_{durabilitéNonPhysique}$$&#x20;

Chacun de ses coefficient est compris entre **0.5** pour les produits les moins durables et **1.5** pour les produits les plus durables.

Le coût environnemental est établi comme suit :&#x20;

$$
CoûtEnvironnemental = \frac{Somme des Impacts}{C_{DurabilitéMin}}
$$

Avec :&#x20;

* &#x20;$$C_{DurabilitéMini}$$ : valeur minimale entre $$C_{durabilitéNonPhysique}$$ et $$C_{durabilitéPhysique}$$
* _SommedesImpacts_ : Somme des impacts du meuble considéré sur l'ensemble de son cycle de vie.
* CoûtEvironnemental : Le coût environnemental ainsi considéré revient à considérer une unité fonctionnelle "utilisation du meuble sur une durée de X jours", où X est la durée moyenne d'utilisation considérée pour la catégorie de meuble considérée (cf. nombre de jours d'utilisation spécifiés dans l'explorateur).

## Coefficient de durabilité physique $$C_{DurabilitéPhysique}$$&#x20;

Le coefficient de durabilité physique est établi à partir des critères définis dans le référentiel ["Meubles Meublants"](#user-content-fn-1)[^1] révisé en novembre 2023.&#x20;

Une distinction est faite entre les PME/TPE et les autres entreprises. Il est en effet considéré qu'il est plus difficile pour une PME ou une TPE de réaliser les tests/essais de durabilité physique sur l'ensemble de leurs produits en catalogue. Cette situation participant à créer un manque d'accessibilité du dispositif pour ces acteurs.&#x20;

{% hint style="info" %}
**Qu'est-ce qu'une PME ?**\
La définition considérée est la [définition réglementaire du décret n°2008-1353 du 18 décembre 2008](https://www.economie.gouv.fr/cedef/definition-petites-et-moyennes-entreprises) : une **PME** est une entreprise dont l’effectif est inférieur à 250 personnes et dont le chiffre d’affaires annuel n'excède pas 50 millions d'euros ou dont le total de bilan n'excède pas 43 millions d'euros.&#x20;
{% endhint %}

<table data-full-width="true"><thead><tr><th width="249">Catégorie</th><th width="199">Seuils proposés par le référentiel "Meubles Meublants"</th><th>Coefficients retenus</th></tr></thead><tbody><tr><td><ul><li>Rangement (en linéaire et en volume)</li><li>Rangement (armoire, caissons à usage professionnel)</li><li>Meubles de rangement salle de bain</li><li>Table de repas, table basse et table de bureau à usage domestique (intérieur)</li><li>Table de repas et table basse (extérieur)</li><li>Table de bureau (professionnel)</li><li>Chaise, siège, banc (intérieur)</li><li>Chaise, siège, banc (extérieur)</li><li>Siège opérateur (bureau)</li><li>Siège visiteur (bureau)</li></ul></td><td><p></p><p>10 ans (niveau 1)<br>15 ans (niveau 2)</p></td><td><p></p><ul><li><strong>x0,8</strong><br>Aucun test réalisé par une <a data-footnote-ref href="#user-content-fn-2">GE</a></li><li><strong>x1</strong><br>Aucun test réalisé par une PME/TPE <br>ou <br>Atteinte du Niveau 1 par une <a data-footnote-ref href="#user-content-fn-2">GE </a> </li><li><strong>x1,2</strong><br>Atteinte du Niveau 2</li></ul></td></tr><tr><td>Meubles de rangement cuisine</td><td>20 ans (niveau 1)<br>30 ans (niveau 2)</td><td><p></p><ul><li><strong>x0,8</strong><br>Aucun test réalisé par une <a data-footnote-ref href="#user-content-fn-2">GE</a></li><li><strong>x1</strong><br>Aucun test réalisé par une PME/TPE <br>ou <br>Atteinte du Niveau 1 par une <a data-footnote-ref href="#user-content-fn-2">GE </a> </li><li><strong>x1,2</strong><br>Atteinte du Niveau 2</li></ul></td></tr><tr><td>Façade de placard</td><td>10 ans (niveau 1)<br>15 ans (niveau 2)<br>20 ans (niveau 3)</td><td><ul><li><strong>x0,8</strong><br>Aucun test réalisé par une <a data-footnote-ref href="#user-content-fn-2">GE</a></li><li><strong>x1</strong><br>Aucun test réalisé par une PME/TPE <br>ou <br>Atteinte du Niveau 1 par une <a data-footnote-ref href="#user-content-fn-2">GE </a> </li><li><strong>x1,1</strong><br>Atteinte du Niveau 2</li><li><strong>x1,2</strong><br>Atteinte du Niveau 3</li></ul></td></tr><tr><td>Encadrement de lit</td><td>10 ans (niveau 1)<br>20 ans (niveau 2)</td><td><p></p><ul><li><strong>x0,8</strong><br>Aucun test réalisé par une <a data-footnote-ref href="#user-content-fn-2">GE</a></li><li><strong>x1</strong><br>Aucun test réalisé par une PME/TPE <br>ou <br>Atteinte du Niveau 1 par une <a data-footnote-ref href="#user-content-fn-2">GE </a> </li><li><strong>x1,2</strong></li></ul></td></tr></tbody></table>

## Coefficient de durabilité non-physique $$C_{DurabilitéNonPhysique}$$&#x20;

Le coefficient de durabilité est établi à partir de 4 critères avec les $$Poids_{critère}$$ comme suit :&#x20;

<table><thead><tr><th width="296">Critère</th><th>Poids_{critère}</th></tr></thead><tbody><tr><td>Incitation à la réparation</td><td>40%</td></tr><tr><td>Largeur de gamme</td><td>15%</td></tr><tr><td>Prix dérisoire</td><td>15%</td></tr><tr><td>Intensité des promotions</td><td>15%</td></tr><tr><td>Traçabilité affichée</td><td>15%</td></tr></tbody></table>

{% hint style="info" %}
Chacun des 4 critères, pris indépendamment, ne suffit pas à qualifier la durabilité non physique d'un meuble et peut présenter des effets de bord. En revanche, la prise en compte des 4 critères ensemble permet de qualifier un positionnement marque/produit avec une incidence sur le nombre d'utilisation des meubles, donc leur durabilité.
{% endhint %}

### Critère : Intensité des promotions

#### **Définition**

**L'intensité des promotions caractérise la fréquence et l'intensité des promotions proposées par une marque tout au long de l'année**.

Précisions :&#x20;

* Le canal de vente sur lequel est évalué ce critère est celui de référence, tel que défini dans la section relative à l'indice "largeur de gamme".
* Si un&#x20;

#### Formule de calcul

L

### Critère : Largeur de gamme

#### **Définition**

**La largeur de gamme désigne le nombre maximal de références proposées par une marque sur le segment de marché de la référence de produits considérée**.

Précisions :&#x20;

* **Le canal de vente considéré est le site internet de la marque**. En l'absence de vente en ligne sur le site de la marque (ou si le site est un canal de vente artificiel), un canal de vente doit être choisi parmi les principaux.
* Par exception, dans le cas d'une **marque qui serait distribuée via une plateforme**, de sorte que les consommateurs identifient plus la plateforme que la marque, c'est le nombre total de références proposées du segment sur la plateforme qui doit être considéré.
* Lorsqu'une marque est proposée au sein d'un **site internet multi-marques**, mais qu'elle y est bien identifiée et que l'essentiel des autres produits proposés sur ce site internet sont également proposés sur le site internet de leur marque propre, c'est alors le nombre de référence de chaque marque qui est considéré.
* Les **12 segments de marché** considérés sont ceux définis par la filière REP des éléments d'ameublement. L'introduction de ces 12 segments de marché vise à éviter un effet de distorsion qui pénaliserait une marque couvrant l'ensemble des segments de marché par rapport à une autre marque qui ne couvrirait par exemple que la literie. &#x20;

| Segments de marché                            |
| --------------------------------------------- |
| Mobilier de salon, séjour, salle à manger     |
| Mobilier d'appoint                            |
| Mobilier de chambre                           |
| Literie (dont matelas)                        |
| Mobilier de bureau                            |
| Mobilier de cuisine                           |
| Mobilier de salle de bain                     |
| Mobilier de jardin                            |
| Sièges                                        |
| Mobilier technique, commercial, collectivités |
| Rembourrés d'assise et de couchage            |
| Décoration textile                            |

* Par "référence", on entend généralement une suite de lettres ou de chiffres figurant sur la page produit, et correspondant à une couleur donnée d’un produit donné. Ce terme peut correspondre à la notion d'unité de gestion de stock (UGC ou SKU pour Stock Keeping Unit) ou encore de **référence couleur**.&#x20;
* **Une référence peut être déclinée en plusieurs tailles**. On compte alors bien une seule référence pour l'ensemble des tailles proposées.
* **Seules les références correspondant à des éléments d'ameublement doivent être comptabilisées**. Les textiles ou produits alimentaires, par exemple, ne doivent pas être comptabilisés. Les références correspondant à des **éléments d'ameublement** mais qui pourraient ne pas être couvertes par le cadre réglementaire (ex : un meuble constitué de matériaux non disponibles dans la base de données officielle -_Base Empreinte_-) doivent bien être comptabilisées.
* Le nombre de références à renseigner doit être le **nombre maximum de références commercialisées un même jour sur l'ensemble de l'année civile**. Ainsi, en cas de contrôle à une date donnée, il doit toujours être observé un nombre de références commercialisées inférieur à la valeur renseignée pour calculer l'indice "largeur de gamme". Il n'est pas attendu de la marque qu'elle déclare le nombre exact de références, lequel n'est connu qu'à la fin de l'année. Elles proposent un nombre en s'engageant à ne pas commercialiser simultanément plus de références. Si une marque n'est pas en capacité d'anticiper précisément le nombre de références qu'elle pourrait  commercialiser sur l'année, elle doit donc considérer une marge qu'il lui revient de choisir.&#x20;

#### Formule de calcul

L'indice "largeur de gamme" prend les valeurs suivantes :&#x20;

* 100% lorsque le nombre de références est inférieur à 50
* 0% lorsque le nombre de références est supérieur à 500
* Entre ces différents points, l'évolution de l'indice est linéaire (cf. schéma ci-après)

### Critère : Incitation à la réparation

#### **Définition**

L'incitation à la réparation est constitué de 2 paramètres iso-pondérés (50/50) :&#x20;

1. le rapport entre le coût moyen de réparation et un prix de vente de référence,
2. autres incitations.&#x20;

#### **Sous-critère 1 = Coût moyen de réparation / prix de vente de référence**

* Le prix de vente considéré est celui proposé sur le canal de vente de référence, tel que défini dans la section relative à l'indice "largeur de gamme".
* Le coût moyen de réparation considéré, pour chaque catégorie de produit, est précisé dans l'[explorateur Ecobalyse](https://ecobalyse-v2.osc-fr1.scalingo.io/#/explore/textile/products). Il s'appuie sur <mark style="color:orange;">\[xxx]</mark>.&#x20;

{% hint style="info" %}
Un lien est observé entre la propension qu'a un produit à être réparé et le rapport entre son prix de réparation et son prix neuf. S'il est aussi cher de réparer un produit que de le racheter, celui-ci a peu de chances d'être réparé.

Etude 1 = [Etude Ademe 2022 sur le fonds réemploi-réutilisation et réparation de la filière TLC](https://librairie.ademe.fr/economie-circulaire-et-dechets/5323-fonds-reemploi-reutilisation-et-reparation-de-la-filiere-tlc.html)  : "_Les études sur les freins et leviers au recours à la réparation ont mis en évidence le frein financier du montant de la réparation. Le consommateur arbitre principalement entre le coût de réparation et le coût d’achat d’un produit neuf.”_"

Etude 2 = [Etude Ecomaison 2024 sur la réparation de meubles](https://ecomaison.com/la-reparation-de-meubles-un-besoin-en-hausse-chez-les-consommateurs-une-solution-a-proposer/) : "La moitié des personnes interrogée se dit prête à payer jusqu’à 20 % du prix initial de leur meuble pour sa réparation."
{% endhint %}

<table><thead><tr><th width="430">Segments de marché</th><th>Prix moyen de réparation (€)</th></tr></thead><tbody><tr><td>Mobilier de salon, séjour, salle à manger</td><td></td></tr><tr><td>Mobilier d'appoint</td><td></td></tr><tr><td>Mobilier de chambre</td><td></td></tr><tr><td>Literie (dont matelas)</td><td></td></tr><tr><td>Mobilier de bureau</td><td></td></tr><tr><td>Mobilier de cuisine</td><td></td></tr><tr><td>Mobilier de salle de bain</td><td></td></tr><tr><td>Mobilier de jardin</td><td></td></tr><tr><td>Sièges</td><td></td></tr><tr><td>Mobilier technique, commercial, collectivités</td><td></td></tr><tr><td>Rembourrés d'assise et de couchage</td><td></td></tr><tr><td>Décoration textile</td><td></td></tr></tbody></table>

Ce sous-critère prend les valeurs suivantes :&#x20;

* 100% si le coût de réparation représente moins de 33% du prix neuf de référence
* 0% si le coût de réparation représente plus de 100% du prix neuf de référence
* Entre ces deux points, l'évolution de l'indice est linéaire

Application au cas d'une chaise de salon, avec un coût moyen de réparation de <mark style="color:orange;">xx</mark>€ :&#x20;

<mark style="color:orange;">\[illustration à intégrer]</mark>



#### **Sous-critère 2 = Autres incitations**&#x20;

Pour bénéficier de ce critère, les modes de preuves suivants sont acceptés :&#x20;

* pièces détachées proposées par le metteur en marché,\
  ou
* notice d'explication (ou autre document équivalant) indiquant au consommateur comment effectuer des réparations simples,\
  ou
* information au consommateur pour l'orienter vers des services de réparation,\
  ou
* offre de réparation proposée par le metteur sur le marché.

### Critère : Prix dérisoire

#### **Définition**

**\[xxx]**

Précisions :&#x20;

[^1]: Emilie Bossanne (FCBA), Arnaud Mankou (FCBA) 2022. \
    Principes généraux pour l’affichage environnemental - Partie 4 : Référentiel méthodologique d’évaluation environnementale de meubles meublants. 92 pages.

[^2]: Grande Entreprise
