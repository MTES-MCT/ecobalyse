const express = require("express");
const { Elm } = require("./server-app");
const cors = require("cors");
const { buildJsonDb } = require("./lib");

const app = express(); // web app
const api = express(); // api app
const host = "0.0.0.0";
const port = process.env.PORT || 3000;

// Web

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
