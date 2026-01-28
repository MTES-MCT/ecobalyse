import { test, expect } from "@playwright/test";

test.describe("Textile simulator", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.getByLabel("Menu principal").getByRole("link", { name: "Textile" }).click();
  });

  test("score card", async ({ page }) => {
    const scoreCard = page.getByTestId("score-card");
    await expect(scoreCard).toBeVisible();

    // Score card text
    const scoreCardText = await scoreCard.textContent();
    expect(scoreCardText).toContain("Pts");
    expect(scoreCardText).toContain("hors durabilité");
    expect(scoreCardText).toContain("Pour 100g");

    // Score card score
    const score = parseFloat(await scoreCard.getAttribute("data-score"));
    expect(score).toBeGreaterThan(0);
  });

  test("exemples selector", async ({ page }) => {
    const scoreCard = page.getByTestId("score-card");
    const score = parseFloat(await scoreCard.getAttribute("data-score"));

    await page.getByRole("button", { name: "Exemples" }).click();
    await page.getByRole("option", { name: "Pull coton (550g) - Chine -" }).click();

    // TODO: find a better way to wait for the score to be greater than the previous one
    await page.waitForTimeout(50);
    const newScore = parseFloat(await scoreCard.getAttribute("data-score"));
    expect(newScore).toBeGreaterThan(score);
  });

  test("life cycle stages", async ({ page }) => {
    const lifeCycleStages = page.getByTestId("life-cycle-stages");
    await expect(lifeCycleStages).toBeVisible();

    const stageNames = await lifeCycleStages.locator(".card-header h2").allInnerTexts();
    expect(stageNames).toHaveLength(8);
    expect(stageNames).toEqual([
      "Matières premières",
      "Transformation - Filature",
      "Transformation - Tissage / Tricotage",
      "Transformation - Ennoblissement",
      "Transformation - Confection",
      "Distribution",
      "Utilisation",
      "Fin de vie",
    ]);
  });

  test("regulatory mode", async ({ page }) => {
    await page.getByRole("button", { name: "Mode exploratoire" }).click();

    await page
      .getByTestId("life-cycle-stages")
      .getByRole("listitem")
      .filter({ hasText: "Titrage : 40 Nm (250 Dtex)" })
      .click();
  });
});
