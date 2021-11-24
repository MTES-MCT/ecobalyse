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
Identifiant du produit
{% endswagger-parameter %}

{% swagger-parameter in="query" name="material" required="true" type="String" %}
UUID de matière première
{% endswagger-parameter %}

{% swagger-parameter in="query" name="countries" type="String[]" required="true" %}
Liste des codes pays pour chaque étape
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

{% swagger-parameter in="query" name="customCountryMixes.fabric" type="Float" %}
Impact du mix énergétique du pays à l'étape de Tissage/Tricotage, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes.dyeing" type="Float" %}
Impact du mix énergétique du pays à l'étape de Teinture, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes.making" type="Float" %}
Impact du mix énergétique du pays à l'étape de Confection, exprimé en kgCO₂/KWh
{% endswagger-parameter %}
{% endswagger %}

#### Exemple de requête

```
$ http https://wikicarbone.osc-fr1.scalingo.io/?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countries[]=CN&countries[]=FR&countries[]=FR&countries[]=FR&countries[]=FR&dyeingWeighting=&airTransportRatio=&recycledRatio=&customCountryMixes.fabric=&customCountryMixes.dyeing=&customCountryMixes.making=
```

Ou [cliquez sur ce lien](https://wikicarbone.osc-fr1.scalingo.io/?mass=0.17\&product=13\&material=f211bbdb-415c-46fd-be4d-ddf199575b44\&countries\[]=CN\&countries\[]=FR\&countries\[]=FR\&countries\[]=FR\&countries\[]=FR\&dyeingWeighting=\&airTransportRatio=\&recycledRatio=\&customCountryMixes.fabric=\&customCountryMixes.dyeing=\&customCountryMixes.making=).

#### Exemple de réponse

```json
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

&#x20;
