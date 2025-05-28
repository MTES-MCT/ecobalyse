// @ts-check
import { test, expect } from "@playwright/test";

test("has expected title", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await expect(page).toHaveTitle(/Ecobalyse/);
});

test("textile callout button", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await page.getByTestId("textile-callout-button").click();

  await expect(page.getByTestId("score-card")).toBeVisible();
});

test("food callout button", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await page.getByTestId("food-callout-button").click();

  await expect(page.getByTestId("score-card")).toBeVisible();
});

test("object callout button", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await page.getByTestId("object-callout-button").click();

  await expect(page.getByTestId("score-card")).toBeVisible();
});
