require("dotenv").config({ quiet: true });

const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");
const bodyParserErrorHandler = require("express-body-parser-error-handler");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const jsonUtils = require("./lib/json");
const { dataFiles } = require("./lib");
const { decrypt } = require("./lib/crypto");
const rateLimit = require("express-rate-limit");
const { createCSPDirectives, extractTokenFromHeaders } = require("./lib/http");
// monitoring
const { setupSentry } = require("./lib/sentry"); // MUST be required BEFORE express
const { createMatomoTracker } = require("./lib/matomo");
const { createPlausibleTracker } = require("./lib/plausible");
const express = require("express");

const expressHost = "0.0.0.0";
const expressPort = 8001;

// Env vars
const { ENABLE_FOOD_SECTION, NODE_ENV, RATELIMIT_MAX_RPM, RATELIMIT_WHITELIST } = process.env;

const INTERNAL_BACKEND_URL = "http://localhost:8002";

const app = express(); // web app
const api = express(); // api app

// Rate-limiting
const rateLimitWhitelist = RATELIMIT_WHITELIST?.split(",").filter(Boolean) ?? [];
const rateLimitMaxRPM = parseInt(RATELIMIT_MAX_RPM, 10) || 5000;
// Make rate-limiting working with X-Forwarded-For headers
app.set("trust proxy", 1);
app.use(
  rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: rateLimitMaxRPM,
    message: { error: `This server is rate-limited to ${rateLimitMaxRPM}rpm, please slow down.` },
    skip: ({ ip }) => NODE_ENV !== "production" || rateLimitWhitelist.includes(ip),
  }),
);

// Sentry monitoring
setupSentry(app);

// Plausible API tracker
const plausibleTracker = createPlausibleTracker(process.env);

// Matomo
const matomoTracker = createMatomoTracker(process.env);

// Middleware
const jsonErrorHandler = bodyParserErrorHandler({
  onError: (err, req, res, next) => {
    res.status(400).send({
      error: { decoding: `Format JSON invalide : ${err.message}` },
      documentation: "https://ecobalyse.beta.gouv.fr/#/api",
    });
  },
});

// Web

// Note: helmet middlewares have to be called *after* the Sentry middleware
// but *before* other middlewares to be applied effectively
app.use(
  helmet({
    crossOriginEmbedderPolicy: false,
    hsts: false,
    xssFilter: false,
    contentSecurityPolicy: {
      useDefaults: true,
      directives: createCSPDirectives(process.env),
    },
  }),
);

app.use(
  express.static("dist", {
    setHeaders: (res) => {
      // Note: helmet sets this header to `0` by default and doesn't allow overriding
      // this value
      res.set("X-XSS-Protection", "1; mode=block");
    },
  }),
);

// Redirects: Web
app.get("/accessibilite", (_, res) => res.redirect("/#/pages/accessibilité"));
app.get("/mentions-legales", (_, res) => res.redirect("/#/pages/mentions-légales"));
app.get("/stats", (_, res) => res.redirect("/#/stats"));

// API
const openApiContents = processOpenApi(
  yaml.load(fs.readFileSync("openapi.yaml")),
  // @FIXME: we should have the correct version number specified in the package.json file
  require("./package.json").version,
);

function processOpenApi(contents, versionNumber) {
  // Add app version info to openapi docs
  contents.version = versionNumber;
  return contents;
}
// Processes
const processesImpacts = fs.readFileSync(dataFiles.detailed, "utf8");
const processes = fs.readFileSync(dataFiles.noDetails, "utf8");

const getProcesses = async (headers, customProcessesImpacts, customProcesses) => {
  let isValidToken = false;
  const token = extractTokenFromHeaders(headers);

  if (token) {
    try {
      const tokenRes = await fetch(`${INTERNAL_BACKEND_URL}/api/tokens/validate`, {
        method: "POST",
        body: JSON.stringify({ token }),
      });
      isValidToken = tokenRes.status == 201;
    } catch (error) {
      console.error("Error validating token from the auth backend", error);
      isValidToken = false;
    }
  }

  if (NODE_ENV === "test" || isValidToken) {
    return customProcessesImpacts ?? processesImpacts;
  } else {
    return customProcesses ?? processes;
  }
};

app.get("/processes/processes.json", async (req, res) => {
  // Note: JSON parsing is done in Elm land
  return res
    .status(200)
    .contentType("text/plain")
    .send(JSON.stringify(await getProcesses(req.headers)));
});

const elmApp = Elm.Server.init();

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
});

api.get("/", async (req, res) => {
  matomoTracker.track(200, req);
  await plausibleTracker.captureEvent(200, req);
  res.status(200).send(openApiContents);
});

// Redirects: API
api.get(/^\/countries$/, (_, res) => res.redirect("textile/countries"));
api.get(/^\/materials$/, (_, res) => res.redirect("textile/materials"));
api.get(/^\/products$/, (_, res) => res.redirect("textile/products"));
const cleanRedirect = (url) => (url.startsWith("/") ? url : "");
api.get(/^\/simulator(.*)$/, ({ url }, res) => res.redirect(`/api/textile${cleanRedirect(url)}`));

const respondWithFormattedJSON = (res, status, body) => {
  res.status(status);
  res.setHeader("Content-Type", "application/json");
  res.send(jsonUtils.serialize(body));
};

// Note: Text/JSON request body parser (JSON is decoded in Elm)
api.all(/(.*)/, bodyParser.json(), jsonErrorHandler, async (req, res) => {
  const processes = await getProcesses(req.headers);

  elmApp.ports.input.send({
    method: req.method,
    protocol: req.protocol,
    host: req.get("host"),
    url: req.url,
    version: null, // note: no way to infer a version number from the request containing none
    body: req.body,
    processes,
    jsResponseHandler: async ({ status, body }) => {
      matomoTracker.track(status, req);
      await plausibleTracker.captureEvent(status, req);
      respondWithFormattedJSON(res, status, body);
    },
  });
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);

const server = app.listen(expressPort, expressHost, () => {
  console.log(`Server listening at http://${expressHost}:${expressPort} (NODE_ENV=${NODE_ENV})`);
});

module.exports = server;
