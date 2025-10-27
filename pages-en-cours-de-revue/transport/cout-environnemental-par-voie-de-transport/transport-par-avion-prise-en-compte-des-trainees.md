---
hidden: true
---

# ✈️ Transport par avion - prise en compte des trainées

## Contexte

Les trainées de condensation des avions (contrails en anglais) sont les traces blanche que l'on aperçoit dans le ciel derrière les avions. Ces trainées, contribuent au  changement climatique. &#x20;

Actuellement les procédés de transport aérien ecoinvent omettent l'impact de ces trainées sur le climat. Nous proposons donc une première approche simplifiée pour les intégrer dans la méthode du "cout environnemental". Des travaux plus approfondis sont en cours au niveau de la base empreinte, et permettront de préciser la modélisation de ce phénomène à l'avenir.&#x20;

### Plus d'information sur les trainées d'avion

Le schéma suivant illustre le phénomène à l'oeuvre :

<figure><img src="../../../.gitbook/assets/liens_entre_aviation_et_climat_strapi.webp" alt=""><figcaption><p>Illustration des trainées d'avion, réalisée par Carbone 4 pour un <a href="https://www.carbone4.com/analyse-faq-aviation-climat">article dédié à ce sujet</a></p></figcaption></figure>

Une étude de 2021 estime que les trainée d'avion et autres impacts "hors CO2" représentent un forçage radiatif de 57.4 mW/m2 contre 34.3mW/m2 pour les émissions de CO2 à la combustion, avec de fortes incertitudes sur les impact hors CO2 (entre 17 et 98 mW/m2 pour l'impact des trainées). Une étude publiée en 2024 sur les trainées de 2029 à 2021 évalue l'impact des trainées à 62.1mW/m2, avec de fortes différences entre les régions du monde. Notamment, le forcage radiatif du aux trainées est évalué à 876 mW m2 en Europe.&#x20;

**Principale documentation  :**

* [Rapport de synthèse sur les connaissances sur les trainées](https://rmi.org/insight/understanding-contrail-management-opportunities-challenges-and-insights/?submitted=1#thank-you), RMI, groupe de travail rassemblant divers types d'acteurs (entreprises du secteur aérien, ONG, instituts de recherche...)
* Article scientifiques de référence sur le sujet :
  * [The contribution of global aviation to anthropogenic climate forcing for 2000 to 2018, D.S. Lee & al, Atmospheric Environment, Volume 244, 2021](https://www.sciencedirect.com/science/article/pii/S1352231020305689).
  * [Global aviation contrail climate effects from 2019 to 2021 Roger Teoh et al (2024)](https://acp.copernicus.org/articles/24/6071/2024/)

## Création du procédé Ecobalyse

Le procédé ecoinvent 3.9.1 "`market for transport, freight, aircraft, long haul, GLO`" est modifié pour y ajouter des émissions de CO2 `e_{CO2,trainées}` modélisant "artificiellement" l'impact des trainées. Ces émissions s'ajoutent aux émissions issus de la combustion du carburant.&#x20;

$$
e_{CO2,trainées} = e_{CO2,combustion} * \frac{RF_{trainées}}{RF_{CO2,combustion}}
$$

Avec :

* `e_{CO2,trainées}` les émissions de CO2 ajoutées au procédé pour modéliser l'impact des trainées.
* `RF_{CO2,combustion}` le forcage radiatif retenu pour les trainées : 57.4 mW/m2
* `RF_{trainées}` le forcage radiatif retenu relatif aux émissions directes de CO2 à la combustion : 34.3mW/m2
* `e_{CO2,combustion}` les émissions de CO2 à la combustion pour ce procédé : 0.6282 kg/tkm

$$
e_{CO2,trainées} = 1.001
$$



