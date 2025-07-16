function extractTokenFromHeaders(headers) {
  // Handle both old and new auth token headers
  const bearerToken = headers["authorization"]?.split("Bearer ")[1]?.trim();
  const classicToken = headers["token"]; // from old auth system
  return bearerToken ?? classicToken;
}

module.exports = {
  extractTokenFromHeaders,
};
