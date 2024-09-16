const Sentry = require("@sentry/node");
const { nodeProfilingIntegration } = require("@sentry/profiling-node");

const { SENTRY_DSN, IS_REVIEW_APP, NODE_ENV } = process.env;

if (SENTRY_DSN) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [nodeProfilingIntegration()],
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
    environment: IS_REVIEW_APP ? "review-app" : NODE_ENV || "development",
  });
}

function monitorExpressApp(app) {
  if (SENTRY_DSN) {
    Sentry.setupExpressErrorHandler(app);
  }
}

module.exports = {
  monitorExpressApp,
};
