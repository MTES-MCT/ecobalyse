# Please only pure functions here
import functools
from subprocess import call

from frozendict import frozendict


@functools.cache
def get_normalization_weighting_factors(impact_defs):
    """Compute normalization and weighting factors for impact definitions.

    Args:
        impact_defs: A frozen dictionary of impact definitions. Must be deepfrozen (using frozendict.deepfreeze()) because this function is cached using @functools.cache, which requires immutable arguments.

    Returns:
        A frozen dictionary mapping impact keys to their normalization factors.
    """

    def extract(score, factor):
        return {
            k: v[score][factor] for k, v in impact_defs.items() if v[score] is not None
        }

    return frozendict(
        {
            "ecs_normalizations": extract("ecoscore", "normalization"),
            "ecs_weightings": extract("ecoscore", "weighting"),
        }
    )


def patch_agb3(path: str):
    # `yield` is used as a variable in some Simapro parameters. bw2parameters cannot handle it:
    # (sed is faster than Python)
    call("sed -i 's/yield/Yield_/g' " + path, shell=True)
    # Fix some errors in Agribalyse:
    call("sed -i 's/01\\/03\\/2005/1\\/3\\/5/g' " + path, shell=True)
    call("sed -i 's/\"0;001172\"/0,001172/' " + path, shell=True)


class DatabaseException(Exception):
    pass


def spproject(activity):
    """return the current (project, library) in simapro for an activity source database"""
    match activity.get("database"):
        case "Ginko":
            return ("Ginko w/o azadirachtin", "")
        case "Ginko 2025":
            return ("Ginko 2025", "")
        case "Ecobalyse_custom_lci":
            # return a non existing project to force looking at brightway
            return ("EcobalyseIsNotASimaProProject", "")
        case "Ecoinvent 3.9.1":
            return ("Ecoinvent 3.9.1", "Ecoinvent 3.9.1 - unit")
        case "Woolmark":
            return ("Woolmark", "")
        case "PastoEco":
            return ("Agribalyse 3.1.1", "")
        case "WFLDB":
            return ("WFLDB", "World Food LCA Database")
        case "Agribalyse 3.1.1":
            return ("Agribalyse 3.1.1", "")
        case "Agribalyse 3.2":
            return ("Agribalyse 3.2", "Agribalyse 3.2 - unit")
        case _:
            raise DatabaseException("Unknown database")


def remove_detailed_impacts(processes):
    return [
        {**process, "impacts": {"ecs": process["impacts"]["ecs"]}}
        for process in processes
    ]


def correct_process_impacts(impacts, corrections):
    """
    Compute corrected impacts (`_c`) defined in the corrections map

    Python objects are passed `by assignement` (it can be considered the same as `by reference`)
    So this function directly mutates the impacts dict, don’t judge me for that, it is needed to
    allow the use of frozendicts in the outer calls
    """
    # compute corrected impacts
    for impact_to_correct, correction in corrections.items():
        # only correct if the impact is not already computed
        if impact_to_correct not in impacts:
            corrected_impact = 0
            for correction_item in correction:  # For each sub-impact and its weighting
                sub_impact_name = correction_item["sub-impact"]
                if sub_impact_name in impacts:
                    sub_impact = impacts.get(sub_impact_name, 1)
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del impacts[sub_impact_name]
            impacts[impact_to_correct] = corrected_impact

    return impacts


def calculate_aggregate(aggregate_name, process_impacts, normalization_factors):
    # We multiply by 10**6 to get the result in µPts
    return sum(
        10**6
        * process_impacts[trigram]
        / normalization_factors[f"{aggregate_name}_normalizations"][trigram]
        * normalization_factors[f"{aggregate_name}_weightings"][trigram]
        for trigram in normalization_factors[f"{aggregate_name}_normalizations"]
    )


def bytrigram(definitions, bynames):
    """takes the impact definitions and some impacts by name, return the impacts by trigram"""
    trigramsByName = {method[1]: trigram for trigram, method in definitions.items()}
    return {
        trigramsByName.get(name): amount["amount"]
        for name, amount in bynames.items()
        if trigramsByName.get(name)
    }


def fix_unit(unit):
    match unit:
        case "cubic meter":
            return "m3"
        case "kilogram":
            return "kg"
        case "kilometer":
            return "km"
        case "kilowatt hour":
            return "kWh"
        case "litre":
            return "L"
        case "megajoule":
            return "MJ"
        case "ton kilometer":
            return "t⋅km"
        case _:
            return unit
