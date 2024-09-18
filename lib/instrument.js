const Sentry = require("@sentry/node");
const { nodeProfilingIntegration } = require("@sentry/profiling-node");

const { SENTRY_DSN, IS_REVIEW_APP, NODE_ENV } = process.env;

const shouldInitSentry = SENTRY_DSN && NODE_ENV === "production";

if (shouldInitSentry) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [nodeProfilingIntegration()],
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
    // IS_REVIEW_APP is set by `scalingo.json` only on review apps
    environment: IS_REVIEW_APP ? "review-app" : NODE_ENV,
  });
}

function monitorExpressApp(app) {
  if (shouldInitSentry) {
    Sentry.setupExpressErrorHandler(app);
  }
}

module.exports = {
  monitorExpressApp,
};
