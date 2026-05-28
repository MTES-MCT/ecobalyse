# Food Ingredient Reference Data for metadata

Reference datasets used for predicting new food ingredient metadata.
These files are copied from the [ecobalyse-method-tooling](https://github.com/MTES-MCT/ecobalyse-method-tooling) repository,
where a prediction pipeline (`predict.py`) uses them to infer metadata for new ingredients
via semantic similarity matching (FoodOn embeddings + pattern-based rules).
Reference datasets that were used for predicting food new ingredient metadata.

## Files

| File | Description |
|------|-------------|
| `food_type.csv` | Food category mapping (vegetable, fruit, meat, fish_seafood, dairy, grain, nut_oilseed, spice_condiment) |
| `nova_classification.csv` | NOVA 1-4 processing level classification (Monteiro et al., 2016) |
| `processing_state.csv` | Raw/processed state mapping, derived from NOVA (NOVA 1 → raw, NOVA 2-4 → processed) |
| `transport_cooling.csv` | Refrigeration needs (none, always, once), based on food type and perishability |
| `cropgroup.csv` | French agricultural crop groups (RPG categories), used for ecosystemic services |
| `density.csv` | Mass per volume (kg/L) - custom fallback values |
| `fao_density.csv` | Mass per volume (kg/L) - FAO reference (primary source, `density.csv` is the fallback) |
| `inedible_part.csv` | Non-edible fraction (0-1) - generic fallback values |
| `agb_inedible.csv` | Non-edible fraction - Agribalyse reference (primary source, `inedible_part.csv` is the fallback) |
| `cooked_to_raw.csv` | Weight change after cooking, from Agribalyse/CIQUAL |

## Sources

- **[FAO](https://www.fao.org/4/ap815e/ap815e.pdf)** — Density reference values (`fao_density.csv`)
- **[CIQUAL](https://ciqual.anses.fr/)** (ANSES) — Cooking ratios, inedible parts, used via Agribalyse
- **[Agribalyse 3.2](https://agribalyse.ademe.fr/)** (ADEME) — Inedible parts (`agb_inedible.csv`), cooked-to-raw ratios. [Annexes](https://entrepot.recherche.data.gouv.fr/dataset.xhtml?persistentId=doi:10.57745/XTENSJ)
- **[FoodOn Ontology](http://purl.obolibrary.org/obo/foodon.owl)** ([OBO Foundry](https://obofoundry.org/ontology/foodon.html)) — ~52k food terms used for semantic similarity matching during prediction
- **[NOVA Classification](https://doi.org/10.1017/S1368980017000234)** (Monteiro, Cannon, Levy et al., 2016) — 4-group food processing classification
- **[RPG](https://www.data.gouv.fr/fr/datasets/registre-parcellaire-graphique-rpg-contours-des-parcelles-et-ilots-culturaux-et-leur-groupe-de-cultures/)** (Registre Parcellaire Graphique) — French agricultural crop group categories
