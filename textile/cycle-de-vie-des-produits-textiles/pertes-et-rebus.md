---
description: Vision d'ensemble de la gestion des pertes et rebut dans l'outil
---

# 🗑️ Pertes et rebut

A chaque étape de la production, des pertes et rebut sont pris en compte. Les formules de calcul sont développées dans chaque page dédiée au procédé en question (cf. tableau ci-après) :

| Masse entrante | Masse sortante | Procédé                                                                                                               |
| -------------- | -------------- | --------------------------------------------------------------------------------------------------------------------- |
| Non applicable | Matière        | [Matière](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-1-matieres)            |
| Matière        | Fil            | [Filature](https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil) |
| Fil            | Etoffe         | [Tricotage / Tissage](tricotage-tissage.md)                                                                           |
| Etoffe         | Tissu          | [Teinture](ennoblissement/)                                                                                           |
| Tissu          | Habit          | [Confection](confection.md)                                                                                           |
| Habit          | Habit          | [Distribution](distribution.md)                                                                                       |

Le paramètre proposé dans le paramétrage du calculateur en ligne est la masse du vêtement, donc la masse à la fin des différentes étapes. Le calcul des masses se fait donc **en remontant la chaîne de production** : d'abord la masse du vêtement, puis la masse d'étoffe, puis la masse de fil, puis la masse de matière première.



{% hint style="danger" %}
Dans cette documentation les taux de pertes sont exprimés de cette manière  $$Tx_{entrante}=m_{perte}/m_{entrante}$$, que l'on nommera taux de perte "masse entrante". 10% de taux de perte "masse entrante" correspond à ce cas de figure :&#x20;

* 1 kg -> procédé -> 0.9 kg

Mais dans les procédés visibles sur github le paramètre \`waste\` correspond à une autre définition du taux de perte qui vient de la Base Impacts : le taux de perte "masse sortante" :  $$Tx_{sortante}=m_{perte}/m_{sortante}$$

![](<../../.gitbook/assets/image (111).png>)&#x20;

Un taux de perte "masse sortante" de 10% (un paramètre \`waste\` de 10%) correspond à ce cas de figure :

* 1,1 kg -> procédé -> 1 kg

Ce qui correspond à un taux de perte "masse entrante" de 0.1/1.1\~9%



On peut montrer que&#x20;

$$Tx_{entrante}= \frac{Tx_{sortante}}{1+Tx_{sortante}}$$
{% endhint %}





&#x20;
