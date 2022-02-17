const fs = require("fs");
const request = require("supertest");
const app = require("../server");

const e2eOutput = [];

async function makeRequest(path, query = []) {
  return await request(app).get(path).query(query.join("&"));
}

describe("Web", () => {
  it("should render the homepage", async () => {
    const response = await request(app).get("/");

    expect(response.statusCode).toBe(200);
    expect(response.type).toEqual("text/html");
    expect(response.text).toContain("<title>wikicarbone</title>");
  });
});

describe("API", () => {
  const successQuery =
    // Successful query params.
    // Note: it's important to pass query string parameters as actual strings here,
    // so we can test for actual qs parsing from the server.
    [
      "mass=0.17",
      "product=tshirt",
      "materials[]=coton;0.5;0",
      "materials[]=acrylique;0.5;0",
      "countryFabric=CN",
      "countryDyeing=CN",
      "countryMaking=CN",
    ];

  function expectFieldErrorMessage(response, field, message) {
    expect(response.statusCode).toBe(400);
    expect("errors" in response.body).toEqual(true);
    expect(field in response.body.errors).toEqual(true);
    expect(response.body.errors[field]).toMatch(message);
  }

  describe("Not found", () => {
    it("should render a 404 response", async () => {
      const response = await request(app).get("/xxx");

      expect(response.statusCode).toBe(404);
    });
  });

  describe("/api", () => {
    it("should render the OpenAPI documentation", async () => {
      const response = await request(app).get("/api");

      expect(response.statusCode).toBe(200);
      expect(response.body.openapi).toEqual("3.0.1");
      expect(response.body.info.title).toEqual("API Wikicarbone");
    });
  });

  describe("/countries", () => {
    it("should render with countries list", async () => {
      const response = await request(app).get("/api/countries");

      expect(response.statusCode).toBe(200);
      expect(response.body).toContainObject({ code: "FR", name: "France" });
    });
  });

  describe("/materials", () => {
    it("should render with materials list", async () => {
      const response = await request(app).get("/api/materials");

      expect(response.statusCode).toBe(200);
      expect(response.body).toContainObject({
        id: "coton",
        name: "Fil de coton conventionnel, inventaire partiellement agrégé",
      });
    });
  });

  describe("/products", () => {
    it("should render with products list", async () => {
      const response = await request(app).get("/api/products");

      expect(response.statusCode).toBe(200);
      expect(response.body).toContainObject({ id: "tshirt", name: "T-shirt" });
    });
  });

  describe("/api/simulator", () => {
    it("should accept a valid query", async () => {
      const response = await makeRequest("/api/simulator", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.impacts.cch).toBeGreaterThan(0);
    });

    it("should validate the mass param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["mass=-1"]),
        "mass",
        /supérieure ou égale à zéro/
      );
    });

    it("should validate the materials param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["materials[]=xxx;1;0"]),
        "materials",
        /Matière non trouvée id=xxx/
      );
    });

    it("should validate the product param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["product=xxx"]),
        "product",
        /Produit non trouvé id=xxx/
      );
    });

    it("should validate the country params are present", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryFabric=FR,countryDyeing=FR"]),
        "countryMaking",
        /Code pays manquant/
      );
    });

    it("should validate the countryFabric param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryFabric=XX"]),
        "countryFabric",
        /Code pays invalide: XX/
      );
    });

    it("should validate the countryDyeing param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryDyeing=XX"]),
        "countryDyeing",
        /Code pays invalide: XX/
      );
    });

    it("should validate the countryMaking param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryMaking=XX"]),
        "countryMaking",
        /Code pays invalide: XX/
      );
    });

    it("should perform a simulation featuring 17 impacts", async () => {
      const response = await makeRequest("/api/simulator/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(17);
    });

    it("should validate the airTransportRatio param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["airTransportRatio=2"]),
        "airTransportRatio",
        /entre 0 et 1/
      );
    });
  });

  describe("/api/simulator/fwe", () => {
    it("should accept a valid query", async () => {
      const response = await makeRequest("/api/simulator/fwe", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.impacts.fwe).toBeGreaterThan(0);
    });
  });

  describe("/api/simulator/detailed", () => {
    it("should accept a valid query", async () => {
      const response = await makeRequest("/api/simulator/detailed", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.lifeCycle.length).toBe(7);
    });
  });
});

describe("End to end simulations", () => {
  const e2e = JSON.parse(fs.readFileSync(`${__dirname}/e2e.json`).toString());

  for (const { name, query, impacts } of e2e) {
    it(name, async () => {
      const response = await makeRequest("/api/simulator", query);
      expect(response.statusCode).toBe(200);
      expect(response.body.impacts).toEqual(impacts);
      e2eOutput.push({
        name,
        query,
        impacts: response.body.impacts,
      });
    });
  }
});

afterAll(() => {
  // Write the output result to a new file, in case we want to update the old one
  // with its contents.
  const target = `${__dirname}/e2e-output.json`;
  fs.writeFileSync(target, JSON.stringify(e2eOutput, null, 2));
  console.info(`E2e tests output written to ${target}.`);
});

// https://medium.com/@andrei.pfeiffer/jest-matching-objects-in-array-50fe2f4d6b98
expect.extend({
  toContainObject(received, argument) {
    if (this.equals(received, expect.arrayContaining([expect.objectContaining(argument)]))) {
      return {
        message: () =>
          `expected ${this.utils.printReceived(
            received
          )} not to contain object ${this.utils.printExpected(argument)}`,
        pass: true,
      };
    }
    return {
      message: () =>
        `expected ${this.utils.printReceived(
          received
        )} to contain object ${this.utils.printExpected(argument)}`,
      pass: false,
    };
  },
});
