const matomo = require("piwik");
const fs = require("fs");

function setupTracker(spec) {
  const tracker = matomo.setup(`https://${process.env.MATOMO_HOST}`, process.env.MATOMO_TOKEN);

  function toMatomoCvar(data) {
    return data.reduce((acc, entry, index) => {
      if (entry.value !== undefined) {
        acc[index + 1] = [entry.name, entry.value];
      }
      return acc;
    }, {});
  }

  function getQueryParams(query) {
    return Object.keys(spec.components.parameters).map((p) => {
      const name = spec.components.parameters[p].name.replace("[]", "");
      return { name: `query.${name}`, value: query[name] };
    });
  }

  return {
    track(status, req) {
      if (process.env.NODE_ENV !== "production") {
        return;
      }
      try {
        // https://developer.matomo.org/api-reference/tracking-api
        const payload = {
          url: "https://ecobalyse.beta.gouv.fr/api" + req.url,
          idsite: process.env.MATOMO_SITE_ID,
          action_name: "ApiRequest",
          e_a: "ApiRequest",
          idgoal: 1, // "API" goal on Matomo
          _rcn: "API",
          _cvar: toMatomoCvar(
            [
              { name: "http.method", value: req.method },
              { name: "http.path", value: req.path },
              { name: "http.status", value: status },
            ].concat(getQueryParams(req.query)),
          ),
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

const dataFiles = {
  detailed: "public/data/processes_impacts.json",
  noDetails: "public/data/processes.json",
};

module.exports = {
  dataFiles,
  setupTracker,
};
