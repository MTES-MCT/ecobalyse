const express = require("express");
const { Elm } = require("./server-app");
const cors = require("cors");
const { buildJsonDb } = require("./lib");

const app = express();
const host = "0.0.0.0";
const port = process.env.PORT || 3000;

// Enable CORS for all requests
app.use(cors());

const elmApp = Elm.Server.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
});

app.all(/(.*)/, ({ method, url }, res) => {
  elmApp.ports.input.send({
    // TODO: headers?
    method,
    url,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

const server = app.listen(port, host, () => {
  console.log(`Example app listening at http://${host}:${port}`);
});

module.exports = server;
