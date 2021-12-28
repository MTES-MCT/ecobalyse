const request = require("supertest");
const app = require("../server");

async function makeRequest(path, query) {
  return await request(app).get(path).query(query);
}

const successQuery = {
  // Minimalistic successful query params.
  // Note: it's important to pass query string parameters as actual strings here,
  // so we can test for actual qs parsing from the server.
  mass: "0.17",
  product: "13",
  material: "f211bbdb-415c-46fd-be4d-ddf199575b44",
  countries: ["CN", "CN", "CN", "CN", "FR"],
};

describe("API server tests", () => {
  describe("/", () => {
    it("should render the expected response", async () => {
      const response = await request(app).get("/");

      expect(response.statusCode).toBe(200);
      expect(response.body.service).toEqual("Wikicarbone");
    });
  });

  describe("/simulator/", () => {
    it("should validate input params", async () => {
      const response = await request(app).get("/simulator/");

      expect(response.statusCode).toBe(400);
      expect(response.body.error).toContain("Expecting an OBJECT with a field named `countries`");
    });

    it("should perform a simulation featuring 16 impacts", async () => {
      const response = await makeRequest("/simulator/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(16);
    });

    it("should validate the mass parameter", async () => {
      const testQueries = [
        { ...successQuery, mass: "0" },
        { ...successQuery, mass: "-1" },
      ];

      for (const query of testQueries) {
        const response = await makeRequest("/simulator/", query);
        expect(response.statusCode).toBe(400);
        expect(response.body.error).toContain("La masse doit être strictement supérieure à zéro.");
      }
    });

    it("should validate the countries parameter", async () => {
      const testQueries = [
        { ...successQuery, countries: ["FR", "FR", "FR", "FR", "FR", "FR"] },
        { ...successQuery, countries: ["FR", "FR"] },
      ];

      for (const query of testQueries) {
        const response = await makeRequest("/simulator/", query);
        expect(response.statusCode).toBe(400);
        expect(response.body.error).toContain("La liste de pays doit contenir 5 pays.");
      }
    });

    it("should validate ratio parameters", async () => {
      const testQueries = [
        { ...successQuery, recycledRatio: "1.1" },
        { ...successQuery, recycledRatio: "-1" },
        { ...successQuery, airTransportRatio: "1.1" },
        { ...successQuery, airTransportRatio: "-1" },
        { ...successQuery, dyeingWeighting: "1.1" },
        { ...successQuery, dyeingWeighting: "-1" },
      ];

      for (const query of testQueries) {
        const response = await makeRequest("/simulator/", query);
        expect(response.statusCode).toBe(400);
        expect(response.body.error.map((s) => s.trim())).toContain("Un ratio doit être compris entre 0 et 1.");
      }
    });
  });

  describe("/simulator/<impact>/", () => {
    it("should validate input params", async () => {
      const response = await request(app).get("/simulator/fwe/");

      expect(response.statusCode).toBe(400);
      expect(response.body.error).toContain("Expecting an OBJECT with a field named `countries`");
    });

    it("should default to cch on unknown impact trigram", async () => {
      const response = await makeRequest("/simulator/xxx/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impact)).toEqual(["cch"]);
    });

    it("should perform a simulation featuring a single impact", async () => {
      const response = await makeRequest("/simulator/fwe/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impact)).toEqual(["fwe"]);
      expect(response.body.impact.fwe).toBeGreaterThan(0);
    });
  });

  describe("/simulator/detailed/", () => {
    it("should validate input params", async () => {
      const response = await request(app).get("/simulator/detailed/");

      expect(response.statusCode).toBe(400);
      expect(response.body.error).toContain("Expecting an OBJECT with a field named `countries`");
    });

    it("should perform a simulation featuring 16 impacts", async () => {
      const response = await makeRequest("/simulator/detailed/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(16);
    });
  });
});
