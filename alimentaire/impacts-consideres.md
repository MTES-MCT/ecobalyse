# Indicateurs d'impacts

## Indicateurs PEF

16 indicateurs environnementaux sont actuellement modélisés sur Ecobalyse Alimentaire, conformément au référentiel méthodologique du PEF (_Product Environmental Footprint_) de la commission européenne.

## Indicateur de biodiversité locale

Les 16 indicateurs du PEF sont complétés afin de mieux prendre en compte l'impact sur la biodiversité locale (à la parcelle). Cet indicateur est calculé selon la méthodologie décrite dans cet article de recherche : [Lindner et al. 2019, Valuing Biodiversity in Life Cycle Impact Assessment](https://www.researchgate.net/publication/336523544\_Valuing\_Biodiversity\_in\_Life\_Cycle\_Impact\_Assessment)

## Indicateur d'impacts sur la biodiversité marine

La pression sur les espèces marines n'est pas pris en compte, en l'état, à travers les 16 indicateurs PEF et l'indicateur de biodiversité locale. Des travaux sont en cours afin de proposer un tel indicateur.

## Indicateurs d'impacts agrégés

À partir des indicateurs d'impacts unitaires, deux indicateurs agrégés sont considérés :&#x20;

* le score PEF, tel que défini dans le recommandation de la Commission européenne de décembre 2021 ;
* un score d'impacts défini pour introduire les indicateurs de biodiversité avec les 16 indicateurs PEF.&#x20;

Les modalités de calcul du score PEF, avec les facteurs de normalisation et de pondération, sont rappelés dans la page suivante : [https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef](https://fabrique-numerique.gitbook.io/ecobalyse/textile/impacts-consideres#score-pef)

Pour le score d'impacts, les facteurs de normalisation du score PEF sont conservés. Les pondérations sont définies comme suit. En première approche :&#x20;

* la pondération du changement climatique est maintenue à 21,06%, afin que le poids relatif de cet impact ne soit pas diminué par l'ajout d'impacts biodiversité ;
* les indicateurs d'impacts biodiversité sont introduits avec une pondération double à la moyenne des 16 indicateurs PEF initiaux (12,5%) ;
* les autres pondérations sont proportionnels aux pondérations PEF initiales, mais réduite afin que la somme des pondérations reste bien à 100%.

![](<../.gitbook/assets/image (1) (1) (1).png>)

| Indicateur                                          | Pondération score PEF (%) | Pondération score d'impacts (%) |
| --------------------------------------------------- | ------------------------- | ------------------------------- |
| Changement climatique                               | 21,06                     | 21,06                           |
| Biodiversité locale (BVI)                           | N/A                       | 12,5                            |
| Biodiversité marine                                 | N/A                       | 12,5                            |
| Appauvrissement de la couche d'ozone                | 6,31                      | 4,31                            |
| Toxicité humaine (cancer)                           | 2,13                      | 1,46                            |
| Toxicité humaine (non cancer)                       | 1,84                      | 1,26                            |
| Particules                                          | 8,96                      | 6,12                            |
| Radiations ionisantes                               | 5,01                      | 3,42                            |
| Formation d'ozone photochimique                     | 4,78                      | 3,27                            |
| Acidification                                       | 6,20                      | 4,24                            |
| Eutrophisation terrestre                            | 3,71                      | 2,54                            |
| Eutrophisation eaux douces                          | 2,80                      | 1,91                            |
| Eutrophisation marine                               | 2,96                      | 2,02                            |
| Utilisation des sols                                | 7,94                      | 5,43                            |
| Écotoxicité eaux douces                             | 1,92                      | 1,31                            |
| Épuisement des ressources en eau                    | 8,51                      | 5,81                            |
| Utilisation de ressources fossiles                  | 8,32                      | 5,69                            |
| Utilisation des ressources minérales et métalliques | 7,55                      | 5,16                            |

### \[ARCHIVE] Poids avec biodiversité locale

| Indicateur                                          | Poids (%) |
| --------------------------------------------------- | --------- |
| Impact biodiversité                                 | 17,4      |
| Changement climatique                               | 17,4      |
| Appauvrissement de la couche d'ozone                | 5,2       |
| Toxicité humaine (cancer)                           | 1,8       |
| Toxicité humaine (non cancer)                       | 1,5       |
| Particules                                          | 7,4       |
| Radiations ionisantes                               | 4,1       |
| Formation d'ozone photochimique                     | 3,9       |
| Acidification                                       | 5,1       |
| Eutrophisation terrestre                            | 3,1       |
| Eutrophisation eaux douces                          | 2,3       |
| Eutrophisation marine                               | 2,4       |
| Utilisation des sols                                | 6,6       |
| Écotoxicité eaux douces                             | 1,6       |
| Épuisement des ressources en eau                    | 7,0       |
| Utilisation de ressources fossiles                  | 6,9       |
| Utilisation des ressources minérales et métalliques | 6,2       |

