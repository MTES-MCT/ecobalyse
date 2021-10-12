# Tricotage

## Schéma

Conformément à la documentation sectorielle textile de la [base Impacts](http://www.base-impacts.ademe.fr), le système "tricotage" est schématisé comme suit :

![](<../../.gitbook/assets/Tricotage (1).PNG>)



Par conséquent, l'impact global du tricotage se comprend comme résultant de la somme de l'impact résultant du procédé de tricotage retenu (cf. intérieur du _system boundaries_) et des procédés externes devant être ajoutés, à savoir :

| Flux externe | UUID du flux                           | unité |
| ------------ | -------------------------------------- | ----- |
| Electricité  | `de442ef0-d725-4c3a-a5e2-b29f51a1186c` | MJ    |

La formule suivante s'applique donc :

$$
ImpactTricotage = ImpactProcédéTricotage + ImpactElec
$$

## Procédé de tricotage

L'impact du procédé de tricotage retenu est le produit de la masse "entrante", en l'occurrence la masse de fil en sortie de filature, avec le coefficient d'impact considéré (cf. [Impacts considérés](../impacts-consideres.md)).

$$
ImpactProcédéTricotage = MasseEntrante(kg) * CoefImpactProcédéTricotage
$$

{% hint style="warning" %}
Remarque : pour les procédés de tricotage retenus (cf. ci-après), les coefficients d'impact sont tous nuls, de sorte que l'impact de l'étape de tricotage se limite finalement à l'impact de l'électricité nécessaire pour opérer ce processus.
{% endhint %}

Un seul procédé de tricotage est considéré :

| Procédé   | UUID                                 |
| --------- | ------------------------------------ |
| Tricotage | 9c478d79-ff6b-45e1-9396-c3bd897faa1d |

{% hint style="info" %}
D'autres procédés de tricotage sont proposé dans la base impacts et pourraient, au besoin, être proposés en option ultérieurement.
{% endhint %}

| Procédés de tricotage alternatifs (non mobilisés)                 |
| ----------------------------------------------------------------- |
|  Tricotage, mailles jetées (indémaillable), inventaire désagrégé  |
|  Tricotage sans couture, inventaire désagrégé                     |
|  Tricotage rectiligne, inventaire désagrégé                       |
|  Tricotage fully-fashioned, inventaire désagrégé                  |
|  Tricotage circulaire, inventaire désagrégé                       |
|  Tricotage chaussant                                              |

## Pertes et rebus

Le procédé de tricotage considéré prévoit qu'une partie du fil mobilisé soit perdu, comme cela est représenté sur le schéma "system boundaries" ci-dessus (Flux intermédiaire - Textile Waste - UUID: `1cc67763-7318-4077-af4a-bcd0ab5ef33f`).

Ces pertes sont prises en compte comme suit :

$$
MasseEtoffeSortante(kg) = MasseFilEntrant(kg) + MassePertes(kg)
$$

Avec :

$$
MassePertes(kg) = MasseEtoffeSortante(kg) * CoefPertesProcedeTricotage
$$

Plus de détail sur la gestion des masses : [Pertes et rebus](../pertes-et-rebus.md).

## Electricité

La quantité d'électricité à mobiliser pour actionner le procédé de tricotage est le produit de la masse "entrante", en l'occurrence la masse de fil en sortie de filature, avec le coefficient du flux intermédiaire correspondant à l'électricité (`de442ef0-d725-4c3a-a5e2-b29f51a1186c`).

Elle s'exprime en MJ dans la table des flux intermédiaires attachés au procédé de teinture.

$$
ElecConsommée(MJ) = MasseEntrante(kg) * CoefFluxElecProcédéTrictotage
$$

Le calcul d'impact de l'électricité ainsi mobilisée est détaillé dans la page suivante : [Electricité](../electricite.md).

{% hint style="danger" %}
L'électricité s'exprime en KWh dans la formule ci-dessous. Une division par 3,6 est donc nécessaire pour assurer le changement d'unité par rapport à l'électricité consommée, calculée d'abord en MJ.
{% endhint %}

$$
ImpactElec = ElecConsommée (KWh) * ImpactProcédéElec
$$

## Limites

* Possibilité / Opportunité d'ouvrir un paramétrage plus précis en choisissant d'autres procédés de tricotage ?
