function createCSPDirectives(env) {
  const { MATOMO_HOST = "", POSTHOG_HOST = "" } = env;
  const FULL_MATOMO_HOST = `https://${MATOMO_HOST}`;
  const POSTHOG_ASSETS_HOST = POSTHOG_HOST ? "https://eu-assets.i.posthog.com" : "";

  const onlyValid = (list) => list.filter((x) => x && !x.endsWith("://"));

  return {
    "default-src": [
      "'self'",
      "https://api.github.com",
      "https://raw.githubusercontent.com",
      "https://sentry.incubateur.net",
      FULL_MATOMO_HOST,
      POSTHOG_ASSETS_HOST,
    ],
    "img-src": [
      "'self'",
      "data:",
      "blob:",
      "https://avatars.githubusercontent.com",
      "https://raw.githubusercontent.com",
    ],
    "object-src": ["blob:"],
    // tracker hosts dependent directives
    "connect-src": onlyValid([
      "'self'",
      "https://api.github.com",
      "https://raw.githubusercontent.com",
      FULL_MATOMO_HOST,
      POSTHOG_HOST,
      POSTHOG_ASSETS_HOST,
    ]),
    "frame-src": onlyValid(["'self'", FULL_MATOMO_HOST]),
    // FIXME: We should be able to remove 'unsafe-inline' as soon as the Matomo
    // server sends the appropriate `Access-Control-Allow-Origin` header
    // or that we eventually switch to using Posthog only
    // @see https://matomo.org/faq/how-to/faq_18694/
    "script-src": onlyValid([
      "'self'",
      "'unsafe-inline'",
      FULL_MATOMO_HOST,
      POSTHOG_HOST,
      POSTHOG_ASSETS_HOST,
    ]),
    "worker-src": onlyValid(["'self'", POSTHOG_HOST, POSTHOG_ASSETS_HOST]),
  };
}

function extractTokenFromHeaders(headers) {
  // Handle both old and new auth token headers
  const bearerToken = headers["authorization"]?.split("Bearer ")[1]?.trim();
  const classicToken = headers["token"]; // from old auth system
  return (bearerToken ?? classicToken) || null;
}

module.exports = {
  createCSPDirectives,
  extractTokenFromHeaders,
};
