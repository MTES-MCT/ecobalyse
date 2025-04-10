require("dotenv").config();
const { monitorExpressApp } = require("./lib/instrument");
const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const jsonUtils = require("./lib/json");
const { setupTracker, dataFiles } = require("./lib");
const { decrypt } = require("./lib/crypto");
const express = require("express");
const rateLimit = require("express-rate-limit");

const app = express(); // web app
const api = express(); // api app
const expressHost = "0.0.0.0";
const expressPort = 8001;
const djangoHost = "127.0.0.1";
const djangoPort = 8002;
const version = express(); // version app

// Env vars
const { ENABLE_FOOD_SECTION, MATOMO_HOST, MATOMO_SITE_ID, MATOMO_TOKEN, NODE_ENV } = process.env;

var rateLimiter = rateLimit({
  windowMs: 1000, // 1 second
  max: 100, // max 100 requests per second
});

// Rate limit the version API as it reads file from the disk
version.use(rateLimiter);

// Matomo
if (NODE_ENV !== "test" && (!MATOMO_HOST || !MATOMO_SITE_ID || !MATOMO_TOKEN)) {
  console.error("Matomo environment variables are missing. Please check the README.");
  process.exit(1);
}

// Sentry monitoring
monitorExpressApp(app);

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
          "https://ecobalyse*.osc-fr1.scalingo.io",
          "https://raw.githubusercontent.com",
          "https://sentry.incubateur.net",
          "*.gouv.fr",
        ],
        "frame-src": ["'self'", `https://${MATOMO_HOST}`, "https://www.loom.com"],
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
        "script-src": ["'self'", "'unsafe-inline'", `https://${MATOMO_HOST}`],
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

// Versions
const versionsDir = "./versions";
let availableVersions = [];

// Loading existing versions in memory
if (fs.existsSync(versionsDir)) {
  const dirs = fs.readdirSync(versionsDir);
  for (const dir of dirs) {
    const currentVersionDir = path.join(versionsDir, dir);

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
    let processesImpacts;

    // Encrypted files exist, use them
    processesImpacts = {
      foodProcesses: decrypt(JSON.parse(fs.readFileSync(foodDetailedEnc).toString("utf-8"))),
      // Old versions don't have the object files
      objectProcesses: fs.existsSync(objectDetailedEnc)
        ? decrypt(JSON.parse(fs.readFileSync(objectDetailedEnc).toString("utf-8")))
        : null,
      textileProcesses: decrypt(JSON.parse(fs.readFileSync(textileDetailedEnc).toString("utf-8"))),
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

// API

const openApiContents = processOpenApi(
  yaml.load(fs.readFileSync("openapi.yaml")),
  require("./package.json").version,
);

// Matomo
const apiTracker = setupTracker(openApiContents);

const processesImpacts = {
  foodProcesses: fs.readFileSync(dataFiles.foodDetailed, "utf8"),
  objectProcesses: fs.readFileSync(dataFiles.objectDetailed, "utf8"),
  textileProcesses: fs.readFileSync(dataFiles.textileDetailed, "utf8"),
};

const processes = {
  foodProcesses: fs.readFileSync(dataFiles.foodNoDetails, "utf8"),
  objectProcesses: fs.readFileSync(dataFiles.objectNoDetails, "utf8"),
  textileProcesses: fs.readFileSync(dataFiles.textileNoDetails, "utf8"),
};

const getProcesses = async (token, customProcessesImpacts, customProcesses) => {
  let isTokenValid = false;
  if (token) {
    const checkTokenUrl = `http://${djangoHost}:${djangoPort}/internal/check_token`;
    const tokenRes = await fetch(checkTokenUrl, { headers: { token } });
    isTokenValid = tokenRes.status == 200;
  }

  if (isTokenValid || NODE_ENV === "test") {
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

const respondWithFormattedJSON = (res, status, body) => {
  res.status(status);
  res.setHeader("Content-Type", "application/json");
  res.send(jsonUtils.serialize(body));
};

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
      respondWithFormattedJSON(res, status, body);
    },
  });
});

// Middleware to check version number and file path
const checkVersionAndPath = (req, res, next) => {
  const versionNumber = req.params.versionNumber;

  const version = availableVersions.find((version) => version.dir === versionNumber);

  if (!version) {
    res.status(404).send("Version not found");
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

version.all("/:versionNumber/api/*", checkVersionAndPath, bodyParser.json(), async (req, res) => {
  const versionNumber = req.params.versionNumber;
  const { processesImpacts, processes } = availableVersions.find(
    (version) => version.dir === versionNumber,
  );
  const versionProcesses = await getProcesses(req.headers.token, processesImpacts, processes);

  const { Elm } = require(path.join(req.staticDir, "server-app"));

  const elmApp = Elm.Server.init();

  elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
    return jsResponseHandler({ status, body });
  });

  const urlWithoutPrefix = req.url.replace(/\/[^/]+\/api/, "");

  elmApp.ports.input.send({
    method: req.method,
    url: urlWithoutPrefix,
    body: req.body,
    processes: versionProcesses,
    jsResponseHandler: ({ status, body }) => {
      respondWithFormattedJSON(res, status, body);
    },
  });
});

version.get("/:versionNumber/processes/processes.json", checkVersionAndPath, async (req, res) => {
  const versionNumber = req.params.versionNumber;
  const { processesImpacts, processes } = availableVersions.find(
    (version) => version.dir === versionNumber,
  );

  return res.status(200).send(await getProcesses(req.headers.token, processesImpacts, processes));
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);
app.use("/versions", version);

const server = app.listen(expressPort, expressHost, () => {
  console.log(`Server listening at http://${expressHost}:${expressPort}`);
});

module.exports = server;
