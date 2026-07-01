#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "countryinfo",
#     "geopy",
#     "searoute",
# ]
# ///
"""Compute road/sea/air distances between countries and write distances_raw.json.
Countries are represented by their alpha-2 codes (France -> FR), and by their centroid

- air distance : geodesic distance * AIR_CIRCUITY_FACTOR
- sea distance : searoute python package
- road distance : if countries are not connected by road, `null`. If they are connected geodesic distance * ROAD_CIRCUITY_FACTOR
"""

import collections
import json
import pathlib
from datetime import datetime

import country_set
import geopy.distance
import searoute
from countryinfo import CountryInfo, all_countries

# road and air distance is longer than geodesic distance so we apply a circuity factor
# from https://www.plancarbonegeneral.com/approches-sectorielles/produit-generique/fret-amont-et-aval
ROAD_CIRCUITY_FACTOR = 1.21
AIR_CIRCUITY_FACTOR = 1.05

# Supplementary edges added to account because even if some countries are separated by water, transport is possible by short ferry
CONNECTIVITY_ADD_EDGES = [
    ("ES", "MA"),  # Gibraltar strait ferry
]

CONNECTIVITY_CUT_EDGES = [
    ("FR", "BR"),  # French Guiana land border, not a mainland-France road route
    ("FR", "SR"),  # French Guiana - Suriname, idem
    ("PA", "CO"),  # Darien Gap: no road between North and South America
]


def load_country_coords(codes):
    """Return {alpha2_code: (lat, lon)} using each country's centroid.

    Centroid coordinates come from countryinfo's latlng(), the approximate
    geographic center of the country.
    """
    coords = {}
    for code in codes:
        latlng = CountryInfo(code).latlng()
        coords[code] = (latlng[0], latlng[1])
    return coords


def _alpha3(alpha2_code):
    """ISO alpha-2 -> alpha-3 (countryinfo borders are expressed in alpha-3)."""
    return CountryInfo(alpha2_code).iso(3)


def build_road_components():
    """Return {alpha3_code: component_id} of land-connected country components.

    Built from the countryinfo land-border graph, plus the curated ADD/CUT edges.
    Two countries are road-connected iff they share a component id; a country with
    no land link (island) is absent from the map, hence connected to nothing.
    """
    adjacency = collections.defaultdict(set)
    for country in all_countries():
        borders = country.borders()
        for neighbor_alpha3 in borders:
            adjacency[country.iso(3)].add(neighbor_alpha3)
            adjacency[neighbor_alpha3].add(country.iso(3))
    for code_from, code_to in CONNECTIVITY_ADD_EDGES:
        adjacency[_alpha3(code_from)].add(_alpha3(code_to))
        adjacency[_alpha3(code_to)].add(_alpha3(code_from))
    for code_from, code_to in CONNECTIVITY_CUT_EDGES:
        adjacency[_alpha3(code_from)].discard(_alpha3(code_to))
        adjacency[_alpha3(code_to)].discard(_alpha3(code_from))

    component_of = {}
    next_component_id = 0
    for seed_country in list(adjacency):
        if seed_country in component_of:
            continue
        next_component_id += 1
        countries_to_visit = [seed_country]
        while countries_to_visit:
            country = countries_to_visit.pop()
            if country in component_of:
                continue
            component_of[country] = next_component_id
            countries_to_visit.extend(adjacency[country] - component_of.keys())
    return component_of


def is_road_connected(code_from, code_to, component_of):
    alpha3_from = _alpha3(code_from)
    alpha3_to = _alpha3(code_to)
    return alpha3_from in component_of and component_of.get(
        alpha3_from
    ) == component_of.get(alpha3_to)


def sea_distance(code_from, code_to, coords):
    """searoute sea distance in km, or None if it cannot be computed."""
    try:
        route = searoute.searoute(
            [coords[code_from][1], coords[code_from][0]],
            [coords[code_to][1], coords[code_to][0]],
            units="km",
        )
        return round(route.properties["length"])
    except Exception as e:
        print(f"sea distance failed for {code_from}-{code_to}: {e!r}")
        return None


def compute_geodesic_distance(code_from, code_to, coords):
    """geopy geodesic (great-circle) distance in km."""
    return round(geopy.distance.distance(coords[code_from], coords[code_to]).km)


def compute_distances(codes, coords, component_of):
    """Build {from: {to: {road, sea, air}}} for every unordered pair of codes."""
    distances = {}
    for i, code_from in enumerate(codes):
        distances[code_from] = {}
        for code_to in codes[i + 1 :]:
            geodesic_distance = compute_geodesic_distance(code_from, code_to, coords)
            connected = is_road_connected(code_from, code_to, component_of)
            distances[code_from][code_to] = {
                "road": round(ROAD_CIRCUITY_FACTOR * geodesic_distance)
                if connected
                else None,
                "sea": sea_distance(code_from, code_to, coords),
                "air": round(AIR_CIRCUITY_FACTOR * geodesic_distance),
            }
    return distances


if __name__ == "__main__":
    here = pathlib.Path(__file__).parent
    # official country list
    codes = country_set.distance_country_codes(country_set.DEFAULT_COUNTRIES_JSON)
    coords = load_country_coords(codes)
    component_of = build_road_components()

    nb_routes = round(len(codes) * (len(codes) - 1) / 2)
    print(f"number of routes : {nb_routes}")

    distances = compute_distances(codes, coords, component_of)

    output_path = here / "distances_raw.json"
    with open(output_path, "w") as outfile:
        json.dump(distances, outfile)
    print(f"{datetime.now().time()} finished writing output to {output_path}")
