"""Single source of truth for the countries the distance pipeline runs on"""

import json
import pathlib

REPO_ROOT = pathlib.Path(__file__).parents[3]
DEFAULT_COUNTRIES_JSON = REPO_ROOT / "public" / "data" / "countries.json"

# region code -> the real country used to represent it
REGION_PROXIES = {
    # TODO "---" is only used for textile/food1, remove when obsolete
    "---": "IN",  # unknown / default
    "REO": "ES",  # Western Europe
    "REE": "CZ",  # Eastern Europe
    "RAS": "CN",  # Asia
    "RAF": "ET",  # Africa
    "RME": "TR",  # Middle East
    "RLA": "BR",  # Latin America
    "RNA": "US",  # North America
    "ROC": "AU",  # Oceania
    "ROF": "MQ",  # French overseas
    "REM": "CZ",  # Europe and Maghreb
}


def distance_country_codes(countries_json_path):
    """Real-country codes to compute distances for, derived from countries.json"""
    with open(countries_json_path, encoding="utf-8") as f:
        official_countries = json.load(f)
    return sorted(
        {REGION_PROXIES.get(c["code"], c["code"]) for c in official_countries}
    )
