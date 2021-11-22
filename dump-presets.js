/**
 * This script perform test simulations from presets and dumps the resulting
 * output in a static JSON file.
 *
 * This scripts:
 * - Create a big JSON aggregate of all public JSON data files
 * - Loads the DumpPresets Elm app and feeds it with this file as a flag
 * - Subscribes and collect Elm app result JSON output
 * - Write it to public/data/dump-presets.json
 */
const fs = require("fs");
const { Elm } = require("./dump-presets-app");
const { buildJsonDb } = require("./lib");

const elmApp = Elm.DumpPresets.init({
  flags: {
    jsonDb: buildJsonDb(),
  },
});

elmApp.ports.output.subscribe((result) => {
  // Exit with error if the process failed
  if ("error" in result) {
    throw new Error(`Error while dumping test preset results: ${jsonExport["error"]}`);
  }

  // Attempt creating a new static JSON dump
  try {
    fs.writeFileSync("public/data/dump-presets.json", JSON.stringify(result, null, 2));
    console.log("Successfully generated preset results at public/data/dump-presets.json");
  } catch (err) {
    throw new Error(`Unable to generate preset results: ${err}`);
  }
});
