require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./compute-aggregated-app");
const lib = require("./lib");

// Check that the data dir is correctly setup
lib.checkDataFiles();

const { ECOBALYSE_DATA_DIR } = process.env;

let textileImpactsFile = `${ECOBALYSE_DATA_DIR}/data/textile/processes_impacts.json`;
let foodImpactsFile = `${ECOBALYSE_DATA_DIR}/data/food/processes_impacts.json`;

const elmApp = Elm.ComputeAggregated.init({
  flags: {
    definitionsString: fs.readFileSync("public/data/impacts.json", "utf-8"),
    textileProcessesString: fs.readFileSync(textileImpactsFile, "utf-8"),
    foodProcessesString: fs.readFileSync(foodImpactsFile, "utf-8"),
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
      exportJson(textileImpactsFile, textileProcesses);
      exportJson(foodImpactsFile, foodProcesses);
      exportJson("public/data/textile/processes.json", textileProcessesOnlyAggregated);
      exportJson("public/data/food/processes.json", foodProcessesOnlyAggregated);
      console.log(`
4 files exported to:

- ${textileImpactsFile}
- ${foodImpactsFile}
- public/data/textile/processes.json
- public/data/food/processes.json

⚠️ Be sure to commit the detailed impacts 'processes_impacts.json' files in the 'ecobalyse-private' repo`);
    } catch (err) {
      console.error(err);
    }
  },
);

elmApp.ports.logError.subscribe((errorMessage) => {
  console.error("Error:", errorMessage);
});
