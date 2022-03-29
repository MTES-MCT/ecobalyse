import json
import requests
import pandas as pd
import itertools
import geopy.distance
import json
import os
import random

"""if you only want to compute the distance for 1 new country, use this script so you don't have to compute the distances between n(n-1)/2 countries
"""


def getSearatesDistance(route_type, route):
    """Query the Searates API for a route ("FR","CN") and a route_type ("road") and returns the distance

    Args:
        route_type (string): "road", "sea" or "air"
        route (tuple): Pair of countries alpha 2 codes : ("FR","CN")

    Returns:
        float : distance of the route in km for the given route_type
    """
    url = buildSearatesQuery(route_type, route)
    response = requests.get(url, headers=headers)
    resp_json = response.json()
    try:
        dist = round(float(resp_json[route_type]["dist"]))
    except KeyError:
        dist = None
    return dist


def buildSearatesQuery(route_type, route):
    """build the url to query the searates API based on a route ("FR","CN") and a route_type ("road")

    Args:
        route_type (string): "road", "sea" or "air"
        route (tuple): Pair of countries alpha 2 codes : ("FR","CN")

    Returns:
        string: url to query the searates API
    """

    base_url = "https://sirius.searates.com/distance-and-time/search?type=" + route_type
    coords0 = country_coords[route[0]]
    coords1 = country_coords[route[1]]
    from_str = "&speed=800&lat_from=" + str(coords0[0]) + "&lng_from=" + str(coords0[1])
    to_str = "&lat_to=" + str(coords1[0]) + "&lng_to=" + str(coords1[1])
    countries_str = "&from_country_code=" + route[0] + "&to_country_code=" + route[1]

    return base_url + from_str + to_str + countries_str


user_agent_list = [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
]
url = "https://httpbin.org/headers"
# Pick a random user agent
user_agent = random.choice(user_agent_list)
# Set the headers
headers = {"User-Agent": user_agent}

df = pd.read_csv("countries_importance.csv")
# select only most important countries
# df = df[(df.importance == 1)]

# build dic of country -> coordinates
country_coords = {}

for i, x in df.iterrows():
    country_coords[x["Alpha-2 code"]] = (
        float(x["Latitude (average)"]),
        float(x["Longitude (average)"]),
    )


# select list of countries to calculate distances
# be careful, the number of pairs of n countries is big : n(n-1)/2

# countries = list(df["Alpha-2 code"])[0:3]
countries = [
    "TR",
    "TN",
    "PT",
    "FR",
    "ES",
    "CN",
    "BD",
    "VN",
    "MA",
    "MM",
    "KH",
    "PK",
    "DE",
    "EG",
    "ET",
    "IT",
    "LK",
    "TW",
    "GB",
    "IN",
]

country_to_add = ["GR"]

distances = {}
remaining_countries = countries.copy()


# log number of routes
n = len(countries)
nb_routes = round(n * (n - 1) / 2)
print("number of routes : " + str(nb_routes))
i = 1
for country_from in country_to_add:
    # for current country build a dictionary of distances with all remaining countries
    country_from_dic = {}

    if len(remaining_countries) > 0:
        # iterate on all remaining countries (country_to)
        for country_to in remaining_countries:
            route = (country_from, country_to)
            print(
                "computing distances for route "
                + str(i)
                + " out of "
                + str(nb_routes)
                + " : "
                + str(route)
            )

            # get distances between country_from and country_to

            country_from_dic[country_to] = {
                "road": getSearatesDistance("road", route),
                "sea": getSearatesDistance("sea", route),
                "air": round(
                    geopy.distance.distance(
                        country_coords[route[0]], country_coords[route[1]]
                    ).km
                ),
            }
            i += 1
        # add dictionary of distances to master dictionary
        distances[country_from] = country_from_dic
        print("finished computing distances for " + country_from)

with open("distances_add_country.json", "w") as outfile:
    json.dump(distances, outfile)
