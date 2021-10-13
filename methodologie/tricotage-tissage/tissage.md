# Tissage



## Schéma

Conformément à la documentation sectorielle textile de la [base Impacts](http://www.base-impacts.ademe.fr), le système "tissage" est schématisé comme suit :

![](../../.gitbook/assets/Tissage.PNG)

Par conséquent, l'impact global du trissage se comprend comme résultant de la somme de l'impact résultant du procédé de tissage retenu (cf. intérieur du _system boundaries_) et des procédés externes devant être ajoutés, à savoir :

| Flux externe                                                                         | UUID du flux                         | unité          |
| ------------------------------------------------------------------------------------ | ------------------------------------ | -------------- |
| <p>Electricité par duite par mètre</p><p><em>Electricity per pick per meter</em></p> | 9ea449e4-38fc-4133-b2d9-7942719c8675 | kWh / (pick,m) |

{% hint style="danger" %}
Attention, le flux externe d'électricité considéré pour le tissage est différent de celui appelé pour les autres étapes de production. Il s'exprime en kWh par duite et par mètre.
{% endhint %}

La formule suivante s'applique donc :

$$
ImpactTissage = ImpactProcédéTissage + ImpactElecParPM
$$

## Procédé de tissage

L'impact du procédé de tissage retenu est le produit de la masse "entrante", en l'occurrence la masse de fil en sortie de filature, avec le coefficient d'impact considéré (cf. [Impacts considérés](../impacts-consideres.md)).

$$
ImpactProcédéTissage = MasseEntrante(kg) * CoefImpactProcédéTissage
$$

{% hint style="warning" %}
Remarque : pour les procédés de tissage retenus (cf. ci-après), les coefficients d'impact sont tous nuls, de sorte que l'impact de l'étape de tissage se limite finalement à l'impact de l'électricité nécessaire (par duite et par mètre) pour opérer ce processus.
{% endhint %}

Un seul procédé de tissage est considéré :

| Procédé               | UUID                                 |
| --------------------- | ------------------------------------ |
| Tissage (habillement) | f9686809-f55e-4b96-b1f0-3298959de7d0 |

{% hint style="info" %}
D'autres procédés de tissage sont proposés dans la base impacts et pourraient, au besoin, être proposés en option ultérieurement.
{% endhint %}

| Procédés de tricotage alternatifs (non mobilisés)           |
| ----------------------------------------------------------- |
| Tissage (ameublement)                                       |
| Production d'un non-tissé aiguilleté, inventaire désagrégé  |
| Non tissé                                                   |

## Pertes et rebus

Le procédé de tissage considéré prévoit qu'une partie du fil mobilisé soit perdu, comme cela est représenté sur le schéma "system boundaries" ci-dessus (Flux intermédiaire - Textile Waste - UUID: `1cc67763-7318-4077-af4a-bcd0ab5ef33f`).

Ces pertes sont prises en compte comme suit :

$$
MasseEtoffeSortante(kg) = MasseFilEntrant(kg) + MassePertes(kg)
$$

Avec :

$$
MassePertes(kg) = MasseEtoffeSortante(kg) * CoefPertesProcedeTissage
$$

Plus de détail sur la gestion des masses : [Pertes et rebus](../pertes-et-rebus.md).

## Electricité (par duite et par mètre)

La quantité d'électricité à mobiliser pour actionner le procédé de tissage est le produit de **l'unité de tissage** avec le coefficient du flux intermédiaire correspondant à l'électricité (9ea449e4-38fc-4133-b2d9-7942719c8675).

$$
ElecConsommée(kWh) = UnitéTissage(duite.m) * CoefFluxElecProcédéTissage(kWh/(duite.m))
$$

Le calcul nécessite donc que soit préalablement établie l'unité de tissage. Celle-ci est définie dans la documentation sectorielle de l'ADEME (Méthodologie d'évaluation des impacts environnementaux des articles d'habillement - formule n°3 - p29)

$$
UnitéTissage(duite.m) = Duitage(duite/m) / Grammage(g/m2) * MasseEntrante (g)
$$

Toujours en application de la documentation sectorielle ADEME (tableau p28), des valeurs par défaut sont utilisées pour le duitage et le grammage.

| Type de vêtement | Duitage par défaut (duite/m) | Grammage par défaut (g/m2) |
| ---------------- | ---------------------------- | -------------------------- |
| Châle            | 1600                         | 140                        |
| Echarpe          | 1600                         | 140                        |
| Débardeur        | N/A tricotage                | N/A tricotage              |
| T-shirt          | N/A tricotage                | N/A tricotage              |
| Gilet            | N/A tricotage                | N/A tricotage              |
| Jupe             | 5000                         | 40                         |
| Pantalon         | 3000                         | 140                        |
| Pull             | N/A tricotage                | N/A tricotage              |
| Chemisier        | 5000                         | 40                         |
| Manteau          | 1600                         | 140                        |
| Veste            | 3000                         | 140                        |
| Cape             | 1600                         | 140                        |
| Robe             | 5000                         | 40                         |
| Jean             | 3000                         | 140                        |

{% hint style="danger" %}
Les vêtements doublés ne sont pas pris en compte à ce stade. Les valeurs par défaut des duitages et grammages sont différentes dans la méthodologie pour les vêtements doublés.
{% endhint %}

Le calcul d'impact de l'électricité ainsi mobilisée est détaillé dans la page suivante : [Electricité](../electricite.md).

{% hint style="danger" %}
L'électricité s'exprime en KWh dans la formule ci-dessous. Contrairement aux autres procédés, il n'est pas nécessaire de faire une conversion de MJ à kWh dans ce cas.
{% endhint %}

$$
ImpactElec = ElecConsommée (KWh) * ImpactProcédéElec
$$

## Limites

* Prendre en compte des vêtements doublés, avec des valeurs par défaut (duitage, grammage) différentes.
* Permettre de modifier les paramètres de l'unité de tissage (duitage, grammage) qui semblent très impactants.
