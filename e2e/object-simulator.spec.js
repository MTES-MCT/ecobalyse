import { test, expect } from "@playwright/test";

test("Object simulator", async ({ page }) => {
  await page.goto("/");
  await page.getByLabel("Menu principal").getByRole("link", { name: "Objets" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Dossier plastique (PP)" }).click();
  await page.getByRole("button", { name: "▶" }).click();
  await page
    .getByRole("row", { name: "▼ Dossier plastique (PP) 0," })
    .getByRole("spinbutton")
    .fill("2");
  await page
    .getByRole("row", { name: "kg Plastique granulé (PP) 0," })
    .getByRole("spinbutton")
    .fill("0.734065");
  await page.getByRole("button", { name: "Plastique granulé (PP)" }).click();
  await page.getByRole("option", { name: "Fibre de viscose" }).click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).click();
  await page.getByRole("option", { name: "Moulage par injection" }).click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).click();
  await page.getByRole("option", { name: /Transformation plastique/ }).click();
  await page.getByRole("button", { name: "Ajouter un élément" }).click();
  await page.getByRole("option", { name: "Acier", exact: true }).click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).nth(1).click();
  await page.getByRole("option", { name: "Transformation métallique (moyenne)" }).click();
  await page.getByRole("button", { name: "Ajouter un composant" }).click();
  await page.getByRole("option", { name: "Assise plastique (PP)" }).click();
  await page.getByRole("button", { name: "▶" }).click();
  await page.getByRole("button", { name: "Ajouter une transformation" }).nth(2).click();
  await page.getByRole("option", { name: "Moulage par injection" }).click();

  await expect(page.getByTestId("score-card")).toBeVisible();

  await expect(page.getByRole("row", { name: /Matières premières \d+,\d+ %/ })).toBeVisible();
  await expect(page.getByRole("row", { name: /Transformation \d+,\d+ %/ })).toBeVisible();
});
