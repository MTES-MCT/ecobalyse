/** Generic API scopes gated by ENABLE_*_SECTION env vars (same flags as the UI). */
// FIXME: this should eventually become a configuration file (eg. scopes.json)
const GENERIC_SCOPE_CONFIG = {
  food2: { env: "ENABLE_FOOD2_SECTION", label: "Alimentaire BÉTA" },
  object: { env: "ENABLE_OBJECTS_SECTION", label: "Objets" },
  veli: { env: "ENABLE_VELI_SECTION", label: "Véhicules" },
};

const GENERIC_SCOPES = Object.keys(GENERIC_SCOPE_CONFIG);

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
  const path = String(url).split("?")[0];
  const segment = path.replace(/^\//, "").split("/")[0];
  return GENERIC_SCOPES.includes(segment) ? segment : null;
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
  GENERIC_SCOPE_CONFIG,
  GENERIC_SCOPES,
  applyGenericScopesToOpenApi,
  getEnabledGenericScopeEntries,
  getEnabledGenericScopes,
  isGenericScopeEnabled,
  parseGenericScopeFromUrl,
};
