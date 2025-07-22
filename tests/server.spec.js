const fs = require("fs");
const request = require("supertest");
const app = require("../server");
const textileExamples = require("../public/data/textile/examples.json");

const e2eOutput = { food: [], textile: [] };

describe("Env", () => {
  it("should be a test environment", () => {
    // ensure the current test suite is run in the expected env!
    expect(process.env.NODE_ENV).toBe("test");
  });
});

describe("Web", () => {
  it("should render the homepage", async () => {
    const response = await request(app).get("/");

    expectStatus(response, 200, "text/html");
    expect(response.text).toContain("<title>Ecobalyse</title>");
  });
});

describe("API", () => {
  const textileQuery = {
    countryFabric: "CN",
    countryDyeing: "CN",
    countryMaking: "CN",
    mass: 0.17,
    materials: [
      { id: "ei-coton", share: 0.5 },
      { id: "ei-pet", share: 0.5 },
    ],
    product: "tshirt",
  };

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

      it("should respond with an HTTP 400 error on invalid JSON provided", async () => {
        const response = await request(app).post("/api/textile/simulator").type("json").send("}{");

        expectStatus(response, 400);
        expect(response.body).toHaveProperty("error");
        expect(response.body.error).toHaveProperty("decoding");
        expect(response.body.error.decoding).toMatch("Format JSON invalide");
      });
    });
  });

  describe("Textile", () => {
    describe("/textile/countries", () => {
      it("should render with textile countries list", async () => {
        await expectListResponseContains("/api/textile/countries", { code: "FR", name: "France" });
      });
    });

    describe("/materials", () => {
      it("should render with materials list", async () => {
        await expectListResponseContains("/api/textile/materials", {
          id: "ei-coton",
          name: "Coton",
        });
      });
    });

    describe("/products", () => {
      it("should render with products list", async () => {
        await expectListResponseContains("/api/textile/products", {
          id: "tshirt",
          name: "T-shirt / Polo",
        });
      });
    });

    describe("/simulator", () => {
      it("should accept a valid query", async () => {
        const response = await makePostRequest("/api/textile/simulator", textileQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.ecs).toBeGreaterThan(0);
      });

      it("should validate the mass param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", { ...textileQuery, mass: -1 }),
          "mass",
          /supérieure ou égale à zéro/,
        );
      });

      it("should validate the materials param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            materials: [{ id: "xxx", share: 1 }],
          }),
          "materials",
          /Matière non trouvée id=xxx/,
        );
      });

      it("should validate the product param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {}),
          "decoding",
          /a field named `product`/,
        );
      });

      it("should validate the countrySpinning param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            countrySpinning: "XX",
          }),
          "countrySpinning",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the countryFabric param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            countryFabric: "XX",
          }),
          "countryFabric",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the countryDyeing param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            countryDyeing: "XX",
          }),
          "countryDyeing",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the countryMaking param (invalid code)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            countryMaking: "XX",
          }),
          "countryMaking",
          /Code pays invalide: XX/,
        );
      });

      it("should validate the disabledSteps param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            disabledSteps: ["xxx"],
          }),
          "decoding",
          /Code étape inconnu: xxx/i,
        );
      });

      it("should validate the dyeingProcessType param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            dyeingProcessType: "xxx",
          }),
          "decoding",
          /Type de teinture inconnu : xxx/i,
        );
      });

      it("should perform a simulation featuring 21 impacts for textile", async () => {
        const response = await makePostRequest("/api/textile/simulator/", textileQuery);

        expectStatus(response, 200);
        expect(Object.keys(response.body.impacts)).toHaveLength(21);
      });

      it("should validate the airTransportRatio param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            airTransportRatio: 2,
          }),
          "decoding",
          /doit être compris(e) entre 0 et 1 inclus/,
        );
      });

      it("should validate the makingWaste param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            makingWaste: 0.9,
          }),
          "makingWaste",
          /doit être compris\(e\) entre/,
        );
      });

      it("should validate the makingDeadStock param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            makingDeadStock: 0.9,
          }),
          "makingDeadStock",
          /taux de stocks dormants(.*)doit être compris\(e\) entre/,
        );
      });

      it("should validate the makingComplexity param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            makingComplexity: "bad-complexity",
          }),
          "decoding",
          /Type de complexité de fabrication inconnu : bad-complexity/,
        );
      });

      it("should validate the yarnSize param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", { ...textileQuery, yarnSize: 0 }),
          "yarnSize",
          /titrage(.*)doit être compris\(e\) entre/,
        );
      });

      it("should validate the physicalDurability param range", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            physicalDurability: 2,
          }),
          "physicalDurability",
          /coefficient de durabilité(.*)doit être compris\(e\) entre/,
        );
      });

      it("should validate the fabricProcess param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            fabricProcess: "notAFabricProcess",
          }),
          "decoding",
          /Procédé de tissage\/tricotage inconnu: notAFabricProcess/,
        );
      });

      it("should validate the surfaceMass param", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", { ...textileQuery, surfaceMass: 10 }),
          "surfaceMass",
          /masse surfacique doit être compris\(e\) entre/,
        );
      });

      it("should validate the printing param kind", async () => {
        const response = await makePostRequest("/api/textile/simulator", {
          ...textileQuery,
          printing: { kind: "pigment", ratio: 0.8 },
        });
        expectStatus(response, 200);
      });

      it("should validate the printing param kind", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            printing: { kind: "bonk", ratio: 0.8 },
          }),
          "decoding",
          /Type d'impression inconnu: bonk/,
        );
      });

      it("should validate the printing param ratio (too high)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            printing: { kind: "pigment", ratio: 0.9 },
          }),
          "decoding",
          /doit être comprise entre 0 et 0.8/,
        );
      });

      it("should validate the printing param ratio (too low)", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/textile/simulator", {
            ...textileQuery,
            printing: { kind: "pigment", ratio: -1 },
          }),
          "decoding",
          /doit être comprise entre 0 et 0.8/,
        );
      });

      it("should validate multiple errored parameters", async () => {
        const response = await makePostRequest("/api/textile/simulator", {
          ...textileQuery,
          countryDyeing: "BadDyeingCode",
          countrySpinning: "BadSpinningCode",
        });

        expect(Object.keys(response.body.error)).toEqual(["countryDyeing", "countrySpinning"]);
      });
    });

    describe("/simulator/ecs", () => {
      it("should accept a valid query", async () => {
        const response = await makePostRequest("/api/textile/simulator/ecs", textileQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.ecs).toBeGreaterThan(0);
      });
    });

    describe("/simulator/detailed", () => {
      it("should accept a valid query", async () => {
        const response = await makePostRequest("/api/textile/simulator/detailed", textileQuery);

        expectStatus(response, 200);
        expect(response.body.lifeCycle).toHaveLength(8);
      });

      it("should expose impacts without durability", async () => {
        const response = await makePostRequest("/api/textile/simulator/detailed", textileQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.ecs > response.body.impactsWithoutDurability.ecs);
      });

      it("should compute pre-treatments", async () => {
        const tShirt = textileExamples.filter(
          ({ name }) => name === "Tshirt coton (150g) - Majorant par défaut",
        )[0];
        expect(tShirt).toBeTruthy();

        const response = await makePostRequest("/api/textile/simulator/detailed", tShirt.query);

        expectStatus(response, 200);

        const ennoblingStep = response.body.lifeCycle.filter(
          ({ label }) => label === "Ennoblissement",
        )[0];
        expect(ennoblingStep).toBeTruthy();

        // FIXME investigate why this has evolved before landing
        expect(ennoblingStep.preTreatments.impacts.ecs).toBeCloseTo(94.0048, 2);
      });
    });

    describe("End to end textile simulations", () => {
      const e2eTextile = require(`${__dirname}/e2e-textile.json`);

      for (const { name, query, impacts } of e2eTextile) {
        it(name, async () => {
          const response = await makePostRequest("/api/textile/simulator/detailed", query);
          e2eOutput.textile.push({
            name,
            query,
            impacts: response.status === 200 ? response.body.impacts : {},
          });
          expectStatus(response, 200);
          expect(response.body.impacts).toEqual(impacts);
        });
      }
    });

    describe("Changing the fabric process", () => {
      const jeanQuery = {
        mass: 0.45,
        product: "jean",
        fabricProcess: "weaving",
        materials: [{ id: "ei-coton", share: 1 }],
        countryFabric: "TR",
        countryDyeing: "TR",
        countryMaking: "TR",
        fading: true,
      };

      it("should change the waste", async () => {
        let response = await makePostRequest("/api/textile/simulator/detailed", jeanQuery);
        expectStatus(response, 200);
        let fabricLifeCycle = response.body.lifeCycle.find((l) => l.label == "Tissage & Tricotage");
        const weavingWaste = fabricLifeCycle.waste;

        response = await makePostRequest("/api/textile/simulator/detailed", {
          ...jeanQuery,
          fabricProcess: "knitting-mix",
        });
        expectStatus(response, 200);
        fabricLifeCycle = response.body.lifeCycle.find((l) => l.label == "Tissage & Tricotage");
        expect(fabricLifeCycle.waste).toBeLessThan(weavingWaste);
      });
    });

    describe("Textile product examples checks", () => {
      const textileExamples = require(`${__dirname}/../public/data/textile/examples.json`);

      for (const { name, query } of textileExamples) {
        it(name, async () => {
          const response = await makePostRequest("/api/textile/simulator", query);
          expect(response.body.error).toBeUndefined();
          expectStatus(response, 200);
        });
      }
    });
  });

  describe("Food", () => {
    describe("/food/countries", () => {
      it("should render with food countries list", async () => {
        await expectListResponseContains("/api/food/countries", { code: "FR", name: "France" });
      });
    });

    describe("/food/ingredients", () => {
      it("should render with ingredients list", async () => {
        await expectListResponseContains("/api/food/ingredients", {
          id: "8f3863e7-f981-4367-90a2-e1aaa096a6e0",
          name: "Lait FR",
          defaultOrigin: "France",
        });
      });
    });

    describe("/food/packagings", () => {
      it("should render with packagings list", async () => {
        await expectListResponseContains("/api/food/packagings", {
          id: "09b63a3c-b0b5-5907-8efd-775b8395f878",
          name: "PVC",
        });
      });
    });

    describe("/food/transforms", () => {
      it("should render with transforms list", async () => {
        await expectListResponseContains("/api/food/transforms", {
          id: "83b897cf-9ed2-5604-83b4-67fab8606d35",
          name: "Cuisson",
        });
      });
    });

    describe("/food", () => {
      describe("POST", () => {
        it("should compute 21 impacts", async () => {
          const response = await makePostRequest("/api/food", {
            ingredients: [
              { id: "9cbc31e9-80a4-4b87-ac4b-ddc051c47f69", mass: 120 },
              { id: "38788025-a65e-4edf-a92f-aab0b89b0d61", mass: 140 },
              { id: "8f3863e7-f981-4367-90a2-e1aaa096a6e0", mass: 60 },
              { id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 225 },
            ],
            transform: {
              id: "83b897cf-9ed2-5604-83b4-67fab8606d35",
              mass: 545,
            },
            packaging: [
              {
                id: "25595091-35b6-5c62-869f-a29c318c367e",
                mass: 105,
              },
            ],
            distribution: "ambient",
            preparation: ["refrigeration"],
          });

          expectStatus(response, 200);
          expect(Object.keys(response.body.results.total)).toHaveLength(21);
        });
      });

      it("should validate an ingredient id", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "invalid", mass: 268 }],
          }),
          "decoding",
          /Not a valid UUID/,
        );
      });

      it("should validate an ingredient mass", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: -1 }],
          }),
          "ingredients",
          /masse doit être supérieure ou égale à zéro/,
        );
      });

      it("should validate an ingredient country code", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [
              {
                country: "BadCountryCode",
                id: "4d5198e7-413a-4ae2-8448-535aa3b302ae",
                mass: 123,
              },
            ],
          }),
          "ingredients",
          /Code pays invalide: BadCountryCode/,
        );
      });

      it("should validate an ingredient transport by plane value", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [
              {
                byPlane: "badValue",
                country: "BR",
                id: "db0e5f44-34b4-4160-b003-77c828d75e60",
                mass: 123,
              },
            ],
          }),
          "decoding",
          /Transport par avion inconnu : badValue/,
        );
      });

      it("should validate an ingredient transport by plane", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [
              {
                byPlane: "byPlane",
                country: "BR",
                id: "4d5198e7-413a-4ae2-8448-535aa3b302ae",
                mass: 123,
              },
            ],
          }),
          "general",
          /Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas/,
        );
      });

      it("should validate a transform code", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            transform: { id: "invalid", mass: 268 },
          }),
          "decoding",
          /\"invalid\" Not a valid UUID/,
        );
      });

      it("should validate a transform mass", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            transform: { id: "83b897cf-9ed2-5604-83b4-67fab8606d35", mass: -1 },
          }),
          "transform",
          /masse doit être supérieure ou égale à zéro/,
        );
      });

      it("should validate a packaging code", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            packaging: [{ id: "invalid", mass: 10 }],
          }),
          "decoding",
          /\"invalid\" Not a valid UUID/,
        );
      });

      it("should validate a packaging mass", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            packaging: [{ id: "25595091-35b6-5c62-869f-a29c318c367e", mass: -1 }],
          }),
          "packaging",
          /masse doit être supérieure ou égale à zéro/,
        );
      });

      it("should validate a distribution storage type", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            distribution: "invalid",
          }),
          "decoding",
          /Choix invalide pour la distribution : invalid/,
        );
      });

      it("should validate a consumption preparation technique id", async () => {
        expectFieldErrorMessage(
          await makePostRequest("/api/food", {
            ingredients: [{ id: "4d5198e7-413a-4ae2-8448-535aa3b302ae", mass: 268 }],
            preparation: ["invalid"],
          }),
          "decoding",
          /Préparation inconnue: invalid/,
        );
      });
    });

    describe("End to end food simulations", () => {
      const e2eFood = require(`${__dirname}/e2e-food.json`);

      for (const { name, query, impacts, scoring } of e2eFood) {
        it(name, async () => {
          const response = await makePostRequest("/api/food", query);
          e2eOutput.food.push({
            name,
            query,
            impacts: response.status === 200 ? response.body.results.total : {},
            scoring: response.status === 200 ? response.body.results.scoring : {},
          });
          expectStatus(response, 200);

          // Add tolerance check for impacts
          Object.entries(impacts).forEach(([key, value]) => {
            expect(response.body.results.total[key]).toBeCloseTo(value, 12);
          });

          Object.entries(scoring).forEach(([key, value]) => {
            expect(response.body.results.scoring[key]).toBeCloseTo(value, 12);
          });
        });
      }
    });

    describe("Food product examples checks", () => {
      const foodExamples = require(`${__dirname}/../public/data/food/examples.json`);

      for (const { name, query } of foodExamples) {
        it(name, async () => {
          const response = await makePostRequest("/api/food", query);
          expect(response.body.error).toBeUndefined();
          expectStatus(response, 200);
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
    if (e2eOutput[key].length === 0) {
      console.error(`Not writing ${target} since it's empty`);
    } else {
      fs.writeFileSync(target, JSON.stringify(e2eOutput[key], null, 2) + "\n");
      console.info(`E2e ${key} tests output written to ${target}.`);
    }
  }

  writeE2eResult("textile");
  writeE2eResult("food");
});

// Test helpers

async function makePostRequest(path, body) {
  return await request(app).post(path).send(body);
}

function expectFieldErrorMessage(response, key, message) {
  expectStatus(response, 400);
  expect(response.body).toHaveProperty("error");
  expect(response.body.error).toHaveProperty(key);
  expect(response.body.error[key]).toMatch(message);
}

async function expectListResponseContains(path, object) {
  const response = await request(app).get(path);

  expectStatus(response, 200);
  expect(response.body).toContainObject(object);
}

function expectStatus(response, expectedCode, type = "application/json") {
  if (response.status === 400 && expectedCode != 400) {
    expect(response.body).toHaveProperty("error", "");
  }
  expect(response.type).toBe(type);
  expect(response.statusCode).toBe(expectedCode);
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
