const matomo = require("piwik");
const fs = require("fs");

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

function getComponentConfigAsString() {
  return fs.readFileSync("public/data/components/config.json", "utf8").toString();
}

function getProcessesAsString(detailed = false) {
  return JSON.stringify(readJsonFile(detailed ? dataFiles.detailed : dataFiles.noDetails));
}

/**
 * Slim detailed impacts payload ([{ id, impacts }]), served as-is to the Elm client
 * which merges it in session db processes on succesful auth.
 */
function getDetailedImpactsAsString() {
  return getProcessesAsString((detailed = true));
}

/**
 * Full detailed processes string (base metadata + detailed impacts), used wherever a
 * complete Db must be built in a non-Web env (Elm API server, static test db, CLI exec)
 */
function getDetailedProcessesAsString() {
  const baseProcesses = readJsonFile(dataFiles.noDetails);
  const detailedImpacts = readJsonFile(dataFiles.detailed);
  return JSON.stringify(mergeDetailedImpacts(baseProcesses, detailedImpacts));
}

/**
 * Override base process impacts with detailed ones, matched by id. Processes without a
 * matching detailed entry keep their base impacts (ecs).
 */
function mergeDetailedImpacts(baseProcesses, detailedImpacts) {
  const impactsById = new Map(detailedImpacts.map(({ id, impacts }) => [id, impacts]));
  return baseProcesses.map((process) =>
    impactsById.has(process.id) ? { ...process, impacts: impactsById.get(process.id) } : process,
  );
}

/**
 * Read a JSON file and parse it into a JavaScript object.
 */
function readJsonFile(path) {
  return JSON.parse(fs.readFileSync(path, "utf8").toString());
}

function filterLegacyFood1Paths(paths) {
  return Object.fromEntries(
    Object.entries(paths).filter(
      ([path, _]) => !path.startsWith("/food") || path.startsWith("/food2"),
    ),
  );
}

const dataFiles = {
  detailed: "public/data/processes_impacts.json",
  noDetails: "public/data/processes.json",
};

module.exports = {
  dataFiles,
  filterLegacyFood1Paths,
  getComponentConfigAsString,
  getDetailedImpactsAsString,
  getDetailedProcessesAsString,
  getProcessesAsString,
  mergeDetailedImpacts,
  setupTracker,
};
