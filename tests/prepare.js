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
    countries: getJson(`${basePath}/countries.json`),
    materials: getJson(`${basePath}/materials.json`),
    processes: getJson(`${basePath}/processes.json`),
    products: getJson(`${basePath}/products.json`),
    transports: getJson(`${basePath}/transports.json`),
    impacts: getJson(`${basePath}/impacts.json`),
  });
}

function buildFoodProcessesJsonDb(basePath = "public/data/food") {
  return serializeForElmTemplateString(getJson(`${basePath}/processes.json`));
}

function buildFoodProductsJsonDb(basePath = "public/data/food") {
  return serializeForElmTemplateString(getJson(`${basePath}/products.json`));
}

const targetDbFile = "src/Static/Db.elm";
const elmTemplate = fs.readFileSync(`${targetDbFile}-template`).toString();
const elmWithFixtures = elmTemplate
  .replace("%textileJson%", buildTextileJsonDb())
  .replace("%foodProcessesJson%", buildFoodProcessesJsonDb())
  .replace("%foodProductsJson%", buildFoodProductsJsonDb());

try {
  fs.writeFileSync(targetDbFile, elmWithFixtures);
  console.log(`Successfully generated Elm static database at ${targetDbFile}`);
} catch (err) {
  throw new Error(`Unable to generate Elm static database: ${err}`);
}
