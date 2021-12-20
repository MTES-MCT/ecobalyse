---
description: Changement climatique, et autres impacts à venir...
---

# Impacts considérés

Dans un premier temps, l'outil Wikicarbone s'appuie sur le [référentiel méthodologique de l'ADEME](https://www.base-impact.ademe.fr).

A des fins d'illustration, seul l'impact “**Changement climatique**” est considéré dans un premier temps.

| Impact                | UUID                                   |
| --------------------- | -------------------------------------- |
| Changement climatique | `b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01` |

Les calculs proposés pourraient toutefois s'appliquer aux autres impacts mentionnés dans la Base Impacts®. Cela pourra être envisagé dans un second temps.

| Impact                                             | UUID                                   |   |   |
| -------------------------------------------------- | -------------------------------------- | - | - |
| Acidification                                      | `b5c611c6-def3-11e6-bf01-fe55135034f3` |   |   |
| Appauvrissement de la couche d'ozone               | `b5c629d6-def3-11e6-bf01-fe55135034f3` |   |   |
| Changement climatique - Biogénie                   | `0db6bc32-3f72-48b9-bdb3-617849c2752f` |   |   |
| Changement climatique - Fossile                    | `2105d3ac-c7c7-4c80-b202-7328c14c66e8` |   |   |
| Changement climatique - Usage de sols              | `6f1b7d2a-eb2d-4b86-9b4d-2301b3186400` |   |   |
| Eutrophisation eaux douces                         | `b53ec18f-7377-4ad3-86eb-cc3f4f276b2b` |   |   |
| Eutrophisation marine                              | `b5c619fa-def3-11e6-bf01-fe55135034f3` |   |   |
| Eutrophisation terrestre                           | `b5c614d2-def3-11e6-bf01-fe55135034f3` |   |   |
| Formation d'ozone photochimique                    | `b5c610fe-def3-11e6-bf01-fe55135034f3` |   |   |
| Particules                                         | `b5c602c6-def3-11e6-bf01-fe55135034f3` |   |   |
| Radiations ionisantes                              | `b5c632be-def3-11e6-bf01-fe55135034f3` |   |   |
| Utilisation de ressources fossiles                 | `b2ad6110-c78d-11e6-9d9d-cec0c932ce01` |   |   |
| Utilisation de ressources minérales et métalliques | `b2ad6494-c78d-11e6-9d9d-cec0c932ce01` |   |   |
| Utilisation des sols                               | `b2ad6890-c78d-11e6-9d9d-cec0c932ce01` |   |   |

La base Impacts ne couvre en revanche pas les impacts suivants du référentiel européen PEF

| Impact                                              |
| --------------------------------------------------- |
| Ecotoxicité pour écosystèmes aquatiques d'eau douce |
| Epuisement des ressources en eau                    |
| Toxicité humaine, cancer                            |
| Toxicité humaine, non cancer                        |

## Score PEF

En s'appuyant sur la documentation adossée au projet de PEFCR Apparel & Footwear, tel que mis en consultation à l'été 2021, un calcul d'un score PEF est réalisé, suite aux opérations suivantes :&#x20;

* normalisation de chacun des impacts
* pondération des impacts normalisés pour obtenir le score

{% hint style="warning" %}
Dans un premier temps, les impacts suivants ne sont pas pris en compte car ils n'apparaissent pas dans la base Impacts : épuisement des ressources en eau, ecotoxicité eau douce, toxicité humaine (cancer), toxicité humaine (non cancer).
{% endhint %}

### Normalisation

$$
ImpactNormalisé = Impact / CoefNormalisation
$$

### Pondération

$$
ScorePEF = Somme (ImpactNormalisé * CoefPondération)
$$

### Coefficients

| Impact | Coef de normalisation | Coef de pondération |
| ------ | --------------------- | ------------------- |
|        |                       |                     |
|        |                       |                     |
|        |                       |                     |

