import { expect } from "@playwright/test";

export async function checkEmails() {
  const res = await fetch("http://localhost:1081/email");
  const emails = await res.json();
  return emails.reverse();
}

export async function deleteAllEmails() {
  const res = await fetch("http://localhost:1081/email/all", { method: "DELETE" });
  return await res.json();
}

export async function expectNotification(page, message) {
  await expect(page.locator(".ToastTray").getByText(message)).toBeVisible();
  // immediately close the notification to avoid unwanted accumulation
  await page.locator(".ToastTray").locator("button", { name: "Fermer" }).nth(0).click();
}

export function extractUrlsFromText(text) {
  return text.match(/\bhttps?:\/\/\S+/gi);
}

// On every full page load the app runs an async boot chain (detailed processes
// for a logged-in user, then the component config) and re-initializes the
// current page once the config lands, discarding any in-page state (selected
// tab, etc.) touched in the meantime. Interacting before that re-init is a race:
// wait for the network to go idle, which covers the whole chain including the
// fetches issued by the re-initialized page itself.
export async function reloadAndSettle(page) {
  await page.reload();
  await page.waitForLoadState("networkidle");
}

export async function loginUser(page, email) {
  await page.goto("/#/auth");

  await page.getByRole("button", { name: "Inscription" }).click();

  await page.getByRole("button", { name: "Connexion", exact: true }).click();

  await expect(page.getByTestId("auth-magic-link-form")).toBeVisible();
  await expect(page.getByTestId("auth-signup-form")).not.toBeVisible();

  await expect(page.getByTestId("auth-magic-link-submit")).toBeDisabled();
  await page.getByPlaceholder("nom@example.com").fill(email);
  await expect(page.getByTestId("auth-magic-link-submit")).not.toBeDisabled();

  const lastEmail = await actAndWaitForNewEmail(() =>
    page.getByTestId("auth-magic-link-submit").click(),
  );

  await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

  expect(lastEmail.subject).toContain("Lien de connexion à Ecobalyse");
  expect(lastEmail.headers.to).toBe(email);
  const links = extractUrlsFromText(lastEmail.text).filter((url) => url.includes("/auth/"));
  expect(links).toHaveLength(1);

  await page.goto(links[0]);

  await page.getByTestId("auth-login-confirm").click();

  await expectNotification(page, "Vous avez désormais accès aux impacts détaillés");
}

export async function registerAndLoginUser(
  page,
  { email, firstName, lastName, organization = { type: "individual" }, optinEmail = true },
) {
  await page.goto("/#/auth");

  await page.getByRole("button", { name: "Inscription" }).click();

  await expect(page.getByTestId("auth-signup-form")).toBeVisible();

  await page.getByPlaceholder("nom@example.com").fill(email);
  await page.getByPlaceholder("Joséphine").fill(firstName);
  await page.getByPlaceholder("Durand").fill(lastName);

  if (optinEmail) {
    await page.getByRole("checkbox", { name: /^J’accepte de recevoir des informations/ }).check();
  }

  // always accept terms
  await page.getByRole("checkbox", { name: /^Je m’engage à respecter/ }).check();
  await page.getByRole("checkbox", { name: /^Pour accéder aux impacts détaillés/ }).check();

  const lastEmail = await actAndWaitForNewEmail(() =>
    page.getByTestId("auth-signup-submit").click(),
  );

  await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

  expect(lastEmail.subject).toContain("Lien de connexion à Ecobalyse");
  expect(lastEmail.headers.to).toBe(email);
  const links = extractUrlsFromText(lastEmail.text).filter((url) => url.includes("/auth/"));
  expect(links).toHaveLength(1);

  await page.goto(links[0]);

  await page.getByTestId("auth-login-confirm").click();

  await expectNotification(page, "Vous avez désormais accès aux impacts détaillés");
}

export async function waitFor(conditionFn, pollInterval = 50, timeoutAfter) {
  const startTime = Date.now();
  while (true) {
    if (typeof timeoutAfter === "number" && Date.now() > startTime + timeoutAfter) {
      throw "Condition not met before timeout";
    }
    const result = await conditionFn();
    if (result) {
      return result;
    } else {
      await new Promise((resolve) => setTimeout(resolve, pollInterval));
    }
  }
}

// Run an action that triggers a transactional email and return that email.
// The inbox baseline is captured BEFORE the action: snapshotting it afterwards
// (as the previous helper did) races with email delivery — a fast email can land
// before we start watching, leaving the watcher waiting forever for a "next"
// email that never comes.
export async function actAndWaitForNewEmail(action) {
  const initialCount = (await checkEmails()).length;
  await action();
  return waitFor(async () => {
    const inbox = await checkEmails();
    return inbox.length > initialCount ? inbox[0] : null;
  });
}
