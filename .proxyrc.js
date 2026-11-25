const http = require("node:http");
const path = require("node:path");
const serveStatic = require("serve-static");

// Let the e2e server proxy `/data/*` to `tests/fixtures/*` when
// `ECOBALYSE_E2E_FIXTURES` is set to "1"

const proxyTable = [
  { context: "/api", target: "http://127.0.0.1:8001", timeout: 30_000 },
  {
    context: "/backend",
    rewrite: (url) => url.replace(/^\/backend/, "") || "/",
    target: "http://127.0.0.1:8002",
    timeout: 30_000,
  },
  { context: "/processes/", target: "http://127.0.0.1:8001", timeout: 30_000 },
  { context: "/schema", target: "http://127.0.0.1:8002", timeout: 30_000 },
  {
    context: "/versions/v7.0.0/",
    rewrite: (url) => url.replace(/^\/versions\/v7\.0\.0/, "") || "/",
    target: "http://0.0.0.0:8000",
    timeout: 30_000,
  },
];

function proxyRequest(route, req, res) {
  const incomingUrl = req.originalUrl || req.url;
  const requestUrl = new URL(
    route.rewrite ? route.rewrite(incomingUrl) : incomingUrl,
    route.target,
  );
  const proxyReq = http.request(
    requestUrl,
    {
      headers: req.headers,
      method: req.method,
      timeout: route.timeout,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on("timeout", () => {
    proxyReq.destroy();
  });
  proxyReq.on("error", () => {
    if (!res.headersSent) {
      res.statusCode = 502;
    }
    res.end();
  });
  req.pipe(proxyReq);
}

function routeRequest(req, res, next) {
  // proxy incoming data requests to serve fixtures instead (used by the e2e test runner)
  if (process.env.ECOBALYSE_E2E_FIXTURES === "1" && req.url.startsWith("/data/")) {
    serveFixtureData(req, res);
  } else {
    const route = proxyTable.find(({ context }) => req.url.startsWith(context));
    if (route) {
      proxyRequest(route, req, res);
    } else {
      next();
    }
  }
}

const staticFixtures = serveStatic(path.join(__dirname, "tests/fixtures"), {
  index: false,
});

function fixtureRequest(req) {
  return Object.create(req, {
    url: {
      enumerable: true,
      value: req.url.replace(/^\/data/, "") || "/",
      writable: true,
    },
  });
}

function serveFixtureData(req, res) {
  staticFixtures(fixtureRequest(req), res, () => {
    res.statusCode = 404;
    res.end();
  });
}

module.exports = function (app) {
  app.use(routeRequest);
};
