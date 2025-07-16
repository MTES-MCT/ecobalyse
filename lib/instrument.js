const Sentry = require("@sentry/node");
const { nodeProfilingIntegration } = require("@sentry/profiling-node");

const { SENTRY_DSN, IS_REVIEW_APP, NODE_ENV } = process.env;

function setupSentry(app) {
  if (SENTRY_DSN && NODE_ENV === "production") {
    Sentry.init({
      dsn: SENTRY_DSN,
      integrations: [nodeProfilingIntegration()],
      tracesSampleRate: 0.1,
      profilesSampleRate: 0.1,
      // IS_REVIEW_APP is set by `scalingo.json` only on review apps
      environment: IS_REVIEW_APP ? "review-app" : NODE_ENV,
    });
    Sentry.setupExpressErrorHandler(app);
  }
}

module.exports = {
  setupSentry,
};
