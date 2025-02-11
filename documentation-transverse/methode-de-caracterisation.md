# Méthode de caractérisation

## EF avec suppression des impacts long-terme

La méthode de caractérisation EF 3.1 est utilisée, avec suppression des émissions à long terme lorsque c'est possible.

### Caractérisation des émissions à long terme

Ecoinvent propose pour chaque méthode de caractérisation des impacts une déclinaison avec et une déclinaison sans les impacts des émissions à long terme.

Ceci est transcrit par dans le logiciel SimaPro par exemple, qui propose l'option d'exclure ses émissions des analyses.

_SIMAPRO : There are two ways in which long-term emissions can influence your results. The first one is by not taking the inventoried long-term emissions into account. Practically that is a cut-off for emissions labeled as long-term. The “Exclude long-term emissions” checkbox in the calculation setup (see Figure 3.5) can be used for this. The second way, that long-term emissions can influence your results, is when the SimaPro Tutorial 53 characterization factors in your method are different for long-term emissions. If there are no separate characterization factors for long-term emissions present in the method, all emissions will be treated equally_

#### Définition des émissions "à long terme"

Une émission est classée comme "à long terme" **si elle est rejetée dans l'environnement plus de 100 ans après que les activités considérées dans le cycle de vie ont eu lieu**. Ce qui est déterminant pour la classification « à long terme », c'est donc le moment où une émission est rejetée dans l'environnement et non le moment où elle produit son impact. Elle diffère donc des impacts à long terme qui seraient causés, par exemple, par la bioaccumulation d'un pesticide dans la chaîne alimentaire.

Concrètement, il s'agit des émissions provenant généralement des déchets en décharges, qui sont libérées dans l'air ou s'infiltrent dans les eaux souterraines plus de 100 ans après la mise en décharge. Elles concernent notamment les déchets nucléaires.

Dans ecoinvent, ces émissions à long terme sont déclarées séparément dans deux catégories d'émissions vers la biosphère explicitement désignés comme "à long terme", à savoir "air, faible densité de population, à long terme" et "eau, souterraine, à long terme". Ces échanges sont exclusivement présents dans les ICV sur le traitement des déchets, où l'on suppose que l'entretien actif de la décharge prend fin après 100 ans.

#### Possibilités de prise en compte des émissions "à long terme"

Lors d'un calcul d'impact environnemental sur une durée donnée (de plus de 100 ans), les émissions à long terme sont présentes dans l'environnement 100 ans de moins que les émissions à court terme. De plus, elles ne contribuent pas à l'urgence environnementale actuelle qui concerne de nombreuses catégories d'impact. Leur facteur de caractérisation devrait donc être plus faible.

A ce jour, il n'existe pas de consensus sur la question de savoir si et comment les émissions à long terme doivent être prises en compte, et la méthode EF ne permet pas de distinguer les horizons temporels : les facteurs de caractérisation sont les mêmes pour les émissions à court terme et à long terme.&#x20;

Deux possibilité subsistent donc :

1. Attribuer le même facteur de caractérisation aux émissions à court terme et à long terme, ce qui conduit à une surestimation des impacts.
2. Ne pas attribuer de facteur de caractérisation aux émissions à long terme, ce qui conduit à une sous-estimation des impacts.

#### Justification du choix Ecobalyse

Ecobalyse fait le choix d'exclure les émissions de long terme, afin de privilégier des technologies permettant de répondre aux enjeux de l'urgence environnementale, déjà évalués comme critiques à l'échelle de ce siècle.





