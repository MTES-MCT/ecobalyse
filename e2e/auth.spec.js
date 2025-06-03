import { test, expect } from "@playwright/test";
import { registerAndLoginUser, checkEmails, extractUrlsFromText, deleteUser } from "./lib";

test.describe("auth", () => {
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
    });

    await test.step("request a magic link", async () => {
      await page.getByTestId("auth-link").click();

      await page.getByRole("button", { name: "Connexion", exact: true }).click();

      await expect(page.getByTestId("auth-magic-link-form")).toBeVisible();
      await expect(page.getByTestId("auth-signup-form")).not.toBeVisible();

      await expect(page.getByTestId("auth-magic-link-submit")).toBeDisabled();
      await page.getByPlaceholder("nom@example.com").fill("alice@cooper.com");
      await expect(page.getByTestId("auth-magic-link-submit")).not.toBeDisabled();

      await page.getByTestId("auth-magic-link-submit").click();

      await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

      await page.waitForTimeout(1000); // sadly no way to wait for the email to be sent
    });

    await test.step("check mail for magic link and open it", async () => {
      const emails = await checkEmails();
      expect(emails).toHaveLength(2);
      expect(emails[0].subject).toContain("Lien de connexion à Ecobalyse");
      expect(emails[0].headers.to).toBe("alice@cooper.com");
      const links = extractUrlsFromText(emails[0].text).filter((url) => url.includes("/auth/"));
      expect(links).toHaveLength(1);

      await page.goto(links[0]);

      await expect(page.getByRole("heading", { name: "Mon compte" })).toBeVisible();
    });
  });
});
