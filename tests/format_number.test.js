const formatNumber = require("../your_module"); // Replace with the actual path to your module

describe("formatNumber", () => {
  test.each([
    [0.000123456789, "1.23457e-4"],
    [0.0000000123456789, "1.23457e-8"],
    [123.456789999, "123.457"],
    [1234567899999, "1.23457e12"],
    [1.23456789999e-7, "1.23457e-7"],
    [0.1, "0.1"],
    [1, "1"],
    [1.00001, "1.00001"],
    [1.000001, "1"],
    [0.9999999, "1"],
    [1.23456e-7, "1.23456e-7"],
    [1.23456e7, "1.23456e7"],
    [1.23456e7, "1.23456e7"],
    [42, "42"],
    [1000000, "1e6"],
    [Infinity, "Infinity"],
    [-Infinity, "-Infinity"],
    [NaN, "NaN"],
  ])("formatNumber(%f) should return %s", (input, expected) => {
    expect(formatNumber(input)).toBe(expected);
  });

  test("formatNumber with custom decimal places", () => {
    expect(formatNumber(123.456789, 4)).toBe("123.4568");
    expect(formatNumber(0.000123456789, 8)).toBe("1.23456789e-4");
  });

  test("formatNumber with invalid input", () => {
    expect(() => formatNumber("not a number")).toThrow();
  });
});
