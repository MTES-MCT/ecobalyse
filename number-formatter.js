function formatNumber(num, precision = 6) {
  if (typeof num !== "number" || isNaN(num)) {
    return String(num);
  }

  const absNum = Math.abs(num);
  if (absNum === 0) {
    return "0";
  }

  // Python uses scientific notation if exponent >= precision or <= -4
  const exponent = Math.floor(Math.log10(absNum));
  const useScientific = exponent >= precision || exponent <= -4;

  if (useScientific) {
    // Use scientific notation
    const scientificStr = num
      .toExponential(precision - 1)
      .replace(/\.?0+e/, "e") // Remove trailing zeros before 'e'
      .replace(/\.$/, "") // Remove trailing decimal point
      .replace(/e\+?/, "e") // Remove '+' sign and leading zeros in positive exponent
      .replace(/e-0?/, "e-"); // Remove leading zeros in negative exponent
    return scientificStr;
  } else {
    // Use fixed notation
    // Calculate decimal places needed based on exponent and precision
    const decimalPlaces = Math.max(0, precision - exponent - 1);
    let fixedStr = num
      .toFixed(decimalPlaces)
      .replace(/\.?0+$/, "") // Remove trailing zeros
      .replace(/\.$/, ""); // Remove trailing decimal point
    return fixedStr;
  }
}

// Replace the existing test cases with Jest-style tests
describe("formatNumber", () => {
  const testCases = [
    [0.0000123456789, "1.23457e-5", "test_1"],
    [0.0000000123456789, "1.23457e-8", "test_2"],
    [123.456789999, "123.457", "test_3"],
    [1234567899999, "1.23457e+12", "test_4"],
    [1.23456789999e-7, "1.23457e-7", "test_5"],
    [0.1, "0.1", "test_6"],
    [1, "1", "test_7"],
    [1.00001, "1.00001", "test_8"],
    [1.000001, "1", "test_9"],
    [0.9999999, "1", "test_10"],
    [1.23456e-7, "1.23456e-7", "test_11"],
    [1.23456e7, "1.23456e7", "test_12"],
    [42, "42", "test_13"],
    [1000000, "1e6", "test_14"],
  ];

  test.each(testCases)("formats %p to %p (%s)", (number, expected, testId) => {
    const result = formatNumber(number);
    expect(result).toBe(expected);
  });
});
