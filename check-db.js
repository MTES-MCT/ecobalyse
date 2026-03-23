require("dotenv").config();
const { Elm } = require("./check-db-app");
const { getProcessesAsString } = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    processes: getProcessesAsString((detailed = true)),
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
