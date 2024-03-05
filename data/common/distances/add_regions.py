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

tmp = copy.deepcopy(old)
for origin, destinations in old.items():
    for destination, distances in destinations.items():
        for r in [r for r, c in regions.items() if c == destination]:
            tmp[origin][r] = distances
new = copy.deepcopy(tmp)
with open("distances_with_regions.tmp.json", "w") as f:
    json.dump(tmp, f, ensure_ascii=False)
for origin, destinations in tmp.items():
    for r in [r for r, c in regions.items() if c == origin]:
        new[r] = destinations

with open("distances_with_regions.json", "w") as f:
    json.dump(new, f, ensure_ascii=False)
