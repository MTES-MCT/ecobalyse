# ⚙️ Outils et pipeline data

Pour faire fonctionner le calculateur, l’équipe Ecobalyse s’appuie sur plusieurs outils. Ils servent à intégrer les bases de données ACV sources, à assurer les mises à jour et la traçabilité, et à produire certaines données manquantes. L'équipe privilégie les outils open-source/open data, dans une logique de contribution et de collaboration avec d'autres acteurs engagés dans cette dynamique (ex: [Départ de Sentier](https://www.d-d-s.ch/)).&#x20;

La chaîne de traitement est la suivante :

1. Identification et mobilisation des inventaires (ICV) issus de bases sources (voir page [Source des procédés](https://fabrique-numerique.gitbook.io/ecobalyse/def-cout-environnemental/source-des-procedes)).
2. Complèter les ICV mobilisés par quelques inventaires générés par l'équipe (voir page [Source des procédés](https://fabrique-numerique.gitbook.io/ecobalyse/def-cout-environnemental/source-des-procedes))
3. Adapter la structure des données pour isoler certains paramètres clés, comme les taux de perte, les quantités d'électricité consommées etc.
4. Calculer les impacts (LCIA) des procédés puis et les intégrer dans l'outil Ecobalyse



Outils utilisés :

[Volca](https://www.volca.run/) : analyses préalables et vérifications

* Exploration des données ACV avant leur intégration dans Ecobalyse, explorations méthodologiques, interprétation, comparaisons entre sources de données etc.
* Transfert de données d’arrière-plan d’ecoinvent vers BAFU, avec analyse des écarts
* Recalcul des impacts pour vérifier la cohérence avec Brightway (contrôle fait historiquement avec SimaPro)

[SimaPro](https://simapro.com/) : import des ICV sources dans brightway

* Export CSV, qui garantissait historiquement une structure homogène entre les bases
* Migration en cours vers l’import direct des formats natifs (par exemple ecospold pour BAFU 2026), en vue d’une chaîne d’outils entièrement open data et open source

[Brightway](https://www.google.com/url?sa=t\&source=web\&rct=j\&opi=89978449\&url=https://brightway.dev/\&ved=2ahUKEwi9z9vhj5SYAxVSgP0HHTaWPH4QFnoECCgQAQ\&usg=AOvVaw1Plwsk35dLTynmW226-IMQ) : modélisation et calcul; export des procédés vers ecobalyse

* Construction des inventaires Ecobalyse\_custom\_lci (documentés dans le dépôt Ecobalyse)
* Structuration des données pour isoler des paramètres clés (taux de perte, etc.)
* Calcul des impacts selon la méthode EF 3.1 adaptée (version 1.03, reprise de SimaPro)







