import { test, expect } from "@playwright/test";
import { waitForAppReady } from "./lib";

test("Food simulator", async ({ page }) => {
  test.setTimeout(30_000);

  await page.goto("/");
  await waitForAppReady(page);
  await page.getByLabel("Menu principal").locator('a[href="#/food"]').click();
  await expect(page).toHaveURL(/#\/food$/);

  await page.getByRole("button", { name: "Exemples" }).click();
  await page.getByRole("option", { name: "Pizza bolognese (375g) - 21" }).click();
  await expect(page.getByRole("button", { name: "Farine UE" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Mozzarella FR" })).toBeVisible();

  // delete wheat
  await page
    .getByRole("listitem")
    .filter({ hasText: "Farine UE" })
    .getByRole("button")
    .nth(2)
    .click();

  await expect(page.getByRole("button", { name: "Farine UE" })).not.toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
