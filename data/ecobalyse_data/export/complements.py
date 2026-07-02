import matplotlib.pyplot as plt

import config

# Forest Management Coefficients
# ------------------------------
# Formula: forestComplement = landOccupation * coefficient[forestManagement]
#
# Reference values (from pine-softwood-intensive-plantation on ecobalyse.beta.gouv.fr),
# forestManagement = intensivePlantation:
#   - ldu impact     = 4316 Pts/kg (56 110 ldu Pt displayed in the UI, with ldu weight 6.29% and ldu norm_factor = 819498)
#   - landOccupation = 1563 m².year
#
# For intensivePlantation, percentage = 25%:
#   coefficient = 0.25 * 4316 / 1563 ~ 0.69

LDU_IMPACT_BY_LAND_OCCUPATION = 4316 / 1563

FOREST_MANAGEMENT_COEFFICIENTS = {
    "diversifiedForest": -1 * LDU_IMPACT_BY_LAND_OCCUPATION * 0.25,  # bonus 25% ldu
    "certifiedDiversifiedForest": -1
    * LDU_IMPACT_BY_LAND_OCCUPATION
    * 0.35,  # bonus 35% ldu
    "intensivePlantation": LDU_IMPACT_BY_LAND_OCCUPATION * 0.25,  # malus 25% ldu
    "sustainableManagement": 0,
    "certifiedSustainableManagement": -1
    * LDU_IMPACT_BY_LAND_OCCUPATION
    * 0.1,  # bonus 10% ldu
}


def compute_forest_complement(
    forest_management: str | None, land_occupation: float | None
) -> float | None:
    """Compute forest complement from forestManagement type and land occupation.

    Returns landOccupation * coefficient(forestManagement), or None if either is None.
    """
    if forest_management is None or land_occupation is None:
        return None

    coefficient = FOREST_MANAGEMENT_COEFFICIENTS[forest_management]
    return land_occupation * coefficient


# Food Complements Coefficients
# -----------------------------
# Each coefficient is calibrated so that the final complement is a fixed
# bonus/malus on a specific reference ingredient. Example: cropDiversity is
# defined as a 10% bonus to soft-wheat-organic.
#
# Detailed in https://github.com/MTES-MCT/ecobalyse/issues/2051


FOOD_COMPLEMENTS_COEFFICIENTS = {
    "cropDiversity": 1.11,
    "hedges": 6.34,
    "permanentPasture": 7.28,
    "plotSize": 7.12,
}


def compute_vegetal_ecosystemic_services(
    food_metadata, ecosystemic_factors, process_with_impacts
) -> dict:
    services = {}
    for eco_service in config.ecosystemic_services_list:
        factor_raw = ecosystemic_factors[food_metadata["cropGroup"]][eco_service][
            food_metadata["scenario"]
        ]
        factor_transformed = es_transform(eco_service, factor_raw)
        if food_metadata["alias"] in (
            config.settings.scopes.food.grazed_grass_permanent_key,
            config.settings.scopes.food.grazed_grass_temporary_key,
        ):
            # don't multiply by landOccupation for grazed grass as unit is already in m2.year
            factor_landocc = -1 * factor_transformed
        else:
            factor_landocc = -1 * factor_transformed * food_metadata["landOccupation"]
        # To get the complement final value, we need to multiply it by its FOOD_COMPLEMENTS_COEFFICIENTS
        factor_final = factor_landocc * FOOD_COMPLEMENTS_COEFFICIENTS[eco_service]

        # vegetal ecosystemic services are capped at 30% of the ecoscore impact
        min_value = -0.3 * abs(process_with_impacts["impacts"]["ecs"])
        final_value = max(factor_final, min_value)

        services[eco_service] = number_format_ecosystemic_service(final_value)

    return services


def number_format_ecosystemic_service(value):
    return float("{:.3g}".format(value))


def compute_animal_ecosystemic_services(
    es_for_activities,
    feed_quantities,
) -> dict:
    services = {}

    hedges = 0
    plotSize = 0
    cropDiversity = 0

    for feed_activity_alias, quantity in feed_quantities.items():
        feed_services = es_for_activities[feed_activity_alias]
        hedges += quantity * feed_services["hedges"]
        plotSize += quantity * feed_services["plotSize"]
        cropDiversity += quantity * feed_services["cropDiversity"]

    services["hedges"] = number_format_ecosystemic_service(hedges)
    services["plotSize"] = number_format_ecosystemic_service(plotSize)
    services["cropDiversity"] = number_format_ecosystemic_service(cropDiversity)

    # permanentPasture is computed here from a raw feed qty, so we apply FOOD_COMPLEMENTS_COEFFICIENTS to it
    # We don't need to apply FOOD_COMPLEMENTS_COEFFICIENTS to the other complements (hedges, plotSize, cropDiversity)
    # as they are weighted sum of vegetal complements that compute_vegetal_ecosystemic_services
    # already multiplied by the FOOD_COMPLEMENTS_COEFFICIENTS
    services["permanentPasture"] = number_format_ecosystemic_service(
        -1
        * feed_quantities.get(config.settings.scopes.food.grazed_grass_permanent_key, 0)
        * FOOD_COMPLEMENTS_COEFFICIENTS["permanentPasture"]
    )
    return services


THRESHOLD_HEDGES = 140  # ml/ha
THRESHOLD_PLOTSIZE = 8  # ha
THRESHOLD_CROPDIVERSITY = 7.5  # simpson number


# For each eco_service, we associate a transformation function
# to get a visual idea of the function, look at es_transformations.png
TRANSFORM = {
    "hedges": (THRESHOLD_HEDGES, lambda x: x / THRESHOLD_HEDGES, lambda x: 1),
    "plotSize": (THRESHOLD_PLOTSIZE, lambda x: 1 - x / THRESHOLD_PLOTSIZE, lambda x: 0),
    "cropDiversity": (
        THRESHOLD_CROPDIVERSITY,
        lambda x: 0,
        lambda x: x - THRESHOLD_CROPDIVERSITY,
    ),
}


def es_transform(eco_service, value):
    if value is None:
        raise ValueError(f"No input value defined for complement {eco_service}")

    if value < 0:
        raise ValueError(f"complement {eco_service} input value can't be lower than 0")

    if eco_service not in TRANSFORM:
        raise ValueError(f"Unknown complement: {eco_service}")

    threshold, func_below, func_above = TRANSFORM[eco_service]
    if value < threshold:
        return func_below(value)
    else:
        return func_above(value)


def plot_es_transformations(save_path=None):
    # Create a range of values for x-axis (input values for es_transform)
    plot_characteristic_dic = {
        "hedges": {"range": range(0, 200), "unit": "Mètre linéaire de haie/ha"},
        "plotSize": {"range": range(0, 25), "unit": "Taille de parcelle (ha)"},
        "cropDiversity": {"range": range(0, 30), "unit": "Simpson number"},
    }  # Adjust the range based on expected values

    num_plots = len(config.ecosystemic_services_list)

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
    for index, eco_service in enumerate(config.ecosystemic_services_list):
        value_range = plot_characteristic_dic[eco_service]["range"]
        transformed_values = [es_transform(eco_service, value) for value in value_range]
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
