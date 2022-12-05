# 🍅 Tomate

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), **la tomate** est modélisée à travers les procédés suivants :&#x20;

| Label / Origine             | France                                   | Autres pays                              |
| --------------------------- | ---------------------------------------- | ---------------------------------------- |
| Agriculture conventionnelle | y défini par la formule ci-dessous       | y défini par la formule ci-dessous       |
| Agriculture biologique      | En attente des graphes comparés d'impact | En attente des graphes comparés d'impact |

Les procédés retenus sont prioritairement des procédés "at farm", c'est à dire des procédés traduisant l'impact de l'ingrédient en sortie de ferme, avant que ne soit par exemple intégré l'impact du transport vers un lieu de transformation ou encore l'impact du conditionnement.

{% hint style="danger" %}
**XXX**
{% endhint %}

## Analyse des procédés disponibles

La base Agribalyse permet de distinguer les inventaires de cycle de vie suivants.&#x20;

* **16 procédés** France "at farm" (at farm gate/at greenhouse) :&#x20;
  * Tomato, conventional, new closed glasshouse,  unavoidable energy and biomass, no liquid CO2, runoff recycling, at farm gate
  * Tomato, conventional, new closed glasshouse,  unavoidable energy and biomass, runoff recycling, at farm gate
  * Tomato, conventional, new glasshouse, biomass and natural gas, runoff recycling, at farm gate
  * Tomato, conventional, new glasshouse, natural gas, no runoff recycling, at farm gate
  * Tomato, conventional, new glasshouse, natural gas, no runoff recycling, with water footprint, at farm gate
  * Tomato, conventional, new glasshouse, natural gas, runoff recycling, at farm gate
  * Tomato, conventional, new glasshouse, natural gas, runoff recycling, with water footprint, at farm gate
  * Tomato, conventional, new glasshouse, unavoidable energy and natural gas, runoff recycling, at farm gate
  * Tomato, conventional, old glasshouse, natural gas, no runoff recycling, at farm gate
  * Tomato, average basket, conventional, heated greenhouse, national average, at greenhouse' (kilogram, FR, None)
  * Tomato, average basket, conventional, soil based, non-heated greenhouse, at greenhouse' (kilogram, FR, None)
  * Tomato, medium size, conventional, heated greenhouse, at greenhouse' (kilogram, FR, None)
  * _Tomato, medium size, conventional, soil based, non-heated greenhouse, at greenhouse' (kilogram, FR, None)_
  * **Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None)**
  * Tomato, production mix, greenhouse production, national average, at greenhouse' (kilogram, FR, None)
* 1 procédé ES :
  * _Tomato, fresh grade {ES}| tomato production, fresh grade, in unheated greenhouse | Cut-off, U - Copied from Ecoinvent' (kilogram, None, None)_
* Dont 3 moyennes nationales France dont la construction est explicitée dans le schéma ci-après
  * Tomato, average basket, conventional, heated greenhouse, national average, at greenhouse' (kilogram, FR, None)
  * **Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None)**
  * Tomato, production mix, greenhouse production, national average, at greenhouse' (kilogram, FR, None)

{% hint style="info" %}
Pour la **tomate bio**, le procédé retenu pourrait être le procédé de la tomate bio "national average", ie Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None), qui correspond à une tomate sous serre.

Cependant, il n'est pas justifié que l'ICV bio retenu corresponde uniquement à une tomate sous serre.&#x20;

D'après les graphes d'analyse comparée des impacts, ...
{% endhint %}

{% hint style="info" %}
**Etant donnée l'existence d'un "consumption mix" pour la tomate, le procédé retenu pour la tomate conventionnelle est calculé à partir du procédé mobilisé dans le consumption mix, transport exclu (cf. arborescence de** Fresh tomato, consumption mix**).**
{% endhint %}

Ce mix de consommation (transport exclu) y appelle 2 procédés x1 et x2 :

* _x1 : Tomato, medium size, conventional, soil based, non-heated greenhouse, at greenhouse' (kilogram, FR, None)_
* _x2 : Tomato, fresh grade {ES}| tomato production, fresh grade, in unheated greenhouse | Cut-off, U - Copied from Ecoinvent' (kilogram, None, None)_

Avec :

$$
y = 0,662*x1 + 0,338*x2
$$

__

__

L'analyse comparée des impacts donne :&#x20;

<figure><img src="../../.gitbook/assets/image (1).png" alt=""><figcaption><p>source: AGB3.0 via Simapro, EF3.0 (adapted)<br><mark style="color:red;"><strong>Schéma illustratif à remplacer</strong></mark></p></figcaption></figure>

{% hint style="info" %}
**Axes de progrès ?**

Les données ICV disponibles dans Agribalyse permettraient potentiellement d'introduire une distinction suivant : ...
{% endhint %}

## Mix de consommation

Le procédé "Fresh tomato, consumption mix" France proposée dans Agribalyse s'appuie sur les procédés suivants.

On observe 2 ICV "autres pays" mobilisés.

<figure><img src="../../.gitbook/assets/tomato.png" alt=""><figcaption></figcaption></figure>

Un transport de <mark style="color:red;">XXX</mark> km en camion y est intégré.
