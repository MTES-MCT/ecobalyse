/**
 * This script generates JSON Db fixtures so tests can perform assertions
 * against actual JSON data without having to rely on Http requests, which
 * is impossible in an Elm test environment.
 */
const fs = require("fs");

function getJson(path) {
  return JSON.parse(fs.readFileSync(path).toString());
}

/**
 * Adapts a standard JSON string to what is expected to be the format
 * used in Elm's template strings (`"""{}"""`).
 */
function serializeForElmTemplateString(toStringify) {
  return JSON.stringify(toStringify).replaceAll("\\", "\\\\");
}

function buildTextileJsonDb(basePath = "public/data") {
  return serializeForElmTemplateString({
    // common data
    countries: getJson(`${basePath}/countries.json`),
    impacts: getJson(`${basePath}/impacts.json`),
    transports: getJson(`${basePath}/transports.json`),
    // textile data
    materials: getJson(`${basePath}/textile/materials.json`),
    processes: getJson(`${basePath}/textile/processes.json`),
    products: getJson(`${basePath}/textile/products.json`),
  });
}

function buildFoodProcessesJsonDb(basePath = "public/data/food") {
  return serializeForElmTemplateString(getJson(`${basePath}/processes.json`));
}

function buildFoodIngredientsJsonDb(basePath = "public/data/food") {
  return serializeForElmTemplateString(getJson(`${basePath}/ingredients.json`));
}

const targetDbFile = "src/Static/Db.elm";
const elmTemplate = fs.readFileSync(`${targetDbFile}-template`).toString();
const elmWithFixtures = elmTemplate
  .replace("%textileJson%", buildTextileJsonDb())
  .replace("%foodProcessesJson%", buildFoodProcessesJsonDb())
  .replace("%foodIngredientsJson%", buildFoodIngredientsJsonDb());

const header =
  "---- THIS FILE WAS GENERATED FROM THE FILE `Db.elm-template` BY THE `/tests/prepare.js` SCRIPT";

try {
  fs.writeFileSync(targetDbFile, `${header}\n\n${elmWithFixtures}`);
  console.log(`Successfully generated Elm static database at ${targetDbFile}`);
} catch (err) {
  throw new Error(`Unable to generate Elm static database: ${err}`);
}
