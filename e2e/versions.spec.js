// @ts-check
import { test, expect } from "@playwright/test";

test.describe("versions", () => {
  test("should be correctly displayed in the select box", async ({ page }) => {
    await page.goto("/");

    const options = page.getByTestId("version-selector").locator("option");

    await expect(options).toHaveText(["Version courante", "Version stable textile"]);
  });

  test("should redirect to the correct page version", async ({ page }) => {
    // Mock the api call before navigating

    await page.goto("/");

    // Single selection matching the value or label
    await page.getByTestId("version-selector").selectOption("v7.0.0");
    await page.waitForURL("**/versions/v7.0.0/#");

    expect(page.url()).toBe("http://localhost:1234/versions/v7.0.0/#");
  });
});
