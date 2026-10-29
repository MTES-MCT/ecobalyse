const {
  API_DOCS_URL,
  createCSPDirectives,
  extractTokenFromHeaders,
  authServerErrors,
  grantGenericApiAccess,
  handleDetailedImpactsRequest,
} = require("../../lib/http");

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
      expect(directives["frame-src"]).toEqual([
        "'self'",
        "https://jedonnemonavis.numerique.gouv.fr",
        "https://matomo.example.com",
        "https://plausible.example.com",
      ]);
      expect(directives["script-src"]).toEqual([
        "'self'",
        "'unsafe-inline'",
        "https://jedonnemonavis.numerique.gouv.fr",
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
      expect(directives["frame-src"]).toEqual([
        "'self'",
        "https://jedonnemonavis.numerique.gouv.fr",
      ]);
      expect(directives["script-src"]).toEqual([
        "'self'",
        "'unsafe-inline'",
        "https://jedonnemonavis.numerique.gouv.fr",
      ]);
      expect(directives["worker-src"]).toEqual(["'self'"]);
    });
  });

  describe("grantGenericApiAccess", () => {
    test("should reject a non-beta non-superuser token with 403", () => {
      expect(grantGenericApiAccess(201, { isBetauser: false, isSuperuser: false })).toEqual({
        status: 403,
        body: {
          error: { authorization: "Accès réservé aux beta-testeurs et superutilisateurs" },
          documentation: API_DOCS_URL,
        },
      });
    });

    test("should allow a beta user token", () => {
      expect(grantGenericApiAccess(201, { isBetauser: true, isSuperuser: false })).toBeNull();
    });

    test("should reject an invalid token with 401", () => {
      expect(grantGenericApiAccess(403, {})).toEqual({
        status: 401,
        body: {
          error: { authorization: "Un token valide est requis pour utiliser l’API" },
          documentation: API_DOCS_URL,
        },
      });
    });
  });

  describe("handleDetailedImpactsRequest", () => {
    test("returns detailed impacts when validation succeeded", () => {
      expect(handleDetailedImpactsRequest(201, "detailed")).toEqual({
        status: 200,
        body: "detailed",
      });
    });

    test.each([
      [403, 403, authServerErrors.termsRequired],
      [401, 401, authServerErrors.invalidToken],
      [500, 503, authServerErrors.unavailable],
    ])("does not return the public file for status %s", (validationStatus, status, detail) => {
      expect(handleDetailedImpactsRequest(validationStatus, "detailed")).toEqual({
        status,
        body: { status, detail },
      });
    });

    test("reports auth server unavailable when it could not be reached", () => {
      expect(handleDetailedImpactsRequest(500)).toEqual({
        status: 503,
        body: { status: 503, detail: authServerErrors.unavailable },
      });
    });

    test("reports a missing detailed impacts data", () => {
      expect(handleDetailedImpactsRequest(201, "")).toEqual({
        status: 503,
        body: { status: 503, detail: authServerErrors.missingData },
      });
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
