const { PostHog } = require("posthog-node");
const { extractTokenFromHeaders } = require("./http");
const { sha1 } = require("./crypto");

function createEvent(statusCode, { headers, method, url }) {
  const event = { statusCode, method, url };
  const token = extractTokenFromHeaders(headers);
  if (token) {
    event.distinctId = sha1(token);
    event.properties = {
      $set_once: { firstRouteCalled: url },
    };
  }
  ["food", "textile", "object", "travel", "other"].forEach((scope) => {
    if (url.startsWith(`/${scope}`)) {
      event.scope = scope;
    }
  });
  return event;
}

function createPosthogTracker(env) {
  const { NODE_ENV, POSTHOG_KEY, POSTHOG_HOST } = env;

  // Actual posthog tracker for production
  if (NODE_ENV === "production" && POSTHOG_KEY && POSTHOG_HOST) {
    const posthog = new PostHog(POSTHOG_KEY, { host: POSTHOG_HOST });

    return {
      captureEvent: (statusCode, request) => {
        const payload = createEvent(statusCode, request);
        posthog.capture("api_request", payload);
      },
      shutdown: async () => {
        await posthog.shutdown();
      },
    };
  } else {
    // Fake posthog tracker for local development and tests
    return {
      captureEvent: (statusCode, request) => {
        const payload = createEvent(statusCode, request);
        console.debug("fake posthog capture", "api_request", payload);
      },
      shutdown: async () => {
        console.debug("fake posthog shutdown");
      },
    };
  }
}

module.exports = {
  createEvent,
  createPosthogTracker,
};
