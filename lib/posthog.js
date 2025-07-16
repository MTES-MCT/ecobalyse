const { PostHog } = require("posthog-node");

const { NODE_ENV, POSTHOG_KEY, POSTHOG_HOST } = process.env;

function createPosthogTracker() {
  if (NODE_ENV === "production" && POSTHOG_KEY && POSTHOG_HOST) {
    const posthog = new PostHog(POSTHOG_KEY, { host: POSTHOG_HOST });
    return {
      captureEvent: (statusCode, { headers, method, url }) =>
        posthog.capture("api_request", {
          statusCode,
          method,
          url,
          distinctId: extractTokenFromHeaders(headers),
          properties: {
            $set_once: { firstRouteCalled: url },
          },
        }),
      shutdown: async () => posthog.shutdown(),
    };
  } else {
    return {
      captureRequest: () => console.debug("fake posthog capture", req.method, req.url),
      shutdown: async () => console.debug("fake posthog shutdown"),
    };
  }
}

module.exports = {
  createPosthogTracker,
};
