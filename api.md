---
description: >-
  Une API HTTP permettant d'interroger le simulateur programmatiquement (version
  alpha)
---

# API

{% hint style="info" %}
Cette API est en version alpha, l'implémentation et le contrat d'interface est susceptible de changer à tout moment. Vous êtes vivement invité à **ne pas exploiter cette API en production**.
{% endhint %}

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

{% swagger-parameter in="query" name="material" required="true" %}
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

{% swagger-parameter in="query" name="customCountryMixes.dyeing" %}
Impact du mix énergétique du pays à l'étape de Teinture, exprimé en kgCO₂/KWh
{% endswagger-parameter %}

{% swagger-parameter in="query" name="customCountryMixes.making" %}
Impact du mix énergétique du pays à l'étape de Confection, exprimé en kgCO₂/KWh
{% endswagger-parameter %}
{% endswagger %}

&#x20;
