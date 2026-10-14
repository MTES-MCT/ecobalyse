# 🥑 Part non comestible

La part non comestible correspond à une partie d'un produit agricole qui n'est pas destinée à la consommation humaine. Ces pertes peuvent inclure des éléments tels que les coquilles d'œufs, les écorces de fruits et légumes, les os, les cartilages et bien d'autres.

Dans le cadre de notre calcul d'impact pour 1 kg de produit comestible, nous devons prendre en compte ces pertes non comestibles. Pour ce faire, nous appliquons un ratio de perte non comestible à chaque ingrédient. Ce ratio peut être trouvé dans la [documentation d'Agribalyse](https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media\&token=0da7c4e0-4332-4bc3-9c86-83b7a6325971).

**Pour simplifier la modélisation, nous considérons le retrait de la part non comestible toujours avant l'étape de transformation.**

## Hypothèses Agribalyse de parts non comestibles

<div><figure><img src="../../.gitbook/assets/Screenshot 2023-04-20 at 17.31.27.png" alt=""><figcaption><p><a href="https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media&#x26;token=0da7c4e0-4332-4bc3-9c86-83b7a6325971">Méthodologie AGB 3.1_Alimentation_Annexes.pdf</a> Parts non comestibles des fruits frais et à coque</p></figcaption></figure> <figure><img src="../../.gitbook/assets/Screenshot 2023-04-20 at 17.31.21.png" alt=""><figcaption><p><a href="https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media&#x26;token=0da7c4e0-4332-4bc3-9c86-83b7a6325971">Méthodologie AGB 3.1_Alimentation_Annexes.pdf </a>Parts non comestibles des légumes</p></figcaption></figure> <figure><img src="../../.gitbook/assets/Screenshot 2023-04-20 at 17.28.24.png" alt=""><figcaption><p><a href="https://3613321239-files.gitbook.io/~/files/v0/b/gitbook-x-prod.appspot.com/o/spaces%2F-LpO7Agg1DbhEBNAvmHP%2Fuploads%2FwE46PsDpfPPo7qd486O6%2FM%C3%A9thodologie%20AGB%203.1_Alimentation.pdf?alt=media&#x26;token=0da7c4e0-4332-4bc3-9c86-83b7a6325971">Méthodologie AGB 3.1_Alimentation.pdf</a> Parts non comestibles des viandes</p></figcaption></figure></div>

NB : Agribalyse ne définit pas de valeur de part non comestibles pour la courgette. Ecobalyse lui applique une valeur de 10%.

Le détail des parts non comestibles considérées est accessible dans la rubrique "ingrédients" de l'explorateur d'Ecbalyse : [https://ecobalyse.beta.gouv.fr/#/explore/food/ingredients](https://ecobalyse.beta.gouv.fr/#/explore/food/ingredients)

<details>

<summary>Exemple de calcul</summary>

Prenons l'exemple d'un carrot cake avec les ingrédients suivants

* oeuf, 120g
* blé tendre, 140g
* lait, 60g
* carotte, 225g

Soit un poids total de : 545g

Alors on aura en sortie de l'étape d'ingrédients :

* oeuf, pnc (part non comestible) = 20%, 120g -> 120 \* (1-0.2) = 96 g d'oeuf comestible
* blé tendre, pnc = 0%, 140g -> 140\*(1-0) = 140 g de blé tendre comestible
* lait, pnc = 0%, 60g -> 60\*(1-0) = 60 g de lait comestible
* carotte, pnc = 10%, 225g -> 225\*(1-0.1) = 202.5g de carotte comestible

Le poids total comestible est donc de : **498.5g**.

Etant donné que l'on cuit notre gâteau, il faut ensuite appliquer le ratio cru-cuit (rcc) (cf. [page dédiée](rapport-cru-cuit.md)) :

* oeuf, rcc (ratio cru-cuit) = 0.974, 96g -> 96 \* 0.974 = 93.5 g d'oeuf
* blé tendre, rcc = 2.259, 140g -> 140\*2.259 = 316.26 g de blé tendre
* lait, rcc = 1, 60g -> 60\*1 = 60 g de lait
* carotte, rcc =, 202.5 -> 202.5\*0.856 = 173.34g de carotte

Le poids total après cuisson est donc de : **643.1g**.

</details>

<details>

<summary>Limites de cette modélisation</summary>

Dans le cas d'une recette mono-ingrédient, par exemple des moules, le retrait de la part non comestible a en réalité lieu chez le consommateur. Prenons le cas d'1 kg de moules dont seulement 50% sont comestibles. Nous allons calculer le transport pour seulement 0.5 kg de moules, alors qu'en réalité 1 kg sont transportés et réfrigérés. Nous allons donc sous-estimer l'impact du transport et de la réfrigération. Cependant, l'impact de la réfrigération et du transport étant généralement inférieur à 5% de l'impact total, cette approximation a peu d'impact sur le score total

</details>
