// To ease having both ongoing and stable version stores leveraged on a same domain,
// we use two distinct localStorage keys
const stableVersionKey = "store";
const ongoingVersionKey = "ecobalyse";

function getKey(localStorage = window.localStorage) {
  if (localStorage[stableVersionKey] && !localStorage[ongoingVersionKey]) {
    // Ongoing version store has never been initialized, while the stable version one has already
    // => Initialize current storage with stable version session data
    localStorage[ongoingVersionKey] = localStorage[stableVersionKey];
  } else if (!localStorage[stableVersionKey] && localStorage[ongoingVersionKey]) {
    // Stable version store has never been initialized, while the ongoing version one has already
    // => Backport only auth data, as other stuff is highly unlikely to be compatible
    try {
      const { auth2 } = JSON.parse(localStorage[ongoingVersionKey]);
      localStorage[stableVersionKey] = JSON.stringify({ auth2 });
    } catch (e) {
      console.warn("Unable to retrieve previous valid legacy session data");
    }
  }

  return ongoingVersionKey;
}

function exportBookmarks(localStorage = window.localStorage) {
  try {
    const jsonExport = JSON.stringify(
      {
        [ongoingVersionKey]: JSON.parse(localStorage[ongoingVersionKey] || "{}")?.bookmarks || [],
        [stableVersionKey]: JSON.parse(localStorage[stableVersionKey] || "{}")?.bookmarks || [],
      },
      null,
      2,
    );
    let a = document.createElement("a");
    a.href = `data:application/json;base64,${toBase64(jsonExport)}`;
    a.download = "ecobalyse-bookmarks.json";
    a.click();
  } catch (e) {
    console.error("Impossible d'exporter les signets", e);
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
          console.error("Impossible d'importer les signets", e);
        }
      });
      reader.readAsText(file);
    }
  });
}

function importVersionBookmarks(results, key, localStorage = window.localStorage) {
  if (results) {
    const bookmarks = results[key];
    if (Array.isArray(bookmarks) && bookmarks.length > 0) {
      const previousStore = JSON.parse(localStorage[key]);
      const updatedStore = JSON.stringify({ ...previousStore, bookmarks });
      localStorage[key] = updatedStore;
    }
  }
}

function toBase64(str) {
  const uint8Array = new TextEncoder().encode(str);
  return btoa(String.fromCharCode(...uint8Array));
}

module.exports = {
  exportBookmarks,
  importBookmarks,
  getKey,
};
