const { createCSPDirectives, extractTokenFromHeaders } = require("../../lib/http");

describe("lib.http", () => {
  describe("createCSPDirectives", () => {
    test("should create a CSP directives object", () => {
      const sampleEnv = {
        MATOMO_HOST: "matomo.example.com",
        POSTHOG_HOST: "https://posthog.example.com",
      };
      const directives = createCSPDirectives(sampleEnv);
      expect(directives["connect-src"]).toEqual(["'self'", "https://posthog.example.com"]);
      expect(directives["frame-src"]).toEqual(["'self'", "https://matomo.example.com"]);
      expect(directives["script-src"]).toEqual([
        "'self'",
        "'unsafe-inline'",
        "https://matomo.example.com",
        "https://posthog.example.com",
      ]);
      expect(directives["worker-src"]).toEqual(["'self'", "https://posthog.example.com"]);
    });

    test("should create a CSP directives object with no tracker hosts", () => {
      const sampleEnv = {};
      const directives = createCSPDirectives(sampleEnv);
      expect(directives["connect-src"]).toEqual(["'self'"]);
      expect(directives["frame-src"]).toEqual(["'self'"]);
      expect(directives["script-src"]).toEqual(["'self'", "'unsafe-inline'"]);
      expect(directives["worker-src"]).toEqual(["'self'"]);
    });
  });

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
