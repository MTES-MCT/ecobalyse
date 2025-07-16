const { PostHog } = require("posthog-node");
const { extractTokenFromHeaders } = require("./http");

const { NODE_ENV, POSTHOG_KEY, POSTHOG_HOST } = process.env;

function createPosthogTracker() {
  if (NODE_ENV === "production" && POSTHOG_KEY && POSTHOG_HOST) {
    const posthog = new PostHog(POSTHOG_KEY, { host: POSTHOG_HOST });
    return {
      captureEvent: async (statusCode, { headers, method, url }) => {
        const event = { statusCode, method, url };
        const token = extractTokenFromHeaders(headers);
        if (token) {
          event.distinctId = await sha1(token);
          event.properties = {
            $set_once: { firstRouteCalled: url },
          };
        }
        posthog.capture("api_request", event);
      },
      shutdown: async () => await posthog.shutdown(),
    };
  } else {
    return {
      captureEvent: async () => console.debug("fake posthog capture", req.method, req.url),
      shutdown: async () => console.debug("fake posthog shutdown"),
    };
  }
}

module.exports = {
  createPosthogTracker,
};
