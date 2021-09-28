const express = require("express");
const { Elm } = require("./server-app");

const server = Elm.Server.init({});

const app = express();
const port = 3000;

app.get("/", (req, res) => {
  function handler(result) {
    server.ports.output.unsubscribe(handler);
    return res.send({ result });
  }
  server.ports.output.subscribe(handler);
  server.ports.input.send(JSON.stringify(req.query.inputs)); // FIXME: http POST + json body
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
