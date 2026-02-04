# Correctifs sur la toxicité et l'écotoxicité

La modélisation des impacts de toxicité humaine (toxicité humaine cancer et toxicité humaine non-cancer) dans la méthode PEF n'est aujourd'hui pas satisfaisante. Dans l'attente de consolider ces deux indicateurs, il est proposé de les supprimer dans le calcul du coût environnemental.

En revanche, l'indicateur d'écotoxicité (écotoxicité eau douce), est lui considéré comme plus robuste par la communauté scientifique, bien que partiel puisque ne prend pas en compte l'ensemble des impacts écotoxiques, notamment sur les milieux terrestres (polinisateurs par exemple). Par ailleurs, l'absence d'un indicateur de "biodiversité locale" dans le cadre ACV actuellement justifie de considérer temporairement cet indicateur d'écotoxicité comme un "proxy" de la biodiversité locale. Il est donc proposé de rehausser sa pondération à hauteur de 21%, c'est-à-dire au même niveau que l'impact changement climatique.

En outre, une différenciation est introduite entre les deux composantes de l'écotoxicité. Celle-ci vient de molécules organiques et de molécules inorganiques. Une écotoxicité corrigée est considérée dans le coût environnemental avec un doublement de l'impact des molécules organiques. Cette modification vient traduire le fait que le niveau de caractérisation et de quantification des effets écotoxiques des molécules organiques et inorgraniques est aujourd'hui différent. Les molécules inorganiques sont bien caractérisés et leurs effets écotoxiques bien quantifiés. Les molécules organiques sont souvent moins bien caractérisées, avec des effets écotoxiques qui sont aujourd'hui établis mais pas nécessairement pleinement quantifiés : effets cocktails, impacts sur les polinisateurs, perturbateurs endocriniens...

$$
EcotoxCorrigée = EcotoxInorganiques + 2* EcotoxOrganiques
$$

Pour respecter le cadre le facteur de normalisation a été recalculé pour bien couvrir l'ensemble de l'écotoxicité corrigée à l'échelle mondiale, après doublement de la contribution liée à l'écotoxicité organiques. Cette modification du facteur de normalisation permet que le doublement de la contribution des molécules organiques à l'écotoxicité ne constitue pas une augmentation masquée de la pondération de l'écotoxicité, mais plutôt une modification des parts relatives liées aux molécules organiques et inorganiques.

Au final, le facteur de normalisation de l'ecotoxicité "ajustée" est le suivant :&#x20;

N<sub>ecotox</sub> = N<sub>inorg</sub> + 2 x N<sub>org</sub>  soit 15 313 + 2x 41403 = 98120 pts

&#x20;Au final, l'effet est le suivant :

* composante organique : 1\*2/1,7 => +17%
* composante inorganique : 1/1,7 => -42%

Le coefficents de pondération et de normalisation, y compris ceux de l'écotoxicité et de l'écotoxicité corrigée sont détaillés dans la rubrique "impacts" de l'explorateur : [https://ecobalyse.beta.gouv.fr/#/explore/food/impacts](https://ecobalyse.beta.gouv.fr/#/explore/food/impacts)
