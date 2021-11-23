const express = require("express");
const { Elm } = require("./server-app");

const app = express();
const port = 3000;
const { buildJsonDb } = require("./lib");

const elmApp = Elm.Server.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe(({ score, fn }) => {
  return fn(score);
});

app.get("/", ({ query }, res) => {
  // sample query string:
  // // http://localhost:3000/?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countries[]=CN&countries[]=FR&countries[]=FR&countries[]=FR&countries[]=FR&dyeingWeighting=&airTransportRatio=&recycledRatio=&customCountryMixes.fabric=&customCountryMixes.dyeing=&customCountryMixes.making=
  const inputs = {
    mass: parseFloat(query.mass),
    product: query.product,
    material: query.material,
    countries: query.countries,
    dyeingWeighting: query.dyeingWeighting || null,
    airTransportRatio: query.airTransportRatio || null,
    recycledRatio: query.recycledRatio || null,
    customCountryMixes: {
      fabric: query["customCountryMixes.fabric"] || null,
      making: query["customCountryMixes.making"] || null,
      dyeing: query["customCountryMixes.dyeing"] || null,
    },
  };
  // console.log(inputs);
  elmApp.ports.input.send({
    inputs,
    fn: (score) => {
      res.status(200).send({ score });
    },
  });
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
