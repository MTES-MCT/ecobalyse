// @ts-check
import { test, expect } from "@playwright/test";

test("magic link form", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await page.getByTestId("auth-link").click();

  await expect(page.getByTestId("auth-magic-link-form")).toBeVisible();
  await expect(page.getByTestId("auth-signup-form")).not.toBeVisible();

  await expect(page.getByTestId("auth-magic-link-submit")).toBeDisabled();
  await page.getByPlaceholder("nom@example.com").fill("test@example.com");
  await expect(page.getByTestId("auth-magic-link-submit")).not.toBeDisabled();
});

test("signup form", async ({ page }) => {
  await page.goto("http://localhost:1234");

  await page.getByTestId("auth-link").click();
  await page.getByRole("button", { name: "Inscription" }).click();

  await expect(page.getByTestId("auth-signup-form")).toBeVisible();
  await expect(page.getByTestId("auth-magic-link-form")).not.toBeVisible();

  await expect(page.getByTestId("auth-signup-submit")).toBeDisabled();
  await page.getByPlaceholder("nom@example.com").fill("test@example.com");
  await expect(page.getByTestId("auth-signup-submit")).not.toBeDisabled();
});
