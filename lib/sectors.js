/** API sectors: legacy (food, textile) and generic (gated by ENABLE_*_SECTION, same flags as the UI). */
// FIXME: this should eventually become a configuration file (eg. sectors.json)
const GENERIC_SECTOR_CONFIG = {
  apparel: { env: "ENABLE_APPAREL_SECTION", label: "Habillement" },
  food2: { env: "ENABLE_FOOD2_SECTION", label: "Alimentaire BÉTA" },
  furniture: { env: "ENABLE_FURNITURE_SECTION", label: "Ameublement" },
  object: { env: "ENABLE_OBJECTS_SECTION", label: "Objets" },
  veli: { env: "ENABLE_VELI_SECTION", label: "Véhicules" },
};

const GENERIC_SECTORS = Object.keys(GENERIC_SECTOR_CONFIG);

const LEGACY_SECTORS = ["food", "textile"];

const ALL_SECTORS = [...LEGACY_SECTORS, ...GENERIC_SECTORS].sort();

function isEnvTrue(name, env = process.env) {
  return env[name] === "True";
}

/**
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {string[]}
 */
function getEnabledGenericSectors(env = process.env) {
  return GENERIC_SECTORS.filter((sector) => isEnvTrue(GENERIC_SECTOR_CONFIG[sector].env, env));
}

/**
 * Enabled generic sectors as `{ id, name }` entries for `GET /generic/scopes`.
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {{ id: string, name: string }[]}
 */
function getEnabledGenericSectorEntries(env = process.env) {
  return getEnabledGenericSectors(env).map((id) => ({
    id,
    name: GENERIC_SECTOR_CONFIG[id].label,
  }));
}

/**
 * @param {string} sector
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {boolean}
 */
function isGenericSectorEnabled(sector, env = process.env) {
  const config = GENERIC_SECTOR_CONFIG[sector];
  if (!config) {
    return false;
  } else {
    return isEnvTrue(config.env, env);
  }
}

/**
 * First path segment when it is a known generic sector.
 * @param {string} url
 * @returns {string | null}
 */
function parseGenericSectorFromUrl(url) {
  const sector = parseSectorFromUrl(url);
  if (sector && GENERIC_SECTORS.includes(sector)) {
    return sector;
  } else {
    return null;
  }
}

/**
 * First path segment when it is a known sector (legacy or generic).
 * @param {string} url
 * @returns {string | null}
 */
function parseSectorFromUrl(url) {
  const path = String(url).split("?")[0];
  const segment = path.replace(/^\//, "").split("/")[0];
  if (ALL_SECTORS.includes(segment)) {
    return segment;
  } else {
    return null;
  }
}

/**
 * When no generic sector is enabled, strip all `/{scope}` paths from OpenAPI docs.
 * Mutates and returns `contents`.
 * @param {object} contents OpenAPI document
 * @param {NodeJS.ProcessEnv} [env]
 */
function applyGenericSectorsToOpenApi(contents, env = process.env) {
  const enabled = getEnabledGenericSectors(env);

  if (enabled.length === 0 && contents.paths) {
    contents.paths = Object.fromEntries(
      Object.entries(contents.paths).filter(
        ([path]) => !path.startsWith("/{scope}") && path !== "/generic/scopes",
      ),
    );
  }

  return contents;
}

module.exports = {
  ALL_SECTORS,
  GENERIC_SECTOR_CONFIG,
  GENERIC_SECTORS,
  LEGACY_SECTORS,
  applyGenericSectorsToOpenApi,
  getEnabledGenericSectorEntries,
  getEnabledGenericSectors,
  isGenericSectorEnabled,
  parseGenericSectorFromUrl,
  parseSectorFromUrl,
};
