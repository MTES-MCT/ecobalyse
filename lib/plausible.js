const { extractTokenFromHeaders } = require("./http");
const { sha1 } = require("./crypto");

/**
 * Create a Plausible event payload for an API request
 */
function createEvent(statusCode, { headers, method, url }, scalingoAppName = null) {
  const token = extractTokenFromHeaders(headers);
  const distinctId = token ? sha1(token) : null;
  const props = {
    authenticated: !!distinctId,
    distinctId,
    method,
    scalingoAppName,
    statusCode,
    subsystem: "api",
  };
  ["food", "object", "textile", "veli"].forEach((scope) => {
    if (url.startsWith(`/${scope}`)) {
      props.scope = scope;
    }
  });
  return {
    name: "pageview",
    domain: domainFromScalingoApp(scalingoAppName),
    url,
    props,
  };
}

function domainFromScalingoApp(path, scalingoAppName) {
  if (scalingoAppName === "ecobalyse") {
    return "ecobalyse.beta.gouv.fr";
  } else if (scalingoAppName === "ecobalyse-staging") {
    return "staging-ecobalyse.incubateur.net";
  } else if (scalingoAppName) {
    // most probably a review app
    return scalingoAppName;
  } else {
    return "localhost";
  }
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
      const event = createEvent(statusCode, request, APP);
      if (enabled) {
        fetch(`https://${PLAUSIBLE_HOST}/api/event`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(event),
        });
      }
      if (NODE_ENV === "development") {
        console.debug("plausible event", event);
      }
    },
  };
}

module.exports = {
  createEvent,
  createPlausibleTracker,
};
