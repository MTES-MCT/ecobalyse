import json

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.export import food


def test_load_es_dic(es_factors_csv_file, es_factors_json):
    content = food.load_ecosystemic_dic(es_factors_csv_file)

    assert len(content) == 35
    assert "AUTRES CULTURES INDUSTRIELLES" in content
    assert content["AUTRES CULTURES INDUSTRIELLES"]["cropDiversity"]["organic"] == 9.196


def test_feed_permanent_pasture():
    """Known grazing live animal has permanent pasture in its feed"""
    feed_file_path = PROJECT_ROOT_DIR / "food" / "ecosystemic_services" / "feed.json"

    with open(feed_file_path) as f:
        content = json.load(f)

    animal = "lamb-organic-national-average-farm-gate-fr-u-live"
    animal_feed = content[animal]

    permanent_key = settings.scopes.food.grazed_grass_permanent_key

    assert animal_feed.get(permanent_key, 0) > 0, (
        f"In {feed_file_path}, expected '{animal}' to have '{permanent_key}' > 0"
    )


def test_raw_to_transformed_keys_in_feed():
    """Every raw (upstream) alias in raw_to_transformed_ratios.json must exist in feed.json"""
    es_dir = PROJECT_ROOT_DIR / "food" / "ecosystemic_services"

    with open(es_dir / "feed.json") as f:
        feed = json.load(f)
    with open(es_dir / "raw_to_transformed_ratios.json") as f:
        raw_to_transformed = json.load(f)

    for raw_alias in raw_to_transformed:
        assert raw_alias in feed, (
            f"Raw alias '{raw_alias}' from raw_to_transformed_ratios.json not found in feed.json"
        )


def test_resolve_feed_direct():
    """Direct products (milk, eggs) resolve from feed.json directly"""
    feed = {"milk-2025": {"grass": 0.5}}
    raw_to_transformed = {}
    transformed_to_raw = food.build_transformed_to_raw(raw_to_transformed)

    result = food.resolve_feed("milk-2025", feed, transformed_to_raw)
    assert result == {"grass": 0.5}


def test_resolve_feed_via_ratio():
    """Transformed products resolve via raw feed × ratio"""
    feed = {"pig-live": {"wheat": 1.0, "corn": 2.0}}
    raw_to_transformed = {
        "pig-live": {"bacon": {"ratio": 2.16, "source": "brightway", "source_ref": ""}}
    }
    transformed_to_raw = food.build_transformed_to_raw(raw_to_transformed)

    result = food.resolve_feed("bacon", feed, transformed_to_raw)
    assert result == {"wheat": 2.16, "corn": 4.32}


def test_resolve_feed_unknown():
    """Unknown alias returns None"""
    result = food.resolve_feed("unknown", {}, {})
    assert result is None
