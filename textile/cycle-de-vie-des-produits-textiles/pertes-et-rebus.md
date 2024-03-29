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
