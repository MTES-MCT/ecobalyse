function createCSPDirectives(env) {
  const { MATOMO_HOST, POSTHOG_HOST } = env;

  const onlyValid = (list) => list.filter((x) => x && !String(x).endsWith("://"));

  return {
    "default-src": [
      "'self'",
      "https://api.github.com",
      "https://raw.githubusercontent.com",
      "https://sentry.incubateur.net",
      "*.gouv.fr",
    ],
    "img-src": [
      "'self'",
      "data:",
      "blob:",
      "https://avatars.githubusercontent.com/",
      "https://raw.githubusercontent.com",
    ],
    "object-src": ["blob:"],
    // tracker hosts dependent directives
    "connect-src": onlyValid(["'self'", POSTHOG_HOST]),
    "frame-src": onlyValid(["'self'", `https://${MATOMO_HOST}`]),
    // FIXME: We should be able to remove 'unsafe-inline' as soon as the Matomo
    // server sends the appropriate `Access-Control-Allow-Origin` header
    // or that we eventually switch to using Posthog only
    // @see https://matomo.org/faq/how-to/faq_18694/
    "script-src": onlyValid(["'self'", "'unsafe-inline'", `https://${MATOMO_HOST}`, POSTHOG_HOST]),
    "worker-src": onlyValid(["'self'", POSTHOG_HOST]),
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
