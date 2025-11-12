const { createCSPDirectives, extractTokenFromHeaders } = require("../../lib/http");

describe("lib.http", () => {
  describe("createCSPDirectives", () => {
    test("should create a CSP directives object", () => {
      const sampleEnv = {
        MATOMO_HOST: "matomo.example.com",
        PLAUSIBLE_HOST: "plausible.example.com",
        SENTRY_DSN: "https://12345@sentry.example.com/67890",
      };
      const directives = createCSPDirectives(sampleEnv);
      expect(directives["connect-src"]).toEqual([
        "'self'",
        "https://api.github.com",
        "https://raw.githubusercontent.com",
        "https://matomo.example.com",
        "https://plausible.example.com",
        "https://sentry.example.com",
      ]);
      expect(directives["frame-src"]).toEqual(["'self'", "https://matomo.example.com"]);
      expect(directives["script-src"]).toEqual([
        "'self'",
        "'unsafe-inline'",
        "https://matomo.example.com",
        "https://plausible.example.com",
      ]);
      expect(directives["worker-src"]).toEqual(["'self'", "https://plausible.example.com"]);
    });

    test("should create a CSP directives object with no tracker hosts", () => {
      const sampleEnv = {};
      const directives = createCSPDirectives(sampleEnv);
      expect(directives["connect-src"]).toEqual([
        "'self'",
        "https://api.github.com",
        "https://raw.githubusercontent.com",
      ]);
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
