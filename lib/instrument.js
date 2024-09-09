const Sentry = require("@sentry/node");
const { nodeProfilingIntegration } = require("@sentry/profiling-node");

const { SENTRY_DSN } = process.env;

if (SENTRY_DSN) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [nodeProfilingIntegration()],
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
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
