# 🍅 Tomate

## Choix de procédés

Considérée comme un ingrédient agricole (at farm), **la tomate** est modélisée à travers les procédés suivants :&#x20;

| Label / Origine             | France                                                                                                    | Espagne                                                                                                                                         | Autres pays                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Agriculture conventionnelle | Tomato, medium size, conventional, soil based, non-heated greenhouse, at greenhouse' (kilogram, FR, None) | Tomato, fresh grade {ES}\| tomato production, fresh grade, in unheated greenhouse \| Cut-off, U - Copied from Ecoinvent' (kilogram, None, None) | y défini par la formule ci-dessous                                                            |
| Agriculture biologique      | Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None)             | Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None)                                                   | Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None) |

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
Pour la **tomate bio**, le procédé retenu est le procédé de la tomate bio "national average", ie Tomato, organic, greenhouse production, national average, at greenhouse' (kilogram, FR, None).
{% endhint %}

{% hint style="info" %}
**Etant donnée l'existence d'un "consumption mix" pour la tomate, le procédé retenu pour la tomate conventionnelle est déterminé à partir du procédé mobilisé dans le consumption mix, transport exclu (cf. arborescence de** Fresh tomato, consumption mix**).**
{% endhint %}

Ce mix de consommation (transport exclu) appelle 2 procédés :

* _Tomato, medium size, conventional, soil based, non-heated greenhouse, at greenhouse' (kilogram, FR, None)_ (défini x1)
* _Tomato, fresh grade {ES}| tomato production, fresh grade, in unheated greenhouse | Cut-off, U - Copied from Ecoinvent' (kilogram, None, None)_ (défini x2)

Ces deux procédés correspondent à tomate conventionnelle FR et ES.

Le procédé de la tomate "autres pays" est calculé comme suit :

$$
y = 0,662*x1 + 0,338*x2
$$

{% hint style="info" %}
On remarque d'après l'analyse d'impacts ci-dessous que la tomate ES est moins impactante que la tomate FR conventionnelle (et il en est de même pour la tomate "autres pays")

Rq : Compte tenu de l'impact inconnu lié aux autres origines, il sera décidé d'une donnée d'impact majorante pour la tomate (à venir).
{% endhint %}

__

L'analyse comparée des impacts donne :&#x20;

<figure><img src="../../.gitbook/assets/image (1) (6).png" alt=""><figcaption><p>source: AGB3.0 via Simapro, EF3.0 (adapted)<br><mark style="color:red;"><strong>Schéma illustratif à remplacer</strong></mark></p></figcaption></figure>

{% hint style="info" %}
**Axes de progrès ?**

Les données ICV disponibles dans Agribalyse permettraient potentiellement d'introduire une distinction suivant : ...
{% endhint %}

## Mix de consommation

Le procédé "Fresh tomato, consumption mix" France proposée dans Agribalyse s'appuie sur les procédés suivants.

On observe 2 ICV "autres pays" mobilisés.

<figure><img src="../../.gitbook/assets/tomato.png" alt=""><figcaption></figcaption></figure>

## Identification de l'origine par défaut

Pour déterminer l'origine d'un ingrédient par défaut, chaque ingrédient est classé dans l'une des 4 catégories suivantes :&#x20;

1. Ingrédient très majoritairement produit en France (> 95%) => transport par défaut : _160 km de camion ?_
2. Ingrédient très majoritairement produit en Europe/_pourtour méditerranéen_ (>95%) => transport par défaut : _2500 km en camion ?_
3. Ingrédient produit également hors Europe (> 5%) => transport par défaut : _18 000 km en bateau ?_
4. Ingrédient spécifique (ex. Haricots et Mangues) => transport par défaut : _y km en avion_

**Tomate (fraiche + industrie) => catégorie 3** (source : FranceAgriMer - à confirmer par dires d'experts) ****&#x20;
