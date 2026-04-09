require("dotenv").config();
const { Elm } = require("./check-db-app");
const { getComponentConfigAsString, getProcessesAsString } = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    detailedProcessesJson: getProcessesAsString((detailed = true)),
    nonDetailedProcessesJson: getProcessesAsString((detailed = false)),
    componentConfigJson: getComponentConfigAsString(),
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
