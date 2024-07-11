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

const app = express(); // web app
const api = express(); // api app
const expressHost = "0.0.0.0";
const expressPort = 8001;
const djangoHost = "127.0.0.1";
const djangoPort = 8002;

// Env vars
const { SENTRY_DSN, MATOMO_HOST, MATOMO_SITE_ID, MATOMO_TOKEN } = process.env;

// Matomo
if (process.env.NODE_ENV !== "test" && (!MATOMO_HOST || !MATOMO_SITE_ID || !MATOMO_TOKEN)) {
  console.error("Matomo environment variables are missing. Please check the README.");
  process.exit(1);
}

if (process.env.NODE_ENV === "test") {
  if (!process.env.ECOBALYSE_PRIVATE) {
    console.error(
      "\n🚨 ERROR: For the tests to work properly, you need to specify the ECOBALYSE_PRIVATE env variable. It needs to point to the https://github.com/MTES-MCT/ecobalyse-private/ repository. Please, edit your .env file accordingly.",
    );
    console.error("-> Exiting the test process.\n");
    process.exit(1);
  }
  const TEXTILE_PROCESSES_IMPACTS_PATH =
    process.env.ECOBALYSE_PRIVATE + "data/textile/processes_impacts.json";
  const FOOD_PROCESSES_IMPACTS_PATH =
    process.env.ECOBALYSE_PRIVATE + "data/food/processes_impacts.json";
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

// Detailed processes files

let textileImpactsFile =
  TEXTILE_PROCESSES_IMPACTS_PATH || "public/data/textile/processes_impacts.json";
let foodImpactsFile = FOOD_PROCESSES_IMPACTS_PATH || "public/data/food/processes_impacts.json";
const textileFile = "public/data/textile/processes.json";
const foodFile = "public/data/food/processes.json";

// If detailed impacts files doesn't exist,
// we should default to the non detailed files
if (!fs.existsSync(textileImpactsFile)) {
  textileImpactsFile = textileFile;
}

if (!fs.existsSync(foodImpactsFile)) {
  foodImpactsFile = foodFile;
}

const processesImpacts = {
  foodProcesses: fs.readFileSync(foodImpactsFile, "utf8"),
  textileProcesses: fs.readFileSync(textileImpactsFile, "utf8"),
};

const processes = {
  foodProcesses: fs.readFileSync(foodFile, "utf8"),
  textileProcesses: fs.readFileSync(textileFile, "utf8"),
};

const getProcesses = async (token) => {
  let isTokenValid = false;
  if (token) {
    const checkTokenUrl = `http://${djangoHost}:${djangoPort}/internal/check_token`;
    const tokenRes = await fetch(checkTokenUrl, { headers: { token } });
    isTokenValid = tokenRes.status == 200;
  }

  if (isTokenValid || process.env.NODE_ENV === "test") {
    return processesImpacts;
  } else {
    return processes;
  }
};

app.get("/processes/processes.json", async (req, res) => {
  return res.status(200).send(await getProcesses(req.headers.token));
});

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

// Note: Text/JSON request body parser (JSON is decoded in Elm)
api.all(/(.*)/, bodyParser.json(), async (req, res) => {
  const processes = await getProcesses(req.headers.token);

  elmApp.ports.input.send({
    method: req.method,
    url: req.url,
    body: req.body,
    processes,
    jsResponseHandler: ({ status, body }) => {
      apiTracker.track(status, req);
      res.status(status).send(body);
    },
  });
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);

// Sentry error handler
// Note: *must* be called *before* any other error handler
if (SENTRY_DSN) {
  app.use(Sentry.Handlers.errorHandler());
}

const server = app.listen(expressPort, expressHost, () => {
  console.log(`Server listening at http://${expressHost}:${expressPort}`);
});

module.exports = server;
