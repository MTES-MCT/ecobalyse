/** API scopes: legacy (food, textile) and generic (gated by ENABLE_*_SECTION, same flags as the UI). */
// FIXME: this should eventually become a configuration file (eg. scopes.json)
const GENERIC_SCOPE_CONFIG = {
  food2: { env: "ENABLE_FOOD2_SECTION", label: "Alimentaire BÉTA" },
  object: { env: "ENABLE_OBJECTS_SECTION", label: "Objets" },
  veli: { env: "ENABLE_VELI_SECTION", label: "Véhicules" },
};

const GENERIC_SCOPES = Object.keys(GENERIC_SCOPE_CONFIG);

const LEGACY_SCOPES = ["food", "textile"];

const ALL_SCOPES = [...LEGACY_SCOPES, ...GENERIC_SCOPES].sort();

function isEnvTrue(name, env = process.env) {
  return env[name] === "True";
}

/**
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {string[]}
 */
function getEnabledGenericScopes(env = process.env) {
  return GENERIC_SCOPES.filter((scope) => isEnvTrue(GENERIC_SCOPE_CONFIG[scope].env, env));
}

/**
 * Enabled generic scopes as `{ id, name }` entries for `GET /generic/scopes`.
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {{ id: string, name: string }[]}
 */
function getEnabledGenericScopeEntries(env = process.env) {
  return getEnabledGenericScopes(env).map((id) => ({
    id,
    name: GENERIC_SCOPE_CONFIG[id].label,
  }));
}

/**
 * @param {string} scope
 * @param {NodeJS.ProcessEnv} [env]
 * @returns {boolean}
 */
function isGenericScopeEnabled(scope, env = process.env) {
  const config = GENERIC_SCOPE_CONFIG[scope];
  if (!config) {
    return false;
  } else {
    return isEnvTrue(config.env, env);
  }
}

/**
 * First path segment when it is a known generic scope.
 * @param {string} url
 * @returns {string | null}
 */
function parseGenericScopeFromUrl(url) {
  const scope = parseScopeFromUrl(url);
  if (scope && GENERIC_SCOPES.includes(scope)) {
    return scope;
  } else {
    return null;
  }
}

/**
 * First path segment when it is a known scope (legacy or generic).
 * @param {string} url
 * @returns {string | null}
 */
function parseScopeFromUrl(url) {
  const path = String(url).split("?")[0];
  const segment = path.replace(/^\//, "").split("/")[0];
  if (ALL_SCOPES.includes(segment)) {
    return segment;
  } else {
    return null;
  }
}

/**
 * When no generic scope is enabled, strip all `/{scope}` paths from OpenAPI docs.
 * Mutates and returns `contents`.
 * @param {object} contents OpenAPI document
 * @param {NodeJS.ProcessEnv} [env]
 */
function applyGenericScopesToOpenApi(contents, env = process.env) {
  const enabled = getEnabledGenericScopes(env);

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
  ALL_SCOPES,
  GENERIC_SCOPE_CONFIG,
  GENERIC_SCOPES,
  LEGACY_SCOPES,
  applyGenericScopesToOpenApi,
  getEnabledGenericScopeEntries,
  getEnabledGenericScopes,
  isGenericScopeEnabled,
  parseGenericScopeFromUrl,
  parseScopeFromUrl,
};
