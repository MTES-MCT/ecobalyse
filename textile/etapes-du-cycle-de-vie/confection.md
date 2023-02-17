---
description: >-
  Ce module est en cours de refonte afin d'enrichir la Documentation et le
  Calculateur.
---

# 👗 Etape 4 - Confection

## Description

L'étape de confection a pour but de séparer les différentes pièces composant un produit et de les assembler par le biais de la confection afin d’obtenir le produit final. Cette étape comprend généralement la découpe du tissu, l'assemblage des différentes pièces ainsi que le repassage et pliage du produit fini.

## Modélisation Ecobalyse

### Paramètres mobilisés

<details>

<summary>Taux de perte (%)</summary>

Un taux de perte par défaut est appliqué par type de vêtement.&#x20;

L'utilisateur a la possibilité de modifier ce paramètre dans le calculateur (min = 0% / max = 40%).\


Cf. l'[Explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products) pour les valeurs par défaut.

</details>

<details>

<summary>Electricité consommée  (MJ / kWh)</summary>

Une quantité d'électricité à mobiliser pour actionner le procédé de confection est appliquée par défaut. Cette valeur est définie selon le niveau de complexité de confection associé au vêtement. Cinq options sont possibles :&#x20;

* Très simple (moins de 5 minutes)
* Simple (entre 5 et 15 minutes)
* Moyen (entre 15 et 30 minutes)
* Complexe (entre 30 minutes et 1H)
* Très complexe (plus de 1H)

L'utilisateur a la possibilité de modifier ce paramètre dans le calculateur.&#x20;



Cf. la section _Hypothèses par défaut_ pour plus d'info.

Cf. l'[Explorateur](https://ecobalyse.beta.gouv.fr/#/explore/textile/products) pour les valeurs par défaut.

</details>

### Méthodologie de calcul

L'étape de _Confection_ est modélisée comme suit :

![](<../../.gitbook/assets/Confection (1).PNG>)

L'impact global de cette étape se comprend donc comme la somme des impacts :&#x20;

* du procédé de confection retenu (cf. intérieur du _system boundaries_),
* du procédé externe devant être ajoutés (électricité)

La formule suivante s'applique donc :

$$
ImpactConfection = ImpactProcédéConfection + ImpactElec
$$

Les **procédés de confection** mis en place sont spécifiques aux spécificités de chaque vêtement. Le socle technique actuellement utilisé (Base Impacts) propose 5 procédés de confection.&#x20;

{% hint style="warning" %}
Remarque : Les coefficients d'impact des procédés de confection sont tous nuls.&#x20;
{% endhint %}

Dès lors, l'impact de l'étape de confection se limite finalement à l'impact de l'électricité nécessaire pour opérer ce processus.&#x20;

Le **procédé externe (électricité)** devant être ajouté est le suivant :

| Flux externe | UUID du flux                           | unité |
| ------------ | -------------------------------------- | ----- |
| Électricité  | `de442ef0-d725-4c3a-a5e2-b29f51a1186c` | MJ    |

### Hypothèses par défaut&#x20;

#### Électricité consommée

Un temps de confection, exprimé en minutes, est associé à chaque niveau de complexité (cf. ci-dessous).

Aussi, 0,029kWh d'électricité est consommée par minute de confection. Cette valeur se base sur les travaux réalisés par le programme [Mistra Future Fashion](#user-content-fn-1)[^1] (Suède). &#x20;

| Complexité    | Temps de confection (minutes) | Electricité consommée (MJ / kWh) |
| ------------- | ----------------------------- | -------------------------------- |
| Très simple   | Moins de 5 minutes            | 0,36 / 0,1                       |
| Simple        | Entre 5 et 15 minutes         | 1,44 / 0,4                       |
| Moyen         | Entre 15 et 30 minutes        | 3,24 / 0,9                       |
| Complexe      | Entre 30 minutes et 1H        | 6,12 / 1,7                       |
| Très complexe | Plus de 1H                    | 12,6 / 3,5                       |

{% hint style="warning" %}
Le procédé d'électricité mobilisé  (`de442ef0-d725-4c3a-a5e2-b29f51a1186c`) s'exprime en MJ tandis que l'affichage sur le calculateur se fait en kWh car cette unité est plus communément utilisée (1kWh = 3,6MJ).
{% endhint %}

#### Délavage (jean)&#x20;

Pour le jean on intègre dans l'étape confection le délavage. Le délavage est un procédé qui s'applique après la confection et qui a un impact environnemental important. En effet le délavage demande des quantités significatives de chaleur, d'électricité et d'eau.

Il existe différents procédés de délavage dans la base impacts :

* mécanique ou chimique
* représentatif ou majorant
* traitement des eaux très efficace à inefficace

Pour l'instant nous ne prenons que le procédé par défaut qui est le plus impactant (chimique, majorant, traitement des eaux inefficace).

## Limites

* Non applicable \
  Les principaux enjeux de la confection d'un point de vue environnemental sont traités de manière satisfaisante.

[^1]: cf. p. 49/167 de l'étude : \
    Environmental assessment of Swedish clothing consumption - six garments, sustainable futurs (2019)
