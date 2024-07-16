require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./compute-aggregated-app");
const lib = require("./lib");

const { ECOBALYSE_DATA_DIR } = process.env;

let textileProcessesPath, foodProcessesPath, textileImpactsProcessesPath, foodImpactsProcessesPath;

try {
  ({
    textileProcessesPath,
    foodProcessesPath,
    textileImpactsProcessesPath,
    foodImpactsProcessesPath,
  } = lib.getDataFiles(ECOBALYSE_DATA_DIR, true));
} catch (err) {
  console.error(`🚨 ERROR: ${err.message}`);
  process.exit(1);
}

const elmApp = Elm.ComputeAggregated.init({
  flags: {
    definitionsString: fs.readFileSync("public/data/impacts.json", "utf-8"),
    textileProcessesString: fs.readFileSync(textileImpactsProcessesPath, "utf-8"),
    foodProcessesString: fs.readFileSync(foodImpactsProcessesPath, "utf-8"),
  },
});

const exportJson = async (filepath, json) => {
  // Using dynamic import to avoid jest runtime error
  // eg. “A dynamic import callback was invoked without --experimental-vm-modules”
  fs.writeFileSync(filepath, JSON.stringify(json, null, 2));
};

elmApp.ports.export.subscribe(
  ({
    textileProcesses,
    foodProcesses,
    textileProcessesOnlyAggregated,
    foodProcessesOnlyAggregated,
  }) => {
    try {
      exportJson(textileImpactsProcessesPath, textileProcesses);
      exportJson(foodImpactsProcessesPath, foodProcesses);
      exportJson(textileProcessesPath, textileProcessesOnlyAggregated);
      exportJson(foodProcessesPath, foodProcessesOnlyAggregated);
      console.log(`
4 files exported to:

- ${textileImpactsProcessesPath}
- ${foodImpactsProcessesPath}
- ${textileProcessesPath}
- ${foodProcessesPath}

⚠️ Be sure to commit the detailed impacts 'processes_impacts.json' files in the 'ecobalyse-private' repo`);
    } catch (err) {
      console.error(err);
    }
  },
);

elmApp.ports.logError.subscribe((errorMessage) => {
  console.error("Error:", errorMessage);
});
