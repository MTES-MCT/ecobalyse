# Impacts corrigés

Des impacts "corrigés" sont calculé pour prendre en compte les manques de connaissances concernant certains impacts toxicité, particulièrement liés à l’utilisation de pesticides de synthèse (effets cocktails, impacts des co-adjuvants et co-formulants, des métabolites, impacts chroniques de certaines molécules ou manques liés au délai requis pour une analyse d’impacts).&#x20;

Cela concerne les 3 impacts de toxicité :&#x20;

* Écotoxicité de l'eau douce
* Toxicité humaine - cancer
* Toxicité humaine - non-cancer

### Calcul&#x20;

Chacun de ses impacts toxicité est décomposé en 3 composantes : "metals" , "organic" et "inorganic". La correction consiste à multiplier l'impact de la composante "organic" (liée à l'utilisation de pesticides de synthèse) par 2.

Par exemple pour la toxicité humaine - cancer (htc : human toxicity - cancer) :

```
htc = htc_metals + htc_organic + htc_inorganic  
htc_corrigé = htc_metals + 2 * htc_organic + htc_inorganic  
```

