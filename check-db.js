require("dotenv").config();
const { Elm } = require("./check-db-app");
const {
  getComponentConfigAsString,
  getDetailedProcessesAsString,
  getProcessesAsString,
} = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    detailedProcessesJson: getDetailedProcessesAsString(),
    nonDetailedProcessesJson: getProcessesAsString(),
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
