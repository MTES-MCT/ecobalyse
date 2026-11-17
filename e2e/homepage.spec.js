// @ts-check
import { test, expect } from "@playwright/test";
import { openSectorMenu, waitForAppReady } from "./lib";

test.describe("homepage", () => {
  test("has expected title", async ({ page }) => {
    await page.goto("/");

    await expect(page).toHaveTitle(/Ecobalyse/);
  });

  test("textile callout button", async ({ page }) => {
    await page.goto("/");
    await waitForAppReady(page);

    const sectorMenu = await openSectorMenu(page);
    await sectorMenu.getByRole("link", { name: "Habillement", exact: true }).click();
    await expect(page).toHaveURL(/textile\/simulator/);

    await expect(page.getByTestId("score-card")).toBeVisible();
  });

  test("food callout button", async ({ page }) => {
    await page.goto("/");

    await page.getByTestId("food-callout-button").click();

    await expect(page.getByTestId("score-card")).toBeVisible();
  });

  test("object callout button", async ({ page }) => {
    await page.goto("/");

    await page.getByTestId("object-callout-button").click();

    await expect(page.getByTestId("score-card")).toBeVisible();
  });
});
