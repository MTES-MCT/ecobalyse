import json

from common.distances.CountryDistances import CountryDistances
from common.export import load_json

INPUT_DISTANCES = "distances_raw.json"
COUNTRIES_OFFICIAL = "../../../public/data/countries.json"
OUTPUT = "../../../public/data/transports.json"

# dictionary of regions to add with the corresponding country
regions = {
    "---": "IN",
    "REO": "ES",
    "REE": "CZ",
    "RAS": "CN",
    "RAF": "ET",
    "RME": "TR",
    "RLA": "BR",
    "RNA": "US",
    "ROC": "AU",
}

# These countries are used to represent regions eg. East Europe -> Czech Republic but are not official countries in the app
placeholder_countries = ["CZ", "ET", "AU"]

if __name__ == "__main__":
    distances = load_json(INPUT_DISTANCES)
    country_distances = CountryDistances(distances)

    # add self distances
    country_distances.add_self_distances()

    countries_official_list = set([c["code"] for c in load_json(COUNTRIES_OFFICIAL)])
    # delete countries that are not needed
    for country in country_distances._all_countries:
        if (
            country not in countries_official_list
            and country not in placeholder_countries
        ):
            country_distances.delete_country(country)

    for region, corresponding_country in regions.items():
        country_distances.add_region(region, corresponding_country)

    for country in placeholder_countries:
        country_distances.delete_country(country)

    if (countries_real := country_distances._all_countries) != countries_official_list:
        missing_countries = countries_official_list - countries_real
        surplus_countries = countries_real - countries_official_list
        raise ValueError(
            f"There's a mismatch between countries_official_list and the countries we have distances. missing countries : {missing_countries}. excess_countries : {surplus_countries}"
        )
    country_distances.validate()

    with open(OUTPUT, "w", encoding="utf-8") as file:
        json.dump(
            country_distances.export_to_nested_dict(),
            file,
            ensure_ascii=False,
        )
