---
description: >-
  Cette page porte sur les spécificités du transport des produits alimentaires.
  Les informations relatives au transport de manière générale sont détaillées
  dans la documentation transverse d'Ecobalyse.
---

# 🍕 Transport Alimentaire

## Déclinaison des étapes de transport sur ce secteur

1. Transport des matières premières (ex : coton, blé, animal) du champs vers le site de fabrication de l'ingrédient, tous deux dans le même pays,
2. Transport de l'ingrédient vers le site de transformation en France,
3. Transport du produit fini entre l'usine de transformation et un entrepôt de stockage, tous deux en France,
4. Transport entre l’entrepôt de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

## 1. Transport des matières premières&#x20;

Le transports des matières première est modélisé par un transport par camion, avec une distance fixée à 160 km.

Pour chaque ingrédient, ce transport de matière première peut se faire par un mode de transport frigorifique ou non (camion et bateau, non applicable pour l'avion). Ceci est défini par le paramètre "Transport frigorifique" de chaque ingrédient, identifié dans l'<mark style="color:red;">Explorateur Alimentaire</mark>, avec les caractéristiques suivantes :&#x20;

* "Toujours frigorifique" : transport frigorifique à cette étape
* "Frigorifique après transformation" ou "Non frigorifique": transport non frigorifique à cette étape

{% hint style="info" %}
En pratique, l'impact de ce transport est également inclut de façon dans le procédé utilisé pour modéliser l'ingrédient (impact peu significatif). Il est volontairement comptabilisé en supplément de façon spécifique de façon à rendre visible la part du transport dans le coût environnemental du produit
{% endhint %}

## 2. Transport des ingrédients

Le transport se modélise avec une part de voie aérienne `a` modifiable égale à 1 ou 0 pour certains ingrédients. Les ingrédients concernés sont identifiés dans l'<mark style="color:red;">Explorateur Ingrédient</mark> avec une origine "Hors Europe et Maghreb par avion". Pour ces ingrédients, transport est modélisé par défaut par une voie aérienne uniquement (paramètre `a` fixé à 1), identifiable à l'aide d'un sélecteur. L'utilisateur peut modifier ce paramétrage et passer à un transport modélisé avec une combinaison de voies terrestre et maritime uniquement (paramètre `a` fixé à 0), avec le sélecteur.

Pour les autres ingrédients, le transport est modélisé avec une combinaison de voies (maritime et terrestre) non modifiable, et aucun sélecteur n'est proposé.

Pour chaque ingrédient, ce transport d'ingrédient peut se faire par un mode de transport frigorifique ou non (camion et bateau, non applicable pour l'avion). Ceci est défini par le paramètre "Transport frigorifique" de chaque ingrédient, identifié dans l'<mark style="color:red;">Explorateur Alimentaire</mark>, avec les caractéristiques suivantes :&#x20;

* "Toujours frigorifique" ou "Frigorifique après transformation" : transport frigorifique à cette étape
* "Non frigorifique": transport non frigorifique à cette étape

{% hint style="info" %}
En pratique, l'impact de ce transport est également inclut de façon dans le procédé utilisé pour modéliser l'ingrédient, sans prise en compte d'un pays d'origine spécifique (impact peu significatif). Il est volontairement comptabilisé en supplément de façon spécifique, de façon à rendre visible la part du transport dans le coût environnemental du produit, et à faire varier cette part en fonction du pays d'origine et de la voie de transport utilisée.
{% endhint %}

## 3. Transport du produit fini vers l'entrepôt de stockage

Le transports du produit fini est modélisé par un transport par camion, avec une distance fixée à 500 km.

Si l'un des ingrédients utilisé doit être transporté en frigorifique, alors le transport du produit transformé est modélisé avec un mode un transport frigorifique.

