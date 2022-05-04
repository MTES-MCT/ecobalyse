const fs = require("fs");
const matomo = require("piwik");

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

function setupTracker(matomoUrl, token) {
  const tracker = matomo.setup(matomoUrl, token);
  return {
    track(req) {
      try {
        // https://developer.matomo.org/api-reference/tracking-api
        const payload = {
          url: req.url,
          idsite: 196,
          action_name: `API${req.path}`,
          _rcn: "API",
          _cvar: Object.keys(req.query).reduce((acc, param, index) => {
            acc[String(index + 1)] = [param, req.query[param]];
            return acc;
          }, {}),
          ua: req.header("User-Agent"),
          lang: req.header("Accept-Language"),
          rand: Math.floor(Math.random() * 10000000),
          rec: 1,
        };
        tracker.track(payload, (err) => {
          if (err) {
            console.error(err);
          }
        });
      } catch (err) {
        console.error(err);
      }
    },
  };
}

module.exports = {
  buildJsonDb,
  setupTracker,
};
