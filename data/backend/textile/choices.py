from django.conf import settings
from os.path import join
import json

FABRICS = {
    "weaving": "Tissage",
    "knitting-straight": "Tricotage Rectiligne",
    "knitting-circular": "Tricotage Circulaire",
    "knitting-integral": "Tricotage Intégral / Whole garment",
    "knitting-fully-fashioned": "Tricotage Fully fashioned / Seamless",
    "knitting-mix": "Tricotage moyen (par défaut)",
}
BUSINESSES = {
    "small-business": "PME/TPE",
    "large-business-with-services": "Grande entreprise proposant un service de réparation et de garantie",
    "large-business-without-services": "Grande entreprise ne proposant pas de service de réparation ou de garantie",
}
DYEINGMEDIA = {"article": "Article", "fabric": "Tissu", "yarn": "Fil"}
MAXKINGCOMPLEXITIES = {
    "very-high": "Très élevée",
    "high": "Élevée",
    "medium": "Moyenne",
    "low": "Faible",
    "very-low": "Très faible",
    "not-applicable": "Non applicable",
}
ORIGINS = {
    "ArtificialFromInorganic": "Matière artificielle d'origine inorganique",
    "ArtificialFromOrganic": "Matière artificielle d'origine organique",
    "NaturalFromAnimal": "Matière naturelle d'origine animale",
    "NaturalFromVegetal": "Matière naturelle d'origine végétale",
    "Synthetic": "Matière synthétique",
}
COUNTRIES = {}
with open(join(settings.GITROOT, "public", "data", "countries.json")) as f:
    COUNTRIES = {c["code"]: c["name"] for c in json.load(f)}

UNITS = {"kWh": "kWh", "kg": "kg", "m2": "m²", "MJ": "MJ", "t*km": "t*km"}
DBS = {
    k: k
    for k in [
        "Base Impacts 2.01",
        "Ecobalyse",
        "Ecoinvent 3.9.1",
    ]
}
STEPUSAGES = {
    k: k
    for k in [
        "Energie",
        "Ennoblissement",
        "Fin de vie",
        "Matières, Filature",
        "Tissage / Tricotage",
        "Transport",
        "Utilisation",
    ]
}
CATEGORIES = {
    k: k
    for k in [
        "Chemise",
        "Jean",
        "Jupe / Robe",
        "Manteau / Veste",
        "Pantalon / Short",
        "Pull / Couche intermédiaire",
        "Tshirt / Polo",
    ]
}
