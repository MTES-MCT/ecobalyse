const express = require("express");
const { Elm } = require("./server-app");

const server = Elm.Server.init({});

const app = express();
const port = 3000;

app.get("/", (req, res) => {
  function handler(result) {
    server.ports.output.unsubscribe(handler);
    return res.send(result);
  }
  server.ports.output.subscribe(handler);
  const inputs = {
    mass: parseFloat(req.query.mass),
    product: req.query.product,
    material: req.query.material,
    countries: req.query.countries,
  };
  console.log(inputs);
  server.ports.input.send(inputs);
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
