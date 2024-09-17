require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./check-db-app");
const lib = require("./lib");

const { ECOBALYSE_DATA_DIR } = process.env;

let dataFiles;
try {
  dataFiles = lib.getDataFiles(ECOBALYSE_DATA_DIR);
} catch (err) {
  console.error(`🚨 ERROR: ${err.message}`);
  process.exit(1);
}

const elmApp = Elm.CheckDb.init({
  flags: {
    textileProcesses: fs.readFileSync(dataFiles.textileDetailed, "utf-8"),
    foodProcesses: fs.readFileSync(dataFiles.foodDetailed, "utf-8"),
  },
});

elmApp.ports.logAndExit.subscribe(({ message, status }) => {
  if (status > 0) {
    console.error(`🚨 ERROR: ${message}`);
  } else {
    console.info(message);
  }
  process.exit(status);
});
