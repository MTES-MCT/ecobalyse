import pytest

from ecobalyse_data.export.complements import (
    MICROFIBERS_COEFFICIENTS,
    MICROFIBERS_RAW_MATERIAL_RATIO,
    compute_microfibers_complement,
)
from ecobalyse_data.export.export_generic import _build_variant_metadata


@pytest.mark.parametrize(
    "origin,expected",
    [
        ("ArtificialFromOrganic", 330),
        ("NaturalFromAnimal", 390),
        ("NaturalFromVegetal", 250),
        ("Synthetic", 820),
    ],
)
def test_microfibers_complement_by_origin(origin, expected):
    assert compute_microfibers_complement(origin, "kg") == pytest.approx(
        expected * MICROFIBERS_RAW_MATERIAL_RATIO
    )


@pytest.mark.parametrize(
    "origin,expected",
    [
        # Values requested in #2236: textile values reduced by 30% for losses
        ("ArtificialFromOrganic", 231),
        ("NaturalFromAnimal", 273),
        ("NaturalFromVegetal", 175),
        ("Synthetic", 574),
    ],
)
def test_microfibers_complement_expected_values(origin, expected):
    assert compute_microfibers_complement(origin, "kg") == pytest.approx(expected)


def test_microfibers_coefficients_match_textile_origins():
    # Must stay in sync with `Origin` in src/Data/Textile/Material/Origin.elm
    assert set(MICROFIBERS_COEFFICIENTS) == {
        "ArtificialFromOrganic",
        "NaturalFromAnimal",
        "NaturalFromVegetal",
        "Synthetic",
    }


def test_microfibers_complement_without_origin():
    assert compute_microfibers_complement(None, "kg") is None
    assert compute_microfibers_complement(None, "m3") is None


def test_microfibers_complement_unknown_origin():
    with pytest.raises(ValueError, match="Unknown textile origin"):
        compute_microfibers_complement("Mineral", "kg")


def test_microfibers_complement_requires_kg():
    with pytest.raises(ValueError, match="expects a process in kg"):
        compute_microfibers_complement("Synthetic", "m2")


def test_build_variant_metadata_adds_microfibers():
    metadata = _build_variant_metadata(
        variant={"alias": "pet", "id": "x", "origin": "Synthetic"},
        activity={"categories": ["material"], "unit": "kg"},
        food_variant=None,
        es_by_alias={},
    )
    assert metadata is not None
    assert metadata["complements"] == {
        "microfibers": pytest.approx(820 * MICROFIBERS_RAW_MATERIAL_RATIO)
    }


def test_build_variant_metadata_without_origin_has_no_microfibers():
    metadata = _build_variant_metadata(
        variant={"alias": "steel", "id": "x"},
        activity={"categories": ["material"], "unit": "kg"},
        food_variant=None,
        es_by_alias={},
    )
    assert metadata is None or "complements" not in metadata


def test_build_variant_metadata_reports_alias_on_error():
    with pytest.raises(ValueError, match="entry 'weird'"):
        _build_variant_metadata(
            variant={"alias": "weird", "id": "x", "origin": "Mineral"},
            activity={"categories": ["material"], "unit": "kg"},
            food_variant=None,
            es_by_alias={},
        )
