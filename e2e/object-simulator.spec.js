import { test, expect } from "@playwright/test";
import { waitForAppReady } from "./lib";

test("object simulator", async ({ page }) => {
  test.setTimeout(30_000);

  await page.goto("/");
  await waitForAppReady(page);
  await page.getByLabel("Menu principal").getByRole("link", { name: "Objets" }).click();

  await page.getByRole("button", { name: "Ajouter un matériau" }).click();
  await page.getByRole("option", { name: "Pied chaise acier" }).click();
  await page.getByRole("button", { name: "Ajouter un matériau" }).click();
  await page.getByRole("option", { name: "Structure acier (canapé 3p)" }).click();
  await page.getByRole("button", { name: "Ajouter un matériau" }).click();
  await page.getByRole("option", { name: "Mousse polyurethane (canapé 3p)" }).click();

  const production = page.locator(".card").filter({ hasText: "Production des matériaux" });
  await production.getByRole("spinbutton").nth(0).fill("2");
  await production.getByRole("spinbutton").nth(1).fill("3");
  await production.getByRole("spinbutton").nth(2).fill("4");

  // Update transform for the first component through element edit modal
  await page.getByRole("button", { name: "▶" }).first().click();
  await page.locator("tbody .btn-group .btn-outline-secondary").first().click();
  await expect(page.getByText("Modifier l'élément")).toBeVisible();
  await page
    .locator(".modal.show")
    .getByRole("button", { name: "Ajouter une transformation" })
    .click();
  // TODO: reactivate this test once the duplicate processes pb is solved
  //await page.getByRole("option", { name: "Extrusion (aluminium)" }).click();

  await expect(page.getByTestId("score-card")).toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
