# 🍕 Transport Alimentaire

## Déclinaison des étapes de transport sur ce secteur

1. Transport des matières premières (ex : coton, blé, animal) du champs vers le site de fabrication de l'ingrédient, tous deux dans le même pays,
2. Transport de l'ingrédient vers le site de transformation en France,
3. Transport du produit fini entre l'usine de transformation et un entrepôt de stockage, tous deux en France,
4. Transport entre l’entrepôt de stockage en France et un magasin ou centre de distribution ou client final s'il est livré directement.

## 1. Transport des matières premières&#x20;

Le transports des matières première est modélisé par un transport par camion, avec une distance fixée à 160 km.

Pour chaque ingrédient, ce transport de matière première peut se faire par un moyen de transport réfrigéré ou non (camion et bateau, non applicable pour l'avion). Ceci est défini dans le [fichier listant les ingrédients](https://github.com/MTES-MCT/ecobalyse/blob/master/public/data/food/ingredients.json), avec les caractéristiques suivantes :&#x20;

* "always" : transport réfrigéré à cette étape
* "once\_transformed", "none": transport non réfrigéré à cette étape

{% hint style="warning" %}
Intérêt de mettre cette info dans l'explorateur ?
{% endhint %}

{% hint style="warning" %}
J'ai vu d'autres termes dans [https://github.com/MTES-MCT/ecobalyse/blob/master/src/Data/Food/Ingredient.elm](https://github.com/MTES-MCT/ecobalyse/blob/master/src/Data/Food/Ingredient.elm) : Always Cool, CoolOnceTransformed, NoCooling&#x20;
{% endhint %}

{% hint style="info" %}
En pratique, l'impact de ce transport est également inclut de façon dans le procédé utilisé pour modélisé l'ingrédient. Il est volontairement comptabilisé en supplément de façon spécifique de façon à rendre visible la part du transport dans le coût environnemental du produit
{% endhint %}

## 2. Transport des ingrédients

Le transport se modélise avec une part de voie aérienne `a`. Cette part de voie aérienne `a`est modifiable ou non par l'utilisateur en fonction des ingrédients.

Pour chaque ingrédient, ce transport de matière première peut se faire par un moyen de transport réfrigéré ou non (camion et bateau, non applicable pour l'avion). Ceci est défini dans le [fichier listant les ingrédients](https://github.com/MTES-MCT/ecobalyse/blob/master/public/data/food/ingredients.json), avec les caractéristiques suivantes :&#x20;

* "always", "once\_transformed" : transport réfrigéré à cette étape
* "none": transport non réfrigéré à cette étape

{% hint style="info" %}
En pratique, l'impact de ce transport est également inclut de façon dans le procédé utilisé pour modélisé l'ingrédient, sans prise en compte d'un pays d'origine spécifique. Il est volontairement comptabilisé en supplément de façon spécifique, de façon à rendre visible la part du transport dans le coût environnemental du produit, et à faire varier cette part en fonction du pays d'origine et de la voie de transport utilisée.
{% endhint %}

### Paramètres par défaut pour l'affichage environnemental

La part de **transport aérien (`a`)**, par rapport au transport "aérien + terrestre + maritime" définie par défaut est indiquée dans l'<mark style="color:red;">Explorateur Ingrédient</mark>.

## 3. Transport du produit fini vers l'entrepôt de stockage

Le transports du produit fini est modélisé par un transport par camion, avec une distance fixée à 500 km.

