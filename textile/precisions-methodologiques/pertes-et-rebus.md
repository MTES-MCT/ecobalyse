---
description: Vision d'ensemble de la gestion des pertes et rebut dans l'outil
---

# 🗑️ Taux de perte et rebut

A chaque étape de la production, des pertes et rebut sont pris en compte. Les formules de calcul sont développées dans chaque page dédiée au procédé en question (cf. tableau ci-après) :

| Masse entrante | Masse sortante | Procédé                                                                                                    |
| -------------- | -------------- | ---------------------------------------------------------------------------------------------------------- |
| Non applicable | Matière        | [Matière](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-1-matieres) |
| Matière        | Fil            | [Filature](../cycle-de-vie-des-produits-textiles/etape-2-fabrication-du-fil-1.md)                          |
| Fil            | Etoffe         | [Tricotage / Tissage](../cycle-de-vie-des-produits-textiles/tricotage-tissage.md)                          |
| Etoffe         | Tissu          | [Teinture](../cycle-de-vie-des-produits-textiles/ennoblissement-1/)                                        |
| Tissu          | Habit          | [Confection](../cycle-de-vie-des-produits-textiles/confection.md)                                          |
| Habit          | Habit          | [Distribution](../cycle-de-vie-des-produits-textiles/distribution.md)                                      |

{% hint style="info" %}
Dans cette documentation le taux de perte $$T$$ vaut :

&#x20;$$T=\frac{m_{perte}}{m_{entrante}}$$

Un taux de perte $$T$$ de 10% correspond à ce cas de figure :&#x20;

m\_entrante -> procédé -> m\_sortante

1 kg -> procédé -> 0.9 kg
{% endhint %}

## Calcul des masses

Le paramètre proposé dans le paramétrage du calculateur en ligne est la masse du vêtement, donc la masse à la fin des différentes étapes.&#x20;

Le calcul des masses se fait donc **en remontant la chaîne de production** : d'abord la masse du vêtement, puis la masse d'étoffe, puis la masse de fil, puis la masse de matière première.

Pour remonter la chaîne de production, on déduit la masse entrante à partir de la masse sortante et du taux de perte $$T$$ de l'étape en utilisant cette formule :\
\
$$m_{entrante} = \frac{m_{sortante}}{1- T}$$





&#x20;
