const fs = require("fs");
const express = require("express");
const cors = require("cors");
const yaml = require("js-yaml");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const { buildJsonDb } = require("./lib");

const app = express(); // web app
const api = express(); // api app
const host = "0.0.0.0";
const port = process.env.PORT || 3000;

// Web

// Important note: helmet middlewares have to be called *before* any
// other middleware to be effective!
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
          "*.gouv.fr",
        ],
        "frame-src": ["'self'", "https://stats.data.gouv.fr"],
        "img-src": [
          "'self'",
          "data:",
          "https://avatars.githubusercontent.com/",
          "https://raw.githubusercontent.com",
        ],
        // FIXME: We should be able to remove 'unsafe-inline' as soon as the Matomo
        // server sends the appropriate `Access-Control-Allow-Origin` header
        // @see https://matomo.org/faq/how-to/faq_18694/
        "script-src": ["'self'", "'unsafe-inline'", "https://stats.data.gouv.fr"],
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

app.get("/stats", (_, res) => {
  res.redirect("/#/stats");
});

// API

const openApiContents = yaml.load(fs.readFileSync("openapi.yaml"));

const elmApp = Elm.Server.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
});

api.get("/", (_, res) => {
  res.status(200).send(openApiContents);
});

api.all(/(.*)/, ({ method, url }, res) => {
  elmApp.ports.input.send({
    method,
    url,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

api.use(cors()); // Enable CORS for all API requests
app.use("/api", api);

const server = app.listen(port, host, () => {
  console.log(`Server listening at http://${host}:${port}`);
});

module.exports = server;
