import pandas as pd
import matplotlib.pyplot as plt

THRESHOLD_HEDGES = 140  # ml/ha
THRESHOLD_PLOTSIZE = 8  # ha
THRESHOLD_CROPDIVERSITY = 7.5  # simpson number

ecosystemic_services_list = ["hedges", "plotSize", "cropDiversity"]


# For each eco_service, we associate a transformation function
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


def ecs_transform(eco_service, value):
    if value < 0:
        raise ValueError(f"complement {eco_service} input value can't be lower than 0")

    if eco_service not in TRANSFORM:
        raise ValueError(f"Unknown complement: {eco_service}")

    threshold, func_below, func_above = TRANSFORM[eco_service]
    if value < threshold:
        return func_below(value)
    else:
        return func_above(value)


def load_ecosystemic_dic(PATH):
    """Load ecosystemic csv as dictionary"""
    ecosystemic_factors_csv = pd.read_csv(PATH, sep=";")
    ecosystemic_factors = {}
    for _, row in ecosystemic_factors_csv.iterrows():
        cropGroup = row["group"]
        ecosystemic_factors[cropGroup] = {
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
    return ecosystemic_factors


def load_ugb_dic(PATH):
    ugb_df = pd.read_csv(PATH, sep=";")
    ugb_dic = {}
    for _, row in ugb_df.iterrows():
        group = row["animal_group2"]
        if group not in ugb_dic:
            ugb_dic[group] = {}
        ugb_dic[group][row["animal_product"]] = row["value"]

    return ugb_dic


def compute_vegetal_ecosystemic_services(ingredients, ecosystemic_factors):
    for ingredient in ingredients:
        if all(
            ingredient.get(key) for key in ["land_occupation", "crop_group", "scenario"]
        ):
            print(f"Computing ecosystemic services for {ingredient['id']}")
            for eco_service in ecosystemic_services_list:
                factor_raw = ecosystemic_factors[ingredient["crop_group"]][eco_service][
                    ingredient["scenario"]
                ]
                factor_transformed = ecs_transform(eco_service, factor_raw)
                factor_final = factor_transformed * ingredient["land_occupation"]
                ingredient.setdefault("ecosystemicServices", {})[eco_service] = float(
                    "{:.5g}".format(factor_final)
                )


def compute_animal_ecosystemic_services(
    ingredients, activities, ecosystemic_factors, feed_file, ugb
):
    ingredients_dic = {el["id"]: el for el in ingredients}
    activities_dic = {el["id"]: el for el in activities}
    for animal_product, feed_quantities in feed_file.items():
        hedges = 0
        plotSize = 0
        cropDiversity = 0
        ecosystemicServices = ingredients_dic[animal_product]["ecosystemicServices"]
        for feed_name, quantity in feed_quantities.items():
            assert (
                feed_name in ingredients_dic
            ), f"feed {feed_name} is not present in ingredients"
            feed_properties = ingredients_dic[feed_name]
            hedges += quantity * feed_properties["ecosystemicServices"]["hedges"]
            plotSize += quantity * feed_properties["ecosystemicServices"]["plotSize"]
            cropDiversity += (
                quantity * feed_properties["ecosystemicServices"]["cropDiversity"]
            )
        ecosystemicServices["hedges"] = hedges
        ecosystemicServices["plotSize"] = plotSize
        ecosystemicServices["cropDiversity"] = cropDiversity

        ecosystemicServices["permanentPasture"] = feed_quantities.get(
            "permanent-pasture", 0
        )

        ecosystemicServices["livestockDensity"] = (
            compute_livestockDensity_ecosystemic_service(
                activities_dic[animal_product], ugb, ecosystemic_factors
            )
        )


def compute_livestockDensity_ecosystemic_service(
    animal_properties, ugb, ecosystemic_factors
):

    livestockDensity_per_ugb = ecosystemic_factors[animal_properties["animal_group1"]][
        "livestockDensity"
    ][animal_properties["scenario"]]
    ugb_per_kg = ugb[animal_properties["animal_group2"]][
        animal_properties["animal_product"]
    ]
    return livestockDensity_per_ugb * ugb_per_kg


def plot_ecs_transformations(save_path=None):
    # Create a range of values for x-axis (input values for ecs_transform)
    plot_characteristic_dic = {
        "hedges": {"range": range(0, 200), "unit": "Mètre linéaire de haie/ha"},
        "plotSize": {"range": range(0, 25), "unit": "Taille de parcelle (ha)"},
        "cropDiversity": {"range": range(0, 30), "unit": "Simpson number"},
    }  # Adjust the range based on expected values

    num_plots = len(ecosystemic_services_list)

    # Create subplots
    fig, axes = plt.subplots(num_plots, 1, figsize=(10, 6 * num_plots))

    # Check if axes is a single axis object or an array of axes
    if num_plots == 1:
        axes = [axes]

    # Add the title text at the top of the plot
    fig.suptitle(
        "The greater the transformed value, the higher the ecosystemic service value, the lower the overall environmental impact",
        fontsize=14,
    )
    # Plotting the transformations for each ecosystemic service in a separate subplot
    for index, eco_service in enumerate(ecosystemic_services_list):
        value_range = plot_characteristic_dic[eco_service]["range"]
        transformed_values = [
            ecs_transform(eco_service, value) for value in value_range
        ]
        ax = axes[index]
        ax.plot(value_range, transformed_values, label=eco_service)
        ax.set_title(f"{eco_service}")
        ax.set_xlabel(plot_characteristic_dic[eco_service]["unit"])
        ax.set_ylabel("Transformed Value")
        ax.legend()
        ax.grid(True)

    if save_path:
        plt.savefig(save_path, bbox_inches="tight")

    plt.tight_layout()
