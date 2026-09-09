import pytest
from ecobalyse.json import CompactJSONEncoder

test_0 = (
    {"value": 0.000123456789},
    """{ "value": 0.00012346 }""",
    "test_0",
)

test_1 = (
    {"value": 0.0000123456789},
    """{ "value": 1.2346e-05 }""",
    "test_1",
)
test_2 = (
    {"nested": {"value": 123.456789999}},
    """{ "nested": { "value": 123.46 } }""",
    "test_2",
)

test_3 = (
    {"list": [1234560000, 0.1000]},
    """{ "list": [1234600000.0, 0.1] }""",
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
    """{ "value": 1234600000.0 }""",
    "test_8",
)

test_9 = (
    {"value": True},
    """{ "value": true }""",
    "test_9",
)

test_10 = (
    {"tuple": (0.000123456789, 1234560000, 0.1000)},
    """{ "tuple": [0.00012346, 1234600000.0, 0.1] }""",
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
    encoder = CompactJSONEncoder(number_precision=5)
    result = encoder.encode(input_data)
    # Convert expected to JSON string for comparison

    assert result == expected, (
        f"{test_id}: Expected {expected}, but got {result} for input {input_data}"
    )


def test_max_width_encoder():

    input_data_small = {
        "data": {
            "numbers": [1.00001, 0.9999999],
        }
    }
    input_data = {
        "data": {
            "numbers": [1.00001, 0.9999999],
            "text": "test utrui utruitrui t",
            "another": "one bites the dust",
        }
    }

    encoder = CompactJSONEncoder()

    result_small = encoder.encode(input_data_small)
    assert result_small == '{ "data": { "numbers": [1.00001, 0.9999999] } }'

    result = encoder.encode(input_data)
    assert (
        result
        == """{
    "data": {
        "numbers": [1.00001, 0.9999999],
        "text": "test utrui utruitrui t",
        "another": "one bites the dust"
    }
}"""
    )


def test_max_items_encoder():

    input_data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    encoder = CompactJSONEncoder()

    result = encoder.encode(input_data)
    assert result == """[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]"""
    input_data.append(10)
    result = encoder.encode(input_data)

    assert (
        result
        == """[
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
]"""
    )
