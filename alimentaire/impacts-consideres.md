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
*   les niveaux des 3 indicateurs de toxicité (écotoxicité, toxicité humaine cancer, toxicité humaine non cancer) sont réhaussés proportionnellement de façons à ce que la somme des 3 fasse 12,5% ;

    _Cette modification revient environ à doubler la pondération de ces 3 indicateurs (\*2,12)._
*   les autres pondérations sont proportionnels aux pondérations PEF initiales, mais réduite afin que la somme des pondérations reste bien à 100%

    _Cette modification revient environ à réduire de 43% la pondération des 12 indicateurs concernés_.

<figure><img src="../.gitbook/assets/Pondérations score d&#x27;impacts - score PEF.png" alt=""><figcaption><p>Pondérations comparées des impacts considérés pour le score PEF (EF 3.1) et le score d'impacts</p></figcaption></figure>

| Indicateur                                          | Pondération score PEF (%) | Pondération score d'impacts (%) |
| --------------------------------------------------- | ------------------------- | ------------------------------- |
| Changement climatique                               | 21,06                     | **21,06**                       |
| Biodiversité locale (BVI)                           | N/A                       | **12,5**                        |
| Biodiversité marine                                 | N/A                       | **12,5**                        |
| Appauvrissement de la couche d'ozone                | 6,31                      | 3,58                            |
| Toxicité humaine (cancer)                           | 2,13                      | **4,52**                        |
| Toxicité humaine (non cancer)                       | 1,84                      | **3,90**                        |
| Particules                                          | 8,96                      | 5,08                            |
| Radiations ionisantes                               | 5,01                      | 2,84                            |
| Formation d'ozone photochimique                     | 4,78                      | 2,71                            |
| Acidification                                       | 6,20                      | 3,52                            |
| Eutrophisation terrestre                            | 3,71                      | 2,10                            |
| Eutrophisation eaux douces                          | 2,80                      | 1,59                            |
| Eutrophisation marine                               | 2,96                      | 1,68                            |
| Utilisation des sols                                | 7,94                      | 4,50                            |
| Écotoxicité eaux douces                             | 1,92                      | **4,07**                        |
| Épuisement des ressources en eau                    | 8,51                      | 4,83                            |
| Utilisation de ressources fossiles                  | 8,32                      | 4,72                            |
| Utilisation des ressources minérales et métalliques | 7,55                      | 4,28                            |

