import { Elm } from "./src/Main.elm";
import * as Sentry from "@sentry/browser";
import { BrowserTracing } from "@sentry/browser";
import Charts from "./lib/charts";

// Sentry
if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    integrations: [new BrowserTracing()],
    tracesSampleRate: 0,
    allowUrls: [
      /^https:\/\/ecobalyse\.beta\.gouv\.fr/,
      /^https:\/\/ecobalyse\.osc-fr1\.scalingo\.io/,
      /^https:\/\/ecobalyse-pr(\d+)\.osc-fr1\.scalingo\.io/,
      /^https:\/\/ecobalyse-v2\.osc-fr1\.scalingo\.io/,
    ],
    ignoreErrors: [
      // Most often due to DOM-aggressive browser extensions
      /_VirtualDom_applyPatch/,
    ],
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

const app = Elm.Main.init({
  flags: {
    clientUrl: location.origin + location.pathname,
    github: {
      repository: process.env.GITHUB_REPOSITORY || "MTES-MCT/ecobalyse",
      branch: process.env.GITHUB_BRANCH || "master",
    },
    matomo: {
      host: process.env.MATOMO_HOST || "",
      siteId: process.env.MATOMO_SITE_ID || "",
    },
    rawStore: localStorage[storeKey] || "",
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
