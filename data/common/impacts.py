from config import settings

main_method = settings.bw.method
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
    "etf-o": (
        main_method,
        "Ecotoxicity, freshwater - organics",
    ),
    "etf-i": (
        main_method,
        "Ecotoxicity, freshwater - inorganics",
    ),
    "etf": (
        main_method,
        "Ecotoxicity, freshwater",
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
