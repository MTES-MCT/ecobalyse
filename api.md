---
description: >-
  Une API HTTP permettant d'interroger le simulateur programmatiquement (version
  alpha)
---

# API

{% hint style="info" %}
Cette API est en version alpha, l'implémentation et le contrat d'interface est susceptible de changer à tout moment. Vous êtes vivement invité à **ne pas exploiter cette API en production**.
{% endhint %}

### Effectuer une simulation

{% swagger method="get" path="/" baseUrl="https://wikicarbone.osc-fr1.scalingo.io" summary="Racine de l'API" %}
{% swagger-description %}
Présente quelques informations sur l'API.
{% endswagger-description %}

{% swagger-response status="200: OK" description="Le serveur est opérationnel" %}
```javascript
{
  "service": "Wikicarbone",
  "documentation": "https://fabrique-numerique.gitbook.io/wikicarbone/api",
  "endpoints": {
    "GET /simulator/": "Simple version of all impacts",
    "GET /simulator/detailed/": "Detailed version for all impacts",
    "GET /simulator/<impact>/": "Simple version for one specific impact"
  }
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="simulator" baseUrl="https://wikicarbone.osc-fr1.scalingo.io/" summary="Effectue une simulation sur un impact précis à partir des paramètres fournis." %}
{% swagger-description %}

{% endswagger-description %}

{% swagger-parameter in="query" name="mass" type="Float" required="true" %}
Masse du produit en kg
{% endswagger-parameter %}

{% swagger-parameter in="query" name="product" type="String" required="true" %}


[Identifiant du produit](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/products.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="material" required="true" type="String" %}


[UUID de matière première](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/materials.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="countries" type="String[]" required="true" %}


[Liste des codes pays pour chaque étape](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/countries.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="dyeingWeighting" type="Float" %}
Taux de majoration du procédé de teinture (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="airTransportRatio" type="Float" %}
Part de transport aérien entre l'étape de confection et de distribution (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="recycledRatio" type="Float" %}
Part de matière recyclée (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[fabric]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Tissage/Tricotage, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[dyeing]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Teinture, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[making]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Confection, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="La simulation a été effectuée avec succès" %}
```javascript
{
  "impacts": {
    "acd": 0.08568167026257227,
    "ccb": 0.0018909961370976002,
    "ccf": 9.237596639851835,
    "cch": 9.239483454407036,
    "ccl": 0,
    "fru": 106.50843780789057,
    "fwe": 0.0006786047744155451,
    "ior": 1.8743227879545548,
    "ldu": 68.35302870158402,
    "mru": 0.000007035159800574921,
    "ozd": 2.8825801148853107e-7,
    "pco": 0.053435901298657204,
    "pma": 0.0000022520072921980913,
    "swe": 0.035825472943942616,
    "tre": 0.2606967172790436
  },
  "query": {
    "mass": 0.17,
    "material": "f211bbdb-415c-46fd-be4d-ddf199575b44",
    "product": "13",
    "countries": ["CN", "CN", "CN", "CN", "FR"],
    "dyeingWeighting": 1.789,
    "airTransportRatio": 0.1234,
    "recycledRatio": 0.567,
    "customCountryMixes": {
      "fabric": null,
      "dyeing": null,
      "making": null
    }
  }
}
```
{% endswagger-response %}

{% swagger-response status="400: Bad Request" description="Les paramètres d'entrée sont invalides" %}
```javascript
{ 
    "error": "Produit non trouvé id=f211bbdb-415c-46fd-be4d-ddf199575b44"
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="simulator/:impact" baseUrl="https://wikicarbone.osc-fr1.scalingo.io/" summary="Effectue une simulation sur tous les impacts à partir des paramètres fournis." %}
{% swagger-description %}
Le paramètre `impact` est le type d'impact étudié, dont le code est parmi les suivants :

`acd`: **Acidification**, unité: `mol éq. H+`

`ozd`: **Appauvrissement de la couche d'ozone**, unité: `kg éq. CFC 11`

`cch`: **Changement climatique**, unité: `kg éq. CO2`

`ccb`: **Changement climatique - Biogénique**, unité: `kg éq. CO2`

`ccf`: **Changement climatique - Fossile**, unité: `kg éq. CO2`

`ccl`: **Changement climatique - Usage des sols**, unité: `kg éq. CO2`

`fwe`: **Eutrophisation eaux douces**, unité: `kg éq. P`

`swe`: **Eutrophisation marine**, unité: `kg éq. N`

`tre`: **Eutrophisation terrestre**, unité: `mol éq. N`

`pco`: **Formation d'ozone photochimique**, unité: `kg éq. COVNM`

`pma`: **Particules**, unité: `incidence de maladie`

`ior`: **Radiations ionisantes**, unité: `éq. kBq U235`

`fru`: **Utilisation de ressources fossiles**, unité: `MJ`

`mru`: **Utilisation de ressources minérales et métalliques**, unité: `kg éq. Sb`

`ldu`: **Utilisation des sols**, unité: `sans dimension (pt)`
{% endswagger-description %}

{% swagger-parameter in="query" name="mass" type="Float" required="true" %}
Masse du produit en kg
{% endswagger-parameter %}

{% swagger-parameter in="query" name="product" type="String" required="true" %}


[Identifiant du produit](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/products.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="material" required="true" type="String" %}


[UUID de matière première](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/materials.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="countries" type="String[]" required="true" %}


[Liste des codes pays pour chaque étape](https://github.com/MTES-MCT/wikicarbone/blob/master/public/data/countries.json)


{% endswagger-parameter %}

{% swagger-parameter in="query" name="dyeingWeighting" type="Float" %}
Taux de majoration du procédé de teinture (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="airTransportRatio" type="Float" %}
Part de transport aérien entre l'étape de confection et de distribution (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="recycledRatio" type="Float" %}
Part de matière recyclée (entre 0 et 1)
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[fabric]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Tissage/Tricotage, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[dyeing]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Teinture, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes[making]" type="Float" %}
Impact du mix énergétique du pays à l'étape de Confection, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="path" name="impact" required="true" %}
Type d'impact à étudier
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="La simulation a été effectuée avec succès" %}
```javascript
{
  "impact": {
    "fwe": 0.0006786047744155451
  },
  "query": {
    "mass": 0.17,
    "material": "f211bbdb-415c-46fd-be4d-ddf199575b44",
    "product": "13",
    "countries": ["CN", "CN", "CN", "CN", "FR"],
    "dyeingWeighting": 1.789,
    "airTransportRatio": 0.1234,
    "recycledRatio": 0.567,
    "customCountryMixes": {
      "fabric": null,
      "dyeing": null,
      "making": null
    }
  }
}
```
{% endswagger-response %}

{% swagger-response status="400: Bad Request" description="Les paramètres d'entrée sont invalides" %}
```javascript
{ 
    "error": "Produit non trouvé id=f211bbdb-415c-46fd-be4d-ddf199575b44"
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="" baseUrl="https://wikicarbone.osc-fr1.scalingo.io/simulator/detailed" summary="Effectue une simulation sur tous les impacts à partir des paramètres fournis et en affiche les résultats détaillés" %}
{% swagger-description %}
Note: les paramètres sont les mêmes que pour le endpoint 

`GET /simulator`

.
{% endswagger-description %}

{% swagger-response status="200: OK" description="La simulation a été effectuée avec succès" %}
```javascript
{
  "inputs": {
    "mass": 0.17,
    "material": {
      "uuid": "f211bbdb-415c-46fd-be4d-ddf199575b44",
      "name": "Fil de coton conventionnel, inventaire partiellement agrégé",
      "shortName": "Coton",
      "category": "Naturelles",
      "materialProcessUuid": "f211bbdb-415c-46fd-be4d-ddf199575b44",
      "recycledProcessUuid": "2b24abb0-c1ec-4298-9b58-350904a26104",
      "primary": true,
      "continent": "Asie - Pacifique",
      "defaultCountry": "CN"
    },
    "product": {
      "id": "13",
      "name": "T-shirt",
      "mass": 0.17,
      "pcrWaste": 0.15,
      "ppm": 0,
      "grammage": 0,
      "knitted": true,
      "fabricProcessUuid": "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5",
      "makingProcessUuid": "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5"
    },
    "countries": [
      {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      }
    ],
    "dyeingWeighting": 1.789,
    "airTransportRatio": 0.1234,
    "recycledRatio": 0.567,
    "customCountryMixes": {
      "fabric": null,
      "dyeing": null,
      "making": null
    }
  },
  "lifeCycle": [
    {
      "label": "Matière & Filature",
      "country": {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      "editable": false,
      "inputMass": 0.26868561370016003,
      "outputMass": 0.21152000000000004,
      "waste": 0.05716561370016,
      "transport": {
        "road": 500,
        "sea": 0,
        "air": 0,
        "impacts": {
          "acd": 0.0002209897504,
          "ccb": 0,
          "ccf": 0.02163257344,
          "cch": 0.02163257344,
          "ccl": 0,
          "fru": 0.30371204960000003,
          "fwe": 4.019028064e-8,
          "ior": 0.001359692864,
          "ldu": 0,
          "mru": 6.533630703999999e-8,
          "ozd": 5.613286032e-12,
          "pco": 0.00019198401280000002,
          "pma": 2.4928583840000004e-9,
          "swe": 0.00009795396016,
          "tre": 0.001067826992
        }
      },
      "impacts": {
        "acd": 0.014516955608960004,
        "ccb": 0.0011581500254976003,
        "ccf": 1.6686864897376006,
        "cch": 1.6698404920928005,
        "ccl": 0,
        "fru": 26.115929108096005,
        "fwe": 0.00018992478395328007,
        "ior": 1.5593541940288003,
        "ldu": 67.89065729158402,
        "mru": 0.000004978183123616001,
        "ozd": 1.4054212628096003e-7,
        "pco": 0.004936623559795201,
        "pma": 2.938944966524801e-7,
        "swe": 0.009677265313219203,
        "tre": 0.032814402464764816
      },
      "heat": 0,
      "kwh": 0,
      "processInfo": {
        "electricity": null,
        "heat": null,
        "dyeing": null,
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "impacts": {
            "acd": 0.00518438,
            "ccb": 0,
            "ccf": 1.20941,
            "cch": 1.20941,
            "ccl": 0,
            "fru": 16.6229,
            "fwe": 1.52e-7,
            "ior": 0.0400805,
            "ldu": 0,
            "mru": 6.13605e-8,
            "ozd": 1.11302e-11,
            "pco": 0.00600068,
            "pma": 2.01468e-8,
            "swe": 0.00215675,
            "tre": 0.0236048
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "airTransport"
        },
        "seaTransport": {
          "cat1": "Transport",
          "cat2": "Maritime",
          "cat3": "Flotte moyenne",
          "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
          "impacts": {
            "acd": 0.000766767,
            "ccb": 0,
            "ccf": 0.0483042,
            "cch": 0.0483042,
            "ccl": 0,
            "fru": 0.255129,
            "fwe": 4.33885e-9,
            "ior": 0.000481343,
            "ldu": 0,
            "mru": 1.47513e-9,
            "ozd": 4.90964e-11,
            "pco": 0.000526131,
            "pma": 5.99782e-9,
            "swe": 0.000186192,
            "tre": 0.00203843
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "seaTransport"
        },
        "roadTransport": {
          "cat1": "Transport",
          "cat2": "Routier",
          "cat3": "Flotte moyenne continentale",
          "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO",
          "uuid": "cf6e9d81-358c-4f44-5ab7-0e7a89440576",
          "impacts": {
            "acd": 0.00208954,
            "ccb": 0,
            "ccf": 0.204544,
            "cch": 0.204544,
            "ccl": 0,
            "fru": 2.87171,
            "fwe": 3.80014e-7,
            "ior": 0.0128564,
            "ldu": 0,
            "mru": 6.17779e-7,
            "ozd": 5.30757e-11,
            "pco": 0.00181528,
            "pma": 2.35709e-8,
            "swe": 0.000926191,
            "tre": 0.0100967
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPreMaking"
        }
      },
      "dyeingWeighting": 1,
      "airTransportRatio": 0,
      "customCountryMix": null
    },
    {
      "label": "Tissage & Tricotage",
      "country": {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      "editable": true,
      "inputMass": 0.21152,
      "outputMass": 0.2,
      "waste": 0.01152,
      "transport": {
        "road": 500,
        "sea": 0,
        "air": 0,
        "impacts": {
          "acd": 0.00020895400000000002,
          "ccb": 0,
          "ccf": 0.0204544,
          "cch": 0.0204544,
          "ccl": 0,
          "fru": 0.287171,
          "fwe": 3.80014e-8,
          "ior": 0.00128564,
          "ldu": 0,
          "mru": 6.177790000000001e-8,
          "ozd": 5.30757e-12,
          "pco": 0.000181528,
          "pma": 2.3570900000000006e-9,
          "swe": 0.00009261910000000001,
          "tre": 0.00100967
        }
      },
      "impacts": {
        "acd": 0.0043011312,
        "ccb": 0,
        "ccf": 0.5075424,
        "cch": 0.5075424,
        "ccl": 0,
        "fru": 5.123328000000001,
        "fwe": 1.0620384e-8,
        "ior": 0.031176672000000002,
        "ldu": 0,
        "mru": 4.0874496e-8,
        "ozd": 3.0297072e-13,
        "pco": 0.0031157616,
        "pma": 1.5938736e-7,
        "swe": 0.0011300592000000002,
        "tre": 0.012332352
      },
      "heat": 0,
      "kwh": 0.48,
      "processInfo": {
        "electricity": "Mix électrique réseau, CN",
        "heat": null,
        "dyeing": null,
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "impacts": {
            "acd": 0.00518438,
            "ccb": 0,
            "ccf": 1.20941,
            "cch": 1.20941,
            "ccl": 0,
            "fru": 16.6229,
            "fwe": 1.52e-7,
            "ior": 0.0400805,
            "ldu": 0,
            "mru": 6.13605e-8,
            "ozd": 1.11302e-11,
            "pco": 0.00600068,
            "pma": 2.01468e-8,
            "swe": 0.00215675,
            "tre": 0.0236048
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "airTransport"
        },
        "seaTransport": {
          "cat1": "Transport",
          "cat2": "Maritime",
          "cat3": "Flotte moyenne",
          "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
          "impacts": {
            "acd": 0.000766767,
            "ccb": 0,
            "ccf": 0.0483042,
            "cch": 0.0483042,
            "ccl": 0,
            "fru": 0.255129,
            "fwe": 4.33885e-9,
            "ior": 0.000481343,
            "ldu": 0,
            "mru": 1.47513e-9,
            "ozd": 4.90964e-11,
            "pco": 0.000526131,
            "pma": 5.99782e-9,
            "swe": 0.000186192,
            "tre": 0.00203843
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "seaTransport"
        },
        "roadTransport": {
          "cat1": "Transport",
          "cat2": "Routier",
          "cat3": "Flotte moyenne continentale",
          "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO",
          "uuid": "cf6e9d81-358c-4f44-5ab7-0e7a89440576",
          "impacts": {
            "acd": 0.00208954,
            "ccb": 0,
            "ccf": 0.204544,
            "cch": 0.204544,
            "ccl": 0,
            "fru": 2.87171,
            "fwe": 3.80014e-7,
            "ior": 0.0128564,
            "ldu": 0,
            "mru": 6.17779e-7,
            "ozd": 5.30757e-11,
            "pco": 0.00181528,
            "pma": 2.35709e-8,
            "swe": 0.000926191,
            "tre": 0.0100967
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPreMaking"
        }
      },
      "dyeingWeighting": 1,
      "airTransportRatio": 0,
      "customCountryMix": null
    },
    {
      "label": "Teinture",
      "country": {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      "editable": true,
      "inputMass": 0.2,
      "outputMass": 0.2,
      "waste": 0,
      "transport": {
        "road": 1000,
        "sea": 0,
        "air": 0,
        "impacts": {
          "acd": 0.00041790800000000004,
          "ccb": 0,
          "ccf": 0.0409088,
          "cch": 0.0409088,
          "ccl": 0,
          "fru": 0.574342,
          "fwe": 7.60028e-8,
          "ior": 0.00257128,
          "ldu": 0,
          "mru": 1.2355580000000001e-7,
          "ozd": 1.061514e-11,
          "pco": 0.000363056,
          "pma": 4.714180000000001e-9,
          "swe": 0.00018523820000000002,
          "tre": 0.00201934
        }
      },
      "impacts": {
        "acd": 0.058037999736783336,
        "ccb": 0.0007328461116,
        "ccf": 6.063615002004,
        "cch": 6.064347814204,
        "ccl": 0,
        "fru": 64.74797896181335,
        "fwe": 0.0004884555817526369,
        "ior": 0.23487442693478136,
        "ldu": 0.46237141000000004,
        "mru": 0.0000016313752518741332,
        "ozd": 1.474884333444713e-7,
        "pco": 0.038537028139764666,
        "pma": 0.0000015987513771031332,
        "swe": 0.022423895070644666,
        "tre": 0.18724442723186668
      },
      "heat": 21.575552,
      "kwh": 3.4724316666666666,
      "processInfo": {
        "electricity": "Mix électrique réseau, CN",
        "heat": "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), RSA",
        "dyeing": "Procédé 100% majorant",
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "impacts": {
            "acd": 0.00518438,
            "ccb": 0,
            "ccf": 1.20941,
            "cch": 1.20941,
            "ccl": 0,
            "fru": 16.6229,
            "fwe": 1.52e-7,
            "ior": 0.0400805,
            "ldu": 0,
            "mru": 6.13605e-8,
            "ozd": 1.11302e-11,
            "pco": 0.00600068,
            "pma": 2.01468e-8,
            "swe": 0.00215675,
            "tre": 0.0236048
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "airTransport"
        },
        "seaTransport": {
          "cat1": "Transport",
          "cat2": "Maritime",
          "cat3": "Flotte moyenne",
          "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
          "impacts": {
            "acd": 0.000766767,
            "ccb": 0,
            "ccf": 0.0483042,
            "cch": 0.0483042,
            "ccl": 0,
            "fru": 0.255129,
            "fwe": 4.33885e-9,
            "ior": 0.000481343,
            "ldu": 0,
            "mru": 1.47513e-9,
            "ozd": 4.90964e-11,
            "pco": 0.000526131,
            "pma": 5.99782e-9,
            "swe": 0.000186192,
            "tre": 0.00203843
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "seaTransport"
        },
        "roadTransport": {
          "cat1": "Transport",
          "cat2": "Routier",
          "cat3": "Flotte moyenne continentale",
          "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], GLO",
          "uuid": "cf6e9d81-358c-4f44-5ab7-0e7a89440576",
          "impacts": {
            "acd": 0.00208954,
            "ccb": 0,
            "ccf": 0.204544,
            "cch": 0.204544,
            "ccl": 0,
            "fru": 2.87171,
            "fwe": 3.80014e-7,
            "ior": 0.0128564,
            "ldu": 0,
            "mru": 6.17779e-7,
            "ozd": 5.30757e-11,
            "pco": 0.00181528,
            "pma": 2.35709e-8,
            "swe": 0.000926191,
            "tre": 0.0100967
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPreMaking"
        }
      },
      "dyeingWeighting": 1.789,
      "airTransportRatio": 0,
      "customCountryMix": null
    },
    {
      "label": "Confection",
      "country": {
        "code": "CN",
        "name": "Chine",
        "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
        "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
        "dyeingWeighting": 1,
        "airTransportRatio": 0.33
      },
      "editable": true,
      "inputMass": 0.2,
      "outputMass": 0.17,
      "waste": 0.03,
      "transport": {
        "road": 0,
        "sea": 18888.9768,
        "air": 1011.88,
        "impacts": {
          "acd": 0.003354000466428952,
          "ccb": 0,
          "ccf": 0.36315309967023524,
          "cch": 0.36315309967023524,
          "ccl": 0,
          "fru": 3.6787159883812244,
          "fwe": 4.007957348807561e-8,
          "ior": 0.008440284626973209,
          "ldu": 0,
          "mru": 1.529203704478728e-8,
          "ozd": 1.5956934184771842e-10,
          "pco": 0.0027217075362973363,
          "pma": 2.272540055847792e-8,
          "swe": 0.000968889254918752,
          "tre": 0.01060614394041208
        }
      },
      "impacts": {
        "acd": 0.004480345,
        "ccb": 0,
        "ccf": 0.52869,
        "cch": 0.52869,
        "ccl": 0,
        "fru": 5.3368,
        "fwe": 1.10629e-8,
        "ior": 0.0324757,
        "ldu": 0,
        "mru": 4.25776e-8,
        "ozd": 3.155945e-13,
        "pco": 0.003245585,
        "pma": 1.660285e-7,
        "swe": 0.001177145,
        "tre": 0.0128462
      },
      "heat": 0,
      "kwh": 0.5,
      "processInfo": {
        "electricity": "Mix électrique réseau, CN",
        "heat": null,
        "dyeing": null,
        "airTransportRatio": "33% de transport aérien",
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "impacts": {
            "acd": 0.00518438,
            "ccb": 0,
            "ccf": 1.20941,
            "cch": 1.20941,
            "ccl": 0,
            "fru": 16.6229,
            "fwe": 1.52e-7,
            "ior": 0.0400805,
            "ldu": 0,
            "mru": 6.13605e-8,
            "ozd": 1.11302e-11,
            "pco": 0.00600068,
            "pma": 2.01468e-8,
            "swe": 0.00215675,
            "tre": 0.0236048
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "airTransport"
        },
        "seaTransport": {
          "cat1": "Transport",
          "cat2": "Maritime",
          "cat3": "Flotte moyenne",
          "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
          "impacts": {
            "acd": 0.000766767,
            "ccb": 0,
            "ccf": 0.0483042,
            "cch": 0.0483042,
            "ccl": 0,
            "fru": 0.255129,
            "fwe": 4.33885e-9,
            "ior": 0.000481343,
            "ldu": 0,
            "mru": 1.47513e-9,
            "ozd": 4.90964e-11,
            "pco": 0.000526131,
            "pma": 5.99782e-9,
            "swe": 0.000186192,
            "tre": 0.00203843
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "seaTransport"
        },
        "roadTransport": {
          "cat1": "Transport",
          "cat2": "Routier",
          "cat3": "Flotte moyenne continentale",
          "name": "Transport en camion (dont parc, utilisation et infrastructure) (50%) [tkm], RER",
          "uuid": "c0397088-6a57-eea7-8950-1d6db2e6bfdb",
          "impacts": {
            "acd": 0.00128435,
            "ccb": 0,
            "ccf": 0.156105,
            "cch": 0.156105,
            "ccl": 0,
            "fru": 2.26004,
            "fwe": 1.79964e-7,
            "ior": 0.0113717,
            "ldu": 0,
            "mru": 4.6569e-7,
            "ozd": 3.95377e-11,
            "pco": 0.00111635,
            "pma": 1.26451e-8,
            "swe": 0.000580492,
            "tre": 0.00647978
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPostMaking"
        }
      },
      "dyeingWeighting": 1,
      "airTransportRatio": 0.1234,
      "customCountryMix": null
    },
    {
      "label": "Distribution",
      "country": {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      "editable": false,
      "inputMass": 0.17,
      "outputMass": 0.17,
      "waste": 0,
      "transport": {
        "road": 500,
        "sea": 0,
        "air": 0,
        "impacts": {
          "acd": 0.00014338650000000002,
          "ccb": 0,
          "ccf": 0.022913875000000004,
          "cch": 0.022913875000000004,
          "ccl": 0,
          "fru": 0.3404607,
          "fwe": 8.4513715e-9,
          "ior": 0.0027848975000000003,
          "ldu": 0,
          "mru": 7.618728500000001e-8,
          "ozd": 4.5727960000000005e-11,
          "pco": 0.00014262745,
          "pma": 1.6560295000000002e-9,
          "swe": 0.000072407845,
          "tre": 0.00075635465
        }
      },
      "impacts": {
        "acd": 0,
        "ccb": 0,
        "ccf": 0,
        "cch": 0,
        "ccl": 0,
        "fru": 0,
        "fwe": 0,
        "ior": 0,
        "ldu": 0,
        "mru": 0,
        "ozd": 0,
        "pco": 0,
        "pma": 0,
        "swe": 0,
        "tre": 0
      },
      "heat": 0,
      "kwh": 0,
      "processInfo": {
        "electricity": null,
        "heat": null,
        "dyeing": null,
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "impacts": {
            "acd": 0.00518438,
            "ccb": 0,
            "ccf": 1.20941,
            "cch": 1.20941,
            "ccl": 0,
            "fru": 16.6229,
            "fwe": 1.52e-7,
            "ior": 0.0400805,
            "ldu": 0,
            "mru": 6.13605e-8,
            "ozd": 1.11302e-11,
            "pco": 0.00600068,
            "pma": 2.01468e-8,
            "swe": 0.00215675,
            "tre": 0.0236048
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "airTransport"
        },
        "seaTransport": {
          "cat1": "Transport",
          "cat2": "Maritime",
          "cat3": "Flotte moyenne",
          "name": "Transport maritime de conteneurs 27,500 t (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "8dc4ce62-ff0f-4680-897f-867c3b31a923",
          "impacts": {
            "acd": 0.000766767,
            "ccb": 0,
            "ccf": 0.0483042,
            "cch": 0.0483042,
            "ccl": 0,
            "fru": 0.255129,
            "fwe": 4.33885e-9,
            "ior": 0.000481343,
            "ldu": 0,
            "mru": 1.47513e-9,
            "ozd": 4.90964e-11,
            "pco": 0.000526131,
            "pma": 5.99782e-9,
            "swe": 0.000186192,
            "tre": 0.00203843
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "seaTransport"
        },
        "roadTransport": {
          "cat1": "Transport",
          "cat2": "Routier",
          "cat3": "Flotte moyenne française",
          "name": "Transport en camion non spécifié France (dont parc, utilisation et infrastructure) (50%) [tkm], FR",
          "uuid": "f49b27fa-f22e-c6e1-ab4b-e9f873e2e648",
          "impacts": {
            "acd": 0.0016869,
            "ccb": 0,
            "ccf": 0.269575,
            "cch": 0.269575,
            "ccl": 0,
            "fru": 4.00542,
            "fwe": 9.94279e-8,
            "ior": 0.0327635,
            "ldu": 0,
            "mru": 8.96321e-7,
            "ozd": 5.37976e-10,
            "pco": 0.00167797,
            "pma": 1.94827e-8,
            "swe": 0.000851857,
            "tre": 0.00889829
          },
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "distribution"
        }
      },
      "dyeingWeighting": 0,
      "airTransportRatio": 0,
      "customCountryMix": null
    }
  ],
  "impacts": {
    "acd": 0.08568167026257227,
    "ccb": 0.0018909961370976002,
    "ccf": 9.237596639851835,
    "cch": 9.239483454407036,
    "ccl": 0,
    "fru": 106.50843780789057,
    "fwe": 0.0006786047744155451,
    "ior": 1.8743227879545548,
    "ldu": 68.35302870158402,
    "mru": 0.000007035159800574921,
    "ozd": 2.8825801148853107e-7,
    "pco": 0.053435901298657204,
    "pma": 0.0000022520072921980913,
    "swe": 0.035825472943942616,
    "tre": 0.2606967172790436
  },
  "transport": {
    "road": 2500,
    "sea": 18888.9768,
    "air": 1011.88,
    "impacts": {
      "acd": 0.0043452387168289525,
      "ccb": 0,
      "ccf": 0.46906274811023524,
      "cch": 0.46906274811023524,
      "ccl": 0,
      "fru": 5.184401737981225,
      "fwe": 2.027254256280756e-7,
      "ior": 0.01644179499097321,
      "ldu": 0,
      "mru": 3.421493290847873e-7,
      "ozd": 2.2683329787971844e-10,
      "pco": 0.0036009029990973366,
      "pma": 3.3945558442477925e-8,
      "swe": 0.001417108360078752,
      "tre": 0.015459335582412082
    }
  }
}
```
{% endswagger-response %}
{% endswagger %}
