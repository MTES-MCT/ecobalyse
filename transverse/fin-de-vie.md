---
hidden: true
---

# ♻️ Fin de vie

## Contexte



## Méthodes de calcul

### Méthode générale, inspirée de la CFF

$$
I_{EoL} = \sum_i m_i*(I_{EoL,rec,i}+I_{EoL,incineration,i}+I_{EoL,landfill,i})
$$

$$
I_{EoL,rec,i} = (1-A_{out,i})*R_{2,i}*(I_{recyclongEoL}-Ev^*_i*Q_{out,i})
$$

$$
I_{EoL,incineration,i} = (1-R_{2,i})*r_{3,i}*(I_{ER.i}-LHV_i*X_{ER,heat,i}*E_{SE,heat,i}-LHV_i*X_{ER,heat,i}*E_{SE,heat,i})
$$

$$
I_{EoL,landfill,i} = (1-R_{2,i})*(1-r_{3,i})*I_{D,i}
$$

Avec :&#x20;

* `I_EoL` : l'impact environnemental du produit en fin de vie, dans l'unité de la catégorie d'impact analysée
* `m_i` : la masse relative à la famille de matériaux `i`, en kg
* `I_EoL,rec,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_EoL,incineration,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `I_EoL,landfill,i` : l'impact environnemental de la famille de matériaux `i` liée au recyclage, dans l'unité de la catégorie d'impact analysée
* `A_out,i` : le facteur d'allocation des impacts entre le produit arrivant en fin de vie et le produit futur utilisant la matière recyclée, sans unité
* `R_2,i` : le taux de recyclage en fin de vie de la famille de matière `i`, en %, dont le calcul est précisé dans la section suivante
* `I_recyclingEol,i` : l'impact environnemental du recyclage d'un kg d'un matériau de la famille de matériaux `i`, dans l'unité de la catégorie d'impact analysée
* `Iv*_i` : l'impact environnemental de la fabrication d'un kg d'un matériau neuf, que le matériaux recyclé de la famille de matériaux `i` va remplacer, dans l'unité de la catégorie d'impact analysée
* <mark style="color:red;">`Q_out,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: blable  de la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, sans unité</mark>
* <mark style="color:red;">`r_3,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: blable  de la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, sans unité</mark>
* <mark style="color:red;">`Q_out,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: blable  de la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, sans unité</mark>
* <mark style="color:red;">`I_ER,i`</mark> <mark style="color:red;"></mark><mark style="color:red;">: l'impact environnemental de l’incinération (y compris transport et tri) d'un kg d'un matériau de la famille de matériaux</mark> <mark style="color:red;"></mark><mark style="color:red;">`i`</mark><mark style="color:red;">, dans l'unité de la catégorie d'impact analysée</mark>





### Calcul du taux de recyclage

$$
R_{2,i} = Rp_2*Rm_{2,i}
$$

Avec :&#x20;

* `R_2,i` : le taux de recyclage de la famille de matière `i`, en %
* `Rp_2` : le taux de recyclabilité du produit, en %
* `Rm_2,i` : le taux de recyclage réel en fin de vie de la famille de matière `i`, en %, pour un produit recyclable

### <mark style="color:red;">Calcul de la recyclabilité produit (Spécifique Ameublement)</mark>

$$
Rp=c*F_{FdV}*(1-Pr)*Mr
$$

Avec :

* <mark style="color:red;">`Rp`</mark> <mark style="color:red;"></mark><mark style="color:red;">: le taux de recyclabilité produit, en %</mark>

### Correspondance avec la CFF

$$
R_{3} = (1-R_{2,i})*r_{3,i}
$$

Avec :&#x20;

* `R_3` : le taux de recyclage en fin de vie de la famille de matière `i`, en %, tel qu'utilisé dans la CFF

## Paramètres retenus pour l’affichage environnemental

r3i : fixé

Rp2 : sectoriel ⇒ voir page dédié + fichier dédié

Rm2,i : par famille de matériaux / par matériaux ⇒ voir explorateur







## Procédés utilisés pour l’affichage environnemental

Les procédés utilisés sont identifiés dans l'[Explorateur de procédé](https://ecobalyse.beta.gouv.fr/#/explore/textile/textile-processes), avec les noms utilisés dans cette page.

