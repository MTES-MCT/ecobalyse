require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./compute-aggregated-app");

if (!process.env.ECOBALYSE_PRIVATE) {
  console.error(
    "\n🚨 ERROR: For the aggregation to work properly, you need to specify the ECOBALYSE_PRIVATE env variable. It needs to point to the https://github.com/MTES-MCT/ecobalyse-private/ repository. Please, edit your .env file accordingly.",
  );
  console.error("-> Exiting the aggregation process.\n");
  process.exit(1);
}
const TEXTILE_PROCESSES_IMPACTS_PATH =
  process.env.ECOBALYSE_PRIVATE + "data/textile/processes_impacts.json";
const FOOD_PROCESSES_IMPACTS_PATH =
  process.env.ECOBALYSE_PRIVATE + "data/food/processes_impacts.json";

const elmApp = Elm.ComputeAggregated.init({
  flags: {
    definitionsString: fs.readFileSync("public/data/impacts.json", "utf-8"),
    textileProcessesString: fs.readFileSync(TEXTILE_PROCESSES_IMPACTS_PATH, "utf-8"),
    foodProcessesString: fs.readFileSync(FOOD_PROCESSES_IMPACTS_PATH, "utf-8"),
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
      exportJson(TEXTILE_PROCESSES_IMPACTS_PATH, textileProcesses);
      exportJson(FOOD_PROCESSES_IMPACTS_PATH, foodProcesses);
      exportJson("public/data/textile/processes.json", textileProcessesOnlyAggregated);
      exportJson("public/data/food/processes.json", foodProcessesOnlyAggregated);
      console.log(
        `\n4 files exported to\n- ${TEXTILE_PROCESSES_IMPACTS_PATH}\n- ${FOOD_PROCESSES_IMPACTS_PATH}\n- public/data/textile/processes.json\n- public/data/food/processes.json!`,
      );
      console.log(
        "\n🚨 Be sure to commit the detailed impacts `processes_impacts.json` files in the `ecobalyse-private` repo.",
      );
    } catch (err) {
      console.error(err);
    }
  },
);

elmApp.ports.logError.subscribe((errorMessage) => {
  console.error("Error:", errorMessage);
});
