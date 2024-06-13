const fs = require("fs");
const textileExamples = require(`${__dirname}/../public/data/textile/examples.json`);
const foodExamples = require(`${__dirname}/../public/data/food/examples.json`);
const request = require("supertest");
const app = require("../server");

function findInvariantToken() {
  if (!process.env.BACKEND_ADMINS) {
    console.log(
      "BACKEND_ADMINS environment variable is not defined. Please check your .env file or environment configuration.",
    );
    return null;
  }

  const admins = process.env.BACKEND_ADMINS.split(",");
  for (let admin of admins) {
    const parts = admin.split("=");
    if (parts.length > 1 && parts[1]) {
      return parts[1];
    }
  }
  console.log("No invariant tokens found in BACKEND_ADMINS");
  return null;
}

const invariant_token = findInvariantToken();

describe("Textile product examples score computation", () => {
  const results = [];

  for (const example of textileExamples) {
    it(example.name, async () => {
      const response = await makePostRequest("/api/textile/simulator/detailed", example.query);

      results.push({
        ...example,
        response: response.status === 200 ? response.body : {},
      });

      expect(response.body.error).toBeUndefined();
      expectStatus(response, 200);
    });
  }

  afterAll(() => {
    const filePath = `${__dirname}/textile-examples-score.json`;
    fs.writeFileSync(filePath, JSON.stringify(results, null, 2) + "\n");
    console.info(`Textile examples tests output written to ${filePath}.`);
  });
});

describe("Food product examples score computation", () => {
  const results = [];

  for (const example of foodExamples) {
    it(example.name, async () => {
      const response = await makePostRequest("/api/food/", example.query);

      results.push({
        ...example,
        response: response.status === 200 ? response.body : {},
      });

      expect(response.body.error).toBeUndefined();
      expectStatus(response, 200);
    });
  }

  afterAll(() => {
    const filePath = `${__dirname}/food-examples-score.json`;
    fs.writeFileSync(filePath, JSON.stringify(results, null, 2) + "\n");
    console.info(`Food examples tests output written to ${filePath}.`);
  });
});

async function makePostRequest(path, body) {
  return await request(app).post(path).set({ token: invariant_token }).send(body);
}

function expectStatus(response, expectedCode, type = "application/json") {
  if (response.status === 400 && expectedCode != 400) {
    expect(response.body).toHaveProperty("errors", "");
  }
  expect(response.type).toBe(type);
  expect(response.statusCode).toBe(expectedCode);
}
