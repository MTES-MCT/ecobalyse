function createCSPDirectives(env) {
  const { POSTHOG_HOST = "", SENTRY_DSN = "" } = env;
  const POSTHOG_ASSETS_HOST = POSTHOG_HOST ? "https://eu-assets.i.posthog.com" : "";
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
      POSTHOG_ASSETS_HOST,
      SENTRY_HOST,
    ]),
    "img-src": onlyValid([SELF, DATA, BLOB, GITHUB_AVATARS_HOST, GITHUB_RAW_HOST]),
    "object-src": onlyValid([BLOB]),
    "connect-src": onlyValid([
      SELF,
      GITHUB_API_HOST,
      GITHUB_RAW_HOST,
      POSTHOG_HOST,
      POSTHOG_ASSETS_HOST,
      SENTRY_HOST,
    ]),
    "script-src": onlyValid([SELF, POSTHOG_HOST, POSTHOG_ASSETS_HOST]),
    "worker-src": onlyValid([SELF, POSTHOG_HOST, POSTHOG_ASSETS_HOST]),
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
