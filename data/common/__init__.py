# Please only pure functions here

from copy import deepcopy

from frozendict import frozendict


def normalization_factors(impact_defs):
    normalization_factors = {}
    for k, v in impact_defs.items():
        if v["ecoscore"]:
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
    Make sure to sort impacts in the json file
    """
    if isinstance(data, list):
        sorted_data = [
            {**item, "impacts": sort_impacts(item["impacts"])}
            if "impacts" in item
            else item
            for item in data
        ]
    elif isinstance(data, dict):
        sorted_data = {
            key: {**value, "impacts": sort_impacts(value["impacts"])}
            if "impacts" in value
            else value
            for key, value in data.items()
        }
    else:
        sorted_data = data
    return sorted_data


def sort_impacts(impacts):
    # Define the desired order of impact keys
    impact_order = [
        "acd",
        "cch",
        "etf",
        "etf-c",
        "fru",
        "fwe",
        "htc",
        "htc-c",
        "htn",
        "htn-c",
        "ior",
        "ldu",
        "mru",
        "ozd",
        "pco",
        "pma",
        "swe",
        "tre",
        "wtu",
        "ecs",
        "pef",
    ]
    return {key: impacts[key] for key in impact_order if key in impacts}


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


def with_corrected_impacts(impact_defs, processes_fd, impacts="impacts"):
    """Add corrected impacts to the processes"""
    corrections = {
        k: v["correction"] for (k, v) in impact_defs.items() if "correction" in v
    }
    processes = dict(processes_fd)
    processes_updated = {}
    for key, process in processes.items():
        # compute corrected impacts
        for impact_to_correct, correction in corrections.items():
            corrected_impact = 0
            for correction_item in correction:  # For each sub-impact and its weighting
                sub_impact_name = correction_item["sub-impact"]
                if sub_impact_name in process[impacts]:
                    sub_impact = process[impacts].get(sub_impact_name, 1)
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del process[impacts][sub_impact_name]
            process[impacts][impact_to_correct] = corrected_impact
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


def with_aggregated_impacts(impact_defs, processes_fd, impacts="impacts"):
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
    for key, process in processes_fd.items():
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
