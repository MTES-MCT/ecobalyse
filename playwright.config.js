// @ts-check
import { defineConfig, devices } from "@playwright/test";

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
import dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.resolve(__dirname, ".env") });

/**
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  timeout: process.env.CI ? 60_000 : 10_000,

  expect: { timeout: process.env.CI ? 10_000 : 2_000 },

  testDir: "./e2e",
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,

  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: [
    [process.env.CI ? "github" : "list"],
    ["html", { outputFolder: "playwright-report", open: "never" }],
  ],

  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: "http://localhost:1234",

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: "on-first-retry",
  },

  // Project dependencies
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1920, height: 1080 },
      },
    },
  ],

  // Run local dev server before starting the tests
  webServer: {
    command: "./bin/playwright-webserver.sh",
    env: {
      DATABASE_URL: "postgresql+asyncpg://ecobalyse@localhost:5433/ecobalyse_test",
      NODE_ENV: "test",
    },
    url: "http://localhost:1234",
    reuseExistingServer: !process.env.CI,
  },

  // Avoid git related timeouts
  // https://github.com/microsoft/playwright/issues/35073#issuecomment-2761312304
  captureGitInfo: {
    commit: false,
    diff: false,
  },
});
