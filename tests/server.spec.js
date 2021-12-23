const request = require("supertest");
const app = require("../server");

async function sampleSucessfulRequest(path) {
  return await request(app)
    .get(path)
    .query("mass=0.17")
    .query("product=13")
    .query("material=f211bbdb-415c-46fd-be4d-ddf199575b44")
    .query("countries[]=CN")
    .query("countries[]=CN")
    .query("countries[]=CN")
    .query("countries[]=CN")
    .query("countries[]=FR");
}

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

    it("should perform a simulation featuring 15 impacts", async () => {
      const response = await sampleSucessfulRequest("/simulator/");

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(15);
    });
  });

  describe("/simulator/<impact>/", () => {
    it("should validate input params", async () => {
      const response = await request(app).get("/simulator/fwe/");

      expect(response.statusCode).toBe(400);
      expect(response.body.error).toContain("Expecting an OBJECT with a field named `countries`");
    });

    it("should default to cch on unknown impact trigram", async () => {
      const response = await sampleSucessfulRequest("/simulator/xxx/");

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impact)).toEqual(["cch"]);
    });

    it("should perform a simulation featuring a single impact", async () => {
      const response = await sampleSucessfulRequest("/simulator/fwe/");

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

    it("should perform a simulation featuring 15 impacts", async () => {
      const response = await sampleSucessfulRequest("/simulator/detailed/");

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(15);
    });
  });
});
