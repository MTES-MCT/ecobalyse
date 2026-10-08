import json
from collections import defaultdict
from pathlib import Path

from import_method import (
    add_legacy_flow_synonyms,
    factors_by_flow_id,
    missing_land_occupation_cfs,
    missing_regional_water_cfs,
)


def method_with(*exchanges):
    return [
        {"name": ("EF 3.1", "Ecotoxicity, freshwater"), "exchanges": list(exchanges)}
    ]


def a_factor(name, amount):
    return {"name": name, "categories": ("soil",), "unit": "kg", "amount": amount}


def test_land_characterization():
    flows = [
        (("biosphere3", "a"), "Occupation, arable land, unspecified use"),
        (("biosphere3", "b"), "Occupation, annual crop"),
        (("biosphere3", "c"), "Water, river"),
    ]

    assert missing_land_occupation_cfs(flows, {("biosphere3", "b")}) == [
        (("biosphere3", "a"), 1)
    ]


def test_the_sea_is_not_land():
    """A fish meal declares 678 m²·year of open ocean on a single line, three orders of
    magnitude above any land in the same block."""
    flows = [
        (("biosphere3", "d"), "Occupation, sea and ocean"),
        (("biosphere3", "e"), "Occupation, dump site, benthos"),
    ]

    assert missing_land_occupation_cfs(flows, set()) == []


def test_an_enantiomer_takes_its_mixture_factor_only_where_it_has_none():
    ecotoxicity = method_with(
        a_factor("Metolachlor", 4066.5), a_factor("Metolachlor, (S)", 6935.5)
    )
    toxicity = [
        {
            "name": ("EF 3.1", "Human toxicity, non-cancer"),
            "exchanges": [a_factor("Metolachlor", 9.8331e-8)],
        }
    ]

    methods = add_legacy_flow_synonyms(ecotoxicity + toxicity)

    assert [
        [(cf["name"], cf["amount"]) for cf in method["exchanges"]] for method in methods
    ] == [
        [("Metolachlor", 4066.5), ("Metolachlor, (S)", 6935.5)],
        [("Metolachlor", 9.8331e-8), ("Metolachlor, (S)", 9.8331e-8)],
    ]


def test_a_stored_factor_names_its_flow_by_key_or_by_id():
    """bw2io writes a freshly imported method from node ids, the scripts extending it
    write from keys, and both forms come back from the same method."""
    ids = {("biosphere3", "a"): 7}

    assert factors_by_flow_id(
        [(["biosphere3", "a"], 1.5), (9, 3.5), (["biosphere3", "gone"], 9.9)], ids
    ) == {7: 1.5, 9: 3.5}


def test_water_of_an_unlisted_region_takes_the_world_average():
    """US electricity regions turbine and return water the method has no factor for."""
    resource, emission = ("natural resource", "in water"), ("water",)
    flows = [
        (
            "turbine",
            "Water, turbine use, unspecified natural origin",
            resource,
            "cubic meter",
        ),
        ("returned", "Water", emission, "kilogram"),
        (
            "FR",
            "Water, turbine use, unspecified natural origin, FR",
            resource,
            "cubic meter",
        ),
        (
            "SERC in",
            "Water, turbine use, unspecified natural origin, SERC",
            resource,
            "cubic meter",
        ),
        ("SERC out", "Water, SERC", emission, "cubic meter"),
        ("MRO out", "Water, MRO, US only", emission, "cubic meter"),
        ("rain", "Water, rain", emission, "cubic meter"),
    ]
    factors = {"turbine": 42.95, "returned": -0.042955, "FR": 6.98}

    assert missing_regional_water_cfs(
        flows, factors, {"FR", "SERC", "MRO, US only"}
    ) == [
        ("SERC in", 42.95),
        ("SERC out", -42.955),
        ("MRO out", -42.955),
    ]


def rename_table() -> list[list[str]]:
    return json.loads(
        (Path(__file__).parent.parent / "simapro-biosphere.json").read_text()
    )


def test_no_name_is_renamed_twice():
    targets = defaultdict(set)
    for compartment, source, target in rename_table():
        targets[(compartment, source)].add(target)

    assert {
        key: sorted(values) for key, values in targets.items() if len(values) > 1
    } == {}


def test_no_rename_loop():
    sources = {(compartment, source) for compartment, source, _ in rename_table()}
    chained = [
        (compartment, source, target)
        for compartment, source, target in rename_table()
        if (compartment, target) in sources
    ]

    assert chained == []
