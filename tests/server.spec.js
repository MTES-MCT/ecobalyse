const request = require("supertest");
const app = require("../server");

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
    // Minimalistic successful query params.
    // Note: it's important to pass query string parameters as actual strings here,
    // so we can test for actual qs parsing from the server.
    [
      "mass=0.17",
      "product=13",
      "material=f211bbdb-415c-46fd-be4d-ddf199575b44",
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

  describe("/api/simulator", () => {
    it("should validate a valid query", async () => {
      const response = await makeRequest("/api/simulator", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.impacts.cch).toBeGreaterThan(0);
    });

    it("should validate the mass param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["mass=-1"]),
        "mass",
        /supérieure ou égale à zéro/,
      );
    });

    it("should validate the material param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["material=xxx"]),
        "material",
        /Impossible de récupérer la matière uuid=xxx./,
      );
    });

    it("should validate the product param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["product=xxx"]),
        "product",
        /Produit non trouvé id=xxx./,
      );
    });

    it("should validate the country params are present", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryFabric=FR,countryDyeing=FR"]),
        "countryMaking",
        /Code pays manquant./,
      );
    });

    it("should validate the countryFabric param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryFabric=XX"]),
        "countryFabric",
        /Code pays invalide: XX./,
      );
    });

    it("should validate the countryDyeing param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryDyeing=XX"]),
        "countryDyeing",
        /Code pays invalide: XX./,
      );
    });

    it("should validate the countryMaking param (invalid code)", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["countryMaking=XX"]),
        "countryMaking",
        /Code pays invalide: XX./,
      );
    });


    it("should perform a simulation featuring 16 impacts", async () => {
      const response = await makeRequest("/api/simulator/", successQuery);

      expect(response.statusCode).toBe(200);
      expect(Object.keys(response.body.impacts)).toHaveLength(16);
    });

    it("should validate the airTransportRatio param", async () => {
      expectFieldErrorMessage(
        await makeRequest("/api/simulator", ["airTransportRatio=2"]),
        "airTransportRatio",
        /entre 0 et 1/,
      );
    });
  });

  describe("/api/simulator/fwe", () => {
    it("should validate a valid query", async () => {
      const response = await makeRequest("/api/simulator/fwe", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.impacts.fwe).toBeGreaterThan(0);
    });
  });

  describe("/api/simulator/detailed", () => {
    it("should validate a valid query", async () => {
      const response = await makeRequest("/api/simulator/detailed", successQuery);

      expect(response.statusCode).toBe(200);
      expect(response.body.lifeCycle.length).toBe(6);
    });
  });
});
