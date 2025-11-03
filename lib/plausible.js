const { extractTokenFromHeaders } = require("./http");
const { createAnonHash } = require("./crypto");

/**
 * Create a Plausible event payload for an API request
 */
function createEvent(statusCode, { headers, method, url }, scalingoAppName = null) {
  const token = extractTokenFromHeaders(headers);
  const anonHash = token ? createAnonHash(token) : null;
  const props = {
    authenticated: !!anonHash,
    anonHash,
    method,
    scalingoAppName,
    statusCode,
    subsystem: "public-api",
  };
  ["food", "object", "textile", "veli"].forEach((scope) => {
    if (url.startsWith(`/${scope}`)) {
      props.scope = scope;
    }
  });
  return {
    name: "pageview",
    domain: scalingoAppName === "ecobalyse" ? "ecobalyse.beta.gouv.fr" : "ecobalyse.test",
    url,
    props,
  };
}

/**
 * A simple Plausible client for tracking public API calls, enabled only in production.
 * It must NOT be used for frontend event tracking.
 */
function createPlausibleTracker(env) {
  const {
    // Current scalingo app name is stored in the APP env var
    APP,
    // Force posting events (eg. for debugging locally)
    FORCE_PLAUSIBLE = false,
    // Current node env
    NODE_ENV,
    // Plausible host
    PLAUSIBLE_HOST = "",
  } = env;

  const enabled = PLAUSIBLE_HOST && (NODE_ENV === "production" || FORCE_PLAUSIBLE);

  if (enabled) {
    console.info(
      "📊 Plausible tracking enabled",
      PLAUSIBLE_HOST,
      FORCE_PLAUSIBLE ? "(forced)" : "",
    );
  }

  return {
    captureEvent: async (statusCode, request) => {
      const headers = {
        "Content-Type": "application/json",
        "User-Agent": request.headers["user-agent"],
        "X-Forwarded-For": request.ip,
      };
      const event = createEvent(statusCode, request, APP);
      if (enabled) {
        try {
          await fetch(`https://${PLAUSIBLE_HOST}/api/event`, {
            method: "POST",
            headers,
            body: JSON.stringify(event),
          });
        } catch (e) {
          console.warn("plausible communication error", e);
        }
      }
      if (NODE_ENV === "development") {
        console.debug("plausible event", headers, event);
      }
    },
  };
}

module.exports = {
  createEvent,
  createPlausibleTracker,
};
