const fs = require("fs");
const request = require("supertest");
const app = require("../server");

const e2eOutput = { food: [], textile: [] };

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
  });

  describe("Textile", () => {
    const successQuery =
      // Successful query params.
      // Note: it's important to pass query string parameters as actual strings here,
      // so we can test for actual qs parsing from the server.
      [
        "mass=0.17",
        "product=tshirt",
        "fabricProcess=knitting-mix",
        "materials[]=ei-coton;0.5",
        "materials[]=ei-pet;0.5",
        "countryFabric=CN",
        "countryDyeing=CN",
        "countryMaking=CN",
      ];

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
      describe("GET", () => {
        it("should accept a valid query", async () => {
          const response = await makeRequest("/api/textile/simulator", successQuery);

          expectStatus(response, 200);
          expect(response.body.impacts.cch).toBeGreaterThan(0);
        });

        it("should validate the mass param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["mass=-1"]),
            "mass",
            /supérieure ou égale à zéro/,
          );
        });

        it("should validate the materials param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["materials[]=xxx;1"]),
            "materials",
            /Matière non trouvée id=xxx/,
          );
        });

        it("should validate the product param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", [
              "product=xxx",
              "fabricProcess=knitting-mix",
            ]),
            "product",
            /Produit non trouvé id=xxx/,
          );
        });

        it("should validate the country params are present", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["countryFabric=FR,countryDyeing=FR"]),
            "countryMaking",
            /Code pays manquant/,
          );
        });

        it("should validate the countryFabric param (invalid code)", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["countryFabric=XX"]),
            "countryFabric",
            /Code pays invalide: XX/,
          );
        });

        it("should validate the countryDyeing param (invalid code)", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["countryDyeing=XX"]),
            "countryDyeing",
            /Code pays invalide: XX/,
          );
        });

        it("should validate the countryMaking param (invalid code)", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["countryMaking=XX"]),
            "countryMaking",
            /Code pays invalide: XX/,
          );
        });

        it("should validate the disabledSteps param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["disabledSteps=xxx"]),
            "disabledSteps",
            /Code étape inconnu: xxx/i,
          );
        });

        it("should validate the dyeingMedium param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["dyeingMedium=xxx"]),
            "dyeingMedium",
            /support de teinture inconnu: xxx/i,
          );
        });

        it("should perform a simulation featuring 21 impacts for textile", async () => {
          const response = await makeRequest("/api/textile/simulator/", successQuery);

          expectStatus(response, 200);
          expect(Object.keys(response.body.impacts)).toHaveLength(21);
        });

        it("should validate the airTransportRatio param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["airTransportRatio=2"]),
            "airTransportRatio",
            /doit être compris entre/,
          );
        });

        it("should validate the makingWaste param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["makingWaste=0.9"]),
            "makingWaste",
            /doit être compris entre/,
          );
        });

        it("should validate the makingDeadStock param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["makingDeadStock=0.9"]),
            "makingDeadStock",
            /doit être compris entre/,
          );
        });

        it("should validate the makingComplexity param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["makingComplexity=bad-complexity"]),
            "makingComplexity",
            /Type de complexité de fabrication inconnu : bad-complexity/,
          );
        });

        it("should validate the yarnSize param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["yarnSize=0"]),
            "yarnSize",
            /doit être compris entre/,
          );
        });

        it("should validate the yarnSize param in Nm", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["yarnSize=0Nm"]),
            "yarnSize",
            /doit être compris entre/,
          );
        });

        it("should validate the yarnSize param in Dtex", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["yarnSize=0Dtex"]),
            "yarnSize",
            /doit être compris entre/,
          );
        });

        it("should validate the yarnSize param unit", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["yarnSize=0BadUnit"]),
            "yarnSize",
            /Le format ne correspond pas au titrage \(yarnSize\) attendu : soit un entier simple \(ie : `40`\), ou avec l'unité `Nm` \(ie : `40Nm`\) ou `Dtex` \(ie : `250Dtex`\)/,
          );
        });

        it("should accept the yarnSize param without any unit", async () => {
          const response = await makeRequest("/api/textile/simulator", ["yarnSize=9"]);
        });

        it("should accept the yarnSize param in Nm", async () => {
          const response = await makeRequest("/api/textile/simulator", ["yarnSize=9Nm"]);
        });

        it("should accept the yarnSize param in Dtex", async () => {
          const response = await makeRequest("/api/textile/simulator", ["yarnSize=9Dtex"]);
        });

        it("should validate the fabricProcess param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["fabricProcess=notAFabricProcess"]),
            "fabricProcess",
            /Procédé de tissage\/tricotage inconnu: notAFabricProcess/,
          );
        });

        it("should validate the surfaceMass param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["surfaceMass=10"]),
            "surfaceMass",
            /doit être compris entre/,
          );
        });

        it("should validate the fading param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["fading=untrue"]),
            "fading",
            /ne peut être que true ou false/,
          );
        });

        it("should validate the printing param", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/textile/simulator", ["printing=bonk"]),
            "printing",
            /Format de type et surface d'impression invalide: bonk/,
          );
        });
      });

      describe("POST", () => {
        it("should compute 21 impacts", async () => {
          const response = await makePostRequest("/api/textile/simulator", {
            mass: 0.17,
            materials: [{ id: "ei-coton", share: 1 }],
            product: "tshirt",
            fabricProcess: "knitting-mix",
            countrySpinning: "BD",
            countryFabric: "TR",
            countryDyeing: "TR",
            countryMaking: "BD",
            airTransportRatio: 0.5,
            durability: 1.2,
            reparability: 1.2,
            makingWaste: null,
            makingComplexity: null,
            yarnSize: null,
            surfaceMass: null,
            knittingProcess: null,
            disabledSteps: ["use"],
          });
          expectStatus(response, 200);
          expect(Object.keys(response.body.impacts)).toHaveLength(21);
        });
      });
    });

    describe("/simulator/fwe", () => {
      it("should accept a valid query", async () => {
        const response = await makeRequest("/api/textile/simulator/fwe", successQuery);

        expectStatus(response, 200);
        expect(response.body.impacts.fwe).toBeGreaterThan(0);
      });
    });

    describe("/simulator/detailed", () => {
      it("should accept a valid query", async () => {
        const response = await makeRequest("/api/textile/simulator/detailed", successQuery);

        expectStatus(response, 200);
        expect(response.body.lifeCycle).toHaveLength(8);
      });
    });

    describe("End to end textile simulations", () => {
      const e2eTextile = require(`${__dirname}/e2e-textile.json`);

      for (const { name, query, impacts } of e2eTextile) {
        it(name, async () => {
          const response = await makeRequest("/api/textile/simulator", query);
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
          id: "milk",
          name: "Lait",
          defaultOrigin: "Europe et Maghreb",
        });
      });
    });

    describe("/food/transforms", () => {
      it("should render with transforms list", async () => {
        await expectListResponseContains("/api/food/transforms", {
          code: "AGRIBALU000000003103966",
          name: "Cuisson",
        });
      });
    });

    describe("/food", () => {
      describe("GET", () => {
        it("should compute 21 impacts for food", async () => {
          const response = await makeRequest("/api/food", [
            "ingredients[]=carrot-fr;268",
            "transform=AGRIBALU000000003103966;1050",
            "distribution=ambient",
          ]);

          expectStatus(response, 200);
          expect(Object.keys(response.body.results.total)).toHaveLength(21);
        });

        it("should validate an ingredient id", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["ingredients[]=invalid;268"]),
            "ingredients",
            /Ingrédient introuvable par id : invalid/,
          );
        });

        it("should validate an ingredient mass", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["ingredients[]=carrot-fr;-1"]),
            "ingredients",
            /masse doit être supérieure ou égale à zéro/,
          );
        });

        it("should validate an ingredient country code", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["ingredients[]=carrot-fr;123;BadCountryCode"]),
            "ingredients",
            /Code pays invalide: BadCountryCode/,
          );
        });

        it("should validate an ingredient transport by plane value", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["ingredients[]=mango-non-eu;123;BR;badValue"]),
            "ingredients",
            /La valeur ne peut être que parmi les choix suivants: '', 'byPlane', 'noPlane'./,
          );
        });

        it("should validate an ingredient transport by plane", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["ingredients[]=carrot-fr;123;BR;byPlane"]),
            "ingredients",
            /Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas./,
          );
        });

        it("should validate a transform code", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["transform=invalid;268"]),
            "transform",
            /Procédé introuvable par code : invalid/,
          );
        });

        it("should validate a transform mass", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["transform=AGRIBALU000000003103966;-1"]),
            "transform",
            /masse doit être supérieure ou égale à zéro/,
          );
        });

        it("should validate a packaging code", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["packaging[]=invalid;268"]),
            "packaging",
            /Procédé introuvable par code : invalid/,
          );
        });

        it("should validate a packaging mass", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["packaging[]=AGRIBALU000000003104019;-1"]),
            "packaging",
            /masse doit être supérieure ou égale à zéro/,
          );
        });

        it("should validate a distribution storage type", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["distribution=invalid"]),
            "distribution",
            /Choix invalide pour la distribution : invalid/,
          );
        });

        it("should validate a consumption preparation technique id", async () => {
          expectFieldErrorMessage(
            await makeRequest("/api/food", ["preparation[]=invalid"]),
            "preparation",
            /Préparation inconnue: invalid/,
          );
        });
      });

      describe("POST", () => {
        it("should compute 21 impacts", async () => {
          const response = await makePostRequest("/api/food", {
            ingredients: [
              { id: "egg-indoor-code3", mass: 0.12 },
              { id: "soft-wheat-fr", mass: 0.14 },
              { id: "milk", mass: 0.06 },
              { id: "carrot-fr", mass: 0.225 },
            ],
            transform: {
              code: "AGRIBALU000000003103966",
              mass: 0.545,
            },
            packaging: [
              {
                code: "AGRIBALU000000003104019",
                mass: 0.105,
              },
            ],
            distribution: "ambient",
            preparation: ["refrigeration"],
          });

          expectStatus(response, 200);
          expect(Object.keys(response.body.results.total)).toHaveLength(21);
        });
      });
    });

    describe("End to end food simulations", () => {
      const e2eFood = require(`${__dirname}/e2e-food.json`);

      for (const { name, query, impacts, scoring } of e2eFood) {
        it(name, async () => {
          const response = await makeRequest("/api/food", query);
          e2eOutput.food.push({
            name,
            query,
            impacts: response.status === 200 ? response.body.results.total : {},
            scoring: response.status === 200 ? response.body.results.scoring : {},
          });
          expectStatus(response, 200);
          expect(response.body.results.total).toEqual(impacts);
          expect(response.body.results.scoring).toEqual(scoring);
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

async function makeRequest(path, query = []) {
  return await request(app).get(path).query(query.join("&"));
}

async function makePostRequest(path, body) {
  return await request(app).post(path).send(body);
}

function expectFieldErrorMessage(response, field, message) {
  expectStatus(response, 400);
  expect("errors" in response.body).toEqual(true);
  expect(field in response.body.errors).toEqual(true);
  expect(response.body.errors[field]).toMatch(message);
}

async function expectListResponseContains(path, object) {
  const response = await request(app).get(path);

  expectStatus(response, 200);
  expect(response.body).toContainObject(object);
}

function expectStatus(response, expectedCode, type = "application/json") {
  if (response.status === 400 && expectedCode != 400) {
    expect(response.body).toHaveProperty("errors", "");
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
