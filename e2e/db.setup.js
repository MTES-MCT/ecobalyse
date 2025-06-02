import { test as setup } from "@playwright/test";
import fs from "node:fs";
import child_process from "node:child_process";

setup.describe("setup", () => {
  setup("test database", async ({}) => {
    if (fs.existsSync(__dirname + "/../db.sqlite3")) {
      // ensure test users don't exist
      // FIXME: we probably want some fixtures and tooling from the backend to do this
      child_process.execFileSync("sqlite3", [
        "db.sqlite3",
        "delete from user_account where email='alice@cooper.com'",
      ]);
    }
  });
});
