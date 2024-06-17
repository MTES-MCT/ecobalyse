# Compléments hors ACV

Ces compléments hors ACV visent à prendre en compte les **externalités environnementales positives de certains modes de production** telles que désignées dans l’[article 2 de la loi Climat et résilience](https://www.legifrance.gouv.fr/jorf/article\_jo/JORFARTI000043956979). Ces externalités positives ne sont aujourd'hui pas intégrées à l'ACV. Pourtant, elles sont essentielles pour appréhender au mieux l'impact systémique de l'agriculture, notamment à l'échelle des territoires. En effet, les pratiques agricoles façonnent grandement les écosystèmes et les paysages, que ce soit en termes de biodiversité (maintien de zones refuges, de corridors écologiques, d'une mosaïque paysagère diversifiée, etc.) ou en termes de résilience face aux aléas divers (préservation contre l'érosion des sols, bouclage des cycles et moindre dépendance à certains nutriments exogènes, régulation naturelle des ravageurs de cultures, etc.). Cinq compléments sont ainsi ajoutés pour prendre en compte ces effets.

## Complément "haies"&#x20;

### Données

{% hint style="info" %}
\=> rédaction : s'inspirer de [https://docs.google.com/presentation/d/1AIVziRc9jjjSMEVS3wpCRSjmrbjWQWf6Ow9YpC7CxPc/edit#slide=id.g2a035ff3f7c\_0\_16](https://docs.google.com/presentation/d/1AIVziRc9jjjSMEVS3wpCRSjmrbjWQWf6Ow9YpC7CxPc/edit#slide=id.g2a035ff3f7c\_0\_16)&#x20;
{% endhint %}

### Formule

### Agrégation au coût environnemental

* $$c_i$$ : le coefficient permettant de moduler l'ampleur du bonus, il ne dépend pas du produit p.$$x_{diversité-agricole}(poulet -bio) = 0.5$$

## Complément "taille des parcelles"

### Données

### Formule

### Agrégation au coût environnemental

## Complément "diversité agricole"

### Données

### Formule

### Agrégation au coût environnemental

## Complément "prairies"

### Données

### Formule

### Agrégation au coût environnemental

## Complément "densité territoriale en élevage"

### Données

### Formule

### Agrégation au coût environnemental

## Exemples de calcul des compléments



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

