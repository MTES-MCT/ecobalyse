const { extractTokenFromHeaders } = require("../../lib/http");

describe("lib.http", () => {
  describe("extractTokenFromHeaders", () => {
    test("should extract token from a bearer token header", () => {
      const headers = { authorization: "Bearer 1234567890" };
      expect(extractTokenFromHeaders(headers)).toBe("1234567890");
    });

    test("should extract token from a classic token header", () => {
      const headers = { token: "1234567890" };
      expect(extractTokenFromHeaders(headers)).toBe("1234567890");
    });

    test("should extract no token when none is provided", () => {
      const headers = {};
      expect(extractTokenFromHeaders(headers)).toBe(null);
    });
  });
});
