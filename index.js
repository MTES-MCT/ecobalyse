import { Elm } from "./src/Main.elm";
import * as Sentry from "@sentry/browser";
import Charts from "./lib/charts";
import posthog from "posthog-js";

// using  let statement to avoid this error:
// @parcel/optimizer-swc: 'const' declarations must be initialized
let { NODE_ENV, POSTHOG_KEY, POSTHOG_HOST, SENTRY_DSN } = process.env;

// Posthog
if (POSTHOG_KEY && POSTHOG_HOST) {
  posthog.init(POSTHOG_KEY, {
    api_host: POSTHOG_HOST,
    person_profiles: "identified_only", // or 'always' to create profiles for anonymous users as well
  });
}

// Sentry
if (SENTRY_DSN) {
  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [Sentry.browserTracingIntegration()],
    tracesSampleRate: 0,
    allowUrls: [
      /^https:\/\/ecobalyse\.beta\.gouv\.fr/,
      /^https:\/\/staging-ecobalyse\.incubateur\.net/,
      // Review apps
      /^https:\/\/ecobalyse-pr.*\.osc-fr1\.scalingo\.io/,
    ],
    ignoreErrors: [
      // Most often due to DOM-aggressive browser extensions
      /_VirtualDom_applyPatch/,
    ],
    environment: process.env.IS_REVIEW_APP ? "review-app" : NODE_ENV || "development",
  });
}

function loadScript(scriptUrl) {
  var d = document,
    g = d.createElement("script"),
    s = d.getElementsByTagName("script")[0];
  g.async = true;
  g.src = scriptUrl;
  s.parentNode.insertBefore(g, s);
}

// The localStorage key to use to store serialized session data
const storeKey = "store";

// Remove trailing slash from root because it's used by the Elm API to resolve backend api urls
const clientUrl = (location.origin + location.pathname).replace(/\/+$/g, "");

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
  },
});

app.ports.copyToClipboard.subscribe((text) => {
  navigator.clipboard.writeText(text).then(
    function () {},
    function (err) {
      alert(
        `Votre navigateur ne supporte pas la copie automatique;
         vous pouvez copier l'adresse manuellement`,
      );
    },
  );
});

app.ports.appStarted.subscribe(() => {
  var _paq = (window._paq = window._paq || []);
  _paq.push(["trackPageView"]);
  _paq.push(["enableLinkTracking"]);
  var u = `https://${process.env.MATOMO_HOST}/`;
  _paq.push(["setTrackerUrl", u + "matomo.php"]);
  _paq.push(["disableCookies"]);
  _paq.push(["setSiteId", process.env.MATOMO_SITE_ID]);
  loadScript(u + "matomo.js");
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
