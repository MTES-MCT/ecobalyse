function createCSPDirectives(env) {
  const { MATOMO_HOST = "", PLAUSIBLE_HOST = "", SENTRY_DSN = "" } = env;
  const FULL_MATOMO_HOST = `https://${MATOMO_HOST}`;
  const FULL_PLAUSIBLE_HOST = `https://${PLAUSIBLE_HOST}`;
  const SENTRY_HOST = extractSentryHost(SENTRY_DSN);
  const BLOB = "blob:";
  const DATA = "data:";
  const GITHUB_API_HOST = "https://api.github.com";
  const GITHUB_AVATARS_HOST = "https://avatars.githubusercontent.com";
  const GITHUB_RAW_HOST = "https://raw.githubusercontent.com";
  const SELF = "'self'";
  const UNSAFE_INLINE = "'unsafe-inline'";

  return {
    "default-src": onlyValid([
      SELF,
      GITHUB_API_HOST,
      GITHUB_RAW_HOST,
      FULL_MATOMO_HOST,
      FULL_PLAUSIBLE_HOST,
      SENTRY_HOST,
    ]),
    "img-src": onlyValid([SELF, DATA, BLOB, GITHUB_AVATARS_HOST, GITHUB_RAW_HOST]),
    "object-src": onlyValid([BLOB]),
    "connect-src": onlyValid([
      SELF,
      GITHUB_API_HOST,
      GITHUB_RAW_HOST,
      FULL_MATOMO_HOST,
      FULL_PLAUSIBLE_HOST,
      SENTRY_HOST,
    ]),
    "frame-src": onlyValid([SELF, FULL_MATOMO_HOST]),
    // FIXME: We should be able to remove UNSAFE_INLINE as soon as the Matomo
    // server sends the appropriate `Access-Control-Allow-Origin` header
    // OR we eventually switch to using Plausible only
    // @see https://matomo.org/faq/how-to/faq_18694/
    "script-src": onlyValid([SELF, UNSAFE_INLINE, FULL_MATOMO_HOST, FULL_PLAUSIBLE_HOST]),
    "worker-src": onlyValid([SELF, FULL_PLAUSIBLE_HOST]),
  };
}

function extractTokenFromHeaders(headers) {
  // Handle both old and new auth token headers
  const bearerToken = headers["authorization"]?.split("Bearer ")[1]?.trim();
  const classicToken = headers["token"]; // from old auth system
  return (bearerToken ?? classicToken) || null;
}

function extractSentryHost(sentryDsn) {
  try {
    const { hostname, protocol } = new URL(sentryDsn);
    return `${protocol}//${hostname}`;
  } catch (error) {
    return "";
  }
}

function onlyValid(list) {
  return list.filter((x) => x && !x.endsWith("://"));
}

module.exports = {
  createCSPDirectives,
  extractTokenFromHeaders,
};
