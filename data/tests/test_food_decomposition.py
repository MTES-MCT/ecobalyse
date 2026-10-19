"""Tests of the decomposition on a fake, in-memory Agribalyse (no Brightway).

`NODES` are the activities (name, unit, production amount, SimaPro category path),
`INPUTS` what each one consumes for one run, `CATALOG` the names that count as catalog
ingredients. Every quantity a test checks is per kg of the decomposed product: an input
amount divided by the production amount of the activity that consumes it, multiplied
along the chain.
"""

from types import SimpleNamespace

from bin import decompose_food
from ecobalyse_data.food_decomposition import (
    CatalogIngredient,
    Decomposer,
    InMemoryGraph,
    InputClass,
    Node,
    classify,
    ingredient_key,
    is_farm_gate,
    preferred_ingredient,
)

FOOD = ("Agricultural", "Food", "Transformation")
FARM = ("Agricultural", "Plant production", "Fruits")
ECOINVENT = ("Others", "Copied from Ecoinvent cut-off S")


def node(name, unit="kilogram", production_amount=1.0, path=FOOD):
    return Node(
        name=name, unit=unit, production_amount=production_amount, category_path=path
    )


MILK = "Cow milk, national average, at farm gate {FR} U"
MILK_VARIANT = "Cow milk, lowland, at farm gate {FR} U"
GOAT_MILK_MIX = "Goat milk, consumption mix {FR} U"
GOAT_MILK_FARM = "Goat milk, intensive, at farm gate {FR} U"
TRUCK = "Transport, freight, lorry {RER}| market for"
OLIVE = "Olive {ES}| olive production | Cut-off, U - Adapted from Ecoinvent U"
OLIVE_OIL_PLANT = "Olive oil, at plant {ES} U"
OLIVE_OIL_MIX = "Olive oil, consumption mix {FR} U"
PESTICIDES = "Emissions from pesticides, mix for fruit tree, at farm S {GLO} - Adapted from WFLDB U"
WFLDB_SYRUP = "Corn glucose syrup, at plant {GLO} - Adapted from WFLDB U"
WFLDB_MAIZE = "Maize grain, at farm {GLO} - Adapted from WFLDB U"
CIDER_APPLE = "Cider apple, at orchard {FR} U"
ELEC = "Electricity, medium voltage {FR}| market for"
HEAT = "Heat, district or industrial, natural gas"
PROPANE = "Propane, burned in industrial furnace, at plant {FR} U"
WATER = "Tap water {FR}| market for tap water"
SALT = "Sodium chloride, powder {GLO}| market for"
YOGURT_MARKET = "Yogurt, from cow milk {GLO}| market for"

NODES = {
    MILK: node(MILK, path=("Agricultural", "Food", "Consumption mixes")),
    MILK_VARIANT: node(
        MILK_VARIANT, path=("Agricultural", "Animal production", "Milk")
    ),
    GOAT_MILK_MIX: node(
        GOAT_MILK_MIX, path=("Agricultural", "Food", "Consumption mixes")
    ),
    GOAT_MILK_FARM: node(
        GOAT_MILK_FARM, path=("Agricultural", "Animal production", "Milk")
    ),
    TRUCK: node(TRUCK, unit="ton kilometer", path=ECOINVENT),
    OLIVE: node(OLIVE, path=("Others", "Adapted from Ecoinvent cut-off U")),
    OLIVE_OIL_PLANT: node(
        OLIVE_OIL_PLANT, path=("Agricultural", "Plant oils", "Transformation")
    ),
    OLIVE_OIL_MIX: node(
        OLIVE_OIL_MIX, path=("Agricultural", "Food", "Consumption mixes")
    ),
    PESTICIDES: node(PESTICIDES, path=("Others", "Adapted from WFLDB")),
    WFLDB_SYRUP: node(WFLDB_SYRUP, path=("Others", "Adapted from WFLDB")),
    WFLDB_MAIZE: node(WFLDB_MAIZE, path=("Others", "Adapted from WFLDB")),
    "syrup": node("syrup"),
    CIDER_APPLE: node(CIDER_APPLE, path=FARM),
    ELEC: node(ELEC, unit="kilowatt hour", path=ECOINVENT),
    HEAT: node(HEAT, unit="megajoule", path=ECOINVENT),
    PROPANE: node(PROPANE, unit="megajoule", path=("Others",)),
    WATER: node(WATER, path=("Others", "Adapted from Ecoinvent cut-off U")),
    SALT: node(SALT, path=ECOINVENT),
    YOGURT_MARKET: node(YOGURT_MARKET, path=ECOINVENT),
    "cheese": node("cheese", production_amount=2.0),
    "cheese mix": node(
        "cheese mix", path=("Agricultural", "Food", "Consumption mixes")
    ),
    "cheese at plant": node("cheese at plant"),
    "juice": node("juice"),
    "concentrate": node("concentrate", production_amount=1.2),
    "pressing": node("pressing", path=("Agricultural", "Food")),
    "yogurt": node("yogurt"),
    "loop a": node("loop a"),
    "loop b": node("loop b"),
}
INPUTS = {
    MILK: [(MILK_VARIANT, 1.0), (PESTICIDES, 0.1)],
    GOAT_MILK_MIX: [(GOAT_MILK_FARM, 1.0), (TRUCK, 0.1)],
    OLIVE_OIL_MIX: [(OLIVE_OIL_PLANT, 1.0), (TRUCK, 0.2)],
    OLIVE_OIL_PLANT: [(OLIVE, 5.0), (ELEC, 0.1)],
    "syrup": [(WFLDB_SYRUP, 1.0)],
    WFLDB_SYRUP: [(WFLDB_MAIZE, 0.9), (HEAT, 2.0)],
    # multi-output process: 10 kg milk for 2 kg of cheese (allocated production amount)
    "cheese": [
        (MILK, 10.0),
        (ELEC, 0.9),
        (HEAT, 3.0),
        (PROPANE, 0.5),
        (WATER, 7.0),
        (SALT, 0.01),
    ],
    "cheese mix": [("cheese", 1.0)],
    "cheese at plant": [("cheese mix", 1.0)],
    # juice: 0.2 kg of a concentrate made of 8 kg apples per 1.2 kg through a unit operation
    "juice": [("concentrate", 0.2), (WATER, 0.8), (ELEC, 0.03)],
    "concentrate": [(CIDER_APPLE, 8.0), ("pressing", 6.0)],
    "pressing": [(ELEC, 0.01)],
    "yogurt": [(YOGURT_MARKET, 1.0)],
    "loop a": [("loop b", 1.0), (ELEC, 1.0)],
    "loop b": [("loop a", 0.5)],
}
CATALOG = {
    MILK,
    "cheese at plant",
    "juice",
    "yogurt",
    OLIVE,
    OLIVE_OIL_PLANT,
    OLIVE_OIL_MIX,
}


def decomposer():
    return Decomposer(InMemoryGraph(NODES, INPUTS), CATALOG)


def test_classify_catalog_ingredient_before_consumption_mix_rule():
    """The fixture milk is raw although its category is a consumption mix, a folder the
    walk normally descends into ("cheese mix", same folder, is a transformation step).
    The milk is raw through its farm-gate name ("at farm gate"), which is tried before
    the transformation folder rule. It would be raw with an empty catalog too."""
    assert classify(NODES[MILK], CATALOG) is InputClass.raw
    assert classify(NODES["cheese mix"], CATALOG) is InputClass.transform


def test_classify_farm_gate_not_in_catalog_is_raw():
    """An activity of the "Plant production" folder that is not in the catalog (cider
    apple) is still a raw material. The CLI reports it as missing from the catalog."""
    assert classify(NODES[CIDER_APPLE], CATALOG) is InputClass.raw


def test_classify_energy_by_unit():
    """Electricity is a kWh input named "Electricity". Heat is any MJ input: a gas heat
    market as well as a propane furnace."""
    assert classify(NODES[ELEC], CATALOG) is InputClass.elec
    assert classify(NODES[HEAT], CATALOG) is InputClass.heat
    assert classify(NODES[PROPANE], CATALOG) is InputClass.heat


def test_classify_water_and_other():
    """Tap water has its own class. Anything that is neither raw, energy, water, waste,
    transport nor an Agribalyse transformation step is "other": salt, and an ecoinvent
    yogurt market."""
    assert classify(NODES[WATER], CATALOG) is InputClass.water
    assert classify(NODES[SALT], CATALOG) is InputClass.other
    assert classify(NODES[YOGURT_MARKET], CATALOG) is InputClass.other


def test_multi_output_product_is_normalised_by_allocated_production_amount():
    """One run of "cheese" makes 2 kg of cheese (production_amount=2.0, the allocated
    share of a multi-output process), so every input is divided by 2.

    Walk from "cheese at plant":

    | Step | Activity            | Input met                | Decision                    |
    |------|---------------------|--------------------------|-----------------------------|
    | 1    | cheese at plant     | 1 kg cheese mix          | transform, walk into it     |
    | 2    | cheese mix          | 1 kg cheese              | transform, walk into it     |
    | 3    | cheese (makes 2 kg) | 10 kg milk               | catalog: 10 / 2 = 5 kg raw  |
    |      |                     | 0.9 kWh electricity      | 0.45 kWh                    |
    |      |                     | 3 MJ gas, 0.5 MJ propane | 1.75 MJ heat                |
    |      |                     | 7 kg tap water           | 3.5 kg water                |
    |      |                     | 0.01 kg salt             | 0.005 kg other              |

    Steps 1 and 2 consume 1 kg each, so the quantities found in "cheese" come back
    unchanged to "cheese at plant"."""
    totals = decomposer().decompose("cheese at plant").totals
    assert totals.raw == {MILK: 5.0}
    assert totals.elec_kwh == 0.45
    assert totals.heat_mj == 1.75
    assert totals.heat_detail == {HEAT: 1.5, PROPANE: 0.25}
    assert totals.water_kg == 3.5
    assert totals.other == {SALT: 0.005}
    assert totals.main_ingredient_share == 1.0


def test_shared_unit_operation_is_multiplied_along_the_chain():
    """Quantities are multiplied along the chain. 1 kg of juice takes 0.2 kg of
    concentrate. One run of "concentrate" makes 1.2 kg from 8 kg of apples and 6 kg of
    "pressing", and pressing uses 0.01 kWh per kg.

    | Quantity per kg of juice | Computed as                         | Value |
    |--------------------------|-------------------------------------|-------|
    | apples                   | 0.2 × 8 / 1.2                       | 1.333 |
    | electricity              | 0.03 (juice) + 0.2 × 6 / 1.2 × 0.01 | 0.04  |
    | water                    | 0.8 (juice)                         | 0.8   |
    """
    totals = decomposer().decompose("juice").totals
    assert abs(totals.raw[CIDER_APPLE] - 0.2 * 8.0 / 1.2) < 1e-12
    assert abs(totals.elec_kwh - (0.03 + 0.2 * 6.0 * 0.01 / 1.2)) < 1e-12
    assert totals.water_kg == 0.8


def test_product_on_an_ecoinvent_market_has_no_raw_material():
    """A product whose only input is an ecoinvent market (yogurt, a model difference in
    Agribalyse 3.2) gives no raw material: the market is "other" and the walk stops
    there. The CLI then skips the product."""
    totals = decomposer().decompose("yogurt").totals
    assert totals.raw == {}
    assert totals.other == {YOGURT_MARKET: 1.0}


def test_cycle_is_truncated_and_reported():
    """A cycle: "loop a" takes 1 kg of "loop b" and 1 kWh, "loop b" takes 0.5 kg of
    "loop a". When the walk meets "loop a" again inside "loop b", it stops, records
    "loop a" as truncated and counts the 0.5 kg as "other" instead of looping forever."""
    totals = decomposer().decompose("loop a").totals
    assert totals.elec_kwh == 1.0
    assert totals.truncated == {"loop a"}
    assert totals.other == {"loop a": 0.5}


def test_memoisation_reuses_the_same_totals():
    """Each activity is decomposed once per Decomposer. Decomposing "cheese mix" after
    "cheese at plant" reuses the totals computed on the way, with the same result."""
    shared = decomposer()
    first = shared.decompose("cheese at plant").totals
    second = shared.decompose("cheese mix").totals
    assert first.raw == second.raw


def test_farm_gate_name_marker_ignores_emission_activities():
    """A farm-gate product is recognised by its name: "at farm gate", WFLDB "at farm",
    or an ecoinvent "olive production" activity. "Emissions from pesticides, ..., at farm
    S" is not one (the " S" excludes it): it is a WFLDB process the walk descends into."""
    assert is_farm_gate(NODES[MILK])
    assert is_farm_gate(NODES[WFLDB_MAIZE])
    assert is_farm_gate(NODES[OLIVE])
    assert not is_farm_gate(NODES[PESTICIDES])
    assert classify(NODES[PESTICIDES], CATALOG) is InputClass.transform


def test_raw_catalog_ingredient_stops_the_walk_before_its_farm_inputs():
    """The fixture milk has inputs of its own (a farm variant, pesticide emissions), but
    once the milk is raw the walk stops there: only the milk is reported."""
    totals = decomposer().decompose("cheese at plant").totals
    assert totals.raw == {MILK: 5.0}


def test_transformed_catalog_ingredient_is_recursed_unless_stop_at_catalog():
    """Olive oil at plant is a catalog ingredient but also a transformation step (Plant
    oils folder), so by default the walk goes through it down to the olives: 5 kg of
    olives and 0.1 kWh per kg of oil. With `stop_at_catalog`, it stops on the oil itself
    (1 kg per kg of the mix)."""
    totals = decomposer().decompose(OLIVE_OIL_MIX).totals
    assert totals.raw == {OLIVE: 5.0}
    assert totals.elec_kwh == 0.1
    stopping = Decomposer(InMemoryGraph(NODES, INPUTS), CATALOG, stop_at_catalog=True)
    assert stopping.decompose(OLIVE_OIL_MIX).totals.raw == {OLIVE_OIL_PLANT: 1.0}


def test_consumption_mix_of_several_raw_materials_is_kept_whole():
    """The goat milk mix averages two farm systems (0.6 + 0.4 kg) plus transport. It is
    kept whole as one raw material, so the component points at one ingredient instead of
    two farm variants. "cheese" makes 2 kg from 4 kg of mix: 2 kg per kg of cheese."""
    nodes = {
        **NODES,
        "goat farm 2": node("goat farm 2", path=("Agricultural", "Animal production")),
    }
    inputs = {
        **INPUTS,
        "cheese": [(GOAT_MILK_MIX, 4.0)],
        GOAT_MILK_MIX: [(GOAT_MILK_FARM, 0.6), ("goat farm 2", 0.4), (TRUCK, 0.1)],
    }
    totals = (
        Decomposer(InMemoryGraph(nodes, inputs), CATALOG).decompose("cheese").totals
    )
    assert totals.raw == {GOAT_MILK_MIX: 2.0}


def test_consumption_mix_of_one_raw_material_is_walked_through():
    """A mix of a single farm system is not kept whole: the walk goes through it to the
    farm milk (4 / 2 = 2 kg per kg of cheese) and counts the mix's transport
    (0.1 tkm per kg of mix × 2 kg = 0.2 tkm)."""
    graph = InMemoryGraph(NODES, {**INPUTS, "cheese": [(GOAT_MILK_MIX, 4.0)]})
    totals = Decomposer(graph, CATALOG).decompose("cheese").totals
    assert totals.raw == {GOAT_MILK_FARM: 2.0}
    assert totals.transport_tkm == 0.2


def test_wfldb_adapted_process_is_recursed():
    """A process Agribalyse adapted from WFLDB (corn glucose syrup) is a transformation
    step even outside the "Agricultural" folder: the walk reaches its maize (0.9 kg)
    and its heat (2 MJ)."""
    totals = decomposer().decompose("syrup").totals
    assert totals.raw == {WFLDB_MAIZE: 0.9}
    assert totals.heat_mj == 2.0


def test_preferred_ingredient_names_the_activity_before_scope_and_scenario():
    """Several aliases can share one Agribalyse activity: the carrot activity also stands
    for beetroot and parsnip. The component must point at the alias whose first word is
    in the activity name ("carrot-fr"), even if another alias has the food2 scope or the
    reference scenario."""

    def variant(alias, scopes=("food", "food2"), scenario="reference"):
        return CatalogIngredient(
            alias=alias,
            metadata_id=alias,
            activity_name="Carrot, conventional, national average, at farm gate {FR} U",
            source="Agribalyse 3.2",
            display_name=alias,
            scopes=scopes,
            scenario=scenario,
            default_origin="France",
        )

    variants = [
        variant("beetroot-fr-2025"),
        variant("carrot-fr", scopes=("food",), scenario="import"),
        variant("parsnip-fr"),
    ]
    assert preferred_ingredient(variants).alias == "carrot-fr"


HEAT_KWH_STUB = "Heat, district or industrial, natural gas {Europe without Switzerland}| market for heat, district or industrial, natural gas | Cut-off, S - Copied from Ecoinvent U"
LPG_KWH = "Energy from Liquefied petroleum gas, burned, Market {GLO}"
COFFEE_KWH = "Coffee treatement, with electronic machinery {GLO} U"


def test_heat_labelled_kwh_is_heat_and_only_native_kwh_is_converted():
    """Some ecoinvent heat markets are labelled kWh in our Agribalyse 3.2 import while
    their amounts are MJ. All three kWh inputs below are handled differently:

    | Input                            | Class     | Per kg of product          |
    |----------------------------------|-----------|----------------------------|
    | ecoinvent heat market, 1.5 "kWh" | heat      | 1.5 MJ, amount kept        |
    | LPG burned (Agribalyse), 1 kWh   | heat      | 3.6 MJ, converted          |
    | coffee treatment, 2 kWh          | transform | walked: 2 × 1 kWh = 2 kWh  |
    """
    nodes = {
        **NODES,
        HEAT_KWH_STUB: node(HEAT_KWH_STUB, unit="kilowatt hour", path=()),
        LPG_KWH: node(LPG_KWH, unit="kilowatt hour", path=("Others", "Transformation")),
        COFFEE_KWH: node(
            COFFEE_KWH,
            unit="kilowatt hour",
            path=("Agricultural", "Field Operations"),
        ),
        "concentrate": node("concentrate"),
    }
    inputs = {
        **INPUTS,
        "concentrate": [(HEAT_KWH_STUB, 1.5), (LPG_KWH, 1.0), (COFFEE_KWH, 2.0)],
        COFFEE_KWH: [(ELEC, 1.0)],
    }
    assert classify(nodes[HEAT_KWH_STUB], CATALOG) is InputClass.heat
    assert classify(nodes[LPG_KWH], CATALOG) is InputClass.heat
    assert classify(nodes[COFFEE_KWH], CATALOG) is InputClass.transform
    totals = (
        Decomposer(InMemoryGraph(nodes, inputs), CATALOG)
        .decompose("concentrate")
        .totals
    )
    assert totals.heat_detail == {HEAT_KWH_STUB: 1.5, LPG_KWH: 3.6}
    assert totals.elec_kwh == 2.0


def test_ingredient_key_is_the_name_before_the_first_comma_brace_or_pipe():
    assert ingredient_key("Banana, at farm {GLO} - Adapted from WFLDB U") == "banana"
    assert ingredient_key("Banana {CO}| banana production | Cut-off, U") == "banana"
    assert ingredient_key(OLIVE) == "olive"
    assert ingredient_key(MILK) == "cow milk"


def test_main_ingredient_adds_up_the_origins_of_the_main_raw_material():
    """1 kg of oil takes olives from two origins and a little salt. The main raw activity
    is the largest origin. The main ingredient is all the olives, which is what the
    component uses. Salt is a catalog ingredient, so a raw material, but not olive.

    | Input           | kg   | Ingredient      |
    |-----------------|------|-----------------|
    | Olive {ES}      | 3.0  | olive           |
    | Olive {IT}      | 2.0  | olive           |
    | Sodium chloride | 0.05 | sodium chloride |

    Main raw activity: Olive {ES}, 3 kg. Main ingredient: olive, 5 kg, 5 / 5.05 of the
    raw inputs."""
    olive_italy = "Olive {IT}| olive production | Cut-off, U - Adapted from Ecoinvent U"
    nodes = {
        **NODES,
        olive_italy: node(olive_italy, path=("Others", "Adapted from Ecoinvent")),
        "oil": node("oil", path=("Agricultural", "Plant oils", "Transformation")),
    }
    inputs = {**INPUTS, "oil": [(OLIVE, 3.0), (olive_italy, 2.0), (SALT, 0.05)]}
    catalog = CATALOG | {olive_italy, SALT}
    totals = Decomposer(InMemoryGraph(nodes, inputs), catalog).decompose("oil").totals
    assert totals.main_raw_activity == (OLIVE, 3.0)
    assert totals.main_ingredient == ("olive", 5.0)
    assert totals.main_ingredient_share == 5.0 / 5.05


def test_build_entries_derives_file_name_ids_and_names_from_the_key_and_product_name(
    monkeypatch,
):
    """`components` builds catalog products and `--activity` products the same way: only
    the key and the French name differ. For 1 kg of cheese made from 4 kg of milk with
    0.4 kWh and 2 MJ, the transformation is per kg of milk:

    | Field               | Value                             |
    |---------------------|-----------------------------------|
    | file name           | abondance-fr-transformation       |
    | elecKwh             | 0.4 / 4 = 0.1                     |
    | heatMJ              | 2 / 4 = 0.5                       |
    | qtyVariationRatio   | 1 / 4 = 0.25                      |
    | component           | Abondance FR (1 kg), 1 kg of milk |
    """
    # The testing settings have no Agribalyse database, which the comment names
    agribalyse_settings = SimpleNamespace(
        bw=SimpleNamespace(agribalyse="Agribalyse 3.2")
    )
    monkeypatch.setattr(decompose_food, "settings", agribalyse_settings)
    raw_milk = CatalogIngredient(
        alias="cow-milk-fr",
        metadata_id="milk-metadata-id",
        activity_name=MILK,
        source="Agribalyse 3.2",
        display_name="Lait de vache FR",
        scopes=("food2",),
        scenario=None,
        default_origin=None,
    )
    result = {
        "product": "Abondance cheese, at plant {FR} U",
        "main_ingredient_kg": 4.0,
        "elec_kwh": 0.4,
        "heat_mj": 2.0,
    }
    entries = decompose_food.build_entries(
        decompose_food.slugify("Abondance FR"), "Abondance FR", raw_milk, result
    )
    transform, component = entries["transform"], entries["component"]
    assert entries["slug"] == "abondance-fr-transformation"
    assert transform["displayName"] == "Transformation : Abondance FR"
    assert (transform["elecKwh"], transform["heatMJ"]) == (0.1, 0.5)
    assert transform["qtyVariationRatio"] == 0.25
    assert component["name"] == "Abondance FR (1 kg)"
    assert component["elements"][0]["material"]["id"] == "milk-metadata-id"
    assert (
        component["elements"][0]["transforms"][0]["id"]
        == transform["metadata"][0]["id"]
    )
