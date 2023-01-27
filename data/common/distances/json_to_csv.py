import json
import pandas as pd
import pycountry
import gettext

with open("distances.json", "r") as f:
    distances = json.load(f)

data = []

countries_set = set()
# iterate on countries_from
for country_from, country_from_dict in distances.items():
    countries_set.add(country_from)
    # iterate on countries_to
    for country_to, dist in country_from_dict.items():
        countries_set.add(country_to)
        route = country_from + "-" + country_to
        reverse_route = country_to + "-" + country_from
        # check alphabetical order
        if country_from < country_to:
            country_0 = country_from
            country_1 = country_to
        else:
            country_0 = country_to
            country_1 = country_from
        route_ordered = country_0 + "-" + country_1
        # add row
        row = [route, route_ordered, dist["road"], dist["sea"], dist["air"]]
        data.append(row)
        # add reverse route row
        row_reverse = [
            reverse_route,
            route_ordered,
            dist["road"],
            dist["sea"],
            dist["air"],
        ]
        data.append(row_reverse)


# add 500 km of road distance for all intra country distances
countries_list = list(countries_set)
countries_list = sorted(countries_list)

for country in countries_list:
    route = country + "-" + country
    row = [route, route, 500, 0, 0]
    data.append(row)

# csv export
distances_df = pd.DataFrame(
    data, columns=["route", "ordered_route", "road", "sea", "air"]
)
distances_df.to_csv("distances.csv", index=False)
countries_importance = pd.read_csv("countries_importance.csv")

## build list of countries with alpha 2 correspondance

# build dic of alpha2 -> country
alpha2_to_country = {}

for i, x in countries_importance.iterrows():
    alpha2_to_country[x["Alpha-2 code"]] = x["Country"]


country_alpha2 = []

french = gettext.translation("iso3166", pycountry.LOCALES_DIR, languages=["fr"])
french.install()
# print list of countries
for alpha2 in countries_list:
    py_country = pycountry.countries.get(alpha_2=alpha2)
    country_french = _(py_country.name)
    row = [alpha2, country_french, py_country.name]
    country_alpha2.append(row)

# csv export
countries_df = pd.DataFrame(country_alpha2, columns=["alpha-2", "name_fr", "name_en"])
countries_df.to_csv("countries.csv", index=False, encoding="utf-8")
