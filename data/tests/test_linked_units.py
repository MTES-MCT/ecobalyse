import pytest

from ecobalyse_data.bw.strategy import convert_to_linked_units, declared_units


def dataset(name, unit, *exchanges):
    return {"name": name, "unit": unit, "exchanges": list(exchanges)}


def exchange(kind, name, unit, amount, categories=()):
    return {
        "type": kind,
        "name": name,
        "unit": unit,
        "amount": amount,
        "categories": categories,
    }


RIVER = ("natural resource", "in water")
FLOWS = {
    ("Water, river, FR", RIVER): {"cubic meter"},
    ("Heat, waste", ("air",)): {"megajoule"},
    ("Water", ("air",)): {"cubic meter", "kilogram"},
}


def products(db, external=()):
    return declared_units([*db, *external], lambda ds: ds["name"])


def test_each_exchange_takes_the_unit_of_what_it_links_to():
    cocoa = dataset(
        "Cocoa",
        "kilogram",
        exchange("biosphere", "Water, river, FR", "litre", 1000.0, RIVER),
        exchange("biosphere", "Heat, waste", "kilowatt hour", 1.0, ("air",)),
        exchange("technosphere", "Wastewater treatment", "litre", 1317.0),
        exchange("technosphere", "Heat", "kilowatt hour", 1.0),
        exchange("technosphere", "Grain drying", "litre", 2.0),
        exchange("production", "Cocoa", "kilogram", 1.0),
    )
    db = [dataset("Wastewater treatment", "cubic meter"), cocoa]
    # heat and grain drying come from the database this one links to
    external = [dataset("Heat", "megajoule"), dataset("Grain drying", "litre")]

    converted = convert_to_linked_units(db, products(db, external), FLOWS)

    assert [(e["unit"], e["amount"]) for e in converted[-1]["exchanges"]] == [
        ("cubic meter", pytest.approx(1.0)),
        ("megajoule", pytest.approx(3.6)),
        ("cubic meter", pytest.approx(1.317)),
        ("megajoule", pytest.approx(3.6)),
        ("litre", 2.0),
        ("kilogram", 1.0),
    ]


def test_a_target_declared_in_several_units_is_left_alone():
    db = [
        dataset(
            "Cocoa", "kilogram", exchange("biosphere", "Water", "litre", 1.0, ("air",))
        )
    ]

    converted = convert_to_linked_units(db, products(db), FLOWS)

    assert converted[-1]["exchanges"][0]["unit"] == "litre"


def test_an_input_with_no_known_conversion_stops_the_import():
    db = [
        dataset("Heat", "megajoule"),
        dataset("Cocoa", "kilogram", exchange("technosphere", "Heat", "kilogram", 1.0)),
    ]

    with pytest.raises(ValueError, match="no conversion"):
        convert_to_linked_units(db, products(db), FLOWS)
