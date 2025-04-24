# Calcul des compléments animaux

Avant de commencer le calcul des compléments pour les animaux, il est nécessaire que les [compléments relatifs aux végétaux](../../alimentaire/old/calcul-des-complements-vegetaux.md) – haie, taille de parcelle, et diversité – aient été préalablement calculés.

## Haies, taille de parcelle et diversité

Les services écosystémiques de haie, taille de parcelle et diversité (hedges, plotSize et cropDiversity) se calcule directement à partir des services écosystémiques des végétaux et des rations consommées par les animaux.

### Rations

Par exemple pour 1 kg de viande de boeuf haché.  Faisons l'hypothèse que les rations en végétaux nécessaires sont les suivantes (exprimées en kg) :

```
  "ground-beef": {
    "silage-maize-fr": 3.42,
    "grazed-grass-temporary": 5.05,
    "grazed-grass-permanent": 37.5
  }
  
```



{% hint style="warning" %}
On raisonnera toujours en rations par kg de **produit animal fini**, que ce soit de viande, d' oeufs, ou de lait.
{% endhint %}

{% hint style="warning" %}
Pour les prairies permanentes et temporaires on fait l'hypothèse que 1 kg d'herbe de prairie = 1 m2.année d'occupation afin de simplifier les calculs.


{% endhint %}

### Compléments des rations

De plus les compléments associés à ces productions végétales, calculés préalablement, sont les suivants :&#x20;

```
{
  "silage-maize-fr": {
    "hedges": 0.43,
    "plotSize": 0.45,
    "cropDiversity": 0.0
  },
  "temporary-pasture": {
    "hedges": 0.81,
    "plotSize": 0.75,
    "cropDiversity": 0.0
  },
  "permanent-pasture": {
    "hedges": 0.76,
    "plotSize": 0.63,
    "cropDiversity": 0.0
  }
}

```

### Services écosystémiques finaux

On en déduit les services écosystémiques d'1 kg de viande de boeuf haché :&#x20;

```
"ground-beef": {
    "hedges": 3.42*0.43 + 5.05*0.81 + 37.5*0.76,
    "plotSize": 3.42*0.45 + 5.05*0.75 + 37.5*0.63,
    "cropDiversity": 3.42*0 + 5.05*0 + 37.5*0
  }
  
Finalement :

"ground-beef": {
    "hedges": 34.06,
    "plotSize": 28.9,
    "cropDiversity": 0
  }
```

## Prairies permanentes - permanentPasture

Le services écosystémiques prairies permanentes est la quantité de m2.an de prairie permanente occupé pour produire 1 kg de produit. Dans notre exemple on a :&#x20;

```
"ground-beef": {
    "permanentPasture": 37.5
  }
```

## Chargement - livestockDensity

Le taux de chargement est un complément qui pénalise les productions animales dont la concentration géographique excède la capacité d'une région, entraînant pollution et déséquilibres écologiques. Cela est particulièrement pertinent pour des cas spécifiques tels que l'élevage porcin en Bretagne et les problématiques d'algues vertes.\


Pour calculer ce complément on a besoin, du chargement par UGB (Unité Gros Bétail) $$C_{UGB}$$ qui réflète le niveau de concentration par production animale et par scénario :

| groupe    | Référence | Bio   | Import |
| --------- | --------- | ----- | ------ |
| bovins    | -0.85     | -0.89 | -2     |
| equidés   | -0.29     | -0.29 | -2     |
| caprins   | 0.09      | -0.16 | -1     |
| ovins     | 0.12      | 0.03  | -1     |
| porcins   | -5.32     | -1.53 | -7     |
| lapins    | -1.28     | -0.18 | -3     |
| volailles | -2.76     | -0.95 | -4     |

D'autre part, pour chaque type de production animale on a la quantité de production animale / UGB $$Prod_{UGB}$$:



| catégorie 1 | catégorie 2 | type   | Prod\_{UGB} | unité         |
| ----------- | ----------- | ------ | ----------- | ------------- |
| bovins      | vache       | lait   | 4138        | kg lait/UGB   |
| caprins     | chèvre      | lait   | 3333        | kg lait/UGB   |
| ovins       | mouton      | lait   | 1400        | kg lait/UGB   |
| volailles   | poulet      | oeuf   | 357         | kg oeuf/UGB   |
| bovins      | vache       | viande | 333         | kg viande/UGB |
| porcins     | porc        | viande | 196         | kg viande/UGB |
| volailles   | poulet      | viande | 182         | kg viande/UGB |
| ovins       | mouton      | viande | 100         | kg viande/UGB |
| ovins       | agneau      | viande | 83          | kg viande/UGB |

Finalement :&#x20;

$$
Chargement = C_{UGB} / Prod_{UGB}
$$

Dans le cas du boeuf haché conventionnel :

<pre><code><strong>Chargement = C_UGB * Prod_UGB
</strong>Chargement = -0.85 * 333
Chargement = 283.05
</code></pre>

## Bilan&#x20;

Les compléments pour notre kg de boeuf haché sont donc :&#x20;

```
"ground-beef": {
    "hedges": 34.06,
    "plotSize": 28.9,
    "cropDiversity": 0,
    "permanentPasture":37.5,
    "livestockDensity":283.05
  }
```
