const fs = require("fs");

function getJson(path) {
  return JSON.parse(fs.readFileSync(path).toString());
}

function buildJsonDb(basePath = "public/data") {
  return JSON.stringify({
    countries: getJson(`${basePath}/countries.json`),
    materials: getJson(`${basePath}/materials.json`),
    processes: getJson(`${basePath}/processes.json`),
    products: getJson(`${basePath}/products.json`),
    transports: getJson(`${basePath}/transports.json`),
    impacts: getJson(`${basePath}/impacts.json`),
  });
}

module.exports = {
  buildJsonDb,
};
