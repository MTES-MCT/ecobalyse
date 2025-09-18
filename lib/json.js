function formatNumber(num, precision = 6) {
  if (typeof num !== "number") {
    return String(num);
  } else if (isNaN(num)) {
    return `null`;
  } else if (num === 0) {
    return "0";
  }

  const absNum = Math.abs(num);
  // Python general format uses scientific notation if exponent >= precision or <= -4
  const exponent = Math.floor(Math.log10(absNum));
  const useScientific = exponent >= precision || exponent < -4;

  if (useScientific) {
    // Use scientific notation
    return num
      .toExponential(precision - 1)
      .replace(/\.?0+e/, "e") // Remove trailing zeros before 'e'
      .replace(/\.$/, "") // Remove trailing decimal point
      .replace(/e\+?/, "e") // Remove '+' sign and leading zeros in positive exponent
      .replace(/e-0?/, "e-"); // Remove leading zeros in negative exponent
  } else {
    // Use fixed notation
    // Calculate decimal places needed based on exponent and precision
    const decimalPlaces = Math.max(0, precision - exponent - 1);
    const numStr = num.toFixed(decimalPlaces);
    return numStr.includes(".")
      ? numStr
          .replace(/\.?0+$/, "") // Remove trailing zeros
          .replace(/\.$/, "") // Remove trailing decimal point
      : numStr;
  }
}

/**
 * Encodes a JavaScript data structure to JSON, reformatting all numbers encountered
 * along the way in a consistent, predictable fashion.
 * @param {*} data
 * @returns String
 */
function serialize(data, indent = 2) {
  const token = ":|--|:";
  return JSON.stringify(
    data,
    (_, value) => {
      if (typeof value === "number") {
        return token + formatNumber(value) + token;
      } else {
        return value;
      }
    },
    indent,
  )
    .replaceAll(`"${token}`, "")
    .replaceAll(`${token}"`, "");
}

module.exports = {
  formatNumber,
  serialize,
};
