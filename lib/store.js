// To ease having both ongoing and stable version stores leveraged on a same domain,
// we use two distinct localStorage keys
const stableVersionKey = "store";
const ongoingVersionKey = "ecobalyse";

function isObjectBookmark(entry) {
  return entry !== null && typeof entry === "object" && !Array.isArray(entry);
}

function backportStableBookmarks(localStorage) {
  const stableVersionDict = JSON.parse(localStorage[stableVersionKey] || "{}");
  const ongoingVersionDict = JSON.parse(localStorage[ongoingVersionKey] || "{}");
  const stableBookmarks = stableVersionDict.bookmarks || [];
  const ongoingBookmarks = ongoingVersionDict.bookmarks || [];

  if (stableBookmarks.length > 0 || ongoingBookmarks.length === 0) {
    return;
  }

  // Only migrate when every entry is a plain js object, which is the bookmark format used
  // by the stable version. The ongoing version stores bookmarks as JSON strings, so copying
  // those into current version store would make stable's strict bookmark decoder fail the
  // whole session (see #2698)
  if (ongoingBookmarks.every(isObjectBookmark)) {
    stableVersionDict.bookmarks = ongoingBookmarks;
    localStorage[stableVersionKey] = JSON.stringify(stableVersionDict);
  }
}

function initializeStoreKey(localStorage = window.localStorage) {
  if (localStorage[stableVersionKey] && !localStorage[ongoingVersionKey]) {
    // Ongoing version store has never been initialized, while the stable version has one already
    try {
      const { auth } = JSON.parse(localStorage[stableVersionKey]);
      if (auth) {
        localStorage[ongoingVersionKey] = JSON.stringify({ auth });
      }
    } catch (e) {
      console.error("Unable to retrieve previous valid legacy session data", e);
    }
  } else if (
    !JSON.parse(localStorage[stableVersionKey] || "{}")?.auth &&
    localStorage[ongoingVersionKey]
  ) {
    // Stable version store has no valid auth, while the ongoing version has one already
    try {
      const { auth } = JSON.parse(localStorage[ongoingVersionKey]);
      const stableVersionDict = JSON.parse(localStorage[stableVersionKey] || "{}");
      stableVersionDict.auth = auth;
      localStorage[stableVersionKey] = JSON.stringify(stableVersionDict);
    } catch (e) {
      console.error("Unable to retrieve previous valid legacy session data", e);
    }
  }

  backportStableBookmarks(localStorage);

  return stableVersionKey;
}

function exportBookmarks(localStorage = window.localStorage) {
  try {
    const jsonExport = JSON.stringify({
      [ongoingVersionKey]: JSON.parse(localStorage[ongoingVersionKey] || "{}")?.bookmarks || [],
      [stableVersionKey]: JSON.parse(localStorage[stableVersionKey] || "{}")?.bookmarks || [],
    });
    let a = document.createElement("a");
    a.href = `data:application/json;base64,${toBase64(jsonExport)}`;
    a.download = createFilename();
    a.click();
  } catch (e) {
    console.error("Unable to export bookmarks", e);
    alert("Erreur durant l'export des signets");
  }
}

function importBookmarks(localStorage = window.localStorage) {
  let field = document.createElement("input");
  field.type = "file";
  field.accept = "application/json,.json";
  field.click();
  field.addEventListener("change", ({ target }) => {
    const file = target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.addEventListener("load", () => {
        try {
          const results = JSON.parse(reader.result);
          importVersionBookmarks(results, stableVersionKey, localStorage);
          importVersionBookmarks(results, ongoingVersionKey, localStorage);
          document.location.reload();
          alert("Les signets ont été importés");
        } catch (e) {
          console.error("Error while importing bookmarks", e);
          alert("Erreur lors de l’import des signets");
        }
      });
      reader.readAsText(file);
    }
  });
}

function importVersionBookmarks(results, key, localStorage = window.localStorage) {
  if (results && key in results) {
    const bookmarks = results[key];
    if (Array.isArray(bookmarks) && bookmarks.length > 0) {
      initializeStoreKey(localStorage);

      const previousStore = JSON.parse(localStorage[key] || "{}");
      const updatedStore = JSON.stringify({ ...previousStore, bookmarks });
      localStorage[key] = updatedStore;
    }
  }
}

function createFilename(date = new Date()) {
  const datePart = date
    .toISOString()
    .replaceAll("-", "")
    .replace("T", "-")
    .replaceAll(":", "")
    .slice(0, 15);
  return `ecobalyse-bookmarks-${datePart}.json`;
}

function toBase64(str) {
  const uint8Array = new TextEncoder().encode(str);
  return btoa(String.fromCharCode(...uint8Array));
}

module.exports = {
  exportBookmarks,
  importBookmarks,
  initializeStoreKey,
};
