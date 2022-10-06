const fs = require("fs");
const request = require("supertest");
const app = require("../server");

const e2eOutput = { food: [], textile: [] };

async function makeRequest(path, query = []) {
  return await request(app).get(path).query(query.join("&"));
}

function expectFieldErrorMessage(response, field, message) {
  expectStatus(response, 400);
  expect("errors" in response.body).toEqual(true);
  expect(field in response.body.errors).toEqual(true);
  expect(response.body.errors[field]).toMatch(message);
}

function toComparable(impacts) {
  return Object.keys(impacts)
    .sort()
    .map((trigram) => {
      return { [trigram]: impacts[trigram] };
    });
}

describe("Web", () => {
  it("should render the homepage", async () => {
    const response = await request(app).get("/");

    expectStatus(response, 200, "text/html");
    expect(response.text).toContain("<title>Ecobalyse</title>");
  });
});

describe("API", () => {
  describe("Not found", () => {
    it("should render a 404 response", async () => {
      const response = await request(app).get("/xxx");

      expectStatus(response, 404, "text/html");
    });
  });

  describe("Common", () => {
    describe("/api", () => {
      it("should render the OpenAPI documentation", async () => {
        const response = await request(app).get("/api");

        expectStatus(response, 200);
        expect(response.body.openapi).toEqual("3.0.1");
        expect(response.body.info.title).toEqual("API Ecobalyse");
      });
    });

    describe("/countries", () => {
      it("should render with countries list", async () => {
        const response = await request(app).get("/api/countries");

        expectStatus(response, 200);
        expect(response.body).toContainObject({ code: "FR", name: "France" });
      });
    });
  });

  describe("Textile", () => {
    const successQuery =
      // Successful query params.
      // Note: it's important to pass query string parameters as actual strings here,
      // so we can test for actual qs parsing from the server.
      [
        "mass=0.17",
        "product=tshirt",
        "materials[]=coton;0.5",
        "materials[]=acrylique;0.5",
        "countryFabric=CN",
        "countryDyeing=CN",
        "countryMaking=CN",
      ];
    describe("/materials", () => {
      it("should render with materials list", async () => {
        const response = await request(app).get("/api/materials");

        expectStatus(response, 200);
        expect(response.body).toContainObject({
          id: "coton",
          name: "Fil de coton conventionnel, inventaire partiellement agrégé",
        });
      });
    });

    describe("/products", () => {
      it("should render with products list", async () => {
        const response = await request(app).get("/api/products");

        expectStatus(response, 200);
        expect(response.body).toContainObject({ id: "tshirt", name: "T-shirt" });
      });
    });

    describe("/simulator", () => {
      it("should accept a valid query", async () => {
        const response = await makeRequest("/api/simulator", successQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.cch).toBeGreaterThan(0);
      });

      it("should validate the mass param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["mass=-1"]),
          "mass",
          /supérieure ou égale à zéro/,
        );
      });

      it("should validate the materials param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["materials[]=xxx;1"]),
          "materials",
          /Matière non trouvée id=xxx/,
        );
      });

      it("should validate the product param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["product=xxx"]),
          "product",
          /Produit non trouvé id=xxx/,
        );
      });

      it("should validate the country params are present", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["countryFabric=FR,countryDyeing=FR"]),
          "countryMaking",
          /Code pays manquant/,
        );
      });

      it("should validate the countryFabric param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["countryFabric=XX"]),
          "countryFabric",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the countryDyeing param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["countryDyeing=XX"]),
          "countryDyeing",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the countryMaking param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["countryMaking=XX"]),
          "countryMaking",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the disabledSteps param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["disabledSteps=xxx"]),
          "disabledSteps",
          /Code étape inconnu: xxx/i,
        );
      });

      it("should perform a simulation featuring 20 impacts", async () => {
        const response = await makeRequest("/api/simulator/", successQuery);

        expectStatus(response, 200);
        expect(Object.keys(response.body.impacts)).toHaveLength(20);
      });

      it("should validate the airTransportRatio param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["airTransportRatio=2"]),
          "airTransportRatio",
          /doit être compris entre/,
        );
      });

      it("should validate the makingWaste param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["makingWaste=0.9"]),
          "makingWaste",
          /doit être compris entre/,
        );
      });

      it("should validate the picking param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["picking=10"]),
          "picking",
          /doit être compris entre/,
        );
      });

      it("should validate the surfaceMass param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["surfaceMass=10"]),
          "surfaceMass",
          /doit être compris entre/,
        );
      });

      it("should validate the disabledFading param", async () => {
        expectFieldErrorMessage(
          await makeRequest("/api/simulator", ["disabledFading=untrue"]),
          "disabledFading",
          /ne peut être que true ou false/,
        );
      });
    });

    describe("/simulator/fwe", () => {
      it("should accept a valid query", async () => {
        const response = await makeRequest("/api/simulator/fwe", successQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.fwe).toBeGreaterThan(0);
      });
    });

    describe("/simulator/detailed", () => {
      it("should accept a valid query", async () => {
        const response = await makeRequest("/api/simulator/detailed", successQuery);

        expectStatus(response, 200);
        expect(response.body.lifeCycle).toHaveLength(8);
      });
    });

    describe("End to end textile simulations", () => {
      const e2eTextile = JSON.parse(fs.readFileSync(`${__dirname}/e2e-textile.json`).toString());

      for (const { name, query, impacts } of e2eTextile) {
        it(name, async () => {
          const response = await makeRequest("/api/simulator", query);
          expectStatus(response, 200);
          e2eOutput.textile.push({
            name,
            query,
            impacts: response.body.impacts,
          });
          expect(toComparable(response.body.impacts)).toEqual(toComparable(impacts));
        });
      }
    });
  });

  describe("Food", () => {
    describe("End to end food simulations", () => {
      const e2eFood = JSON.parse(fs.readFileSync(`${__dirname}/e2e-food.json`).toString());

      for (const { name, query, impacts } of e2eFood) {
        it(name, async () => {
          const response = await makeRequest("/api/food/recipe", query);
          expectStatus(response, 200);
          e2eOutput.food.push({
            name,
            query,
            impacts: response.body.impacts,
          });
          expect(toComparable(response.body.impacts)).toEqual(toComparable(impacts));
        });
      }
    });
  });
});

afterAll(() => {
  // Write the output results to new files, in case we want to update the old ones
  // with their contents.
  function writeE2eResult(key) {
    const target = `${__dirname}/e2e-${key}-output.json`;
    fs.writeFileSync(target, JSON.stringify(e2eOutput[key], null, 2));
    console.info(`E2e ${key} tests output written to ${target}.`);
  }

  writeE2eResult("textile");
  writeE2eResult("food");
});

function expectStatus(response, code, type = "application/json") {
  expect(response.type).toBe(type);
  expect(response.statusCode).toBe(code);
}

// https://medium.com/@andrei.pfeiffer/jest-matching-objects-in-array-50fe2f4d6b98
expect.extend({
  toContainObject(received, argument) {
    if (this.equals(received, expect.arrayContaining([expect.objectContaining(argument)]))) {
      return {
        message: () =>
          `expected ${this.utils.printReceived(
            received,
          )} not to contain object ${this.utils.printExpected(argument)}`,
        pass: true,
      };
    }
    return {
      message: () =>
        `expected ${this.utils.printReceived(
          received,
        )} to contain object ${this.utils.printExpected(argument)}`,
      pass: false,
    };
  },
});
