require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./check-db-app");
const { dataFiles } = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    foodProcesses: fs.readFileSync(dataFiles.foodDetailed, "utf-8"),
    objectProcesses: fs.readFileSync(dataFiles.objectDetailed, "utf-8"),
    textileProcesses: fs.readFileSync(dataFiles.textileDetailed, "utf-8"),
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
