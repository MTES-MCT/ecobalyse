// @ts-check
import { test, expect } from "@playwright/test";
import { waitForAppReady } from "./lib";

test.describe("homepage", () => {
  test("has expected title", async ({ page }) => {
    await page.goto("/");

    await expect(page).toHaveTitle(/Ecobalyse/);
  });

  test("textile callout button", async ({ page }) => {
    test.setTimeout(30_000);

    await page.goto("/");
    await waitForAppReady(page);

    await page.getByLabel("Menu principal").getByRole("link", { name: "Textile" }).click();
    await expect(page).toHaveURL(/textile\/simulator/);

    await expect(page.getByTestId("score-card")).toBeVisible();
  });

  test("food callout button", async ({ page }) => {
    test.setTimeout(30_000);

    await page.goto("/");
    await waitForAppReady(page);

    await page.getByTestId("food-callout-button").click();

    await expect(page.getByTestId("score-card")).toBeVisible();
  });

  test("object callout button", async ({ page }) => {
    test.setTimeout(30_000);

    await page.goto("/");
    await waitForAppReady(page);

    await page.getByTestId("object-callout-button").click();

    await expect(page.getByTestId("score-card")).toBeVisible();
  });
});
