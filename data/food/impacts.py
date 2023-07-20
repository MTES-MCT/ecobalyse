impacts = {
    "acd": ("Environmental Footprint 3.1 (adapted) patch wtu", "Acidification"),
    "ozd": ("Environmental Footprint 3.1 (adapted) patch wtu", "Ozone depletion"),
    "cch": ("Environmental Footprint 3.1 (adapted) patch wtu", "Climate change"),
    "fwe": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Eutrophication, freshwater",
    ),
    "swe": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Eutrophication, marine",
    ),
    "tre": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Eutrophication, terrestrial",
    ),
    "pco": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Photochemical ozone formation",
    ),
    "pma": ("Environmental Footprint 3.1 (adapted) patch wtu", "Particulate matter"),
    "ior": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ionising radiation",
    ),
    "fru": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Resource use, fossils",
    ),
    "mru": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Resource use, minerals and metals",
    ),
    "ldu": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Land use",
    ),
    "wtu": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Water use",
    ),
    "etf-o1": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ecotoxicity, freshwater - organics - p.1",
    ),
    "etf-o2": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ecotoxicity, freshwater - organics - p.2",
    ),
    "etf-i": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ecotoxicity, freshwater - inorganics",
    ),
    "etf1": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ecotoxicity, freshwater - part 1",
    ),
    "etf2": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Ecotoxicity, freshwater - part 2",
    ),
    "htc": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, cancer",
    ),
    "htc-o": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, cancer - organics",
    ),
    "htc-i": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, cancer - inorganics",
    ),
    "htn": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, non-cancer",
    ),
    "htn-o": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, non-cancer - organics",
    ),
    "htn-i": (
        "Environmental Footprint 3.1 (adapted) patch wtu",
        "Human toxicity, non-cancer - inorganics",
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
