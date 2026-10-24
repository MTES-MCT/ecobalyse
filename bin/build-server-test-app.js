#!/usr/bin/env node

/**
 * Compile server-app.test.js from tests/fixtures, then restore the production
 * src/Static/ProdJson.elm without compiling server-app.js.
 */
const { execFileSync } = require("child_process");
const { buildDatabase } = require("./build-db");

buildDatabase({
  dataDir: "tests/fixtures",
  label: "API test",
  moduleName: "Static.ProdJson",
  outFile: "src/Static/ProdJson.elm",
  processesFileName: "processes.json",
});

try {
  execFileSync("elm", ["make", "src/Server.elm", "--optimize", "--output=server-app.test.js"], {
    stdio: "inherit",
  });
} finally {
  // As the Elm Server.elm module imports Static.ProdJson, the elm-make call above
  // overwrites src/Static/ProdJson.elm with tests/fixtures data, so we can test
  // the app against test data.
  // Once done, we restore the production db.
  // FIXME: we should find a better/cleaner way to achieve the same, but how? :/
  execFileSync(process.execPath, ["bin/build-db", "production"], { stdio: "inherit" });
}
