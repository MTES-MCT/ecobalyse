// Note: this file MUST be required BEFORE requiring express.
const Sentry = require("@sentry/node");
const { nodeProfilingIntegration } = require("@sentry/profiling-node");

const { SENTRY_DSN, IS_REVIEW_APP, NODE_ENV } = process.env;

const enabled = SENTRY_DSN && NODE_ENV === "production";

if (enabled) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [nodeProfilingIntegration()],
    tracesSampleRate: 0.1,
    profilesSampleRate: 0.1,
    // IS_REVIEW_APP is set by `scalingo.json` only on review apps
    // See: https://developers.scalingo.com/scalingo-json-schema/
    environment: IS_REVIEW_APP ? "review-app" : NODE_ENV,
  });
  Sentry.setTag("subsystem", "express-server");
}

function setupSentry(app) {
  if (enabled) {
    Sentry.setupExpressErrorHandler(app);
    console.info("📊 Sentry monitoring enabled");
  }
}

module.exports = {
  setupSentry,
};
