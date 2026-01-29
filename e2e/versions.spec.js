// @ts-check
import { test, expect } from "@playwright/test";

test.describe("versions", () => {
  test("should be correctly displayed in the select box", async ({ page }) => {
    await page.goto("/");

    const options = page.getByTestId("version-selector").locator("option");

    await expect(options).toHaveText(["Version courante", "Version stable textile"]);
  });
});
