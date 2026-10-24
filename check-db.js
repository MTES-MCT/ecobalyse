require("dotenv").config();
const { Elm } = require("./check-db-app");
const { getComponentConfigAsString, getDetailedProcessesAsString } = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    componentConfigJson: getComponentConfigAsString(),
    detailedProcessesJson: getDetailedProcessesAsString(),
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
