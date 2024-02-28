"""
Takes a distances.json and returns the same with added regions
"""
import json
import copy

regions = {
    "IN": "--",
    "ES": "REO",
    "CZ": "REE",
    "IN": "RAS",
    "ET": "RAF",
    "TR": "RMO",
    "BR": "RAL",
    "US": "RAN",
    "AU": "ROC",
}
old = dict()
with open("distances.json") as f:
    old = json.load(f)

new = copy.deepcopy(old)
for origin, destinations in old.items():
    if origin in regions:
        new[regions[origin]] = destinations
    for destination, distances in destinations.items():
        if destination in regions:
            new[origin][regions[destination]] = distances

print(json.dumps(new))
