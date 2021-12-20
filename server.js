const express = require("express");
const { Elm } = require("./server-app");

const app = express();
const host = "0.0.0.0";
const port = process.env.PORT || 3000;
const { buildJsonDb } = require("./lib");

const elmApp = Elm.Server.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe(({ status, body, jsResponseHandler }) => {
  return jsResponseHandler({ status, body });
});

app.get(/(.*)/, ({ query, path }, res) => {
  elmApp.ports.input.send({
    expressPath: path,
    expressQuery: query,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

app.listen(port, host, () => {
  console.log(`Example app listening at http://${host}:${port}`);
});
