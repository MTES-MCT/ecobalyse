import { test, expect } from "@playwright/test";
import { deleteUser, registerAndLoginUser } from "./lib";
import impacts from "../public/data/impacts.json";

test.describe("Textile simulator", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.getByTestId("textile-callout-button").click();
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

  test("life cycle steps", async ({ page }) => {
    const lifeCycleSteps = page.getByTestId("life-cycle-steps");
    await expect(lifeCycleSteps).toBeVisible();

    const stepNames = await lifeCycleSteps.locator(".card-header h2").allInnerTexts();
    expect(stepNames).toHaveLength(8);
    expect(stepNames).toEqual([
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
      .getByTestId("life-cycle-steps")
      .getByRole("listitem")
      .filter({ hasText: "Titrage : 40 Nm (250 Dtex)" })
      .click();
  });

  test("impact selector", async ({ page }) => {
    const impactSelector = page.getByTestId("impact-selector");

    // When not logged in, the impact selector is not visible
    await expect(impactSelector).not.toBeVisible();

    // When logged in, the impact selector is visible
    await deleteUser("alice@cooper.com");
    await registerAndLoginUser(page, {
      email: "alice@cooper.com",
      firstName: "Alice",
      lastName: "Cooper",
      organization: { type: "individual" },
      optinEmail: false,
    });

    await page.goto("/");
    await page.getByTestId("textile-callout-button").click();

    await expect(impactSelector).toBeVisible();

    // Check that impact option list matches available impact definitions
    const impactOptions = await impactSelector.locator("option").allInnerTexts();
    expect(impactOptions).toHaveLength(Object.keys(impacts).length);
    for (const [_, { label_fr }] of Object.entries(impacts)) {
      expect(impactOptions).toContain(label_fr);
    }
  });
});
