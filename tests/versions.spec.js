require("expect-puppeteer");

describe("Homepage", () => {
  beforeAll(async () => {
    await page.goto("http://localhost:1234");
  });

  it('should display "Ecobalyse" header on page', async () => {
    await expect(page).toMatchTextContent(/Calculez le coût environnemental de vos produits/);
  });
});
