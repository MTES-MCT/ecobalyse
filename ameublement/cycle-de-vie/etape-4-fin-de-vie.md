---
icon: bin-recycle
---

# Etape 4 : Fin de vie

La fin de vie d'un meuble dépend de 3 paramètres clés :&#x20;

* la présence de perturbateur(s) de recyclage,
* la composition,
* le taux de collecte.

### Présence de perturbateur de recyclage

Si un meuble propose au moins un perturbateur de recyclage, alors le meuble ne peut pas suivre les débouchés spécifiques de la filière REP des éléments d'ameublement.&#x20;

Dès lors, le meuble est considéré comme "non recyclable" et le scénario par défaut ci-dessous s'applique.

{% hint style="info" %}
Déchets d'éléments d'ameublement (scénario par défaut)

Lorsqu'un meuble n'est pas recyclable ou qu'une matière ne dispose pas de filière spécifique en fin de vie, un scénario par défaut est appliqué.

Ce scénario se base sur la fin de vie moyenne des déchets en sortie de déchèterie en France en 2021 :&#x20;

* 75% incinération
* 25% enfouissement

Source : rapport "La collecte des déchets par le service public en France en 2021" / p. 38/50).&#x20;
{% endhint %}

&#x20;:eyes: La liste des perturbateurs de recyclage est proposée par les organismes de la filière REP. &#x20;

:bulb: L'utilisateur a la possibilité de préciser si son produit est "recyclable" ou "non recyclable". Lorsqu'au moins un perturbateur de recyclage est présent dans le meuble, ce dernier est considéré comme "non recyclable".&#x20;

### Composition

Lorsqu'un meuble est collecté par la filière et est recyclable (c'est à dire que le meuble ne présente pas d'éléments perturbateur de recyclage), les scénarios de fin de vie sont spécifiques aux matières entrant dans la composition du produit.&#x20;

4 grandes familles de matière (bois, métal, rembourré/matelas/mousse, plastique) proposent des scénarios spécifiques. Les autres matières proposent le scénario par défaut "Autres" qui reprend la fin de vie des déchets d'éléments d'ameublement.&#x20;

<table><thead><tr><th width="264">Matière</th><th>% recyclage</th><th>% incinération</th><th>% enfouissement</th></tr></thead><tbody><tr><td>Bois</td><td>71%</td><td>29%</td><td>0%</td></tr><tr><td>Métal</td><td>100%</td><td>0%</td><td>0%</td></tr><tr><td>Rembourré/Matelas/Mousse</td><td>3%</td><td>97%</td><td>0%</td></tr><tr><td>Plastique</td><td>92%</td><td>9%</td><td>1%</td></tr><tr><td><a data-footnote-ref href="#user-content-fn-1">Autres</a></td><td>0%</td><td>75%</td><td>25%</td></tr></tbody></table>

Source : Filière des éléments d'ameublement \_ données 2022 (Bilan annuel 2023)

### Taux de collecte

Un taux de collecte de 40% est appliqué par défaut pour l'ensemble des meubles.

Ce taux de collecte correspond à la moyenne des éléments d'ameublement collectés séparément par la filière REP (ex : bennes d'éléments d'ameublement en déchetterie, dépôt de meubles chez un distributeur, etc.).&#x20;

Les meubles non collectés (60% des cas) sont considérés comme terminant leur vie en décheterie sous la forme d'encombrants sans tri spécifique à chaque matière. Dès lors, le scénario par défaut des déchets d'éléments d'ameublement est proposé (75% incinération / 25% enfouissement).

### Illustration de la fin de vie d'un meuble&#x20;

Une chaise de salon de 2kg, recyclable, et composée à 80% de bois et à 20% de textile proposera comme scénarios de fin de vie :&#x20;

* Recyclage bois : 4,4544kg (2kg \* 40% \* 80% \* 71%)\
  Via le taux de collecte de 40%, il est considéré qu'une telle chaise sera collectée par la filière dans 40% des cas. Dès lors, les scénarios de fin de vie spécifiques au bois (71% de recyclage et 29% d'incinération) sont applicables sur la partie du meuble collectée (\* 40%) et en bois (\*80%).&#x20;
* Incinération bois : 0,1856 kg (2kg \* 40% \* 80% \* 29%)\
  Même raisonnement que ci-dessus.
* Incinération mix matières : 1,02 kg (2kg \* 40% \* 20% \* 75% + 2kg \* 60% \* 75%)\
  La partie en textile de la chaise (20%) est traitée dans le scénario matière "Autres"; c'est à dire à 75% en incinération et 25% en enfouissement. La première partie de la formule reflète cela.\
  La seconde partie de la formule (2kg \* 60% \* 75%) se concentre sur la partie du meuble qui n'est pas collectée (1 - 40% = 60%). Le scénario par défaut des déchets d'éléménts d'ameublement s'applique donc (75% en incinération et 25% en enfouissement).&#x20;
* Enfouissement mix matières : 0,34 kg (2kg \* 40% \* 20% \* 25% + 2kg \* 60% \* 25%)\
  Même raisonnement que ci-dessus.&#x20;

### Procédés mobilisés pour la fin de vie

<table data-full-width="true"><thead><tr><th width="183">Scénario</th><th>Procédé Ecoinvent</th></tr></thead><tbody><tr><td>Autres déchets (incinération)</td><td>1 kilogram of Municipal solid waste {FR}| treatment of municipal solid waste, municipal incineration | Cut-off, U</td></tr><tr><td>Autres déchets (enfouissement)</td><td>1 kilogram of Municipal solid waste {RoW}| treatment of municipal solid waste, sanitary landfill | Cut-off, U</td></tr><tr><td>Plastique (incinération)</td><td>1 kilogram of Waste plastic, mixture {CH}| treatment of waste plastic, mixture, municipal incineration FAE | Cut-off, U</td></tr><tr><td>Plastique (enfouissement)</td><td>1 kilogram of Waste plastic, mixture {CH}| treatment of waste plastic, mixture, sanitary landfill | Cut-off, U</td></tr><tr><td>Plastique (recyclage)</td><td>1 kilogram of Polyethylene, high density, granulate, recycled {US}| polyethylene production, high density, granulate, recycled | Cut-off, U</td></tr><tr><td>Métal (recyclage)</td><td>1 kilogram of Aluminium scrap, post-consumer, prepared for melting {RER}| treatment of aluminium scrap, post-consumer, by collecting, sorting, cleaning, pressing | Cut-off, U</td></tr><tr><td>Bois (incinération)</td><td>1 kilogram of Waste wood, untreated {CH}| treatment of waste wood, untreated, municipal incineration FAE | Cut-off, U</td></tr><tr><td>Bois (recyclage)</td><td>1 kilogram of Wood chips, from post-consumer wood, measured as dry mass {CH}| treatment of waste wood, post-consumer, sorting and shredding | Cut-off, U</td></tr><tr><td>Rembourré / Matelas / Mousse (incinération)</td><td>1 kilogram of Waste polyurethane {CH}| treatment of waste polyurethane, municipal incineration FAE | Cut-off, U</td></tr></tbody></table>

<figure><img src="../../.gitbook/assets/Coût environnemental des procédés de fin de vie (uPts _ kg) (2).png" alt=""><figcaption></figcaption></figure>

&#x20;

[^1]: Application du scénario par défaut des déchets d'éléments d'ameublement
