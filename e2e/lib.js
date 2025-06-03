import { expect } from "@playwright/test";
import child_process from "node:child_process";

export async function checkEmails() {
  const res = await fetch("http://localhost:1081/email");
  const emails = await res.json();
  return emails.reverse();
}

export async function deleteAllEmails() {
  const res = await fetch("http://localhost:1081/email/all", { method: "DELETE" });
  return await res.json();
}

async function execSqlite(query) {
  return new Promise((resolve, reject) => {
    child_process.execFile("sqlite3", ["db.sqlite3", query], (error, stdout) => {
      if (error) {
        reject(error);
      } else {
        resolve(stdout);
      }
    });
  });
}

export async function deleteUser(email) {
  return await execSqlite(`delete from user_account where email='${email}'`);
}

export function extractUrlsFromText(text) {
  return text.match(/\bhttps?:\/\/\S+/gi);
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

  await page.getByTestId("auth-signup-submit").click();

  const lastEmail = await waitForNewEmail();

  await expect(page.getByText("Email de connexion envoyé")).toBeVisible();

  expect(lastEmail.subject).toContain("Lien de connexion à Ecobalyse");
  expect(lastEmail.headers.to).toBe("alice@cooper.com");
  const links = extractUrlsFromText(lastEmail.text).filter((url) => url.includes("/auth/"));
  expect(links).toHaveLength(1);

  await page.goto(links[0]);

  await expect(page.getByText("Vous avez désormais accès aux impacts détaillés")).toBeVisible();
}

async function waitFor(conditionFn, pollInterval = 50, timeoutAfter) {
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

export async function waitForNewEmail() {
  const initial = await checkEmails();
  return waitFor(async () => {
    const inbox = await checkEmails();
    if (inbox.length > initial.length) {
      return inbox[0];
    } else {
      return null;
    }
  });
}
