---
description: Comment calculer l'impact matière en prenant en compte le terme M3 de la CFF ?
---

# 📚 Recyclage des vêtements en fin de vie - M3

Voici la partie de la CFF qui prend en compte l'impact du recyclage en fin de vie.

$$
M_{3} = (1-A)*R_{2}*(E_{recyEOL} - E^*_{v} * \frac{Qsout}{Qp})
$$

{% hint style="info" %}
Ce terme est négligé étant donné son impact faible. Pour plus de justification dans la section suivante
{% endhint %}

### Définition des paramètres

* **R2** - le taux de matière recyclé en fin de vie
* **ErecyEOL** - impacts dues au recyclage en fin de vie : la collecte, le tri et le processus de recyclage
* **E\*v** - impacts dues à la production de matière vierge substitué par le recyclage.
* **Qsout/Qp** - Rapport de qualité entre la matière substitué (Qp) et la matière recyclé substituan (Qsout)

### Filières de recyclage

Il est possible qu'un produit ait plusieurs filières de recyclage. Dans ce cas il faut appliquer le terme M3 pour chaque filière de recyclage.

![PEFCR A\&F - v1.2 - ligne 1131](<../../../.gitbook/assets/Screenshot 2022-03-16 at 16.27.52.png>)

3 filières de recyclage sont identifiés pour les vêtements dans le PEFCR A\&F :

* Vêtement -> Vêtement
* Vêtement -> Wiper
* Vêtement -> Insulation

![PEFCR A\&F - v1.2 - Filières de recyclage des vêtements](<../../../.gitbook/assets/Screenshot 2022-03-16 at 17.09.18.png>)

On remarque que les seules filières avec un taux de recyclage non nuls sont la filière Wiper et Insulation.

#### Filière Wiper

Estimons l'impact de la prise en compte du recyclage sur la filière Wiper pour un vêtement d'1kg de coton primaire.

L'impact estimé de l'étape de matière et filature hors CFF est de `1.82 mPt` PEF.

Estimons l'impact du terme M3 de la CFF.

On fait les hypothèses suivantes :

Le coton recyclé remplace du coton primaire pour le wiper

```
M3_wiper = (1-A) * R2  * ( Erecy_wiper - E*v * Qout/Qp)
M3_wiper = (1-0.8) * 5% * ( 0.44 - 1.82 * 0.3)
M3_wiper = - 0.001 mPt
```

Ainsi le terme M3\_wiper réduit l'impact 0.001 mPt soit de 0.05%.

Etant donné cet impact négligeable, on ne prend pas en compte la filière de reyclage en wiper dans le calcul de l'impact matière des vêtements.

#### Filière Isolant

Faute de données sur l'impact de la production de laine de verre, on ne prend pas en compte cette filière de recyclage.
