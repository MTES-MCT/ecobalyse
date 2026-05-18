# Ecosystemic Services Data

Input data for computing ecosystemic services of food ingredients.

## Files

| File | Description |
|------|-------------|
| `feed.json` | Animal feed composition: maps each live animal/egg/milk alias to its feed ingredients and quantities. Doesn't include meat ingredients. |
| `raw_to_transformed_ratios.json` | Link transformed ingredients (meat, cheese, …) to their upstream raw product (live animal, milk, …) and the quantity of raw needed to produce 1 kg of transformed. |
| `ecosystemic_factors.csv` | Ecosystemic service factors per crop group and scenario (hedges, plotSize, cropDiversity) |
| `es_transformations.png` | Visualization of the transformation functions applied to ecosystemic factors |

## feed.json

Each key is a live animal/egg/milk ingredient alias. The value is an object mapping feed ingredient aliases to quantities.
Each quantity is expressed in the unit of the processes except `grazed-grass-...` which is in m2.year
For example `silage-maize-fr-2025` is in kg so to produce 1 kg of `milk-2025` you need :
- 0.175 m2.year of `grazed-grass-permanent-2025`
- 0.349 kg of `silage-maize-fr-2025` and so on...

Example:

```json
{
  "milk-2025": {
    "grazed-grass-permanent-2025": 0.175,
    "grazed-grass-temporary-2025": 0.438,
    "silage-maize-fr-2025": 0.349,
    "soft-wheat-fr": 0.0857,
    "soybean-br-deforestation": 0.0646
  },
  "beef-cattle-conventional-fr-live": {
    "grazed-grass-permanent-2025": 16.2318,
    "grazed-grass-temporary-2025": 2.18543,
    "silage-maize-fr-2025": 1.47682,
    "soft-wheat-fr": 0.549669,
    "soybean-br-deforestation": 0.231788
  },
}
```

## raw_to_transformed_ratios.json

Keyed by **raw** (upstream) alias. Each value maps a **transformed** (downstream) alias to an object:

```json
{
  "beef-cattle-conventional-fr-live": {
    "beef-with-bone":    { "ratio": 1.5,  "source": "brightway", "source_ref": "" },
    "beef-without-bone": { "ratio": 1.875, "source": "brightway", "source_ref": "" },
    "ground-beef-2025":  { "ratio": 2.3,  "source": "brightway", "source_ref": "" }
  },
  "cow-milk-fr": {
    "blue-cheese-auvergne-fr": { "ratio": 4.47, "source": "cmaps", "source_ref": "blue-cheese-auvergne-v1" }
  }
}
```

To produce 1 kg of `beef-with-bone` you need 1.5 kg of `beef-cattle-conventional-fr-live`, so its feed is 1.5 × the feed of `beef-cattle-conventional-fr-live` (which is in `feed.json`).

### Fields

- `ratio` — kg of raw per kg of transformed.
- `source` — one of:
  - `brightway_manual` — hand copy-pasted from a Brightway/Simapro activity exchange.
  - `cmaps_activities_to_create` — taken from the first exchange of a `from_scratch` entry in `activities_to_create.json`
  - `manual` — neither of the above.
- `source_ref` — free-text anchor a reviewer can use to find the ratio in the source system:
  - For `brightway`: the Brightway activity name (e.g. `Meat with bone, beef, for direct consumption {FR}`).
  - For `cmaps`: the `alias` in `activities_to_create.json` (e.g. `blue-cheese-auvergne-v1`).

### How to update

- **Brightway rows.** Open Brightway, navigate to the activity, and copy the `amount` on the relevant exchange. Update `ratio` here and fill in `source_ref` with the activity name.
- **CMAPS rows.** Ensure a `from_scratch` entry exists in `activities_to_create.json`. Set `ratio` equal to the first exchange's `amount`, `source` to `"cmaps"`, and `source_ref` to that entry's `alias`. The test `tests/test_raw_to_transformed_ratios.py::test_cmaps_rows_match_activities_to_create` enforces this consistency.
