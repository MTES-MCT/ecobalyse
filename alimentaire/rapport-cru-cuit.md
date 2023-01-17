# 🍚 Rapport cru/cuit

Un ingrédient peut perdre de la masse à la cuisson (ex: courgettes) ou en gagner (ex: riz). Pour prendre en compte cette variation de la masse, on associe à chaque ingrédient un rapport cru/cuit selon le tableau ci-dessous (provenant de la documentation d'Agribalyse).

<figure><img src="../.gitbook/assets/image (3).png" alt=""><figcaption><p>Méthodologie AGB 3.1_Alimentation.pdf</p></figcaption></figure>

La masse post-cuisson s'exprime donc en fonction de la masse pre-cuisson et du rapport cru/cuit de cette manière :

$$
m_{post\_cuisson} = m_{pre\_cuisson} * r_{cru-cuit}
$$

## Cas d'une recette multi-ingrédients

On applique à chaque ingrédient son rapport cru/cuit.

Par exemple pour une recette avec 100g de riz et 200g de courgettes, on aura post-cuisson 100\*2,259=226g de riz et 200\*0.86 = 172g de courgettes.
