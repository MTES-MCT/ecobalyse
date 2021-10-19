/**
 * This script generates JSON Db fixtures so tests can perform assertions
 * against actual JSON data without having to rely on Http requests, which
 * is impossible in an Elm test environment.
 */
const fs = require("fs");

function getJson(path) {
  return JSON.parse(fs.readFileSync(path).toString());
}

const finalJson = {
  countries: getJson("public/data/countries.json"),
  processes: getJson("public/data/processes.json"),
  products: getJson("public/data/products.json"),
};

const elmTemplate = fs.readFileSync("tests/TestDb.elm-template").toString();
const elmFixtures = elmTemplate.replace("%json", JSON.stringify(finalJson, 2));

try {
  fs.writeFileSync("tests/TestDb.elm", elmFixtures);
  console.log("Successfully generated Elm db fixtures at tests/TestDb.elm");
} catch (err) {
  throw new Error(`Unable to generate Elm db fixtures: ${err}`);
}
