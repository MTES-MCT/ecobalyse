import "rapidoc";
import * as Sentry from "@sentry/browser";
import { BrowserTracing } from "@sentry/tracing";
import Charts from "./lib/charts";

// Sentry
// if (process.env.SENTRY_DSN) {
//   Sentry.init({
//     dsn: process.env.SENTRY_DSN,
//     integrations: [new BrowserTracing()],
//     tracesSampleRate: 0,
//     allowUrls: [
//       /^https:\/\/ecobalyse\.beta\.gouv\.fr/,
//       /^https:\/\/ecobalyse\.osc-fr1\.scalingo\.io/,
//       /^https:\/\/ecobalyse-pr(\d+)\.osc-fr1\.scalingo\.io/,
//     ],
//     ignoreErrors: [
//       // Most often due to DOM-aggressive browser extensions
//       /_VirtualDom_applyPatch/,
//     ],
//   });
// }

// The localStorage key to use to store serialized session data
const storeKey = "store";

const app = window.Elm.Main.init({
  flags: {
    clientUrl: location.origin + location.pathname,
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
  var u = "https://stats.data.gouv.fr/";
  _paq.push(["setTrackerUrl", u + "matomo.php"]);
  _paq.push(["disableCookies"]);
  _paq.push(["setSiteId", "196"]);
  var d = document,
    g = d.createElement("script"),
    s = d.getElementsByTagName("script")[0];
  g.async = true;
  g.src = u + "matomo.js";
  s.parentNode.insertBefore(g, s);
});

app.ports.saveStore.subscribe((rawStore) => {
  localStorage[storeKey] = rawStore;
});

app.ports.scrollTo.subscribe((pos) => {
  window.scrollTo(pos.x, pos.y);
});

app.ports.selectInputText.subscribe((id) => {
  try {
    document.getElementById(id).select();
  } catch (_) {}
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
