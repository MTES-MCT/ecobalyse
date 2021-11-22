/**
 * This script generates JSON Db fixtures so tests can perform assertions
 * against actual JSON data without having to rely on Http requests, which
 * is impossible in an Elm test environment.
 */
const fs = require("fs");
const { buildJsonDb } = require("../lib");

const elmTemplate = fs.readFileSync("tests/TestDb.elm-template").toString();
const elmFixtures = elmTemplate.replace("%json%", buildJsonDb());

try {
  fs.writeFileSync("tests/TestDb.elm", elmFixtures);
  console.log("Successfully generated Elm db fixtures at tests/TestDb.elm");
} catch (err) {
  throw new Error(`Unable to generate Elm db fixtures: ${err}`);
}
