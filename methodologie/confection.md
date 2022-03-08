---
description: >-
  Découpe du tissu, assemblage des différentes pièces, repassage et pliage du
  produit fini.
---

# 👗 Etape 4 - Confection

## Schéma

Conformément à la documentation sectorielle textile de la [base Impacts](http://www.base-impacts.ademe.fr), le système "teinture" est schématisé comme suit :

![](<../.gitbook/assets/Confection (1).PNG>)

Par conséquent, l'impact global de l'étape de confection se comprend comme résultant de la somme de l'impact résultant du procédé de confection retenu (cf. intérieur du _system boundaries_) et des procédés externes devant être ajoutés, à savoir :

| Flux externe | UUID du flux                           | unité |
| ------------ | -------------------------------------- | ----- |
| Electricité  | `de442ef0-d725-4c3a-a5e2-b29f51a1186c` | MJ    |

La formule suivante s'applique donc :

$$
ImpactConfection = ImpactProcédéConfection + ImpactElec
$$

## Procédé de confection

L'impact du procédé de confection retenu est le produit du nombre d'articles / vêtements par le coefficient d'impact considéré (cf. [Impacts considérés](impacts-consideres.md)).

$$
ImpactProcédéConfection = NbrArticles * CoefImpactProcédéConfection
$$

{% hint style="warning" %}
Remarque : pour les procédés de confection retenus (cf. ci-après), les coefficients d'impact sont tous nuls, de sorte que l'impact de l'étape de confection se limite finalement à l'impact de l'électricité nécessaire pour opérer ce processus.

Une ambigüité apparaît dans la méthodologie entre :&#x20;

* la documentation sectorielle textile qui précise, pour la section "making of clothing" (1.2.2.3.4.), que "the inventory refers to the production of 1 item of clothing"
* la documentation du procédé de la base impacts qui une unité de référence en kg.&#x20;
{% endhint %}

Le choix de procédé réalisé dépend du vêtement considéré :

| Vêtement  | Procédé                                             | UUID                                   |
| --------- | --------------------------------------------------- | -------------------------------------- |
| Châle     | Confection (ceinture, châle, chapeau, sac, écharpe) | `0a260a3f-260e-4b43-a0df-0cf673fda960` |
| Echarpe   | Confection (ceinture, châle, chapeau, sac, écharpe) | `0a260a3f-260e-4b43-a0df-0cf673fda960` |
| Débardeur | Confection (débardeur, tee-shirt, combinaison)      | `26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5` |
| T-shirt   | Confection (débardeur, tee-shirt, combinaison)      | `26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5` |
| Gilet     | Confection (gilet, jupe, pantalon, pull)            | `387059fc-72cb-4a92-b1e7-2ef9242f8380` |
| Jupe      | Confection (gilet, jupe, pantalon, pull)            | `387059fc-72cb-4a92-b1e7-2ef9242f8380` |
| Pantalon  | Confection (gilet, jupe, pantalon, pull)            | `387059fc-72cb-4a92-b1e7-2ef9242f8380` |
| Pull      | Confection (gilet, jupe, pantalon, pull)            | `387059fc-72cb-4a92-b1e7-2ef9242f8380` |
| Chemisier | Confection (chemisier, manteau, veste, cape, robe)  | `7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe` |
| Manteau   | Confection (chemisier, manteau, veste, cape, robe)  | `7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe` |
| Veste     | Confection (chemisier, manteau, veste, cape, robe)  | `7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe` |
| Cape      | Confection (chemisier, manteau, veste, cape, robe)  | `7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe` |
| Robe      | Confection (chemisier, manteau, veste, cape, robe)  | `7fe48d7c-a568-4bd5-a3ac-cfa88255b4fe` |
| Jean      | Confection (jeans)                                  | `1f428a50-73c0-4fc1-ab39-00fd312458ee` |

{% hint style="info" %}
Les 5 procédés mobilisés sont les seuls disponibles à ce jour dans la base Impacts. Il n'est donc pas possible en l'état de proposer d'alternative.
{% endhint %}

## Pertes et rebut

Les différents procédés de confection ne prévoient pas de perte dans la base Impacts, contrairement à ce qui peut être affiché dans le schéma "system boundaries" ci-dessus (Flux intermédiaire - Textile Waste - UUID: `1cc67763-7318-4077-af4a-bcd0ab5ef33f`).

En revanche, des pertes sont bien mentionnées dans la documentation sectorielle ADEME, en fonction du type de vêtement considéré (cf. Méthodologie d'évaluation des impacts environnementaux des articles d'habillement - Annexe A.1.c - p28) :

| Vêtement  | Groupe   | Pertes (%) |
| --------- | -------- | ---------- |
| Châle     | Groupe 1 | `10%`      |
| Echarpe   | Groupe 1 | `10%`      |
| Débardeur | Groupe 2 | `15%`      |
| T-shirt   | Groupe 2 | `15%`      |
| Gilet     | Groupe 3 | `20%`      |
| Jupe      | Groupe 3 | `20%`      |
| Pantalon  | Groupe 3 | `20%`      |
| Pull      | Groupe 3 | `20%`      |
| Chemisier | Groupe 4 | `20%`      |
| Manteau   | Groupe 4 | `20%`      |
| Veste     | Groupe 4 | `20%`      |
| Cape      | Groupe 4 | `20%`      |
| Robe      | Groupe 4 | `20%`      |
| Jean      | Groupe 5 | `22%`      |

La formule appliquée pour calculer la masse de tissu nécessaire, avant confection, pour obtenir l'habit confectionné est la suivante :

$$
MasseTissu(kg) = MasseHabit(kg) / (1-Pertes)
$$

{% hint style="danger" %}
Attention : le calcul des pertes est donc différent pour l'étape de confection par rapport aux autres étapes de la fabrication du vêtement.
{% endhint %}

Plus de détail sur la gestion des masses : [Pertes et rebut](pertes-et-rebus.md).

## Electricité

La quantité d'électricité à mobiliser pour actionner le procédé de confection est le produit du nombre d'articles / vêtements, avec le coefficient du flux intermédiaire correspondant à l'électricité (`de442ef0-d725-4c3a-a5e2-b29f51a1186c`).

Elle s'exprime en MJ dans la table des flux intermédiaires attachés au procédé de teinture.

$$
ElecConsommée(MJ) = NbrArticles * CoefFluxElecProcédéTeinture
$$

{% hint style="warning" %}
Une ambigüité apparaît dans la méthodologie entre :&#x20;

* la documentation sectorielle textile qui précise, pour la section "making of clothing" (1.2.2.3.4.), que "the inventory refers to the production of 1 item of clothing"
* la documentation du procédé de la base impacts qui une unité de référence en kg.&#x20;
{% endhint %}

Le calcul d'impact de l'électricité ainsi mobilisée est détaillé dans la page suivante : [Electricité](electricite.md).

{% hint style="danger" %}
L'électricité s'exprime en KWh dans la formule ci-dessous. Une division par 3,6 est donc nécessaire pour assurer le changement d'unité par rapport à l'électricité consommée, calculée d'abord en MJ.
{% endhint %}

$$
ImpactElec = ElecConsommée (KWh) * ImpactProcédéElec
$$

## Limites

* Lever l'ambigüité méthodologique sur la prise en compte du nombre d'articles ou de la masse sortante dans les calculs d'impacts et d'électricité mobilisée

## Cas particulier du Jean : Délavage

Pour le jean on intègre dans l'étape confection le délavage. Le délavage est un procédé qui s'applique après la confection et qui a un impact environmental important. En effet le délavage demande des quantités significatives de chaleur, d'électricité et d'eau.

Il existe différents procédés de délavage dans la base impacts :&#x20;

* mécanique ou chimique
* représentatif ou majorant
* traitement des eaux très efficace à inefficace

Pour l'instant nous ne prenons que le procédé par défaut qui est le plus impactant (chimique, majorant, traitement des eaux inefficace).
