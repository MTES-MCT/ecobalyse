// To ease having both ongoing and stable version stores leveraged on a same domain,
// we use two distinct localStorage keys
const stableVersionKey = "store";
const ongoingVersionKey = "ecobalyse";

function getKey() {
  if (localStorage[stableVersionKey] && !localStorage[ongoingVersionKey]) {
    // Ongoing version store has never been initialized, while the stable version one has already
    // => Initialize current storage with stable version session data
    localStorage[ongoingVersionKey] = localStorage[stableVersionKey];
  } else if (!localStorage[stableVersionKey] && localStorage[ongoingVersionKey]) {
    // Stable version store has never been initialized, while the ongoing version one has already
    // => Backport only auth data, as other stuff is highly unlikely to be compatible
    try {
      const ongoingSessionData = JSON.parse(localStorage[stableVersionKey]);
      localStorage[stableVersionKey] = { auth2: ongoingSessionData.auth2 };
    } catch (e) {
      console.warn("Unable to retrieve previous valid legacy session data");
    }
  }

  return ongoingVersionKey;
}

function exportBookmarks() {
  try {
    const jsonExport = JSON.stringify({
      ongoing: JSON.parse(localStorage[ongoingVersionKey])?.bookmarks,
      stable: JSON.parse(localStorage[stableVersionKey])?.bookmarks,
    });
    let a = document.createElement("a");
    a.href = `data:application/json;base64,${toBase64(jsonExport)}`;
    a.download = "ecobalyse-bookmarks.json";
    a.click();
  } catch (e) {
    console.error("Impossible d'exporter les signets", e);
  }
}

function toBase64(str) {
  const uint8Array = new TextEncoder().encode(str);
  return btoa(String.fromCharCode(...uint8Array));
}

module.exports = {
  exportBookmarks,
  getKey,
};
