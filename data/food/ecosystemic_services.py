import json
import pandas as pd

ACTIVITIES = "activities.json"
ECOSYSTEMIC_FACTORS = "ecosystemic_factors.csv"
THRESHOLD_HEDGES = 140  # ml/ha
THRESHOLD_CROPSIZE = 8  # ha
THRESHOLD_DIVERSITY = 7.5

THRESHOLD_HEDGES = 140  # ml/ha
THRESHOLD_CROPSIZE = 8  # ha
THRESHOLD_DIVERSITY = 7.5

ecosystemic_services_list = ["hedges", "cropSize", "diversity"]

TRANSFORM = {
    "hedges": (THRESHOLD_HEDGES, lambda x: x / THRESHOLD_HEDGES, lambda x: 1),
    "cropSize": (THRESHOLD_CROPSIZE, lambda x: 1 - x / THRESHOLD_CROPSIZE, lambda x: 0),
    "diversity": (THRESHOLD_DIVERSITY, lambda x: 0, lambda x: x - THRESHOLD_DIVERSITY),
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


with open(ACTIVITIES, "r") as f:
    activities = json.load(f)


# load ecosystemic csv as dictionary

ecosystemic_factors_csv = pd.read_csv(ECOSYSTEMIC_FACTORS, sep=";")
ecosystemic_factors = {}

for _, row in ecosystemic_factors_csv.iterrows():
    cropGroup = row["group"]
    ecosystemic_factors[cropGroup] = {
        "hedges": {
            "reference": row["hedges_reference"],
            "bio": row["hedges_bio"],
            "import": row["hedges_import"],
        },
        "plotSize": {
            "reference": row["plotSize_reference"],
            "bio": row["plotSize_bio"],
            "import": row["plotSize_import"],
        },
        "cropDiversity": {
            "reference": row["cropDiversity_reference"],
            "bio": row["cropDiversity_bio"],
            "import": row["cropDiversity_import"],
        },
    }
