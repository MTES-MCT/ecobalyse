import { test, expect } from "@playwright/test";

test("Object simulator", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Menu principal").getByRole("link", { name: "Objets" }).click();

  // Add a component to the simulation
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Dossier plastique (PP)" }).click();

  // Open details
  await page.getByRole("button", { name: "▶" }).click();

  // Change default element material, select steel
  await page.getByRole("button", { name: "Plastique granulé (PP)" }).click();
  await page.getByRole("option", { name: "Acier (non allié)" }).click();

  // Add a transformation to the steel element
  await page.getByRole("button", { name: "Ajouter une transformation" }).click();
  await page.getByRole("option", { name: "Transformation métallique (" }).click();

  // Add a second element, select plastic
  await page.getByRole("button", { name: "Ajouter un élément" }).click();
  await page.getByRole("option", { name: "Production de PET, granulés," }).click();

  // Add a textile material only transformation
  await page.getByRole("button", { name: "Ajouter une transformation" }).nth(1).click();
  await page.getByRole("option", { name: "Filage (40 Nm)" }).click();

  await expect(page.getByTestId("score-card")).toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
