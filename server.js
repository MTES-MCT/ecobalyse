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

app.get("/", ({ query }, res) => {
  // sample query string:
  // http://localhost:3000/?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countries[]=CN&countries[]=FR&countries[]=FR&countries[]=FR&countries[]=FR&dyeingWeighting=&airTransportRatio=&recycledRatio=&customCountryMixes.fabric=&customCountryMixes.dyeing=&customCountryMixes.making=
  elmApp.ports.input.send({
    expressQuery: query,
    jsResponseHandler: ({ status, body }) => {
      res.status(status).send(body);
    },
  });
});

app.listen(port, host, () => {
  console.log(`Example app listening at http://${host}:${port}`);
});
