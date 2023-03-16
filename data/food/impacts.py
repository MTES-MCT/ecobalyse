impacts = {
    "acd": ("EF v3.1 EN15804", "acidification", "accumulated exceedance (AE)"),
    "ozd": ("EF v3.1", "ozone depletion", "ozone depletion potential (ODP)"),
    "cch": ("EF v3.1", "climate change", "global warming potential (GWP100)"),
    "fwe": (
        "EF v3.1",
        "eutrophication: freshwater",
        "fraction of nutrients reaching freshwater end compartment (P)",
    ),
    "swe": (
        "EF v3.1",
        "eutrophication: marine",
        "fraction of nutrients reaching marine end compartment (N)",
    ),
    "tre": ("EF v3.1", "eutrophication: terrestrial", "accumulated exceedance (AE)"),
    "pco": (
        "EF v3.1 EN15804",
        "photochemical oxidant formation: human health",
        "tropospheric ozone concentration increase",
    ),
    "pma": ("EF v3.1", "particulate matter formation", "impact on human health"),
    "ior": (
        "EF v3.1",
        "ionising radiation: human health",
        "human exposure efficiency relative to u235",
    ),
    "fru": (
        "EF v3.1",
        "energy resources: non-renewable",
        "abiotic depletion potential (ADP): fossil fuels",
    ),
    "mru": (
        "EF v3.1",
        "material resources: metals/minerals",
        "abiotic depletion potential (ADP): elements (ultimate reserves)",
    ),
    "ldu": ("EF v3.1", "land use", "soil quality index"),
    "wtu": (
        "EF v3.1",
        "water use",
        "user deprivation potential (deprivation-weighted water consumption)",
    ),
    "etf": (
        "EF v3.1",
        "ecotoxicity: freshwater",
        "comparative toxic unit for ecosystems (CTUe)",
    ),
    "htc": (
        "EF v3.1",
        "human toxicity: carcinogenic",
        "comparative toxic unit for human (CTUh)",
    ),
    "htn": (
        "EF v3.1 EN15804",
        "human toxicity: non-carcinogenic",
        "comparative toxic unit for human (CTUh)",
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
