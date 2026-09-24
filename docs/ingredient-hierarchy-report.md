# Retrieving the ingredient hierarchy report

This report checks that the scores of food ingredients follow an expected order.
For a given base product (soft wheat, for instance), the expected order is:

    organic < France < European Union < outside EU < unknown origin

It also checks a few explicit pairs, for example that the most impactful chicken
stays below conventional beef.

## When is the report generated?

- On every update of the `main` branch.
- On every pull request that changes the impact data or the check script.

## Downloading the report

1. Open the runs page for the main branch:
   https://github.com/MTES-MCT/ecobalyse/actions/workflows/ingredient_hierarchy.yml?query=branch%3Amain
   (you need to be signed in to GitHub and a member of the project).
2. Click the most recent run at the top of the list.
3. Scroll down to the **Artifacts** section at the bottom of the page.
![alt text](image.png)
4. Click **ingredient-hierarchy-report**. A zip file downloads.
5. Unzip it.


## What is in the zip

| File or folder | Content |
|---|---|
| `ingredient_hierarchy_anomalies_fr.csv` | List of anomalies in French spreadsheet format (`;` separator, decimal comma). Opens directly in Excel or LibreOffice with French settings. |
| `ingredient_hierarchy_anomalies.csv` | Same list in standard format (`,` separator, decimal point). |
| `ingredient_plots/` | One chart per base product, with one bar per variant and the breakdown by impact. Files whose name ends with `_anomaly` concern a product with at least one anomaly. |
| `ingredient_plots/_all_meats_barchart.png` | All meats on a single chart. |
| `ingredient_plots/_pair_…png` | One chart per explicit pair check. |
| `bookmarks/` | One bookmark file per base product, to import into the Ecobalyse comparator. |

When no anomaly is found, the CSV files are not in the zip.

## Reading the anomalies file

One row per pair of ingredients in the wrong order. Rows visible to end users
come first, then by decreasing gap.

| Column | Meaning |
|---|---|
| `base_ingredient` | Base product concerned. |
| `reason` | Summary of the anomaly: the variant expected to be lower is written before the `>`. |
| `visible` | `1` when both ingredients are visible to users, `0` when one of them is hidden. |
| `hidden_variants` | The hidden ingredients of the pair, if any. |
| `expected_lower_variant`, `expected_lower_ecs` | Variant that should have the lower score, and its score (ecoscore, complements included). |
| `expected_lower_display_name`, `expected_lower_activity_name` | Name shown in Ecobalyse and name of the source process. |
| `expected_lower_lci_catalog` | Link to the ingredient definition file on GitHub. |
| `expected_higher_…` | Same information for the variant that should have the higher score. |
| `delta` | Score gap between the two, in points. The larger it is, the more the anomaly deserves attention. |

On the charts, hidden ingredients are written in grey italics.
