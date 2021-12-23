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

{% swagger method="get" path="simulator/<impact>" baseUrl="https://wikicarbone.osc-fr1.scalingo.io/" summary="Effectue une simulation sur tous les impacts à partir des paramètres fournis." %}
{% swagger-description %}
`Le`&#x20;

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
