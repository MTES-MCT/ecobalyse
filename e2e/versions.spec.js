// @ts-check
import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  // Mock the api call before navigating
  await page.route("https://api.github.com/repos/MTES-MCT/ecobalyse/releases", async (route) => {
    const json = [
      {
        html_url: "https://github.com/MTES-MCT/ecobalyse/releases/tag/test_build",
        tag_name: "test_build",
        target_commitish: "master",
        name: "test_build",
        draft: false,
        prerelease: false,
        body: "",
      },
    ];
    const headers = {
      "Content-Type": "application/json",
      "access-control-allow-origin": "*",
      "content-security-policy": "default-src 'none'",
      server: "github.com",
    };
    await route.fulfill({ json, headers });
  });
});

test.describe("versions", () => {
  test("should be correctly displayed in the select box", async ({ page }) => {
    await page.goto("/");

    const options = page.getByTestId("version-selector").locator("option");

    await expect(options).toHaveText(["Unreleased", "test_build"]);
  });

  test("should redirect to the correct page version", async ({ page }) => {
    // Mock the api call before navigating

    await page.goto("/");

    // Single selection matching the value or label
    await page.getByTestId("version-selector").selectOption("test_build");
    await page.waitForURL("**/versions/test_build/#");

    expect(page.url()).toBe("http://localhost:1234/versions/test_build/#");

    await expect(page.getByText("Calculer l’impact de l’alimentation")).toBeVisible();

    await page.getByTestId("header-brand").click();

    expect(page.url()).toBe("http://localhost:1234/");

    await expect(page.getByText("Calculer l’impact de l’alimentation")).toBeVisible();
  });
});
