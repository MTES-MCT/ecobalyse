const express = require("express");
const { Elm } = require("./server-app");

const app = express();
const port = 3000;

app.get("/", (req, res) => {
  const elmApp = Elm.Server.init({});
  function handler(result) {
    elmApp.ports.output.unsubscribe(handler);
    return res.send(result);
  }
  elmApp.ports.output.subscribe(handler);
  const inputs = JSON.stringify({
    mass: parseFloat(req.query.mass),
    product: req.query.product,
    material: req.query.material,
    countries: req.query.countries,
  });
  console.log(inputs);
  elmApp.ports.input.send(inputs);
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
