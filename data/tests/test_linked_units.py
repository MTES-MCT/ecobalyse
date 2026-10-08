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


def products(db, external=()):
    return declared_units([*db, *external], lambda ds: ds["name"])


def test_each_exchange_takes_the_unit_of_what_it_links_to():
    irrigation = ("natural resource", "in water")
    cocoa = dataset(
        "Cocoa",
        "kilogram",
        # a regional water flow no import has created yet still lands in m3
        exchange("biosphere", "Water, river, ES", "litre", 1000.0, irrigation),
        exchange("technosphere", "Wastewater treatment", "litre", 1317.0),
        exchange("technosphere", "Heat", "kilowatt hour", 1.0),
        exchange("technosphere", "Grain drying", "litre", 2.0),
        exchange("production", "Cocoa", "kilogram", 1.0),
    )
    db = [dataset("Wastewater treatment", "cubic meter"), cocoa]
    # heat and grain drying come from the database this one links to
    external = [dataset("Heat", "megajoule"), dataset("Grain drying", "litre")]

    converted = convert_to_linked_units(db, products(db, external))

    assert [(e["unit"], e["amount"]) for e in converted[-1]["exchanges"]] == [
        ("cubic meter", pytest.approx(1.0)),
        ("cubic meter", pytest.approx(1.317)),
        ("megajoule", pytest.approx(3.6)),
        ("litre", 2.0),
        ("kilogram", 1.0),
    ]


def test_a_flow_in_kilograms_is_another_flow():
    """Sun drying emits water in kilograms, which the method characterizes per kg."""
    db = [
        dataset(
            "Drying",
            "kilogram",
            exchange("biosphere", "Water", "kilogram", 1.0, ("air",)),
        )
    ]

    converted = convert_to_linked_units(db, products(db))

    assert converted[-1]["exchanges"][0]["unit"] == "kilogram"


def test_a_product_declared_in_several_units_is_left_alone():
    db = [
        dataset("Heat", "megajoule"),
        dataset("Heat", "kilowatt hour"),
        dataset("Cocoa", "kilogram", exchange("technosphere", "Heat", "kilogram", 1.0)),
    ]

    converted = convert_to_linked_units(db, products(db))

    assert converted[-1]["exchanges"][0]["unit"] == "kilogram"


def test_an_input_with_no_known_conversion_stops_the_import():
    db = [
        dataset("Heat", "megajoule"),
        dataset("Cocoa", "kilogram", exchange("technosphere", "Heat", "kilogram", 1.0)),
    ]

    with pytest.raises(ValueError, match="no conversion"):
        convert_to_linked_units(db, products(db))
