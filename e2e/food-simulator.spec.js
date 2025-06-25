import { test, expect } from "@playwright/test";

test("Food simulator", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Menu principal").getByRole("link", { name: "Alimentaire" }).click();

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
