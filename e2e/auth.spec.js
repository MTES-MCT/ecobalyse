// @ts-check
import { test, expect } from "@playwright/test";

test("magic link form", async ({ page }) => {
  await page.goto("/");

  await page.getByTestId("auth-link").click();

  await expect(page.getByTestId("auth-magic-link-form")).toBeVisible();
  await expect(page.getByTestId("auth-signup-form")).not.toBeVisible();

  await expect(page.getByTestId("auth-magic-link-submit")).toBeDisabled();
  await page.getByPlaceholder("nom@example.com").fill("alice@cooper.com");
  await expect(page.getByTestId("auth-magic-link-submit")).not.toBeDisabled();

  await page.getByTestId("auth-magic-link-submit").click();

  // TODO: have a user in the db
  // const res = await fetch("http://localhost:1081/email");
  // const emails = await res.json();
  // console.log(emails);
});

test("signup form", async ({ page }) => {
  await page.goto("/");

  await page.getByTestId("auth-link").click();
  await page.getByRole("button", { name: "Inscription" }).click();

  await expect(page.getByTestId("auth-signup-form")).toBeVisible();
  await expect(page.getByTestId("auth-magic-link-form")).not.toBeVisible();

  await expect(page.getByTestId("auth-signup-submit")).toBeDisabled();
  await page.getByPlaceholder("nom@example.com").fill("alice@cooper.com");
  await expect(page.getByTestId("auth-signup-submit")).not.toBeDisabled();

  await page.getByPlaceholder("Joséphine").fill("Alice");
  await page.getByPlaceholder("Durand").fill("Cooper");
  await page.getByRole("checkbox", { name: /^Je m’engage à respecter/ }).check();

  await page.getByTestId("auth-signup-submit").click();

  await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

  await page.waitForTimeout(100); // sadly no way to wait for the email to be sent

  const res = await fetch("http://localhost:1081/email");
  const emails = await res.json();
  expect(emails).toHaveLength(1);
  expect(emails[0].subject).toContain("Lien de connexion à Ecobalyse");
  expect(emails[0].headers.to).toBe("alice@cooper.com");
});
