import json
import pandas as pd

with open("transports.json", "r") as f:
    distances = json.load(f)

data = []

countries = set()
# iterate on countries_from
for country_from, country_from_dict in distances.items():
    countries.add(country_from)
    # iterate on countries_to
    for country_to, dist in country_from_dict.items():
        countries.add(country_to)
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
countries_list = list(countries)
for country in countries:
    route = country + "-" + country
    row = [route, route, 500, 0, 0]
    data.append(row)


distances_df = pd.DataFrame(
    data, columns=["route", "ordered_route", "road", "sea", "air"]
)
distances_df.to_csv("distances.csv", index=False)
