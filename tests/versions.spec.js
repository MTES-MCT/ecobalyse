require("expect-puppeteer");

describe("Homepage", () => {
  // Use the class selector for the select box
  const selectBoxSelector = ".VersionSelector";

  beforeAll(async () => {
    page.setDefaultTimeout(10000);

    // Enable request interception
    await page.setRequestInterception(true);

    // Intercept the request to the GitHub releases API
    page.on("request", (request) => {
      if (request.url() === "https://api.github.com/repos/MTES-MCT/ecobalyse/releases") {
        const response = {
          status: 200,
          headers: {
            "Content-Type": "application/json",
            "access-control-allow-origin": "*",
            "content-security-policy": "default-src 'none'",
            server: "github.com",
          },
          body: JSON.stringify([
            {
              html_url: "https://github.com/MTES-MCT/ecobalyse/releases/tag/test_build",
              tag_name: "test_build",
              target_commitish: "master",
              name: "test_build",
              draft: false,
              body: "",
            },
          ]),
        };
        // Respond with mock data
        request.respond(response);
      } else if (!request.url().includes("localhost:1234")) {
        // Abort all requests to the outside to avoid unnecessary network calls
        request.abort();
      } else {
        // Allow other requests to proceed as normal
        request.continue();
      }
    });

    await page.goto("http://localhost:1234");
  });

  it('should display "Ecobalyse" header on page', async () => {
    await expect(page).toMatchTextContent(/Calculez le coût environnemental de vos produits/);
  }, 10000);

  it("should have the correct options in the select box", async () => {
    // Wait for the releases network request that populates the select box
    await page.waitForSelector(selectBoxSelector, { visible: true });

    // Wait for the options to be populated
    await page.waitForFunction(
      (selector) => document.querySelectorAll(selector).length > 1,
      {},
      `${selectBoxSelector} option`,
    );

    // Get the options from the select box
    const options = await page.$$eval(`${selectBoxSelector} option`, (options) =>
      options.map((option) => option.textContent),
    );

    // Check the expected options
    const expectedOptions = ["Unreleased", "test_build"];
    expect(options).toEqual(expect.arrayContaining(expectedOptions));
  }, 10000);

  it('should navigate to the correct URL and display the link after selecting "test_build"', async () => {
    // Wait for the releases network request that populates the select box
    await page.waitForSelector(selectBoxSelector, { visible: true });

    // Wait for the options to be populated
    await page.waitForFunction(
      (selector) => document.querySelectorAll(selector).length > 1,
      {},
      `${selectBoxSelector} option`,
    );
    // Click on the option containing "test_build"
    await page.select(selectBoxSelector, "test_build"); // Use the value attribute of the option if available

    // Wait for navigation to complete
    await page.waitForNavigation();

    // Check that the URL is correct
    expect(page.url()).toBe("http://localhost:1234/versions/test_build/#");

    // Wait for the link to be visible
    const linkSelector = "a"; // Adjust the selector if necessary
    await page.waitForSelector(linkSelector, { visible: true });

    // Check that the link contains the expected text
    await expect(page).toMatchTextContent(/Calculer l’impact de l’alimentation/);

    const headerLinkSelector = "a.HeaderBrand";

    // Check going back to home
    await page.waitForSelector(headerLinkSelector, { visible: true });

    // Click the HeaderBrand link
    await page.click(headerLinkSelector);

    // Check that the URL is now back to the homepage
    expect(page.url()).toBe("http://localhost:1234/");

    await expect(page).toMatchTextContent(/Calculer l’impact de l’alimentation/, {
      timeout: 50000,
    });
  }, 10000);
});
