import { test, expect } from "@playwright/test";
import {
  loginUser,
  deleteAllEmails,
  extractUrlsFromText,
  registerAndLoginUser,
  waitForNewEmail,
} from "./lib";

import impacts from "../public/data/impacts.json";

test.describe("auth", () => {
  test.describe.configure({ mode: "serial" });

  test.beforeEach(async () => {
    await deleteAllEmails();
  });

  test("alice registers and signs in", async ({ page }) => {
    await test.step("register", async () => {
      await registerAndLoginUser(page, {
        email: "alice@cooper.com",
        firstName: "Alice",
        lastName: "Cooper",
        organization: { type: "individual" },
        optinEmail: false,
      });

      await expect(page.getByPlaceholder("Joséphine")).toHaveValue("Alice");
      await expect(page.getByPlaceholder("Durand")).toHaveValue("Cooper");
      await expect(page.getByPlaceholder("nom@example.com")).toHaveValue("alice@cooper.com");
      await expect(page.getByPlaceholder("ACME Inc.")).toHaveValue("Particulier");
      await expect(
        page.getByRole("checkbox", { name: /^J’accepte de recevoir/ }),
      ).not.toBeChecked();

      await expect(page.getByRole("button", { name: /^Mettre à jour/ })).toBeVisible();
    });

    await test.step("logout", async () => {
      await page.getByRole("button", { name: "Déconnexion" }).click();

      await expect(page.getByText("Vous avez été deconnecté")).toBeVisible();

      await expect(page.getByRole("link", { name: "Mon compte" })).not.toBeVisible();
    });

    await test.step("request a magic link and use it", async () => {
      await page.getByTestId("auth-link").click();

      await page.getByRole("button", { name: "Connexion", exact: true }).click();

      await expect(page.getByTestId("auth-magic-link-form")).toBeVisible();
      await expect(page.getByTestId("auth-signup-form")).not.toBeVisible();

      await expect(page.getByTestId("auth-magic-link-submit")).toBeDisabled();
      await page.getByPlaceholder("nom@example.com").fill("alice@cooper.com");
      await expect(page.getByTestId("auth-magic-link-submit")).not.toBeDisabled();

      await page.getByTestId("auth-magic-link-submit").click();

      const lastEmail = await waitForNewEmail();

      await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

      expect(lastEmail.subject).toContain("Lien de connexion à Ecobalyse");
      expect(lastEmail.headers.to).toBe("alice@cooper.com");
      const links = extractUrlsFromText(lastEmail.text).filter((url) => url.includes("/auth/"));
      expect(links).toHaveLength(1);

      await page.goto(links[0]);

      await expect(page.getByRole("heading", { name: "Mon compte" })).toBeVisible();
    });

    await test.step("browser reload and auto-login", async () => {
      await page.reload();

      await expect(page.getByRole("heading", { name: "Mon compte" })).toBeVisible();
    });

    await test.step("api tokens", async () => {
      await page.getByRole("link", { name: "Mon compte" }).click();

      await page.getByRole("button", { name: "Jetons d'API" }).click();

      await expect(page.getByText("Aucun jeton d'API actif")).toBeVisible();

      await page.getByRole("button", { name: "Créer un jeton d'API" }).click();

      await expect(
        page.getByRole("heading", { name: "Un nouveau jeton d'API a été créé" }),
      ).toBeVisible();

      const apiTokenField = page.getByTestId("auth-api-token");
      await expect(apiTokenField).not.toBeEmpty();
      const apiToken = await apiTokenField.inputValue();

      await page.getByRole("button", { name: "Retour à la liste des jetons" }).click();

      const apiTokensTable = page.getByTestId("auth-api-tokens-table");
      await expect(apiTokensTable).toBeVisible();
      await expect(apiTokensTable.locator("tbody tr")).toHaveCount(1);

      await expect(apiTokensTable.locator("tbody tr td:nth-child(2)")).toHaveText("Jamais utilisé");

      // Use token once
      const apiResponse = await fetch("http://localhost:1234/api/textile/simulator/detailed", {
        method: "POST",
        headers: { Authorization: `Bearer ${apiToken}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          mass: 0.17,
          materials: [{ id: "ei-coton", share: 1 }],
          product: "tshirt",
        }),
      });
      const apiResponseJson = await apiResponse.json();
      expect(apiResponseJson.impacts.cch).toBeGreaterThan(0);

      await page.reload();
      await page.getByRole("button", { name: "Jetons d'API" }).click();

      await expect(apiTokensTable.locator("tbody tr td:nth-child(2)")).not.toHaveText(
        "Jamais utilisé",
      );

      await page.getByRole("button", { name: "Supprimer ce jeton" }).click();

      await expect(
        page.getByRole("heading", { name: "Supprimer et invalider ce jeton d'API" }),
      ).toBeVisible();

      await expect(page.getByText("Dernière utilisation")).toBeVisible();

      await page.getByRole("button", { name: "Supprimer et invalider" }).click();

      await expect(page.getByText("Le jeton d'API a été supprimé")).toBeVisible();

      await expect(page.getByText("Aucun jeton d'API actif")).toBeVisible();

      // Try reusing the deleted token
      const apiResponse2 = await fetch("http://localhost:1234/api/textile/simulator/detailed", {
        method: "POST",
        headers: { Authorization: `Bearer ${apiToken}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          mass: 0.17,
          materials: [{ id: "ei-coton", share: 1 }],
          product: "tshirt",
        }),
      });
      const apiResponseJson2 = await apiResponse2.json();
      expect(apiResponseJson2.impacts.cch).toBe(0); // no detailed impact
    });

    await test.step("admin access", async () => {
      // alice can't see the admin button
      await expect(
        page.getByLabel("Menu principal").getByRole("link", { name: "Admin" }),
      ).not.toBeVisible();

      await page.goto("/#/auth"); // triggers user admin status reloading

      await page.getByRole("button", { name: "Déconnexion" }).click();

      // Bob is an admin
      await loginUser(page, "bob@dylan.com");

      await page.goto("/#/auth"); // triggers user admin status reloading

      await expect(
        page.getByLabel("Menu principal").getByRole("link", { name: "Admin" }),
      ).toBeVisible();

      await page.getByLabel("Menu principal").getByRole("link", { name: "Admin" }).click();

      await expect(page.getByRole("heading", { name: "Ecobalyse Admin" })).toBeVisible();
    });

    await test.step("impact selector", async () => {
      await page.goto("/#/auth"); // triggers user admin status reloading
      await page.getByRole("button", { name: "Déconnexion" }).click();
      await page.goto("/");
      await page.getByTestId("textile-callout-button").click();

      // When not logged in, the impact selector is not visible
      await expect(page.getByTestId("impact-selector")).not.toBeVisible();

      // When logged in, the impact selector is visible
      await loginUser(page, "bob@dylan.com");

      await page.goto("/");
      await page.getByTestId("textile-callout-button").click();

      await expect(page.getByTestId("impact-selector")).toBeVisible();

      // Check that impact option list matches available impact definitions
      const impactOptions = await page
        .getByTestId("impact-selector")
        .locator("option")
        .allInnerTexts();

      expect(impactOptions).toHaveLength(Object.keys(impacts).length);
      for (const [_, { label_fr }] of Object.entries(impacts)) {
        expect(impactOptions).toContain(label_fr);
      }
    });
  });
});
