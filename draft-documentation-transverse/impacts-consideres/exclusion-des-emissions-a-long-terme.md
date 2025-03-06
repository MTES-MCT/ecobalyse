---
description: >-
  La méthode de caractérisation EF 3.1 est utilisée, avec suppression des
  émissions à long terme lorsque c'est possible. Cette page décrit ce que sont
  les émissions à long terme et explique ce choix.
---

# Exclusion des émissions à long terme

Ecoinvent propose pour chaque méthode de caractérisation des impacts une déclinaison avec et une déclinaison sans les impacts des émissions à long terme.

Ceci est transcrit par dans le logiciel SimaPro par exemple, qui propose l'option d'exclure ses émissions des analyses.

## Définition des émissions "à long terme"

Une émission est classée comme "à long terme" **si elle est rejetée dans l'environnement plus de 100 ans après que les activités considérées dans le cycle de vie ont eu lieu**. Ce qui est déterminant pour la classification « à long terme », c'est donc le moment où une émission est rejetée dans l'environnement et non le moment où elle produit son impact. Elle diffère donc des impacts à long terme qui seraient causés, par exemple, par la bioaccumulation d'un pesticide dans la chaîne alimentaire.

Concrètement, il s'agit des émissions provenant généralement des déchets en décharges, qui sont libérées dans l'air ou s'infiltrent dans les eaux souterraines plus de 100 ans après la mise en décharge. Elles concernent notamment les déchets nucléaires.

Dans ecoinvent, ces émissions à long terme sont déclarées séparément dans deux catégories d'émissions vers la biosphère explicitement désignés comme "à long terme", à savoir "air, faible densité de population, à long terme" et "eau, souterraine, à long terme". Ces échanges sont exclusivement présents dans les ICV sur le traitement des déchets, où l'on suppose que l'entretien actif de la décharge prend fin après 100 ans.

## Possibilités de prise en compte des émissions "à long terme"

Lors d'un calcul d'impact environnemental sur une durée donnée (de plus de 100 ans), les émissions à long terme sont présentes dans l'environnement 100 ans de moins que les émissions à court terme. De plus, elles ne contribuent pas à l'urgence environnementale actuelle qui concerne de nombreuses catégories d'impact. Leur facteur de caractérisation devrait donc être plus faible.

A ce jour, il n'existe pas de consensus sur la question de savoir si et comment les émissions à long terme doivent être prises en compte. **Il n'y a pas de recommandation à l'échelle européenne sur ce sujet.**

La méthode EF ne permet par ailleurs pas de distinguer les horizons temporels : les facteurs de caractérisation sont les mêmes pour les émissions à court terme et à long terme.&#x20;

Deux possibilité subsistent donc :

1. Attribuer le même facteur de caractérisation aux émissions à court terme et à long terme, ce qui conduit à une surestimation des impacts.
2. Ne pas attribuer de facteur de caractérisation aux émissions à long terme, ce qui conduit à une sous-estimation des impacts.

## Justification du choix Ecobalyse

Le document suivant liste les arguments pour et contre les deux approches : [Implementation of Life Cycle Impact Assessment Methods](exclusion-des-emissions-a-long-terme.md#https-esu-services.ch-fileadmin-download-publiclci-03_lcia-implementation.pdf), 2007, ecoinvent, partie II.2.1.3, pages 5 à 10.

Ecobalyse fait le choix d'exclure les émissions à long terme, principalement pour les raisons suivantes :&#x20;

* Les ICV EF3.1 pour l'électricité n'incluent pas les émissions à long terme
* Souhait de privilégier des technologies permettant de répondre aux enjeux de l'urgence environnementale actuelle, déjà évalués comme critiques à l'échelle de ce siècle (effondrement de la biodiversité, changements climatiques, raréfaction des énergies fossiles)&#x20;
* Très forte incertitude sur ces émissions, avec certaines hypothèses qui sont de nature conservatrices. Par exemple, l'impact des radiations ionisantes à faible intensité est évalué comme deux à dix fois plus faible que les radiations de forte intensité, et c'est l'hypothèse d'un impact deux fois plus faible qui est retenu (méthode de caractérisation du FRU, [Human health damages due to ionising radiation in life cycle impact assessment](https://esu-services.ch/fileadmin/download/frischknecht-2000-HumanHealth.pdf), page 10-11)
* Il s'agit d'une pratique déjà courante chez les praticiens ACV

