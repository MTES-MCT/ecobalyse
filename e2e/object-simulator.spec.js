import { test, expect } from "@playwright/test";

test("object simulator", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Menu principal").getByRole("link", { name: "Objets" }).click();

  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Dossier plastique (PP)" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Assise plastique (PP)" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Cadre plastique" }).click();

  await page.getByRole("row", { name: "▶ Dossier plastique" }).getByRole("spinbutton").fill("2");
  await page.getByRole("row", { name: "▶ Assise plastique" }).getByRole("spinbutton").fill("3");
  await page.getByRole("row", { name: "▶ Cadre plastique" }).getByRole("spinbutton").fill("4");

  // Update transform for the first component
  await page.getByRole("button", { name: "▶" }).first().click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).click();
  await page.getByRole("option", { name: "Moulage par injection" }).click();

  await expect(page.getByTestId("score-card")).toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
