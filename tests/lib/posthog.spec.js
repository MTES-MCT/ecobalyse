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
        statusCode: 200,
        method: "GET",
        url: "/food",
        scope: "food",
      });
    });

    test("should create an authenticated event", () => {
      const event = createEvent(200, {
        headers: { authorization: "Bearer 1234567890" },
        method: "GET",
        url: "/food",
      });
      expect(event).toEqual({
        statusCode: 200,
        method: "GET",
        url: "/food",
        scope: "food",
        distinctId: sha1("1234567890"),
        properties: {
          $set_once: { firstRouteCalled: "/food" },
        },
      });
    });

    test("should handle different scopes", () => {
      const event = createEvent(200, {
        headers: {},
        method: "GET",
        url: "/textile/detailed",
      });
      expect(event).toEqual({
        statusCode: 200,
        method: "GET",
        url: "/textile/detailed",
        scope: "textile",
      });
    });
  });
});
