require("dotenv").config();
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
const express = require("express");
const rateLimit = require("express-rate-limit");
// monitoring
const { setupSentry } = require("./lib/sentry");
const { createMatomoTracker } = require("./lib/matomo");
const { createPosthogTracker } = require("./lib/posthog");

const expressHost = "0.0.0.0";
const expressPort = 8001;

// Env vars
const {
  ENABLE_FOOD_SECTION,
  MATOMO_HOST,
  NODE_ENV,
  POSTHOG_HOST,
  RATELIMIT_MAX_RPM,
  RATELIMIT_WHITELIST,
} = process.env;

const INTERNAL_BACKEND_URL = "http://localhost:8002";

const app = express(); // web app
const api = express(); // api app
const version = express(); // version app

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

// Posthog API tracker
const posthogTracker = createPosthogTracker();

// Matomo
const matomoTracker = createMatomoTracker();

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
function createCSPDirectives() {
  return {
    "default-src": [
      "'self'",
      "https://api.github.com",
      "https://raw.githubusercontent.com",
      "https://sentry.incubateur.net",
      "*.gouv.fr",
    ],
    "frame-src": ["'self'", `https://${MATOMO_HOST}`],
    "img-src": [
      "'self'",
      "data:",
      "blob:",
      "https://avatars.githubusercontent.com/",
      "https://raw.githubusercontent.com",
    ],
    "connect-src": ["'self'", POSTHOG_HOST],
    "object-src": ["blob:"],
    // FIXME: We should be able to remove 'unsafe-inline' as soon as the Matomo
    // server sends the appropriate `Access-Control-Allow-Origin` header
    // @see https://matomo.org/faq/how-to/faq_18694/
    "script-src": ["'self'", "'unsafe-inline'", `https://${MATOMO_HOST}`, POSTHOG_HOST],
    "worker-src": ["'self'", POSTHOG_HOST],
  };
}
// Note: helmet middlewares have to be called *after* the Sentry middleware
// but *before* other middlewares to be applied effectively
app.use(
  helmet({
    crossOriginEmbedderPolicy: false,
    hsts: false,
    xssFilter: false,
    contentSecurityPolicy: {
      useDefaults: true,
      directives: createCSPDirectives(),
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

// Versions
const versionsDir = "./versions";
let availableVersions = [];

// Loading existing versions in memory
if (fs.existsSync(versionsDir)) {
  const dirs = fs.readdirSync(versionsDir);
  for (const dir of dirs) {
    const currentVersionDir = path.join(versionsDir, dir);

    // check for mono or multiple processes files
    if (fs.existsSync(path.join(currentVersionDir, "data/processes.json"))) {
      // Single process file
      const processes = fs.readFileSync(
        path.join(currentVersionDir, "data/processes.json"),
        "utf8",
      );
      const processesImpactsEnc = path.join(currentVersionDir, "processes_impacts.json.enc");

      availableVersions.push({
        dir,
        processes,
        processesImpacts: decrypt(
          JSON.parse(fs.readFileSync(processesImpactsEnc).toString("utf-8")),
        ),
      });
    } else {
      // Multiple process files
      const foodNoDetails = path.join(currentVersionDir, "data/food/processes.json");
      const objectNoDetails = path.join(currentVersionDir, "data/object/processes.json");
      const textileNoDetails = path.join(currentVersionDir, "data/textile/processes.json");

      const foodDetailedEnc = path.join(currentVersionDir, "processes_impacts_food.json.enc");
      const objectDetailedEnc = path.join(currentVersionDir, "processes_impacts_object.json.enc");
      const textileDetailedEnc = path.join(currentVersionDir, "processes_impacts_textile.json.enc");

      // We should not check for the existence of objectNoDetails because old versions don't have it
      // and it's expected
      if (!fs.existsSync(foodNoDetails) || !fs.existsSync(textileNoDetails)) {
        console.error(
          `🚨 ERROR: processes files without details missing for version ${dir}. Skipping version.`,
        );
        continue;
      }

      // Encrypted files exist, use them
      let processesImpacts = {
        foodProcesses: decrypt(JSON.parse(fs.readFileSync(foodDetailedEnc).toString("utf-8"))),
        // Old versions don't have the object files
        objectProcesses: fs.existsSync(objectDetailedEnc)
          ? decrypt(JSON.parse(fs.readFileSync(objectDetailedEnc).toString("utf-8")))
          : null,
        textileProcesses: decrypt(
          JSON.parse(fs.readFileSync(textileDetailedEnc).toString("utf-8")),
        ),
      };

      availableVersions.push({
        dir,
        processes: {
          foodProcesses: fs.readFileSync(foodNoDetails, "utf8"),
          // Old versions don't have the object files
          objectProcesses: fs.existsSync(objectNoDetails)
            ? fs.readFileSync(objectNoDetails, "utf8")
            : null,

          textileProcesses: fs.readFileSync(textileNoDetails, "utf8"),
        },
        processesImpacts,
      });
    }
  }
}

// API

const openApiContents = processOpenApi(
  yaml.load(fs.readFileSync("openapi.yaml")),
  require("./package.json").version,
);

// Processes
const processesImpacts = fs.readFileSync(dataFiles.detailed, "utf8");
const processes = fs.readFileSync(dataFiles.noDetails, "utf8");

function extractTokenFromHeaders(headers) {
  // Handle both old and new auth token headers
  const bearerToken = headers["authorization"]?.split("Bearer ")[1]?.trim();
  const classicToken = headers["token"]; // from old auth system
  return bearerToken ?? classicToken;
}

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

api.get("/", (req, res) => {
  matomoTracker.track(200, req);
  posthogTracker.captureEvent(200, req);
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
    jsResponseHandler: ({ status, body }) => {
      matomoTracker.track(status, req);
      posthogTracker.captureEvent(status, req);
      respondWithFormattedJSON(res, status, body);
    },
  });
});

// Middleware to check version number and file path
const checkVersionAndPath = (req, res, next) => {
  const versionNumber = req.params.versionNumber;

  const version = availableVersions.find((version) => version.dir === versionNumber);

  if (!version) {
    // If no version is found, don’t display a blank page but redirect to the home
    res.redirect("/");
  }
  const staticDir = path.join(__dirname, "versions", versionNumber);
  req.staticDir = staticDir;
  next();
};

version.use("/:versionNumber", checkVersionAndPath, (req, res, next) => {
  express.static(req.staticDir)(req, res, next);
});

version.get("/:versionNumber/api", checkVersionAndPath, (req, res) => {
  const openApiContents = processOpenApi(
    yaml.load(fs.readFileSync(path.join(req.staticDir, "openapi.yaml"))),
    req.params.versionNumber,
  );
  res.status(200).send(openApiContents);
});

version.all(
  "/:versionNumber/api/*all",
  checkVersionAndPath,
  bodyParser.json(),
  jsonErrorHandler,
  async (req, res) => {
    const versionNumber = req.params.versionNumber;
    const { processesImpacts, processes } = availableVersions.find(
      (version) => version.dir === versionNumber,
    );
    const versionProcesses = await getProcesses(req.headers, processesImpacts, processes);

    const { Elm } = require(path.join(req.staticDir, "server-app"));

    const elmApp = Elm.Server.init();

    elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
      return jsResponseHandler({ status, body });
    });

    const urlWithoutPrefix = req.url.replace(/\/[^/]+\/api/, "");

    matomoTracker.track(res.statusCode, req);
    posthogTracker.captureEvent(res.statusCode, req);

    elmApp.ports.input.send({
      method: req.method,
      url: urlWithoutPrefix,
      body: req.body,
      processes: versionProcesses,
      jsResponseHandler: ({ status, body }) => {
        respondWithFormattedJSON(res, status, body);
      },
    });
  },
);

version.get("/:versionNumber/processes/processes.json", checkVersionAndPath, async (req, res) => {
  const versionNumber = req.params.versionNumber;
  const { processesImpacts, processes } = availableVersions.find(
    (version) => version.dir === versionNumber,
  );

  // Note: JSON parsing is done in Elm land
  return res
    .status(200)
    .contentType("text/plain")
    .send(JSON.stringify(await getProcesses(req.headers, processesImpacts, processes)));
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);
app.use("/versions", version);

const server = app.listen(expressPort, expressHost, () => {
  console.log(`Server listening at http://${expressHost}:${expressPort}`);
});

async function handleExit(signal) {
  // Since the Node client batches events to PostHog, the shutdown function
  // ensures that all the events are captured before shutting down
  console.log(`Received ${signal}. Flushing…`);
  await posthogTracker.shutdown();
  console.log("Flush complete");
  server.close(() => process.exit(0));
}

process.on("SIGINT", handleExit);
process.on("SIGQUIT", handleExit);
process.on("SIGTERM", handleExit);

module.exports = server;
