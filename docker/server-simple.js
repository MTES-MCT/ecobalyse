require("dotenv").config({ quiet: true });

const fs = require("fs");
const bodyParser = require("body-parser");
const bodyParserErrorHandler = require("express-body-parser-error-handler");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const jsonUtils = require("./lib/json");
const { dataFiles } = require("./lib");
const { createCSPDirectives } = require("./lib/http");
// monitoring
const express = require("express");

const expressHost = "0.0.0.0";
const expressPort = 8001;

// Env vars
const { ENABLE_FOOD_SECTION, NODE_ENV } = process.env;

const app = express(); // web app
const api = express(); // api app

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
  require("./package.json").version,
);

// Processes
const processes = fs.readFileSync(dataFiles.noDetails, "utf8");

const getProcesses = async (headers, customProcessesImpacts, customProcesses) => {
  // Always return non detailed impacts for now
  // We need to figure a way to use the detailed impacts in the docker first
  return customProcesses ?? processes;
};

function processOpenApi(contents, versionNumber) {
  // Add app version info to openapi docs
  contents.version = versionNumber;
  // Remove food api docs if disabled from env
  if (ENABLE_FOOD_SECTION !== "True") {
    contents.paths = Object.fromEntries(
      Object.entries(contents.paths).filter(([path, _]) => !path.startsWith("/food")),
    );
  }
  return contents;
}

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
    url: req.url,
    body: req.body,
    processes,
    jsResponseHandler: async ({ status, body }) => {
      respondWithFormattedJSON(res, status, body);
    },
  });
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);

const server = app.listen(expressPort, expressHost, () => {
  console.log(`Server listening at http://${expressHost}:${expressPort} (NODE_ENV=${NODE_ENV})`);
});

async function handleExit(signal) {
  // Since the Node client batches events to PostHog, the shutdown function
  // ensures that all the events are captured before shutting down
  console.log(`Received ${signal}. Flushing…`);
  console.log("Flush complete");
  server.close(() => process.exit(0));
}

process.on("SIGINT", handleExit);
process.on("SIGQUIT", handleExit);
process.on("SIGTERM", handleExit);

module.exports = server;
