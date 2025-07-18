const request = require("supertest");

describe("Rate Limiting", () => {
  let originalEnv;

  function setupTestApp(env) {
    process.env.MATOMO_HOST = "";
    process.env.NODE_ENV = "production";
    process.env.POSTHOG_HOST = "";
    process.env.SENTRY_DSN = "";
    for (const key in env) {
      process.env[key] = env[key];
    }

    return require("../server");
  }

  beforeAll(() => {
    // Store original environment variables
    originalEnv = {
      MATOMO_HOST: process.env.MATOMO_HOST,
      NODE_ENV: process.env.NODE_ENV,
      POSTHOG_HOST: process.env.POSTHOG_HOST,
      RATELIMIT_MAX_RPM: process.env.RATELIMIT_MAX_RPM,
      RATELIMIT_WHITELIST: process.env.RATELIMIT_WHITELIST,
    };
  });

  afterAll(() => {
    // restore original environment variables
    Object.assign(process.env, originalEnv);
  });

  beforeEach(() => {
    // clear module cache to ensure a fresh server instance
    jest.resetModules();
  });

  describe("Rate limiting in production", () => {
    let app;

    beforeEach(() => {
      app = setupTestApp({ RATELIMIT_MAX_RPM: "2" });
    });

    it("should allow requests within rate limit", async () => {
      // first request should succeed
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      // second request should succeed (within limit of 2)
      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);
    });

    it("should allow requests to the API within rate limit", async () => {
      // first request should succeed
      const res1 = await request(app).get("/api");
      expect(res1.status).toBe(200);

      // second request should succeed (within limit of 2)
      const res2 = await request(app).get("/api");
      expect(res2.status).toBe(200);
    });

    it("should block requests exceeding rate limit", async () => {
      // first two requests should succeed
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);

      // third request should be rate limited
      const res3 = await request(app).get("/");
      expect(res3.status).toBe(429);
      expect(res3.body).toEqual({
        error: "This server is rate-limited to 2rpm, please slow down.",
      });
    });

    it("should include rate limit headers", async () => {
      const response = await request(app).get("/");

      expect(response.headers).toHaveProperty("x-ratelimit-limit");
      expect(response.headers).toHaveProperty("x-ratelimit-remaining");
      expect(response.headers).toHaveProperty("x-ratelimit-reset");

      expect(parseInt(response.headers["x-ratelimit-limit"])).toBe(2);
      expect(parseInt(response.headers["x-ratelimit-remaining"])).toBe(1);
    });
  });

  describe("Rate limiting whitelist", () => {
    it("should skip rate limiting for whitelisted IPs", async () => {
      const app = setupTestApp({ RATELIMIT_WHITELIST: "127.0.0.1,192.168.1.1" });

      const response = await request(app).get("/").set("X-Forwarded-For", "127.0.0.1");
      expect(response.status).toBe(200);
    });

    it("should apply rate limiting for non-whitelisted IPs", async () => {
      const app = setupTestApp({ RATELIMIT_WHITELIST: "192.168.1.1" });

      // requests from non-whitelisted IP
      const res1 = await request(app).get("/").set("X-Forwarded-For", "10.0.0.1");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/").set("X-Forwarded-For", "10.0.0.1");
      expect(res2.status).toBe(200);

      const res3 = await request(app).get("/").set("X-Forwarded-For", "10.0.0.1");
      expect(res3.status).toBe(429);
    });

    it("should handle empty whitelist correctly", async () => {
      const app = setupTestApp({ RATELIMIT_WHITELIST: "" });

      // these should be rate limited
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);

      const res3 = await request(app).get("/");
      expect(res3.status).toBe(429);
    });
  });

  describe("Rate limiting in non-production environments", () => {
    let app;

    beforeEach(() => {
      app = setupTestApp({
        NODE_ENV: "test",
        RATELIMIT_MAX_RPM: "1",
      });
    });

    it("should skip rate limiting in test environment", async () => {
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);

      const res3 = await request(app).get("/");
      expect(res3.status).toBe(200);
    });

    it("should skip rate limiting in development environment", async () => {
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);

      const res3 = await request(app).get("/");
      expect(res3.status).toBe(200);
    });
  });

  describe("Rate limit configuration", () => {
    it("should handle invalid RATELIMIT_MAX_RPM gracefully", async () => {
      const app = setupTestApp({ RATELIMIT_MAX_RPM: "invalid" });

      // Should fall back to default (>2rpm)
      const res1 = await request(app).get("/");
      expect(res1.status).toBe(200);

      const res2 = await request(app).get("/");
      expect(res2.status).toBe(200);

      const res3 = await request(app).get("/");
      expect(res3.status).toBe(200);
    });
  });
});
