const request = require("supertest");
const app = require("../server");

async function makeRequest(path, query = []) {
  return await request(app).get(path).query(query.join("&"));
}

function expectFieldErrorMessage(response, field, message) {
  expect(response.statusCode).toBe(400);
  expect("errors" in response.body).toEqual(true);
  expect(field in response.body.errors).toEqual(true);
  expect(response.body.errors[field]).toMatch(message);
}

const successQuery =
  // Minimalistic successful query params.
  // Note: it's important to pass query string parameters as actual strings here,
  // so we can test for actual qs parsing from the server.
  [
    "mass=0.17",
    "product=13",
    "material=f211bbdb-415c-46fd-be4d-ddf199575b44",
    "countries=CN,CN,CN,CN,FR",
  ];

describe("API server tests", () => {
  describe("Not found", () => {
    it("should render a 404 response", async () => {
      const response = await request(app).get("/xxx");

      expect(response.statusCode).toBe(404);
    });
  });

  describe("/", () => {
    it("should render the expected response", async () => {
      const response = await request(app).get("/");

      expect(response.statusCode).toBe(200);
      expect(response.body.service).toEqual("Wikicarbone");
    });
  });

  describe("/simulator/", () => {
    it("should validate a valid query", async () => {
      const response = await makeRequest("/simulator/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.impacts.cch).toBeGreaterThan(0);
    });

    it("should validate the mass param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["mass=-1"]),
        "mass",
        /supérieure ou égale à zéro/,
      );
    });

    it("should validate the material param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["material=xxx"]),
        "material",
        /matière manquant ou invalide/,
      );
    });

    it("should validate the product param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["product=xxx"]),
        "product",
        /produit manquant ou invalide/,
      );
    });

    it("should validate the countries param (length)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["countries=FR"]),
        "countries",
        /5 pays/,
      );
    });

    it("should validate the countries param (invalid codes)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["countries=FR,FR,XX,FR,FR"]),
        "countries",
        /Code pays invalide: XX/,
      );
    });

    it("should perform a simulation featuring 15 impacts", async () => {
      const response = await makeRequest("/simulator/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(15);
    });

    it("should validate the airTransportRatio param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/simulator/", ["airTransportRatio=2"]),
        "airTransportRatio",
        /entre 0 et 1/,
      );
    });
  });
});
