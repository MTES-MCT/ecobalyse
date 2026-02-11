const { exportBookmarks, importBookmarks, getKey } = require("../../lib/store");

describe("lib.store", () => {
  const stableStore = { bookmarks: [{ name: "My bookmark in stable store" }] };
  const ongoingStore = { bookmarks: [{ name: "My bookmark in ongoing store" }] };

  let origDocument, origAlert, origConsoleError;

  beforeEach(() => {
    origDocument = global.document;
    origAlert = global.alert;
    origConsoleError = console.error;
  });

  afterEach(() => {
    global.document = origDocument;
    global.alert = origAlert;
    console.error = origConsoleError;
  });

  describe("getKey", () => {
    test("should initialize ongoing store from stable store when only stable exists", () => {
      const localStorage = {
        store: JSON.stringify(stableStore),
      };

      const key = getKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(localStorage.ecobalyse).toBe(localStorage.store);
    });

    test("should not alter stores when both stable and ongoing stores exist", () => {
      const localStorage = {
        ecobalyse: JSON.stringify(ongoingStore),
        store: JSON.stringify(stableStore),
      };

      const key = getKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(localStorage.store).toBe(JSON.stringify(stableStore));
      expect(localStorage.ecobalyse).toBe(JSON.stringify(ongoingStore));
    });

    test("should return ongoing key when no store is initialized", () => {
      const localStorage = {};

      const key = getKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(localStorage.store).toBeUndefined();
      expect(localStorage.ecobalyse).toBeUndefined();
    });
  });

  describe("exportBookmarks", () => {
    const localStorage = {
      ecobalyse: JSON.stringify(ongoingStore),
      store: JSON.stringify(stableStore),
    };

    test("should export bookmarks for both stores as a JSON file", () => {
      const linkElement = {
        click: jest.fn(),
      };

      global.document = {
        createElement: jest.fn((tag) => {
          if (tag === "a") {
            return linkElement;
          }
          return {};
        }),
      };

      exportBookmarks(localStorage);

      expect(linkElement.download).toBe("ecobalyse-bookmarks.json");

      const [, base64Payload] = linkElement.href.split(",");
      const decodedJson = Buffer.from(base64Payload, "base64").toString("utf8");
      const parsed = JSON.parse(decodedJson);

      expect(parsed).toEqual({
        ecobalyse: ongoingStore.bookmarks,
        store: stableStore.bookmarks,
      });
    });

    test("should alert user when export fails", () => {
      global.document = {
        createElement: jest.fn(() => {
          throw new Error("badaboum");
        }),
      };

      global.alert = jest.fn();
      console.error = jest.fn();

      exportBookmarks(localStorage);

      expect(global.alert).toHaveBeenCalledWith("Erreur durant l'export des signets");
      expect(console.error).toHaveBeenCalledWith(
        "Unable to export bookmarks",
        expect.any(Error, /badaboum/),
      );
    });
  });

  describe("importBookmarks", () => {
    let origFileReader, fileUploadHandler;

    beforeEach(() => {
      origFileReader = global.FileReader;
      fileUploadHandler = undefined;
    });

    afterEach(() => {
      global.FileReader = origFileReader;
    });

    test("should import bookmarks for both stores and reload the page on success", () => {
      const localStorage = {
        ecobalyse: JSON.stringify(ongoingStore),
        store: JSON.stringify(stableStore),
      };
      const ongoingBookmarks = [{ name: "A bookmark to import in ongoing store" }];
      const stableBookmarks = [{ name: "A bookmark to import in stable store" }];

      global.FileReader = function () {
        this.result = null;
        this.addEventListener = (_, handler) => {
          this.onLoad = handler;
        };
        this.readAsText = jest.fn(() => {
          this.result = JSON.stringify({
            ecobalyse: ongoingBookmarks,
            store: stableBookmarks,
          });
          this.onLoad();
        });
      };

      global.document = {
        location: { reload: jest.fn() },
        createElement: jest.fn((_) => ({
          click: jest.fn(),
          addEventListener: (_, handler) => {
            fileUploadHandler = handler;
          },
        })),
      };

      global.alert = jest.fn();

      importBookmarks(localStorage);

      fileUploadHandler({ target: { files: [{ name: "ecobalyse-bookmarks.json" }] } });

      expect(global.alert).toHaveBeenCalledWith("Les signets ont été importés");
      expect(document.location.reload).toHaveBeenCalled();

      expect(JSON.parse(localStorage.ecobalyse)).toEqual({ bookmarks: ongoingBookmarks });
      expect(JSON.parse(localStorage.store)).toEqual({ bookmarks: stableBookmarks });
    });

    test("should alert the user when the import fails", () => {
      const localStorage = {
        ecobalyse: JSON.stringify(ongoingStore),
        store: JSON.stringify(stableStore),
      };

      global.FileReader = function () {
        this.addEventListener = (_, handler) => {
          this.onLoad = handler;
        };
        this.readAsText = jest.fn(() => {
          this.result = "invalid json string";
          this.onLoad();
        });
      };

      global.document = {
        location: { reload: jest.fn() },
        createElement: jest.fn((_) => ({
          click: jest.fn(),
          addEventListener: (_, handler) => {
            fileUploadHandler = handler;
          },
        })),
      };

      global.alert = jest.fn();
      console.error = jest.fn();

      importBookmarks(localStorage);

      fileUploadHandler({ target: { files: [{ name: "ecobalyse-bookmarks.json" }] } });

      expect(global.alert).toHaveBeenCalledWith("Erreur lors de l’import des signets");
      expect(console.error).toHaveBeenCalledWith(
        "Error while importing boookmarks",
        expect.any(Error),
      );
      expect(document.location.reload).not.toHaveBeenCalled();
    });
  });
});
