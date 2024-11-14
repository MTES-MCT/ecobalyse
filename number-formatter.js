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
  const useScientific = exponent >= precision || exponent < -4;

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

module.exports = formatNumber;
