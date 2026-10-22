#!/usr/bin/env node

/**
 * Compile server-app.test.js from tests/fixtures, then restore the production
 * src/Static/Json.elm without compiling server-app.js.
 * FIXME: try to do all this directly from package.json
 */
const { execFileSync } = require("child_process");
const { buildDatabase } = require("./build-db");

buildDatabase({
  dataDir: "tests/fixtures",
  label: "API test",
  moduleName: "Static.Json",
  outFile: "src/Static/Json.elm",
  processesFileName: "processes.json",
});

try {
  execFileSync("elm", ["make", "src/Server.elm", "--optimize", "--output=server-app.test.js"], {
    stdio: "inherit",
  });
} finally {
  execFileSync(process.execPath, ["bin/build-db", "production"], { stdio: "inherit" });
}
