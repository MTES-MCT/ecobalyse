import child_process from "node:child_process";
import fs from "fs";
import { test as setup } from "@playwright/test";

setup("Setup test database", async ({}) => {
  if (process.env.NODE_ENV === "test" && fs.existsSync(__dirname + "/../db.sqlite3")) {
    console.info("Prepping up test db…");
    try {
      // ensure test users don't exist
      // FIXME: we probably want some fixtures and tooling from the backend to do this
      child_process.execFileSync("sqlite3", [
        "db.sqlite3",
        "delete from user_account where email='alice@cooper.com'",
      ]);
    } catch (error) {
      console.error("Error setting up test db", error);
    }
  }
});
