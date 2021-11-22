/**
 * This script perform test simulations from presets and dumps the resulting
 * output in a static JSON file.
 */
const fs = require("fs");
const { Elm } = require("./dump-presets-app");

/* TODO :
- create an Elm main entrypoint :
  * loading Db from static (see Db tests)
  * batch running simulation for presets
  * collect results and dump them as JSON
- Load Elm app here (ensure it's compiled)
- Init it with appropriate flags(?)
- Subscribe to result output, collect result
- Write resulting JSON to public/data/dump-presets.json with these results
*/

function getJson(path) {
  return JSON.parse(fs.readFileSync(path).toString());
}

const jsonDb = JSON.stringify({
  countries: getJson("public/data/countries.json"),
  materials: getJson("public/data/materials.json"),
  processes: getJson("public/data/processes.json"),
  products: getJson("public/data/products.json"),
  transports: getJson("public/data/transports.json"),
});

const elmApp = Elm.DumpPresets.init({ flags: { jsonDb } });

elmApp.ports.output.subscribe((result) => {
  try {
    fs.writeFileSync("public/data/dump-presets.json", JSON.stringify(result));
    console.log("Successfully generated preset results at public/data/dump-presets.json");
  } catch (err) {
    throw new Error(`Unable to generate preset results: ${err}`);
  }
});
