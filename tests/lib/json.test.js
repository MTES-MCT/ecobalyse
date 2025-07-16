const { formatNumber, serialize } = require("../../lib/json");

const testData = [
  [NaN, `null`],
  [0, "0"],
  [0.000123456789, "0.000123457"],
  [0.0000123456789, "1.23457e-5"],
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
  [42.0, "42"],
  [1000000, "1e6"],
];

describe("lib.json", () => {
  describe("formatNumber", () => {
    test.each(testData)("formatNumber(%f) should return %s", (input, expected) => {
      expect(formatNumber(input)).toBe(expected);
    });
  });

  describe("serialize", () => {
    test.each(
      testData.map(([input, expected]) => {
        return [{ input }, `{"input":${expected}}`];
      }),
    )("serialize(%f) should return %s", (input, expected) => {
      expect(serialize(input, 0)).toBe(expected);
    });
  });
});
