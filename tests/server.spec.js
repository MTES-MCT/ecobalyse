const request = require("supertest");
const app = require("../server");

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

    it("should perform a simulation on default impact", async () => {
      const response = await request(app)
        .get("/simulator/")
        .query("mass=0.17")
        .query("product=13")
        .query("material=f211bbdb-415c-46fd-be4d-ddf199575b44")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=FR");

      expect(response.statusCode).toBe(200);
      expect(response.body.impact).toBeGreaterThan(0);
    });

    it("should perform a simulation on specific impact", async () => {
      const response = await request(app)
        .get("/simulator/")
        .query("impact=fwe")
        .query("mass=0.17")
        .query("product=13")
        .query("material=f211bbdb-415c-46fd-be4d-ddf199575b44")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=FR");

      expect(response.statusCode).toBe(200);
      expect(response.body.impact).toBeGreaterThan(0);
    });
  });

  describe("/simulator/all/", () => {
    it("should validate input params", async () => {
      const response = await request(app).get("/simulator/all/");
      expect(response.statusCode).toBe(400);
      expect(response.body.error).toContain("Expecting an OBJECT with a field named `countries`");
    });

    it("should retrieve all 15 impacts", async () => {
      const response = await request(app)
        .get("/simulator/all/")
        .query("mass=0.17")
        .query("product=13")
        .query("material=f211bbdb-415c-46fd-be4d-ddf199575b44")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=CN")
        .query("countries[]=FR");
      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body)).toHaveLength(15);
    });
  });
});
