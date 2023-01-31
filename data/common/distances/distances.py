import json
import math
from re import A
import requests
import pandas as pd
import geopy.distance
import json
import random
import time
from datetime import datetime
import requests


"""Script to get the distances between countries for a list of countries. To identify countries we use the 2 letters code (France->FR).


# Runtime
Takes about 1 minute to compute 10 routes.
10 countries -> 45 routes -> 4.5 minutes
The number of routes is n(n-1)/2 with n the number of countries.
20 countries -> 190 routes -> 19 minutes
"""


# select list of countries to calculate distances
# be careful, the number of pairs of n countries is big : n(n-1)/2

countries = [
"AL",
"BD",
"BE",
"BR",
"CH",
"CN",
"CZ",
"DE",
"EG",
"ES",
"ET",
"FR",
"GB",
"GR",
"HU",
"IN",
"IT",
"KE",
"KH",
"LK",
"MA",
"MM",
"NL",
"NZ",
"PE",
"PK",
"PL",
"PT",
"RO",
"TN",
"TR",
"TW",
"US",
"VN"
]


def getSearatesDistance(route_type, route, headers):
    """Query the Searates API for a route ("FR","CN") and a route_type ("road") and returns the distance

    Args:@@
        route_type (string): "road", "sea" or "air"
        route (tuple): Pair of countries alpha 2 codes : ("FR","CN")

    Returns:
        float : distance of the route in km for the given route_type
    """
    url = buildSearatesQuery(route_type, route)
    retries = 5

    dist = None

    for i in range(retries):
        try:

            response = requests.get(
                url,
                headers=headers,
                # proxies={"http": proxy, "https": proxy}
            )
            resp_json = response.json()
            if route_type == "road":    
                dist = round(float(resp_json[route_type]["distance"]))
            else:
                dist = round(float(resp_json[route_type]["dist"]))
            break

        except Exception as e:
            print("Error")
            time.sleep(1)
            if i == 5:
                print(
                    "failed to get distance for " + str(route_type) + " " + str(route)
                )

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
    from_str = "&lat_from=" + str(coords0[0]) + "&lng_from=" + str(coords0[1])
    to_str = "&lat_to=" + str(coords1[0]) + "&lng_to=" + str(coords1[1])
    countries_str = "&from_country_code=" + route[0] + "&to_country_code=" + route[1]

    return base_url + from_str + to_str + countries_str





def compute_distances(countries, intermediarySave = False):
    remaining_countries = countries.copy()

    index = 1
    for i, country_from in enumerate(countries):
        # pick a random user_agent
        user_agent = random.choice(user_agent_list)
        headers = {"User-Agent": user_agent}
        # remove current country (country_from) from remaining_countries
        remaining_countries.remove(country_from)
        # for current country build a dictionary of distances with all remaining countries
        country_from_dic = {}

        if len(remaining_countries) > 0:
            # iterate on all remaining countries (country_to)
            for i2, country_to in enumerate(remaining_countries):                
                route = (country_from, country_to)
                # sleep 10 seconds 1 out of 10 times
                # if random.randint(1, 10) == 10:
                #    time.sleep(10)
                # sleep for a few seconds
                time.sleep(random.randint(1, 3))
                timeObj = str(datetime.now().time())

                print(
                    timeObj
                    + " computing distances for route "
                    + str(index)
                    + " out of "
                    + str(nb_routes)
                    + " : "
                    + str(route)
                )

                # get distances between country_from and country_to
                country_from_dic[country_to] = {
                    "road": getSearatesDistance("road", route, headers),
                    "sea": getSearatesDistance("sea", route, headers),
                    "air": round(
                        geopy.distance.distance(
                            country_coords[route[0]], country_coords[route[1]]
                        ).km
                    ),
                }
                index += 1            
            # add dictionary of distances to master dictionary
            distances[country_from] = country_from_dic
            timeObj = str(datetime.now().time())
            print(timeObj + " finished computing distances for " + country_from)            
        else:
            distances[country_from] = {}

        if i % 2 == 0 and intermediarySave:
            with open(
                "distances_" + str(index) + ".json", "w"
            ) as outfile:
                json.dump(distances, outfile)        
            timeObj = str(datetime.now().time())
            print(timeObj + " " + str(index) + " writing intermediate output")

        print(remaining_countries)
    
# Searates API won't work after a nb of requests
# Changing the user agent fix that

user_agent_list = [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
]
url = "https://httpbin.org/headers"


if __name__ == "__main__":
    # source url : https://gist.github.com/tadast/8827699
    countries_data = pd.read_csv(
        "countries_data.csv"
    )

    # build dic of country -> coordinates
    country_coords = {}

    for i, country_data in countries_data.iterrows():
        country_coords[country_data["Alpha-2 code"]] = (
            float(country_data["Latitude (average)"]),
            float(country_data["Longitude (average)"]),
        )

    countries = sorted(countries)    
    
    # log the nb of routes

    distances = {}
    
    n = len(countries)
    nb_routes = round(n * (n - 1) / 2)
    print("number of routes : " + str(nb_routes))

    compute_distances(countries, intermediarySave = True)

    with open("distances.json", "w") as outfile:
        json.dump(distances, outfile)
    timeObj = str(datetime.now().time())
    print(timeObj + " finished writing output to distances.json")
