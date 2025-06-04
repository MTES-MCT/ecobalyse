import { test, expect } from "@playwright/test";
import {
  registerAndLoginUser,
  deleteAllEmails,
  extractUrlsFromText,
  deleteUser,
  waitForNewEmail,
} from "./lib";

test.describe("auth", () => {
  test.beforeEach(async () => {
    await deleteAllEmails();
  });

  test("alice registers and signs in", async ({ page }) => {
    await test.step("register", async () => {
      // ensure user doesn't exist (race condition)
      await deleteUser("alice@cooper.com");

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

      await expect(page.getByTestId("auth-api-token")).not.toBeEmpty();

      await page.getByRole("button", { name: "Retour à la liste des jetons" }).click();

      const apiTokensTable = page.getByTestId("auth-api-tokens-table");
      await expect(apiTokensTable).toBeVisible();
      await expect(apiTokensTable.locator("tbody tr")).toHaveCount(1);

      await expect(apiTokensTable.locator("tbody tr td:nth-child(2)")).toHaveText("Jamais utilisé");

      await page.getByRole("button", { name: "Supprimer ce jeton" }).click();

      await expect(
        page.getByRole("heading", { name: "Supprimer et invalider ce jeton d'API" }),
      ).toBeVisible();

      await expect(page.getByText("Le token n'a jamais été utilisé")).toBeVisible();

      await page.getByRole("button", { name: "Supprimer et invalider" }).click();

      await expect(page.getByRole("heading", { name: "Jeton d'API supprimé" })).toBeVisible();

      await expect(page.getByText("Aucun jeton d'API actif")).toBeVisible();
    });
  });
});
