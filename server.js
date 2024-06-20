require("dotenv").config();
const fs = require("fs");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const Sentry = require("@sentry/node");
const { Elm } = require("./server-app");
const lib = require("./lib");
const memoize = require("fast-memoize");
const path = require("path");
const rateLimit = require("express-rate-limit");

const app = express(); // web app
const api = express(); // api app
const version = express(); // version app
const host = "0.0.0.0";
const express_port = 8001;
const django_port = 8002;
const max_memoize_age = 1000 * 60 * 24; // 24 hours memoization

// Env vars
const { SENTRY_DSN, MATOMO_HOST, MATOMO_SITE_ID, MATOMO_TOKEN } = process.env;

var rateLimiter = rateLimit({
  windowMs: 1000, // 1 second
  max: 100, // max 100 requests per second
});

// Matomo
if (process.env.NODE_ENV !== "test" && (!MATOMO_HOST || !MATOMO_SITE_ID || !MATOMO_TOKEN)) {
  console.error("Matomo environment variables are missing. Please check the README.");
  process.exit(1);
}

// Sentry
if (SENTRY_DSN) {
  Sentry.init({ dsn: SENTRY_DSN, tracesSampleRate: 0.1 });
  // Note: Sentry middleware *must* be the very first applied to be effective
  app.use(Sentry.Handlers.requestHandler());
}

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
      directives: {
        "default-src": [
          "'self'",
          "https://api.github.com",
          "https://raw.githubusercontent.com",
          "https://sentry.incubateur.net",
          "*.gouv.fr",
        ],
        "frame-src": ["'self'", `https://${process.env.MATOMO_HOST}`, "https://www.loom.com"],
        "img-src": [
          "'self'",
          "data:",
          "blob:",
          "https://avatars.githubusercontent.com/",
          "https://raw.githubusercontent.com",
        ],
        // FIXME: We should be able to remove 'unsafe-inline' as soon as the Matomo
        // server sends the appropriate `Access-Control-Allow-Origin` header
        // @see https://matomo.org/faq/how-to/faq_18694/
        "script-src": ["'self'", "'unsafe-inline'", `https://${process.env.MATOMO_HOST}`],
        "object-src": ["blob:"],
      },
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

const openApiContents = yaml.load(fs.readFileSync("openapi.yaml"));

// Matomo
const apiTracker = lib.setupTracker(openApiContents);

const elmApp = Elm.Server.init();

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
});

api.get("/", (req, res) => {
  apiTracker.track(200, req);
  res.status(200).send(openApiContents);
});

// Redirects: API
api.get(/^\/countries$/, (_, res) => res.redirect("textile/countries"));
api.get(/^\/materials$/, (_, res) => res.redirect("textile/materials"));
api.get(/^\/products$/, (_, res) => res.redirect("textile/products"));
const cleanRedirect = (url) => (url.startsWith("/") ? url : "");
api.get(/^\/simulator(.*)$/, ({ url }, res) => res.redirect(`/api/textile${cleanRedirect(url)}`));

const getProcesses = async (token) => {
  let headers = {};
  if (token) {
    headers["token"] = token;
  }

  const processesUrl = `http://127.0.0.1:${django_port}/processes/processes.json`;
  const processesRes = await fetch(processesUrl, { headers: headers });
  const processes = await processesRes.json();
  return { processes: processes, status: processesRes.status };
};

const memoizedGetProcesses = memoize(getProcesses, { maxAge: max_memoize_age });

// Note: Text/JSON request body parser (JSON is decoded in Elm)
api.all(/(.*)/, bodyParser.json(), async (req, res) => {
  let result;
  try {
    result = await memoizedGetProcesses(req.headers.token);
    if (result.status != 200) {
      return res.status(result.status).send(result.processes);
    }
  } catch (err) {
    console.error(err.message);
    return res.status(500).send("Error while retrieving the processes");
  }

  elmApp.ports.input.send({
    method: req.method,
    url: req.url,
    body: req.body,
    processes: result.processes,
    jsResponseHandler: ({ status, body }) => {
      apiTracker.track(status, req);
      res.status(status).send(body);
    },
  });
});

version.use("/:versionNumber", (req, res, next) => {
  const versionNumber = req.params.versionNumber;

  // Construct the directory path based on the versionNumber path segment
  const staticDir = path.join(__dirname, "versions", versionNumber);

  // Verify that the file path is under the static directory for security reasons
  filePath = fs.realpathSync(path.resolve(staticDir));
  if (!filePath.startsWith(staticDir)) {
    res.statusCode = 403;
    res.end();
    return;
  }

  if (fs.existsSync(staticDir)) {
    // Serve static files from the constructed directory
    express.static(staticDir)(req, res, next);
  } else {
    // If the directory doesn't exist, we should check if me can build it or retrieve it ?
  }
});

version.get("/:versionNumber/api", (req, res) => {
  const versionNumber = req.params.versionNumber;

  const staticDir = path.join(__dirname, "versions", versionNumber);

  // Verify that the file path is under the static directory for security reasons
  filePath = fs.realpathSync(path.resolve(staticDir));
  if (!filePath.startsWith(staticDir)) {
    res.statusCode = 403;
    res.end();
    return;
  }

  const openApiContents = yaml.load(fs.readFileSync(path.join(staticDir, "openapi.yaml")));
  res.status(200).send(openApiContents);
});

version.all("/:versionNumber/api/*", bodyParser.json(), async (req, res) => {
  const versionNumber = req.params.versionNumber;

  const staticDir = path.join(__dirname, "versions", versionNumber);

  // Verify that the file path is under the static directory for security reasons
  filePath = fs.realpathSync(path.resolve(staticDir));
  if (!filePath.startsWith(staticDir)) {
    res.statusCode = 403;
    res.end();
    return;
  }

  const foodProcesses = fs
    .readFileSync(path.join(staticDir, "data", "food", "processes_impacts.json"))
    .toString();
  const textileProcesses = fs
    .readFileSync(path.join(staticDir, "data", "textile", "processes_impacts.json"))
    .toString();

  const processes = {
    foodProcesses: foodProcesses,
    textileProcesses: textileProcesses,
  };

  const { Elm } = require(path.join(staticDir, "server-app"));

  const elmApp = Elm.Server.init();

  elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
    return jsResponseHandler({ status, body });
  });

  const urlWithoutPrefix = req.url.replace(/\/[^/]+\/api/, "");

  elmApp.ports.input.send({
    method: req.method,
    url: urlWithoutPrefix,
    body: req.body,
    processes: processes,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

version.use(rateLimiter);

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);
app.use("/versions", version);

// Sentry error handler
// Note: *must* be called *before* any other error handler
if (SENTRY_DSN) {
  app.use(Sentry.Handlers.errorHandler());
}

const server = app.listen(express_port, host, () => {
  console.log(`Server listening at http://${host}:${express_port}`);
});

module.exports = server;
