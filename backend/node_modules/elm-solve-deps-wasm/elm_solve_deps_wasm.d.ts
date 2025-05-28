/* tslint:disable */
/* eslint-disable */
/**
* Initialize the panic hook for more meaningful errors in case of panics,
* and also initialize the logger for the wasm code.
*
* # Panics
*
* Will panic if the logger cannot be initialized.
*/
export function init(): void;
/**
* Solve dependencies for the provided `elm.json`.
*
* Include also test dependencies if `use_test` is `true`.
* It is possible to add additional constraints.
* The caller is responsible to provide implementations to be able to fetch the `elm.json` of
* dependencies, as well as to list existing versions (in preferred order) for a given package.
*
* # Errors
*
* If there is a PubGrub error, it will be reported.
*
* # Panics
*
* If the `elm.json` cannot be decoded, it will panic.
* @param {string} project_elm_json_str
* @param {boolean} use_test
* @param {Record<string, string>} additional_constraints_str
* @param {(pkg: string, version: string) => string} js_fetch_elm_json
* @param {(pkg: string) => string[]} js_list_available_versions
* @returns {string}
*/
export function solve_deps(project_elm_json_str: string, use_test: boolean, additional_constraints_str: Record<string, string>, js_fetch_elm_json: (pkg: string, version: string) => string, js_list_available_versions: (pkg: string) => string[]): string;
