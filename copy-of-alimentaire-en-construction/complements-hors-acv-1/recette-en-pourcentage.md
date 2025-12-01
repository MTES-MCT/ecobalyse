---
hidden: true
---

# §Recette en pourcentage

### La masse du produit fini



La masse du produit final à renseigner correspond à la masse du produit après transformation (cuisson, mélange...). Elle ne prend pas en compte l'emballage.&#x20;



### Une recette en pourcentage de masse à la mise en œuvre&#x20;



Lors de la conception de la recette, l'utilisateur renseigne pour chaque ingrédient sa proportion en pourcentage de masse à la mise en œuvre : il s'agit de la masse de l'ingrédient utilisée dans la recette **après avoir retiré sa part non comestible.**&#x20;

#### <mark style="color:red;">Et si je ne peux pas modéliser l'entièreté de la recette ?</mark>

Rien n'oblige l'utilisateur à le faire. Néanmoins, un message d'avertissement sera visible si la somme des pourcentages de la recette n'atteint pas 100%.&#x20;

<mark style="color:blue;">A noter que plus on se rapproche de 100%, plus la modélisation est précise. Il est donc très important de faire</mark> <mark style="color:blue;"></mark><mark style="color:blue;">**remonter les ingrédients manquants**</mark> <mark style="color:blue;"></mark><mark style="color:blue;">grâce au canal de communication !</mark>



### Exemple de conversion Pourcentage/Masse



Je rentre la recette du gâteau à la banane notée telle que sur mon cahier des charges :

`Masse finale du gâteau : 1000g`

&#x20;_Pourcentages **à la mise en œuvre** (donc en ayant **retiré la Part Non Comestible**, et **avant toute transformation**)_ :

* 70% de banane
* 15% de farine
* 10% de sucre
* 5% d’œuf



Or, le gâteau à subit une étape de cuisson, il faut donc remonter depuis la masse du produit final jusqu'à la masse pré-cuisson.<br>

| Ingrédients | Rapport Cru/Cuit |
| ----------- | ---------------- |
| banane      | 0.856            |
| farine      | 1                |
| sucre       | 1                |
| oeuf        | 0.974            |

**Masse à la mise en œuvre du gâteau à la banane** :&#x20;

M = `masse du produit fini renseignée par l’utilisateur` / somme (`% ingrédients à la mise en oeuvre` \* `rapport cru cuit`))

```
= `1000 / ( 0.7*0.856 + 0.15*1 + 0.1*1 + 0.05*0.974 )`

= 1113,7 g
```



Donc,

**Masse à la mise en œuvre de chaque ingrédient** :

m = `% ingrédient à la mise en oeuvre * masse du produit à la mise en oeuvre`

m\_banane = `0.7 * 1113.7` = 779.6 g

m\_farine = `0.15 * 1113.7` = 167 g

m\_sucre = `0.1 * 1113.7` = 111.4 g

m\_oeuf = `0.05 * 1113.7` = 55.7 g

_Ces valeurs sont affichées à côté de chaque ingrédient correspondant._



Enfin,

Pour le **calcul d’impact**, on calcule la **masse brute de chaque ingrédient** :&#x20;

m\_brute\_ingrédient = `masse de l’ingrédient mise en œuvre` / `(1- part non comestible de l’ingrédient)`
