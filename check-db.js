require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./check-db-app");
const { dataFiles } = require("./lib");

const elmApp = Elm.CheckDb.init({
  flags: {
    processes: JSON.stringify(
      JSON.parse(fs.readFileSync(dataFiles.detailed, "utf8").toString()).concat(
        JSON.parse(fs.readFileSync(dataFiles.genericDetailed, "utf8")),
      ),
    ),
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
