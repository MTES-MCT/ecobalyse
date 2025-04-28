---
hidden: true
---

# Paramétrage

Le paramétrage peut se faire "de zéro" (produit personnalisé) ou mobiliser la fonction "exemples" de l'outil qui permet de partir d'un produit pré-paramétré.

<figure><img src="../../.gitbook/assets/image (309).png" alt=""><figcaption></figcaption></figure>



<details>

<summary>Analyse numérique</summary>

```

Bonus_diversité_agricole = 0.5 * 2.3 * 4.14 
Bonus_diversité_agricole = 4.76 µPts d'impacts


Bonus_infra_agro_écologique = 0.7 * 2.3 * 4.14 
Bonus_infra_agro_écologique = 6.67 µPts d'impacts

Bonus_cond_élevage = 0.3 * 1.5 * 4.14 
Bonus_cond_élevage = 1.86 µPts d'impacts


Bonus_total = Bonus_diversité_agricole + Bonus_infra_agro_écologique + Bonus_cond_élevage
Bonus_total = 4.76 + 6.67 + 1.86
Bonus_total = 13.3 µPts d'impacts

```

On a finalement :

```
Score d'impacts avant bonus = 97.04 µPts d'impact

Score d'impacts après bonus = Score d'impacts avant bonus - Bonus_total
Score d'impacts après bonus = 97.04 - 13.3
Score d'impacts après bonus = 83.74 µPts d'impact
```

</details>

