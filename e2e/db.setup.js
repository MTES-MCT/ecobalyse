import { test as setup } from "@playwright/test";
import fs from "node:fs";
import { deleteUser } from "./lib";

setup.describe("setup", () => {
  setup("test database", async ({}) => {
    if (fs.existsSync(__dirname + "/../db.sqlite3")) {
      // ensure test users don't exist
      // FIXME: we probably want some fixtures and tooling from the backend to do this
      await deleteUser("alice@cooper.com");
    }
  });
});
