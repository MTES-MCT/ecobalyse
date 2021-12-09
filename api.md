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

{% swagger method="get" path="" baseUrl="https://wikicarbone.osc-fr1.scalingo.io/" summary="" %}
{% swagger-description %}
Effectue une simulation à partir des paramètres fournis.
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
    "co2": 4.380278341466434,
    "inputs": {
        "airTransportRatio": null,
        "countries": [
            {
                "airTransportRatio": 0.33,
                "code": "CN",
                "dyeingWeighting": 1,
                "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
                "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
                "name": "Chine"
            },
            {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            }
        ],
        "dyeingWeighting": null,
        "mass": 0.17,
        "material": {
            "category": "Naturelles",
            "materialProcessUuid": "f211bbdb-415c-46fd-be4d-ddf199575b44",
            "name": "Fil de coton conventionnel, inventaire partiellement agrégé",
            "primary": true,
            "recycledProcessUuid": "2b24abb0-c1ec-4298-9b58-350904a26104",
            "shortName": "Coton",
            "uuid": "f211bbdb-415c-46fd-be4d-ddf199575b44"
        },
        "product": {
            "fabricProcessUuid": "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5",
            "grammage": 0,
            "id": "13",
            "knitted": true,
            "makingProcessUuid": "26e3ca02-9bc0-45b4-b8b4-73f4b3701ad5",
            "mass": 0.17,
            "name": "T-shirt",
            "pcrWaste": 0.15,
            "ppm": 0
        }
    },
    "lifeCycle": [
        {
            "airTransportRatio": 0,
            "co2": 3.4625612480000005,
            "country": {
                "airTransportRatio": 0.33,
                "code": "CN",
                "dyeingWeighting": 1,
                "electricityProcessUuid": "8f923f3d-0bd2-4326-99e2-f984b4454226",
                "heatProcessUuid": "2e8de6f6-0ea1-455b-adce-ea74d307d222",
                "name": "Chine"
            },
            "customCountryMix": null,
            "dyeingWeighting": 1,
            "editable": false,
            "heat": 0,
            "inputMass": 0.25407803552,
            "kwh": 0,
            "label": "Matière & Filature",
            "outputMass": 0.21152,
            "processInfo": {
                "dyeing": null,
                "electricity": null,
                "heat": null
            },
            "transport": {
                "air": 0,
                "co2": 0.220162474866432,
                "road": 0,
                "sea": 21548
            },
            "waste": 0.04255803552
        },
        {
            "airTransportRatio": 0,
            "co2": 0.0390348,
            "country": {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            "customCountryMix": null,
            "dyeingWeighting": 0,
            "editable": true,
            "heat": 0,
            "inputMass": 0.21152,
            "kwh": 0.48,
            "label": "Tissage & Tricotage",
            "outputMass": 0.2,
            "processInfo": {
                "dyeing": null,
                "electricity": "Mix électrique réseau, FR",
                "heat": null
            },
            "transport": {
                "air": 0,
                "co2": 0.0204544,
                "road": 500,
                "sea": 0
            },
            "waste": 0.01152
        },
        {
            "airTransportRatio": 0,
            "co2": 0.5540614061,
            "country": {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            "customCountryMix": null,
            "dyeingWeighting": 0,
            "editable": true,
            "heat": 5.174,
            "inputMass": 0.2,
            "kwh": 0.3983333333333334,
            "label": "Teinture",
            "outputMass": 0.2,
            "processInfo": {
                "dyeing": "Procédé représentatif",
                "electricity": "Mix électrique réseau, FR",
                "heat": "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR"
            },
            "transport": {
                "air": 0,
                "co2": 0.0409088,
                "road": 1000,
                "sea": 0
            },
            "waste": 0
        },
        {
            "airTransportRatio": 0,
            "co2": 0.0069124125,
            "country": {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            "customCountryMix": null,
            "dyeingWeighting": 0,
            "editable": true,
            "heat": 0,
            "inputMass": 0.2,
            "kwh": 0.085,
            "label": "Confection",
            "outputMass": 0.17,
            "processInfo": {
                "dyeing": null,
                "electricity": "Mix électrique réseau, FR",
                "heat": null
            },
            "transport": {
                "air": 0,
                "co2": 0.013268925,
                "road": 500,
                "sea": 0
            },
            "waste": 0.03
        },
        {
            "airTransportRatio": 0,
            "co2": 0,
            "country": {
                "airTransportRatio": 0,
                "code": "FR",
                "dyeingWeighting": 0,
                "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
                "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
                "name": "France"
            },
            "customCountryMix": null,
            "dyeingWeighting": 0,
            "editable": false,
            "heat": 0,
            "inputMass": 0.17,
            "kwh": 0,
            "label": "Distribution",
            "outputMass": 0.17,
            "processInfo": {
                "dyeing": null,
                "electricity": null,
                "heat": null
            },
            "transport": {
                "air": 0,
                "co2": 0.022913875000000004,
                "road": 500,
                "sea": 0
            },
            "waste": 0
        }
    ],
    "transport": {
        "air": 0,
        "co2": 0.31770847486643206,
        "road": 2500,
        "sea": 21548
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

#### Exemple de requête

```
$ http https://wikicarbone.osc-fr1.scalingo.io/?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countries[]=CN&countries[]=FR&countries[]=FR&countries[]=FR&countries[]=FR&dyeingWeighting=&airTransportRatio=&recycledRatio=&customCountryMixes[fabric]=&customCountryMixes[dyeing]=&customCountryMixes[making]=
```

#### Exemple de réponse

```json
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
      "primary": true
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
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
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
    "dyeingWeighting": null,
    "airTransportRatio": null,
    "recycledRatio": null,
    "customCountryMixes": { "fabric": 0.1, "dyeing": 0.2, "making": 0.3 }
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
      "inputMass": 0.25407803552,
      "outputMass": 0.21152,
      "waste": 0.04255803552,
      "transport": { "road": 0, "sea": 21548, "air": 0, "co2": 0.220162474866432, "fwe": 1.9775753538496e-8 },
      "co2": 3.4625612480000005,
      "fwe": 0.0003359487552,
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
          "climateChange": 1.20941,
          "freshwaterEutrophication": 1.52e-7,
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
          "climateChange": 0.0483042,
          "freshwaterEutrophication": 4.33885e-9,
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
          "climateChange": 0.204544,
          "freshwaterEutrophication": 3.80014e-7,
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
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      "editable": true,
      "inputMass": 0.21152,
      "outputMass": 0.2,
      "waste": 0.01152,
      "transport": { "road": 500, "sea": 0, "air": 0, "co2": 0.0204544, "fwe": 3.80014e-8 },
      "co2": 0.04800000000000001,
      "fwe": 1.5691056e-8,
      "heat": 0,
      "kwh": 0.48,
      "processInfo": {
        "electricity": "Mix électrique personnalisé: 0,100 kgCO₂e/KWh",
        "heat": null,
        "dyeing": null,
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "climateChange": 1.20941,
          "freshwaterEutrophication": 1.52e-7,
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
          "climateChange": 0.0483042,
          "freshwaterEutrophication": 4.33885e-9,
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
          "climateChange": 0.204544,
          "freshwaterEutrophication": 3.80014e-7,
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPreMaking"
        }
      },
      "dyeingWeighting": 0,
      "airTransportRatio": 0,
      "customCountryMix": 0.1
    },
    {
      "label": "Teinture",
      "country": {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      "editable": true,
      "inputMass": 0.2,
      "outputMass": 0.2,
      "waste": 0,
      "transport": { "road": 1000, "sea": 0, "air": 0, "co2": 0.0409088, "fwe": 7.60028e-8 },
      "co2": 0.6013346102666667,
      "fwe": 0.000016010311140506667,
      "heat": 5.174,
      "kwh": 0.3983333333333334,
      "processInfo": {
        "electricity": "Mix électrique personnalisé: 0,200 kgCO₂e/KWh",
        "heat": "Mix Vapeur (mix technologique|mix de production, en sortie de chaudière), FR",
        "dyeing": "Procédé représentatif",
        "airTransportRatio": null,
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "climateChange": 1.20941,
          "freshwaterEutrophication": 1.52e-7,
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
          "climateChange": 0.0483042,
          "freshwaterEutrophication": 4.33885e-9,
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
          "climateChange": 0.204544,
          "freshwaterEutrophication": 3.80014e-7,
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPreMaking"
        }
      },
      "dyeingWeighting": 0,
      "airTransportRatio": 0,
      "customCountryMix": 0.2
    },
    {
      "label": "Confection",
      "country": {
        "code": "FR",
        "name": "France",
        "electricityProcessUuid": "05585055-9742-4fff-81ff-ad2e30e1b791",
        "heatProcessUuid": "12fc43f2-a007-423b-a619-619d725793ea",
        "dyeingWeighting": 0,
        "airTransportRatio": 0
      },
      "editable": true,
      "inputMass": 0.2,
      "outputMass": 0.17,
      "waste": 0.03,
      "transport": { "road": 500, "sea": 0, "air": 0, "co2": 0.013268925, "fwe": 1.5296940000000002e-8 },
      "co2": 0.15,
      "fwe": 1.634485e-8,
      "heat": 0,
      "kwh": 0.5,
      "processInfo": {
        "electricity": "Mix électrique personnalisé: 0,300 kgCO₂e/KWh",
        "heat": null,
        "dyeing": null,
        "airTransportRatio": "Aucun transport aérien",
        "airTransport": {
          "cat1": "Transport",
          "cat2": "Aérien",
          "cat3": "Flotte moyenne",
          "name": "Transport aérien long-courrier (dont flotte, utilisation et infrastructure) [tkm], GLO",
          "uuid": "839b263d-5111-4318-9275-7026937e88b2",
          "climateChange": 1.20941,
          "freshwaterEutrophication": 1.52e-7,
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
          "climateChange": 0.0483042,
          "freshwaterEutrophication": 4.33885e-9,
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
          "climateChange": 0.156105,
          "freshwaterEutrophication": 1.79964e-7,
          "heat": 0,
          "elec_pppm": 0,
          "elec": 0,
          "waste": 0,
          "alias": "roadTransportPostMaking"
        }
      },
      "dyeingWeighting": 0,
      "airTransportRatio": 0,
      "customCountryMix": 0.3
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
      "transport": { "road": 500, "sea": 0, "air": 0, "co2": 0.022913875000000004, "fwe": 8.4513715e-9 },
      "co2": 0,
      "fwe": 0,
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
          "climateChange": 1.20941,
          "freshwaterEutrophication": 1.52e-7,
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
          "climateChange": 0.0483042,
          "freshwaterEutrophication": 4.33885e-9,
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
          "climateChange": 0.269575,
          "freshwaterEutrophication": 9.94279e-8,
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
  "co2": 4.579604333133101,
  "fwe": 0.0003521486305115451,
  "transport": { "road": 2500, "sea": 21548, "air": 0, "co2": 0.31770847486643206, "fwe": 0 }
}
```

&#x20;
