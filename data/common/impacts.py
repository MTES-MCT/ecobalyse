main_method = "Environmental Footprint 3.1 (adapted) patch wtu"
impacts = {
    "acd": (main_method, "Acidification"),
    "ozd": (main_method, "Ozone depletion"),
    "cch": (main_method, "Climate change"),
    "fwe": (
        main_method,
        "Eutrophication, freshwater",
    ),
    "swe": (
        main_method,
        "Eutrophication, marine",
    ),
    "tre": (
        main_method,
        "Eutrophication, terrestrial",
    ),
    "pco": (
        main_method,
        "Photochemical ozone formation",
    ),
    "pma": (main_method, "Particulate matter"),
    "ior": (
        main_method,
        "Ionising radiation",
    ),
    "fru": (
        main_method,
        "Resource use, fossils",
    ),
    "mru": (
        main_method,
        "Resource use, minerals and metals",
    ),
    "ldu": (
        main_method,
        "Land use",
    ),
    "wtu": (
        main_method,
        "Water use",
    ),
    "etf-o1": (
        main_method,
        "Ecotoxicity, freshwater - organics - p.1",
    ),
    "etf-o2": (
        main_method,
        "Ecotoxicity, freshwater - organics - p.2",
    ),
    "etf-i": (
        main_method,
        "Ecotoxicity, freshwater - inorganics",
    ),
    "etf1": (
        main_method,
        "Ecotoxicity, freshwater - part 1",
    ),
    "etf2": (
        main_method,
        "Ecotoxicity, freshwater - part 2",
    ),
    "htc": (
        main_method,
        "Human toxicity, cancer",
    ),
    "htc-o": (
        main_method,
        "Human toxicity, cancer - organics",
    ),
    "htc-i": (
        main_method,
        "Human toxicity, cancer - inorganics",
    ),
    "htn": (
        main_method,
        "Human toxicity, non-cancer",
    ),
    "htn-o": (
        main_method,
        "Human toxicity, non-cancer - organics",
    ),
    "htn-i": (
        main_method,
        "Human toxicity, non-cancer - inorganics",
    ),
}


def bytrigram(definitions, bynames):
    """takes the definitions above and some impacts by name, return the impacts by trigram"""
    if not isinstance(bynames, dict):
        print(bynames)
    names2trigrams = {method[1]: trigram for trigram, method in definitions.items()}
    try:
        return {
            names2trigrams.get(name): amount["amount"]
            for name, amount in bynames.items()
            if names2trigrams.get(name)
        }
    except Exception as e:
        return str(e)
