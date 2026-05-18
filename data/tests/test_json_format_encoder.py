import pytest

from common import FormatNumberJsonEncoder


@pytest.mark.parametrize(
    "input_data, expected, test_id",
    [
        ({"value": 0.000123456789}, '{"value": 0.00012346}', "test_0"),
        ({"value": 0.0000123456789}, '{"value": 1.2346e-05}', "test_1"),
        (
            {"nested": {"value": 123.456789999}},
            '{"nested": {"value": 123.46}}',
            "test_2",
        ),
        ({"list": [1234560000, 0.1000]}, '{"list": [1234600000.0, 0.1]}', "test_3"),
        (
            {"mixed": [{"value": 1000000}, 42.0]},
            '{"mixed": [{"value": 1000000.0}, 42.0]}',
            "test_4",
        ),
        ({"value": None}, '{"value": null}', "test_5"),
        ({"text": "hello"}, '{"text": "hello"}', "test_6"),
        (
            {"data": {"numbers": [1.00001, 0.9999999], "text": "test"}},
            '{"data": {"numbers": [1.0, 1.0], "text": "test"}}',
            "test_7",
        ),
        ({"value": 1234560000}, '{"value": 1234600000.0}', "test_8"),
        ({"value": True}, '{"value": true}', "test_9"),
        (
            {"tuple": tuple([0.000123456789, 1234560000, 0.1000])},
            '{"tuple": [0.00012346, 1234600000.0, 0.1]}',
            "test_10",
        ),
        ({"value": 0}, '{"value": 0}', "test_0_are_kept_as_int"),
    ],
)
def test_format_number_json_encoder(input_data, expected, test_id):
    encoder = FormatNumberJsonEncoder()
    result = encoder.encode(input_data)
    # Convert expected to JSON string for comparison

    assert result == expected, (
        f"{test_id}: Expected {expected}, but got {result} for input {input_data}"
    )
