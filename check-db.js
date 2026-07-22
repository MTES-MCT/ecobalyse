require("dotenv").config();
const { Elm } = require("./check-db-app");
const {
  getComponentConfigAsString,
  getDetailedImpactsAsString,
  getProcessesAsString,
} = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    componentConfigJson: getComponentConfigAsString(),
    impactDetailsJson: getDetailedImpactsAsString(),
    nonDetailedProcessesJson: getProcessesAsString((detailed = false)),
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
