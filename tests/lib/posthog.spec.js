const { createEvent } = require("../../lib/posthog");
const { sha1 } = require("../../lib/crypto");

describe("lib.posthog", () => {
  describe("createEvent", () => {
    test("should create an anonymous event", () => {
      const event = createEvent(200, {
        headers: {},
        method: "GET",
        url: "/food",
      });
      expect(event).toEqual({
        event: "api_request",
        distinctId: "anonymous",
        properties: {
          $current_url: "/api/food",
          method: "GET",
          path: "/food",
          scalingoAppName: null,
          scope: "food",
          statusCode: 200,
        },
      });
    });

    test("should create an authenticated event", () => {
      const event = createEvent(
        200,
        {
          headers: { authorization: "Bearer 1234567890" },
          method: "GET",
          url: "/food",
        },
        "ecobalyse",
      );
      expect(event).toEqual({
        event: "api_request",
        distinctId: sha1("1234567890"),
        properties: {
          $current_url: "https://ecobalyse.beta.gouv.fr/api/food",
          method: "GET",
          path: "/food",
          scalingoAppName: "ecobalyse",
          scope: "food",
          statusCode: 200,
        },
      });
    });

    test("should handle different scopes", () => {
      const event = createEvent(
        200,
        {
          headers: {},
          method: "GET",
          url: "/textile/detailed",
        },
        "ecobalyse-staging",
      );
      expect(event).toEqual({
        event: "api_request",
        distinctId: "anonymous",
        properties: {
          $current_url: "https://staging-ecobalyse.incubateur.net/api/textile/detailed",
          method: "GET",
          path: "/textile/detailed",
          scalingoAppName: "ecobalyse-staging",
          scope: "textile",
          statusCode: 200,
        },
      });
    });

    test("should handle no scope", () => {
      const event = createEvent(200, {
        headers: {},
        method: "GET",
        url: "/",
      });
      expect(event).toEqual({
        event: "api_request",
        distinctId: "anonymous",
        properties: {
          $current_url: "/api/",
          method: "GET",
          path: "/",
          scalingoAppName: null,
          statusCode: 200,
        },
      });
    });
  });
});
