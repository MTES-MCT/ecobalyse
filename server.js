require("dotenv").config();
const { monitorExpressApp } = require("./lib/instrument");
const fs = require("fs");
const path = require("path");
const bodyParser = require("body-parser");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const lib = require("./lib");
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
const { ECOBALYSE_DATA_DIR, MATOMO_HOST, MATOMO_SITE_ID, MATOMO_TOKEN, NODE_ENV } = process.env;

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

let dataFiles;
try {
  dataFiles = lib.getDataFiles(ECOBALYSE_DATA_DIR);
} catch (err) {
  console.error(`🚨 ERROR: ${err.message}`);
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
    index: "index.html",
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
    const textileNoDetails = path.join(currentVersionDir, "data/textile/processes.json");

    const foodDetailed = path.join(currentVersionDir, "data/food/processes_impacts.json");
    const textileDetailed = path.join(currentVersionDir, "data/textile/processes_impacts.json");

    const foodDetailedEnc = path.join(currentVersionDir, "processes_impacts_food.json.enc");
    const textileDetailedEnc = path.join(currentVersionDir, "processes_impacts_textile.json.enc");

    if (!fs.existsSync(foodNoDetails) || !fs.existsSync(textileNoDetails)) {
      console.error(
        `🚨 ERROR: processes files without details missing for version ${dir}. Skipping version.`,
      );
    }
    let processesImpacts;

    if (fs.existsSync(foodDetailedEnc) && fs.existsSync(textileDetailedEnc)) {
      console.log(`Encrypted files found for ${dir}: ${foodDetailedEnc} && ${textileDetailedEnc}`);
      // Encrypted files exist, use them
      processesImpacts = {
        foodProcesses: decrypt(JSON.parse(fs.readFileSync(foodDetailedEnc).toString("utf-8"))),
        textileProcesses: decrypt(
          JSON.parse(fs.readFileSync(textileDetailedEnc).toString("utf-8")),
        ),
      };
    } else if (fs.existsSync(foodDetailed) || fs.existsSync(textileDetailed)) {
      // Or use old files
      processesImpacts = {
        foodProcesses: fs.readFileSync(foodDetailed, "utf8"),
        textileProcesses: fs.readFileSync(textileDetailed, "utf8"),
      };
    }

    availableVersions.push({
      dir,
      processes: {
        foodProcesses: fs.readFileSync(foodNoDetails, "utf8"),
        textileProcesses: fs.readFileSync(textileNoDetails, "utf8"),
      },
      processesImpacts,
    });
  }
}

// API

const openApiContents = yaml.load(fs.readFileSync("openapi.yaml"));
openApiContents.version = require("./package.json").version;

// Matomo
const apiTracker = lib.setupTracker(openApiContents);

const processesImpacts = {
  foodProcesses: fs.readFileSync(dataFiles.foodDetailed, "utf8"),
  textileProcesses: fs.readFileSync(dataFiles.textileDetailed, "utf8"),
};

const processes = {
  foodProcesses: fs.readFileSync(dataFiles.foodNoDetails, "utf8"),
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
  const openApiContents = yaml.load(fs.readFileSync(path.join(req.staticDir, "openapi.yaml")));
  res.status(200).send(openApiContents);
});

version.all("/:versionNumber/api/*", checkVersionAndPath, bodyParser.json(), async (req, res) => {
  const foodProcesses = fs
    .readFileSync(path.join(req.staticDir, "data", "food", "processes_impacts.json"))
    .toString();
  const textileProcesses = fs
    .readFileSync(path.join(req.staticDir, "data", "textile", "processes_impacts.json"))
    .toString();

  const processes = {
    foodProcesses: foodProcesses,
    textileProcesses: textileProcesses,
  };

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
    processes: processes,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
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
