import json
from collections import defaultdict
from pathlib import Path

from import_method import missing_land_occupation_cfs


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
