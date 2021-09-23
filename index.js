import { Elm } from "./src/Main.elm";

// The localStorage key to use to store serialized session data
const storeKey = "store";

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: {
    clientUrl: location.origin + location.pathname,
    rawStore: localStorage[storeKey] || "",
  },
});

app.ports.saveStore.subscribe((rawStore) => {
  localStorage[storeKey] = rawStore;
});

app.ports.scrollTo.subscribe((pos) => {
  window.scrollTo(pos.x, pos.y);
});

app.ports.copyToClipboard.subscribe((text) => {
  navigator.clipboard.writeText(text).then(
    function () {},
    function (err) {
      alert("Votre navigateur ne supporte pas la copie automatique; vous pouvez copier l'adresse manuellement");
    }
  );
});

// Ensure session is refreshed when it changes in another tab/window
window.addEventListener(
  "storage",
  (event) => {
    if (event.storageArea === localStorage && event.key === storeKey) {
      app.ports.storeChanged.send(event.newValue);
    }
  },
  false
);

// Matomo tracking is enabled for production hostnames only
// Note: The tracker code is incompatible with Parcel's HMR, hence why we don't want to to run on a local dev instance
if (["mtes-mct.github.io", "wikicarbone.beta.gouv.fr"].indexOf(location.hostname) !== -1) {
  var _paq = (window._paq = window._paq || []);
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(["trackPageView"]);
  _paq.push(["enableLinkTracking"]);
  (function () {
    var u = "https://stats.data.gouv.fr/";
    _paq.push(["setTrackerUrl", u + "piwik.php"]);
    _paq.push(["setSiteId", "196"]);
    var d = document,
      g = d.createElement("script"),
      s = d.getElementsByTagName("script")[0];
    g.async = true;
    g.src = u + "piwik.js";
    s.parentNode.insertBefore(g, s);
  })();
}
