const { createEvent } = require("../../lib/plausible");
const { sha1 } = require("../../lib/crypto");

describe("lib.plausible", () => {
  describe("createEvent", () => {
    test("should create an anonymous event", () => {
      const event = createEvent(200, {
        headers: {},
        method: "GET",
        url: "/food",
      });
      expect(event).toEqual({
        name: "pageview",
        domain: "localhost",
        url: "/food",
        props: {
          authenticated: false,
          distinctId: null,
          method: "GET",
          scalingoAppName: null,
          scope: "food",
          statusCode: 200,
          subsystem: "api",
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
        name: "pageview",
        domain: "localhost",
        url: "/food",
        props: {
          authenticated: true,
          distinctId: sha1("1234567890"),
          method: "GET",
          scalingoAppName: "ecobalyse",
          scope: "food",
          statusCode: 200,
          subsystem: "api",
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
        name: "pageview",
        domain: "localhost",
        url: "/textile/detailed",
        props: {
          authenticated: false,
          distinctId: null,
          method: "GET",
          scalingoAppName: "ecobalyse-staging",
          scope: "textile",
          statusCode: 200,
          subsystem: "api",
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
        name: "pageview",
        domain: "localhost",
        url: "/",
        props: {
          authenticated: false,
          distinctId: null,
          method: "GET",
          scalingoAppName: null,
          statusCode: 200,
          subsystem: "api",
        },
      });
    });
  });
});
