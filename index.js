import { Elm } from "./src/Main.elm";
import * as Sentry from "@sentry/browser";
import Charts from "./lib/charts";

// The root Web client URL, including protocol and without trailing slash
const clientUrl = (location.origin + location.pathname).replace(/\/+$/g, "");

// Use current domain and path as the localStorage key, so that each version has its own browser storage
// eg. foo.org and foo.org/versions/v7.0.0 uses distinct browser stores
const storeKey = "ecobalyse_" + (location.hostname + location.pathname).replace(/\/+$/g, "");

// using a `let` statement to avoid this error:
// @parcel/optimizer-swc: 'const' declarations must be initialized
let { FORCE_PLAUSIBLE, NODE_ENV, PLAUSIBLE_HOST, SENTRY_DSN } = process.env;
const plausibleEnabled = PLAUSIBLE_HOST && (NODE_ENV === "production" || FORCE_PLAUSIBLE);

// Sentry
if (NODE_ENV === "production" && SENTRY_DSN) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [Sentry.browserTracingIntegration()],
    tracesSampleRate: 0,
    allowUrls: [
      /^https:\/\/ecobalyse\.beta\.gouv\.fr/,
      /^https:\/\/staging-ecobalyse\.incubateur\.net/,
      // Review apps
      /^https:\/\/ecobalyse-staging-pr.*\.osc-fr1\.scalingo\.io/,
    ],
    ignoreErrors: [
      // Most often due to DOM-aggressive browser extensions
      /_VirtualDom_applyPatch/,
    ],
    // IS_REVIEW_APP is set by `scalingo.json` only on review apps
    // See: https://developers.scalingo.com/scalingo-json-schema/
    environment: process.env.IS_REVIEW_APP ? "review-app" : NODE_ENV || "development",
  });
  Sentry.setTag("subsystem", "front-end");
}

function loadScript(scriptUrl, attributes = {}) {
  var d = document,
    g = d.createElement("script"),
    s = d.getElementsByTagName("script")[0];
  g.async = true;
  g.src = scriptUrl;
  for (const [key, value] of Object.entries(attributes)) {
    g.setAttribute(key, value);
  }
  s.parentNode.insertBefore(g, s);
}

const app = Elm.Main.init({
  flags: {
    clientUrl,
    enabledSections: {
      food: process.env.ENABLE_FOOD_SECTION === "True",
      objects: process.env.ENABLE_OBJECTS_SECTION === "True",
      textile: true, // always enabled
      veli: process.env.ENABLE_VELI_SECTION === "True",
    },
    rawStore: localStorage[storeKey] || "null",
    matomo: {
      host: process.env.MATOMO_HOST || "",
      siteId: process.env.MATOMO_SITE_ID || "",
    },
    scalingoAppName: process.env.APP || null,
    versionPollSeconds: parseInt(process.env.VERSION_POLL_SECONDS) || 300,
  },
});

app.ports.copyToClipboard.subscribe((text) => {
  navigator.clipboard.writeText(text).then(
    function () {},
    function () {
      alert(
        `Votre navigateur ne supporte pas la copie automatique; vous pouvez copier l'adresse manuellement`,
      );
    },
  );
});

app.ports.appStarted.subscribe(() => {
  // Matomo
  var _paq = (window._paq = window._paq || []);
  _paq.push(["trackPageView"]);
  _paq.push(["enableLinkTracking"]);
  var u = `https://${process.env.MATOMO_HOST}/`;
  _paq.push(["setTrackerUrl", u + "matomo.php"]);
  _paq.push(["disableCookies"]);
  _paq.push(["setSiteId", process.env.MATOMO_SITE_ID]);
  loadScript(u + "matomo.js");

  // Plausible
  if (plausibleEnabled) {
    window.plausible =
      window.plausible ||
      function () {
        (window.plausible.q = window.plausible.q || []).push(arguments);
      };
    loadScript(
      `https://${PLAUSIBLE_HOST}/js/script.file-downloads.outbound-links.pageview-props.tagged-events.manual.local.js`,
      {
        defer: true,
        "data-domain":
          process.env.APP === "ecobalyse" ? "ecobalyse.beta.gouv.fr" : "ecobalyse.test",
      },
    );
  }
});

app.ports.loadRapidoc.subscribe((rapidocScriptUrl) => {
  // load the rapi-doc script if the component hasn't be registered yet
  if (!customElements.get("rapi-doc")) {
    loadScript(rapidocScriptUrl);
  }
});

app.ports.saveStore.subscribe((rawStore) => {
  localStorage[storeKey] = rawStore;
});

app.ports.addBodyClass.subscribe((cls) => {
  document.body.classList.add(cls);
});

app.ports.removeBodyClass.subscribe((cls) => {
  document.body.classList.remove(cls);
});

app.ports.sendPlausibleEvent.subscribe(({ name, properties }) => {
  if (!plausibleEnabled) return;

  try {
    const props = Object.fromEntries(properties);
    const event = name === "pageview" ? { u: props.url.replace("/#/", "/"), props } : { props };
    window.plausible(name, event);
    if (NODE_ENV === "development") {
      console.debug("plausible event", name, JSON.stringify(event, null, 2));
    }
  } catch (e) {
    console.error("plausible error", e);
  }
});

app.ports.scrollTo.subscribe((pos) => {
  window.scrollTo(pos.x, pos.y);
});

app.ports.scrollIntoView.subscribe((id) => {
  let node = document.getElementById(id);
  node?.scrollIntoView({ behavior: "smooth" });
});

// Ensure session is refreshed when it changes in another tab/window
window.addEventListener(
  "storage",
  (event) => {
    if (event.storageArea === localStorage && event.key === storeKey) {
      app.ports.storeChanged.send(event.newValue);
    }
  },
  false,
);

// Register custom chart elements
Charts.registerElements();
