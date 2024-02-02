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


# load ecosystemic csv as dictionary
def load_ecosystemic_dic(PATH):
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
        }
    return ecosystemic_factors


def plot_ecs_transformations(save_path=None):
    # Create a range of values for x-axis (input values for ecs_transform)
    value_range_dic = {
        "hedges": range(0, 200),
        "plotSize": range(0, 25),
        "cropDiversity": range(0, 30),
    }  # Adjust the range based on expected values

    num_plots = len(ecosystemic_services_list)

    # Create subplots
    fig, axes = plt.subplots(num_plots, 1, figsize=(10, 6 * num_plots))

    # Check if axes is a single axis object or an array of axes
    if num_plots == 1:
        axes = [axes]

    # Plotting the transformations for each ecosystemic service in a separate subplot
    for index, eco_service in enumerate(ecosystemic_services_list):
        value_range = value_range_dic[eco_service]
        transformed_values = [
            ecs_transform(eco_service, value) for value in value_range
        ]
        ax = axes[index]
        ax.plot(value_range, transformed_values, label=eco_service)
        ax.set_title(f"Transformation: {eco_service}")
        ax.set_xlabel("Input Value")
        ax.set_ylabel("Transformed Value")
        ax.legend()
        ax.grid(True)
    if save_path:
        plt.savefig(save_path)

    plt.tight_layout()
