---
description: >-
  Changement climatique, et autres impacts couverts par la base Impacts. Calcul
  d'un score PEF.
---

# Impacts considérés

Dans un premier temps, l'outil Wikicarbone s'appuie sur le [référentiel méthodologique de l'ADEME](https://www.base-impact.ademe.fr).

Cela permet que soient pris en compte les 15 impacts suivants.

| Acidification                                      | `b5c611c6-def3-11e6-bf01-fe55135034f3` | mol H+ eq          |   |
| -------------------------------------------------- | -------------------------------------- | ------------------ | - |
| Appauvrissement de la couche d'ozone               | `b5c629d6-def3-11e6-bf01-fe55135034f3` | kg CFC-11 eq       |   |
| Changement climatique                              | `b2ad6d9a-c78d-11e6-9d9d-cec0c932ce01` | kg CO2 eq          |   |
| Changement climatique - Biogénie                   | `0db6bc32-3f72-48b9-bdb3-617849c2752f` | kg CO2 eq          |   |
| Changement climatique - Fossile                    | `2105d3ac-c7c7-4c80-b202-7328c14c66e8` | kg CO2 eq          |   |
| Changement climatique - Usage de sols              | `6f1b7d2a-eb2d-4b86-9b4d-2301b3186400` | kg CO2 eq          |   |
| Eutrophisation eaux douces                         | `b53ec18f-7377-4ad3-86eb-cc3f4f276b2b` | kg P eq            |   |
| Eutrophisation marine                              | `b5c619fa-def3-11e6-bf01-fe55135034f3` | kg N eq            |   |
| Eutrophisation terrestre                           | `b5c614d2-def3-11e6-bf01-fe55135034f3` | mol N eq           |   |
| Formation d'ozone photochimique                    | `b5c610fe-def3-11e6-bf01-fe55135034f3` | kg NMVOC eq        |   |
| Particules                                         | `b5c602c6-def3-11e6-bf01-fe55135034f3` | disease incidences |   |
| Radiations ionisantes                              | `b5c632be-def3-11e6-bf01-fe55135034f3` | kg Bq-U235 eq      |   |
| Utilisation de ressources fossiles                 | `b2ad6110-c78d-11e6-9d9d-cec0c932ce01` | MJ                 |   |
| Utilisation de ressources minérales et métalliques | `b2ad6494-c78d-11e6-9d9d-cec0c932ce01` | kg Sb eq           |   |
| Utilisation des sols                               | `b2ad6890-c78d-11e6-9d9d-cec0c932ce01` | pt                 |   |

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

| Impact                                              | Coef de normalisation                                                | Coef de pondération                 |
| --------------------------------------------------- | -------------------------------------------------------------------- | ----------------------------------- |
| Changement climatique                               | 8,10E+03 kg CO2e                                                     | 21,06 %                             |
| Appauvrissement de la couche d'ozone                | 5,36E-02 kg CFC-11                                                   | 6,31 %                              |
| Toxicité humaine (cancer)                           | <p>1,69E-05<br>Non pris en compte</p>                                | <p>2,13 %<br>Non pris en compte</p> |
| Toxicité humaine (non cancer)                       | <p>2,30E-04<br>Non pris en compte</p>                                | <p>1,84 %<br>Non pris en compte</p> |
| Particules                                          | 5,95E-04 diseases incicences                                         | 8,96 %                              |
| Radiations ionisantes                               | 4,22E+03 kBq U-235 eq                                                | 5,01 %                              |
| Formation d'ozone photochimique                     | 4,01E+01 kg NMVOC eq                                                 | 4,78 %                              |
| Acidification                                       | 5,56E+01 mol H+eq                                                    | 6,20 %                              |
| Eutrophisation terrestre                            | 1,77E+02 mol N eq                                                    | 3,71 %                              |
| Eutrophisation eaux douces                          | 1,61E+00 kg P eq                                                     | 2,80 %                              |
| Eutrophisation marine                               | 1,95E+01 kg N eq                                                     | 2,96 %                              |
| Utilisation des sols                                | 8,19E+05 pt                                                          | 7,94 %                              |
| Ecotoxicité eaux douces                             | <p>4,27E+04 CTUe<br>Non pris en compte</p>                           | <p>1,92 %<br>Non pris en compte</p> |
| Epuisement des ressources en eau                    | <p>1,15E+04 m3 water eq of deprived water <br>Non pris en compte</p> | <p>8,51 %<br>Non pris en compte</p> |
| Utilisation de ressources fossiles                  | 6,50E+04 MJ                                                          | 8,32 %                              |
| Utilisation des ressources minérales et métalliques | 6,36E-02 kg Sb eq                                                    | 7,55 %                              |

{% hint style="info" %}
Les 3 sous-indicateurs du changement climatique (biongénique, fossile, usage des sols) ne sont pas considérés pour la normalisation et la pondération PEF
{% endhint %}

