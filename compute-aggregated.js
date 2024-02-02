require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./compute-aggregated-app");

const elmApp = Elm.ComputeAggregated.init({
  flags: {
    definitionsString: fs.readFileSync("public/data/impacts.json", "utf-8"),
    textileProcessesString: fs.readFileSync("public/data/textile/processes_impacts.json", "utf-8"),
    foodProcessesString: fs.readFileSync("public/data/food/processes_impacts.json", "utf-8"),
  },
});

const exportJson = (filePath, json) => {
  fs.writeFileSync(filePath, JSON.stringify(json, null, 2) + "\n");
};

elmApp.ports.export.subscribe(
  ({
    textileProcesses,
    foodProcesses,
    textileProcessesOnlyAggregated,
    foodProcessesOnlyAggregated,
  }) => {
    try {
      exportJson("public/data/textile/processes_impacts.json", textileProcesses);
      exportJson("public/data/food/processes_impacts.json", foodProcesses);
      exportJson("public/data/textile/processes.json", textileProcessesOnlyAggregated);
      exportJson("public/data/food/processes.json", foodProcessesOnlyAggregated);
      console.log("EXPORTED!");
    } catch (err) {
      console.error(err);
    }
  },
);

elmApp.ports.logError.subscribe((errorMessage) => {
  console.error("Error:", errorMessage);
});
