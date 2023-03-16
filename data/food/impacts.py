impacts = {
    "acd": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Acidification"),
    "ozd": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Ozone depletion"),
    "cch": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Climate change"),
    "fwe": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Eutrophication, freshwater",
    ),
    "swe": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Eutrophication, marine",
    ),
    "tre": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Eutrophication, terrestrial",
    ),
    "pco": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Photochemical ozone formation",
    ),
    "pma": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Particulate matter"),
    "ior": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Ionising radiation"),
    "fru": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Resource use, fossils",
    ),
    "mru": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Resource use, minerals and metals",
    ),
    "ldu": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Land use"),
    "wtu": ("EF 3.1 Method interim for AGRIBALYSE (Subimpacts)", "Water use"),
    "etf": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Ecotoxicity, freshwater",
    ),
    "etfo": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Ecotoxicity, freshwater - organics",
    ),
    "etfi": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Ecotoxicity, freshwater - inorganics",
    ),
    "etfm": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Ecotoxicity, freshwater - metals",
    ),
    "htc": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, cancer",
    ),
    "htco": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, cancer - organics",
    ),
    "htci": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, cancer - inorganics",
    ),
    "htcm": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, cancer - metals",
    ),
    "htn": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, non-cancer",
    ),
    "htno": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, non-cancer - organics",
    ),
    "htni": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, non-cancer - inorganics",
    ),
    "htnm": (
        "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)",
        "Human toxicity, non-cancer - metals",
    ),
}

"""Correspondance between the impact name we chose in our export (the trigrams) and the name in the Agribalyse_synthese.

The key is the Agribalyse_synthese name, the value is a tuple (trigram, multiplier),
with `multiplier` the unit (eg E-06) in the Agribalyse_synthese name.

"""
impacts_to_synthese = {
    # TODO: find/add the equivalent in `impacts`
    # "Score unique EF (mPt/kg de produit)": "",
    "Changement climatique (kg CO2 eq/kg de produit)": ("cch", 1),
    "Appauvrissement de la couche d'ozone (E-06 kg CVC11 eq/kg de produit)": (
        "ozd",
        0.000001,
    ),
    "Rayonnements ionisants (kBq U-235 eq/kg de produit)": ("ior", 1),
    "Formation photochimique d'ozone (E-03 kg NMVOC eq/kg de produit)": ("pco", 0.001),
    "Particules (E-06 disease inc./kg de produit)": ("pma", 0.000001),
    "Acidification terrestre et eaux douces (mol H+ eq/kg de produit)": ("acd", 1),
    "Eutrophisation terreste (mol N eq/kg de produit)": ("tre", 1),
    "Eutrophisation eaux douces (E-03 kg P eq/kg de produit)": ("fwe", 0.001),
    "Eutrophisation marine (E-03 kg N eq/kg de produit)": ("swe", 0.001),
    "Utilisation du sol (Pt/kg de produit)": ("ldu", 1),
    "Écotoxicité pour écosystèmes aquatiques d'eau douce (CTUe/kg de produit)": (
        "etf",
        1,
    ),
    "Épuisement des ressources eau (m3 depriv./kg de produit)": ("wtu", 1),
    "Épuisement des ressources énergétiques (MJ/kg de produit)": ("fru", 1),
    "Épuisement des ressources minéraux (E-06 kg Sb eq/kg de produit)": (
        "mru",
        0.000001,
    ),
}
