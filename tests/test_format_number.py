import pytest

from data.common.export import format_number


@pytest.mark.parametrize(
    "number, expected, test_id",
    [
        (0.0000123456789, "1.23457e-5", "test_1"),
        (0.0000000123456789, "1.23457e-8", "test_2"),
        (123.456789999, "123.457", "test_3"),
        (1234567899999, "1.23457e12", "test_4"),
        (1.23456789999e-7, "1.23457e-7", "test_5"),
        (0.1, "0.1", "test_6"),
        (1, "1", "test_7"),
        (1.00001, "1.00001", "test_8"),
        (1.000001, "1", "test_9"),
        (0.9999999, "1", "test_10"),
        (1.23456e-7, "1.23456e-7", "test_11"),
        (1.23456e7, "1.23456e7", "test_12"),
        (42, "42", "test_13"),
        (1000000, "1e6", "test_14"),
    ],
)
def test_format_number(number, expected, test_id):
    result = format_number(number)
    assert (
        result == expected
    ), f"{test_id}: Expected {expected}, but got {result} for number {number}"
