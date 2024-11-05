# Please only pure functions here

from copy import deepcopy

from frozendict import frozendict


def normalization_factors(impact_defs):
    normalization_factors = {}
    for k, v in impact_defs.items():
        if v.get("ecoscore"):
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def spproject(activity):
    """return the current simapro project for an activity"""
    match activity.get("database"):
        case "Ginko":
            return "Ginko w/o azadirachtin"
        case "Ecobalyse":
            # return a non existing project to force looking at brightway
            return "EcobalyseIsNotASimaProProject"
        case "Ecoinvent 3.9.1":
            return "ADEME UPR"
        case _:
            return "AGB3.1.1 2023-03-06"


def remove_detailed_impacts(processes):
    result = list()
    for process in processes:
        new_process = deepcopy(process)
        for k in new_process["impacts"].keys():
            if k not in ("pef", "ecs"):
                new_process["impacts"][k] = 0
        result.append(new_process)
    return result


def order_json(data):
    """
    Export data to a JSON file, with added newline at the end.
    Sort all dictionary keys alphabetically and recursively.
    """
    if isinstance(data, dict):
        return dict(sorted((k, order_json(v)) for k, v in data.items()))
    elif isinstance(data, list):
        return [order_json(item) for item in data]
    else:
        return data


def with_subimpacts(impacts):
    """compute subimpacts"""
    if not impacts:
        return impacts
    # etf-o = etf-o1 + etf-o2
    impacts["etf-o"] = impacts["etf-o1"] + impacts["etf-o2"]
    del impacts["etf-o1"]
    del impacts["etf-o2"]
    # etf = etf1 + etf2
    impacts["etf"] = impacts["etf1"] + impacts["etf2"]
    del impacts["etf1"]
    del impacts["etf2"]
    return impacts


def with_corrected_impacts(impact_defs, frozen_processes, impacts="impacts"):
    """Add corrected impacts to the processes"""
    corrections = {
        k: v["correction"] for (k, v) in impact_defs.items() if "correction" in v
    }
    processes = dict(frozen_processes)
    processes_updated = {}
    for key, process in processes.items():
        # compute corrected impacts
        for impact_to_correct, correction in corrections.items():
            # only correct if the impact is not already computed
            dimpacts = process.get(impacts, {})
            if impact_to_correct not in dimpacts:
                corrected_impact = 0
                for (
                    correction_item
                ) in correction:  # For each sub-impact and its weighting
                    sub_impact_name = correction_item["sub-impact"]
                    if sub_impact_name in dimpacts:
                        sub_impact = dimpacts.get(sub_impact_name, 1)
                        corrected_impact += sub_impact * correction_item["weighting"]
                        del dimpacts[sub_impact_name]
                dimpacts[impact_to_correct] = corrected_impact
        processes_updated[key] = process
    return frozendict(processes_updated)


def calculate_aggregate(process_impacts, normalization_factors):
    # We multiply by 10**6 to get the result in µPts
    return sum(
        10**6 * process_impacts.get(impact, 0) * normalization_factors.get(impact, 0)
        for impact in normalization_factors
    )


def bytrigram(definitions, bynames):
    """takes the impact definitions and some impacts by name, return the impacts by trigram"""
    trigramsByName = {method[1]: trigram for trigram, method in definitions.items()}
    return {
        trigramsByName.get(name): amount["amount"]
        for name, amount in bynames.items()
        if trigramsByName.get(name)
    }


def with_aggregated_impacts(impact_defs, frozen_processes, impacts="impacts"):
    """Add aggregated impacts to the processes"""

    # Pre-compute normalization factors
    normalization_factors = {
        "ecs": {
            k: v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            for k, v in impact_defs.items()
            if v["ecoscore"] is not None
        },
        "pef": {
            k: v["pef"]["weighting"] / v["pef"]["normalization"]
            for k, v in impact_defs.items()
            if v["pef"] is not None
        },
    }

    processes_updated = {}
    for key, process in frozen_processes.items():
        updated_process = dict(process)
        updated_impacts = updated_process[impacts].copy()

        updated_impacts["pef"] = calculate_aggregate(
            updated_impacts, normalization_factors["pef"]
        )
        updated_impacts["ecs"] = calculate_aggregate(
            updated_impacts, normalization_factors["ecs"]
        )

        updated_process[impacts] = updated_impacts
        processes_updated[key] = updated_process

    return frozendict(processes_updated)


def fix_unit(unit):
    match unit:
        case "cubic meter":
            return "m³"
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
