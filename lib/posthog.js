const { PostHog } = require("posthog-node");
const { extractTokenFromHeaders } = require("./http");
const { sha1 } = require("./crypto");

/**
 * Create a Posthog event payload for an API request
 */
function createEvent(statusCode, { headers, method, url }, scalingoAppName = null) {
  const token = extractTokenFromHeaders(headers);
  const distinctId = token ? sha1(token) : "anonymous";
  const properties = {
    $current_url: buildFullUrl(url, scalingoAppName),
    path: url,
    method,
    scalingoAppName,
    statusCode,
  };
  ["food", "object", "textile", "veli"].forEach((scope) => {
    if (url.startsWith(`/${scope}`)) {
      properties.scope = scope;
    }
  });
  return {
    event: "api_request",
    distinctId,
    properties,
  };
}

/**
 * Build a fully qualified API url if the scalingo app is identified, otherwise return just the path
 */
function buildFullUrl(path, scalingoAppName) {
  if (scalingoAppName === "ecobalyse") {
    return `https://ecobalyse.beta.gouv.fr/api${path}`;
  } else if (scalingoAppName === "ecobalyse-staging") {
    return `https://staging-ecobalyse.incubateur.net/api${path}`;
  } else {
    return `/api${path}`;
  }
}

/**
 * A wrapper around the PostHog client for tracking public API calls, enabled only in production.
 * It must NOT be used for frontend event tracking.
 */
function createPosthogTracker(env) {
  const {
    // Current scalingo app name is stored in the APP env var
    APP,
    // Force posting events (eg. for debugging locally)
    FORCE_POSTHOG = false,
    // Current node env
    NODE_ENV,
    // Posthog API key
    POSTHOG_KEY,
    // Posthog host
    POSTHOG_HOST,
  } = env;

  const enabled = (NODE_ENV === "production" || FORCE_POSTHOG) && POSTHOG_KEY && POSTHOG_HOST;

  if (enabled) {
    console.info("📊 Posthog tracking enabled", POSTHOG_HOST, FORCE_POSTHOG ? "(forced)" : "");
    const posthog = new PostHog(POSTHOG_KEY, { host: POSTHOG_HOST });

    return {
      captureEvent: (statusCode, request) => {
        const event = createEvent(statusCode, request, APP);
        posthog.capture(event);
      },
      shutdown: async () => {
        try {
          await posthog.shutdown();
        } catch (err) {
          console.error("⚠️ error shutting down Posthog", err.message);
        }
      },
    };
  } else {
    return {
      captureEvent: (statusCode, request) => {
        const event = createEvent(statusCode, request, APP);
        if (NODE_ENV === "development") {
          console.debug("fake posthog capture", event);
        }
      },
      shutdown: async () => {
        if (NODE_ENV === "development") {
          console.debug("fake posthog shutdown");
        }
      },
    };
  }
}

module.exports = {
  createEvent,
  createPosthogTracker,
};
