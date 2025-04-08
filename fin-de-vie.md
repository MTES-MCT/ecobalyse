---
hidden: true
---

# ♻️ Fin de vie

## Contexte



## Méthodes de calcul

### Méthode générale, inspirée de la CFF

$$
I_{recyclage,i} = m_i*(1-A_{out,i})*R_{2,i}*I_{recycling.i}
$$

$$
I_{incineration} = m*R_{3,i}*I_{ER.i}
$$

Avec :

* <mark style="color:red;">`I_recyclage,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental du produit en fin de vie liée au recyclage, pour la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, dans l'unité de la catégorie d'impact analysée</mark>
* <mark style="color:red;">`m_i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: la masse relative à la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, en kg</mark>
* <mark style="color:red;">`A_out,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le facteur d'allocation des impacts entre le produit arrivant en fin de vie et le produit futur utilisant la matière recyclée, sans unité</mark>
* <mark style="color:red;">`R_2,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le taux de recyclage en fin de vie de la famille de matière</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, en %</mark>
* <mark style="color:red;">`I_recycling,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental du recyclage d'un kg d'un matériau de la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, dans l'unité de la catégorie d'impact analysée</mark>

### <mark style="color:red;">Calcul du taux de recyclage</mark>

$$
R_{2,i} = Rp*r_i+(1-Rp)*r_{defaut}
$$

Avec :

* <mark style="color:red;">`R_2,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le taux de recyclage en fin de vie de la famille de matière</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, en %</mark>
* <mark style="color:red;">`Rp`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le taux de recyclabilité produit, en %</mark>
*

### <mark style="color:red;">Calcul de la recyclabilité produit</mark>

$$
Rp=c*F_{FdV}*(1-Pr)*Mr
$$

Avec :

* <mark style="color:red;">`Rp`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le taux de recyclabilité produit, en %</mark>
*

## Paramètres retenus pour l’affichage environnemental





## Procédés utilisés pour l’affichage environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), avec les noms utilisés dans cette page.

