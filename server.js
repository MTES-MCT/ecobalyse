const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const { Elm } = require("./server-app");
const { buildJsonDb } = require("./lib");

const app = express(); // web app
const api = express(); // api app
const host = "0.0.0.0";
const port = process.env.PORT || 3000;

// Web

app.use(
  // Important note: this has to be called prior to any other
  // middleware to be effective!
  helmet({
    contentSecurityPolicy: {
      useDefaults: true,
      directives: {
        "default-src": [
          "'self'",
          "https://stats.data.gouv.fr",
          "https://raw.githubusercontent.com",
        ],
        "img-src": ["'self'", "data:", "https://raw.githubusercontent.com"],
        "script-src": ["'self'", "https://stats.data.gouv.fr"],
      },
    },
  }),
);

app.use(express.static("dist"));

app.get("/stats", (_, res) => {
  res.redirect("/#/stats");
});

// API

const elmApp = Elm.Server.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
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
