const matomo = require("piwik");

const { NODE_ENV, MATOMO_HOST, MATOMO_TOKEN, MATOMO_SITE_ID } = process.env;

function setupTracker(spec) {
  if (NODE_ENV !== "production" || !MATOMO_HOST || !MATOMO_TOKEN) {
    // Skip tracking through
    return {
      track() {},
    };
  }

  const tracker = matomo.setup(`https://${MATOMO_HOST}`, MATOMO_TOKEN);

  function toMatomoCvar(data) {
    return data.reduce((acc, entry, index) => {
      if (entry.value !== undefined) {
        acc[index + 1] = [entry.name, entry.value];
      }
      return acc;
    }, {});
  }

  return {
    track(status, req) {
      try {
        // https://developer.matomo.org/api-reference/tracking-api
        const payload = {
          url: "https://ecobalyse.beta.gouv.fr/api" + req.url,
          idsite: MATOMO_SITE_ID,
          action_name: "ApiRequest",
          e_a: "ApiRequest",
          idgoal: 1, // "API" goal on Matomo
          _rcn: "API",
          _cvar: toMatomoCvar([
            { name: "http.method", value: req.method },
            { name: "http.path", value: req.path },
            { name: "http.status", value: status },
          ]),
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
