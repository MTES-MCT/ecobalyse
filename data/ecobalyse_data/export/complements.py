# Complement coefficients (forest + food)
# ========================================
# Complements final value are computed using this formula
#  final_value = raw_signal * coefficient
# where coefficient is calculated from a desired output on a reference scenario

# Forest Management Coefficients
# ------------------------------
# Formula: forestComplement = landOccupation * coefficient[forestManagement]
#
# Reference values (from pine-softwood-intensive-plantation on ecobalyse.beta.gouv.fr),
# forestManagement = intensivePlantation:
#   - ldu impact     = 4.316 Pts/kg (displayed as 4316 mPts)
#   - landOccupation = 1563 m².year
#
# For intensivePlantation, percentage = 25%:
#   coefficient = 0.25 * 4.316 / 1563 ~ 0.00069

LDU_IMPACT_BY_LAND_OCCUPATION = 4.316 / 1563

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
# Reference scores recorded on 2026-05-18.
# Detailed in https://github.com/MTES-MCT/ecobalyse/issues/2051

SOFT_WHEAT_ORGANIC_ECS_WITHOUT_COMPLEMENTS = 81.3
SOFT_WHEAT_ORGANIC_CROP_DIVERSITY = 7.3

BEEF_WITHOUT_BONE_ORGANIC_ECS_WITHOUT_COMPLEMENTS = 2047.7
BEEF_WITHOUT_BONE_ORGANIC_HEDGES = 35.6
BEEF_WITHOUT_BONE_ORGANIC_PERMANENT_PASTURE = 28.1
BEEF_WITHOUT_BONE_ORGANIC_PLOT_SIZE = 33.9

FOOD_COMPLEMENTS_COEFFICIENTS = {
    # ~1.11, defined as 10% bonus to soft-wheat-organic
    "cropDiversity": 0.1
    * SOFT_WHEAT_ORGANIC_ECS_WITHOUT_COMPLEMENTS
    / SOFT_WHEAT_ORGANIC_CROP_DIVERSITY,
    # ~5.75, defined as 10% bonus to beef-without-bone-organic
    "hedges": 0.1
    * BEEF_WITHOUT_BONE_ORGANIC_ECS_WITHOUT_COMPLEMENTS
    / BEEF_WITHOUT_BONE_ORGANIC_HEDGES,
    # ~7.29, defined as 10% bonus to beef-without-bone-organic
    "permanentPasture": 0.1
    * BEEF_WITHOUT_BONE_ORGANIC_ECS_WITHOUT_COMPLEMENTS
    / BEEF_WITHOUT_BONE_ORGANIC_PERMANENT_PASTURE,
    # ~6.04, defined as 10% bonus to beef-without-bone-organic
    "plotSize": 0.1
    * BEEF_WITHOUT_BONE_ORGANIC_ECS_WITHOUT_COMPLEMENTS
    / BEEF_WITHOUT_BONE_ORGANIC_PLOT_SIZE,
}
