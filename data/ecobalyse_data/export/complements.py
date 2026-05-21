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
# Detailed in https://github.com/MTES-MCT/ecobalyse/issues/2051


FOOD_COMPLEMENTS_COEFFICIENTS = {
    "cropDiversity": 1.11,
    "hedges": 6.34,
    "permanentPasture": 7.28,
    "plotSize": 7.12,
}
