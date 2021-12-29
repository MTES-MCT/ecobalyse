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

app.all(/(.*)/, (req, res) => {
  const { method, url, path, query } = req;
  // console.log({
  //   url: req.url,
  //   method: req.method,
  //   baseUrl: req.baseUrl,
  //   originalUrl: req.originalUrl,
  //   params: req.params,
  //   query: req.query,
  // });
  elmApp.ports.input.send({
    // TODO: headers?
    method,
    url,
    path, // FIXME: remove me
    expressQuery: query,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

const server = app.listen(port, host, () => {
  console.log(`Example app listening at http://${host}:${port}`);
});

module.exports = server;
