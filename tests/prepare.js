/**
 * This script generates JSON Db fixtures so tests can perform assertions
 * against actual JSON data without having to rely on Http requests, which
 * is impossible in an Elm test environment.
 */
const fs = require("fs");
const { buildTextileJsonDb, buildFoodProcessesJsonDb, buildFoodProductsJsonDb } = require("../lib");

const elmTemplate = fs.readFileSync("tests/TestDb.elm-template").toString();
const elmWithFixtures = elmTemplate
  .replace("%textileJson%", buildTextileJsonDb())
  .replace("%foodProcessesJson%", buildFoodProcessesJsonDb())
  .replace("%foodProductsJson%", buildFoodProductsJsonDb());

try {
  fs.writeFileSync("tests/TestDb.elm", elmWithFixtures);
  console.log("Successfully generated Elm textile and food db fixtures at tests/TestDb.elm");
} catch (err) {
  throw new Error(`Unable to generate Elm db fixtures: ${err}`);
}
