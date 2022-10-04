/**
 * This script generates JSON Db fixtures so tests can perform assertions
 * against actual JSON data without having to rely on Http requests, which
 * is impossible in an Elm test environment.
 */
const fs = require("fs");
const lib = require("../lib");

/**
 * Adapts a standard JSON string to what is expected to be the format
 * used in Elm's template strings (`"""{}"""`).
 */
function adaptJsonStringToElm(toStringify) {
  return toStringify.replaceAll("\\", "\\\\");
}

const elmTemplate = fs.readFileSync("tests/TestDb.elm-template").toString();
const elmWithFixtures = elmTemplate
  .replace("%textileJson%", adaptJsonStringToElm(lib.buildTextileJsonDb()))
  .replace("%foodProcessesJson%", adaptJsonStringToElm(lib.buildFoodProcessesJsonDb()))
  .replace("%foodProductsJson%", adaptJsonStringToElm(lib.buildFoodProductsJsonDb()));

try {
  fs.writeFileSync("tests/TestDb.elm", elmWithFixtures);
  console.log("Successfully generated Elm textile and food db fixtures at tests/TestDb.elm");
} catch (err) {
  throw new Error(`Unable to generate Elm db fixtures: ${err}`);
}
