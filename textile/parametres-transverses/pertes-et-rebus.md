---
description: Vision d'ensemble de la gestion des pertes et rebut dans l'outil
---

# 🗑 Pertes et rebut

A chaque étape de la production, des pertes et rebut sont pris en compte. Les formules de calcul sont développées dans chaque page dédiée au procédé en question (cf. tableau ci-après) :

| Masse entrante   | Masse sortante | Procédé                                                               |
| ---------------- | -------------- | --------------------------------------------------------------------- |
| Matière première | Fil            | [Matière et filature](../etapes-du-cycle-de-vie/filature/)            |
| Fil              | Etoffe         | [Tricotage / Tissage](../etapes-du-cycle-de-vie/tricotage-tissage.md) |
| Etoffe           | Tissu          | [Teinture](../etapes-du-cycle-de-vie/teinture.md)                     |
| Tissu            | Habit          | [Confection](../etapes-du-cycle-de-vie/confection.md)                 |
| Habit            | Habit          | [Distribution](../etapes-du-cycle-de-vie/distribution.md)             |

Le paramètre proposé dans le paramétrage du calculateur en ligne est la masse d'habit, donc la masse à la fin des différentes étapes. Le calcul des masses se fait donc **en remontant la chaîne de production** : d'abord la masse de tissu, puis la masse d'étoffe, puis la masse de fil, puis la masse de matière première.
