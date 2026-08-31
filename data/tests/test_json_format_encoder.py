import pytest
from ecobalyse.json import CompactJSONEncoder

test_0 = (
    {"value": 0.000123456789},
    """{ "value": 0.0001235 }""",
    "test_0",
)

test_1 = (
    {"value": 0.0000123456789},
    """{ "value": 1.235e-05 }""",
    "test_1",
)
test_2 = (
    {"nested": {"value": 123.456789999}},
    """{ "nested": { "value": 123.5 } }""",
    "test_2",
)

test_3 = (
    {"list": [1234560000, 0.1000]},
    """{ "list": [1235000000.0, 0.1] }""",
    "test_3",
)

test_4 = (
    {"mixed": [{"value": 1000000}, 42.0]},
    """{ "mixed": [
    { "value": 1000000.0 },
    42.0
] }""",
    "test_4",
)
test_5 = (
    {"value": None},
    """{ "value": null }""",
    "test_5",
)

test_6 = (
    {"text": "hello"},
    """{ "text": "hello" }""",
    "test_6",
)

test_7 = (
    {"data": {"numbers": [1.00001, 0.9999999], "text": "test"}},
    """{ "data": { "numbers": [1.0, 1.0], "text": "test" } }""",
    "test_7",
)

test_8 = (
    {"value": 1234560000},
    """{ "value": 1235000000.0 }""",
    "test_8",
)

test_9 = (
    {"value": True},
    """{ "value": true }""",
    "test_9",
)

test_10 = (
    {"tuple": (0.000123456789, 1234560000, 0.1000)},
    """{ "tuple": [0.0001235, 1235000000.0, 0.1] }""",
    "test_10",
)

test_0_are_kept_as_int = (
    {"value": 0},
    """{ "value": 0 }""",
    "test_0_are_kept_as_int",
)


@pytest.mark.parametrize(
    "input_data, expected, test_id",
    [
        test_0,
        test_1,
        test_2,
        test_3,
        test_4,
        test_5,
        test_6,
        test_7,
        test_8,
        test_9,
        test_10,
        test_0_are_kept_as_int,
    ],
)
def test_format_number_json_encoder(input_data, expected, test_id):
    encoder = CompactJSONEncoder(number_precision=4)
    result = encoder.encode(input_data)
    # Convert expected to JSON string for comparison

    assert result == expected, (
        f"{test_id}: Expected {expected}, but got {result} for input {input_data}"
    )
