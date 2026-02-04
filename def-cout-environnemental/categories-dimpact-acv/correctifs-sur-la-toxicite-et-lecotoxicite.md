# Correctifs sur la toxicité et l'écotoxicité

#### Suppression des indicateurs de toxicité humaine

La modélisation des impacts de toxicité humaine (toxicité humaine cancer et toxicité humaine non-cancer) dans la méthode PEF n'est aujourd'hui pas satisfaisante. Dans l'attente de consolider ces deux indicateurs, il est proposé de les supprimer dans le calcul du coût environnemental.

#### Rehaussement de la pondération de l'écotoxicité à 21%

En revanche, l'indicateur d'écotoxicité (écotoxicité eau douce), est lui considéré comme plus robuste par la communauté scientifique, bien que partiel puisque ne prend pas en compte l'ensemble des impacts écotoxiques, notamment sur les milieux terrestres (polinisateurs par exemple).

Par ailleurs, l'absence d'un indicateur de "biodiversité locale" dans le cadre ACV actuellement justifie de considérer temporairement cet indicateur d'écotoxicité comme un "proxy" de la biodiversité locale. Il est donc proposé de rehausser sa pondération à hauteur de 21%, c'est-à-dire au même niveau que l'impact changement climatique.

#### Différenciation de la part organique-inorganique

En outre, une différenciation est introduite entre les deux composantes de l'écotoxicité. Celle-ci vient de molécules organiques et dCorrectifs sur la toxicité et l'écotoxicitée molécules inorganiques. Une écotoxicité corrigée est considérée dans le coût environnemental avec un doublement de l'impact des molécules organiques.

$$
EcotoxCorrigée = EcotoxInorganique + 2* EcotoxOrganique
$$

Cette modification vient traduire le fait que le niveau de caractérisation et de quantification des effets écotoxiques des molécules organiques et inorgraniques est aujourd'hui différent. Les molécules inorganiques sont bien caractérisés et leurs effets écotoxiques bien quantifiés. Les molécules organiques sont souvent moins bien caractérisées, avec des effets écotoxiques qui sont aujourd'hui établis mais pas nécessairement pleinement quantifiés : effets cocktails, impacts sur les polinisateurs, perturbateurs endocriniens...

#### Recalcul du facteur de normalisation

Pour respecter le cadre le facteur de normalisation a été recalculé pour bien couvrir l'ensemble de l'écotoxicité corrigée à l'échelle mondiale, après doublement de la contribution liée à l'écotoxicité organiques. Cette modification du facteur de normalisation permet que le doublement de la contribution des molécules organiques à l'écotoxicité ne constitue pas une augmentation masquée de la pondération de l'écotoxicité, mais plutôt une modification des parts relatives liées aux molécules organiques et inorganiques.

Au final, le facteur de normalisation de l'ecotoxicité corrigée $$N_{ecotox\_corrigée}$$ est  :&#x20;

$$N_{ecotox\_corrigée} = N_{inorganique} + 2 * N_{organique}$$

&#x20; $$N_{ecotox\_corrigée}$$  = 15 313 + 2 \* 41 403 = 98 120 CTUe

#### Impact sur chaque composante

On avait $$N_{ecotox}$$ = 56 716 CTUe

D'où $$N_{ecotox\_corrigée} = 1.73 * N_{ecotox}$$

| Composante  | Calcul        | Variation |
| ----------- | ------------- | --------- |
| Organique   | 1 \* 2 /1.73  | +16%      |
| Inorganique | 1/1.73        | -42%      |

Le coefficients de pondération et de normalisation, y compris ceux de l'écotoxicité et de l'écotoxicité corrigée sont détaillés dans la rubrique "impacts" de l'explorateur : [https://ecobalyse.beta.gouv.fr/#/explore/food/impacts](https://ecobalyse.beta.gouv.fr/#/explore/food/impacts)
