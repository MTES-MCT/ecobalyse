"""
Takes a distances.json and returns the same with added regions
"""
import json
import copy

regions = {
    "---": "IN",
    "REO": "ES",
    "REE": "CZ",
    "RAS": "IN",
    "RAF": "ET",
    "RMO": "TR",
    "RAL": "BR",
    "RAN": "US",
    "ROC": "AU",
}
old = dict()
with open("distances.json") as f:
    old = json.load(f)

new = copy.deepcopy(old)
for origin, destinations in old.items():
    if origin in regions.values():
        for r in [r for r, c in regions.items() if c == origin]:
            new[r] = destinations
    for destination, distances in destinations.items():
        if destination in regions:
            new[origin][regions[destination]] = distances

with open("distances_with_regions.json", "w") as f:
    json.dump(new, f, ensure_ascii=False)
