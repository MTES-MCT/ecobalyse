import pandas as pd
import matplotlib.pyplot as plt
from frozendict import frozendict


THRESHOLD_HEDGES = 140  # ml/ha
THRESHOLD_PLOTSIZE = 8  # ha
THRESHOLD_CROPDIVERSITY = 7.5  # simpson number

complements_list = ["hedges", "plotSize", "cropDiversity"]


# For each complement, we associate a transformation function
# to get a visual idea of the function, look at ecs_transformations.png
TRANSFORM = {
    "hedges": (THRESHOLD_HEDGES, lambda x: x / THRESHOLD_HEDGES, lambda x: 1),
    "plotSize": (THRESHOLD_PLOTSIZE, lambda x: 1 - x / THRESHOLD_PLOTSIZE, lambda x: 0),
    "cropDiversity": (
        THRESHOLD_CROPDIVERSITY,
        lambda x: 0,
        lambda x: x - THRESHOLD_CROPDIVERSITY,
    ),
}


def ecs_transform(complement, value):
    if value < 0:
        raise ValueError(f"complement {complement} input value can't be lower than 0")

    if complement not in TRANSFORM:
        raise ValueError(f"Unknown complement: {complement}")

    threshold, func_below, func_above = TRANSFORM[complement]
    if value < threshold:
        return func_below(value)
    else:
        return func_above(value)


def load_complements_dic(PATH):
    """Load complement csv as dictionary"""
    complements_factors_csv = pd.read_csv(PATH, sep=";")
    complements_factors = {}
    for _, row in complements_factors_csv.iterrows():
        cropGroup = row["group"]
        complements_factors[cropGroup] = {
            "hedges": {
                "reference": row["hedges_reference"],
                "organic": row["hedges_organic"],
                "import": row["hedges_import"],
            },
            "plotSize": {
                "reference": row["plotSize_reference"],
                "organic": row["plotSize_organic"],
                "import": row["plotSize_import"],
            },
            "cropDiversity": {
                "reference": row["cropDiversity_reference"],
                "organic": row["cropDiversity_organic"],
                "import": row["cropDiversity_import"],
            },
            "livestockDensity": {
                "reference": row["livestockDensity_reference"],
                "organic": row["livestockDensity_organic"],
                "import": row["livestockDensity_import"],
            },
        }
    return frozendict(complements_factors)


def load_ugb_dic(PATH):
    ugb_df = pd.read_csv(PATH, sep=";")
    ugb_dic = {}
    for _, row in ugb_df.iterrows():
        group = row["animal_group2"]
        if group not in ugb_dic:
            ugb_dic[group] = {}
        ugb_dic[group][row["animal_product"]] = row["value"]

    return frozendict(ugb_dic)


def compute_vegetal_complements(ingredients_tuple, complements_factors):
    ingredients = list(ingredients_tuple)
    ingredients_updated = []
    for ingredient in ingredients:
        if all(
            ingredient.get(key) for key in ["land_occupation", "crop_group", "scenario"]
        ):
            print(f"Computing complement services for {ingredient['id']}")
            for complement in complements_list:
                factor_raw = complements_factors[ingredient["crop_group"]][complement][
                    ingredient["scenario"]
                ]
                factor_transformed = ecs_transform(complement, factor_raw)
                factor_final = factor_transformed * ingredient["land_occupation"]
                ingredient.setdefault("complements", {})[complement] = float(
                    "{:.5g}".format(factor_final)
                )
        ingredients_updated.append(ingredient)
    return tuple(ingredients_updated)


def compute_animal_complements(
    ingredients, activities, complement_factors, feed_file, ugb
):
    activities_dic = {el["id"]: el for el in activities}
    ingredients_dic_updated = {el["id"]: el for el in ingredients}
    ingredients_dic = frozendict(ingredients_dic_updated)
    for animal_product, feed_quantities in feed_file.items():
        hedges = 0
        plotSize = 0
        cropDiversity = 0
        complements = ingredients_dic[animal_product].get("complements", {})

        for feed_name, quantity in feed_quantities.items():
            assert (
                feed_name in ingredients_dic
            ), f"feed {feed_name} is not present in ingredients"
            feed_properties = ingredients_dic[feed_name]
            hedges += quantity * feed_properties["complements"]["hedges"]
            plotSize += quantity * feed_properties["complements"]["plotSize"]
            cropDiversity += quantity * feed_properties["complements"]["cropDiversity"]
        complements["hedges"] = hedges
        complements["plotSize"] = plotSize
        complements["cropDiversity"] = cropDiversity

        complements["permanentPasture"] = feed_quantities.get(
            "grazed-grass-permanent", 0
        )

        complements["livestockDensity"] = compute_livestockDensity_complement(
            frozendict(activities_dic[animal_product]), ugb, complement_factors
        )
        ingredients_dic_updated[animal_product]["complements"] = complements
    return tuple([v for k, v in ingredients_dic_updated.items()])


def compute_livestockDensity_complement(animal_properties, ugb, complement_factors):
    try:
        livestockDensity_per_ugb = complement_factors[
            animal_properties["animal_group1"]
        ]["livestockDensity"][animal_properties["scenario"]]
        ugb_per_kg = ugb[animal_properties["animal_group2"]][
            animal_properties["animal_product"]
        ]
        return livestockDensity_per_ugb * ugb_per_kg
    except KeyError as e:
        print(
            f"Error processing animal with ID {animal_properties.get('id', 'Unknown')}: Missing key {e}"
        )
        raise


def plot_ecs_transformations(save_path=None):
    # Create a range of values for x-axis (input values for ecs_transform)
    plot_characteristic_dic = {
        "hedges": {"range": range(0, 200), "unit": "Mètre linéaire de haie/ha"},
        "plotSize": {"range": range(0, 25), "unit": "Taille de parcelle (ha)"},
        "cropDiversity": {"range": range(0, 30), "unit": "Simpson number"},
    }  # Adjust the range based on expected values

    num_plots = len(complements_list)

    # Create subplots
    fig, axes = plt.subplots(num_plots, 1, figsize=(10, 6 * num_plots))

    # Check if axes is a single axis object or an array of axes
    if num_plots == 1:
        axes = [axes]

    # Add the title text at the top of the plot
    fig.suptitle(
        "The greater the transformed value, the higher the complementservice value, the lower the overall environmental impact",
        fontsize=14,
    )
    # Plotting the transformations for each complementservice in a separate subplot
    for index, complement in enumerate(complements_list):
        value_range = plot_characteristic_dic[complement]["range"]
        transformed_values = [ecs_transform(complement, value) for value in value_range]
        ax = axes[index]
        ax.plot(value_range, transformed_values, label=complement)
        ax.set_title(f"{complement}")
        ax.set_xlabel(plot_characteristic_dic[complement]["unit"])
        ax.set_ylabel("Transformed Value")
        ax.legend()
        ax.grid(True)

    if save_path:
        plt.savefig(save_path, bbox_inches="tight")

    plt.tight_layout()
