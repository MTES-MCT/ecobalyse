import { test, expect } from "@playwright/test";

test("object simulator", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Menu principal").getByRole("link", { name: "Objets" }).click();

  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Pied chaise acier" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Structure acier (canapé 3p)" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Mousse polyurethane (canapé 3p)" }).click();

  await page.getByRole("row", { name: "▶ Pied chaise acier" }).getByRole("spinbutton").fill("2");
  await page.getByRole("row", { name: "▶ Structure acier" }).getByRole("spinbutton").fill("3");
  await page.getByRole("row", { name: "▶ Mousse polyurethane" }).getByRole("spinbutton").fill("4");

  // Update transform for the first component
  await page.getByRole("button", { name: "▶" }).first().click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).click();
  await page.getByRole("option", { name: "Extrusion" }).click();

  await expect(page.getByTestId("score-card")).toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
