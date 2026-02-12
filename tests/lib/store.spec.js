const { exportBookmarks, importBookmarks, initializeStoreKey } = require("../../lib/store");

describe("lib.store", () => {
  const anonStableStore = { bookmarks: [{ name: "My bookmark in stable store" }] };
  const anonOngoingStore = { bookmarks: [{ name: "My bookmark in ongoing store" }] };
  const sampleFilename = "ecobalyse-bookmarks-20260212-095036.json";

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

  describe("initializeStoreKey", () => {
    test("should initialize ongoing store with auth only when only stable store exists", () => {
      const authStableStore = {
        auth2: { token: "stable-session-token" },
        bookmarks: anonStableStore.bookmarks,
      };
      const localStorage = {
        store: JSON.stringify(authStableStore),
      };

      const key = initializeStoreKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(JSON.parse(localStorage.ecobalyse)).toEqual(authStableStore);
    });

    test("should backport auth only to stable store when only ongoing store exists", () => {
      const authOngoingStore = {
        auth2: { token: "ongoing-session-token" },
        bookmarks: anonOngoingStore.bookmarks,
      };
      const localStorage = {
        ecobalyse: JSON.stringify(authOngoingStore),
      };

      const key = initializeStoreKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(JSON.parse(localStorage.store)).toEqual({ auth2: authOngoingStore.auth2 });
    });

    test("should not alter stores when both stable and ongoing stores exist", () => {
      const stableSession = { auth2: { token: "stable-session-token" } };
      const ongoingSession = { auth2: { token: "ongoing-session-token" } };
      const localStorage = {
        ecobalyse: JSON.stringify(ongoingSession),
        store: JSON.stringify(stableSession),
      };

      const key = initializeStoreKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(localStorage.store).toBe(JSON.stringify(stableSession));
      expect(localStorage.ecobalyse).toBe(JSON.stringify(ongoingSession));
    });

    test("should return ongoing key when no store is initialized", () => {
      const localStorage = {};

      const key = initializeStoreKey(localStorage);

      expect(key).toBe("ecobalyse");
      expect(localStorage.store).toBeUndefined();
      expect(localStorage.ecobalyse).toBeUndefined();
    });
  });

  describe("exportBookmarks", () => {
    const localStorage = {
      ecobalyse: JSON.stringify(anonOngoingStore),
      store: JSON.stringify(anonStableStore),
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

      expect(linkElement.download).toMatch(/ecobalyse-bookmarks-\d{8}-\d{6}\.json/);

      const [, base64Payload] = linkElement.href.split(",");
      const decodedJson = Buffer.from(base64Payload, "base64").toString("utf8");
      const parsed = JSON.parse(decodedJson);

      expect(parsed).toEqual({
        ecobalyse: anonOngoingStore.bookmarks,
        store: anonStableStore.bookmarks,
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
        ecobalyse: JSON.stringify(anonOngoingStore),
        store: JSON.stringify(anonStableStore),
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

      fileUploadHandler({
        target: { files: [{ name: sampleFilename }] },
      });

      expect(global.alert).toHaveBeenCalledWith("Les signets ont été importés");
      expect(document.location.reload).toHaveBeenCalled();

      expect(JSON.parse(localStorage.ecobalyse)).toEqual({ bookmarks: ongoingBookmarks });
      expect(JSON.parse(localStorage.store)).toEqual({ bookmarks: stableBookmarks });
    });

    test("should keep existing bookmarks list when import file has no bookmarks", () => {
      const localStorage = {
        ecobalyse: JSON.stringify(anonOngoingStore),
        store: JSON.stringify(anonStableStore),
      };

      global.FileReader = function () {
        this.result = null;
        this.addEventListener = (_, handler) => {
          this.onLoad = handler;
        };
        this.readAsText = jest.fn(() => {
          // empty bookmarks lists in import file
          this.result = JSON.stringify({
            ecobalyse: [],
            store: [],
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

      fileUploadHandler({
        target: { files: [{ name: sampleFilename }] },
      });

      expect(JSON.parse(localStorage.ecobalyse)).toEqual(anonOngoingStore);
      expect(JSON.parse(localStorage.store)).toEqual(anonStableStore);
    });

    test("should alert the user when the import fails", () => {
      const localStorage = {
        ecobalyse: JSON.stringify(anonOngoingStore),
        store: JSON.stringify(anonStableStore),
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

      fileUploadHandler({
        target: { files: [{ name: sampleFilename }] },
      });

      expect(global.alert).toHaveBeenCalledWith("Erreur lors de l’import des signets");
      expect(console.error).toHaveBeenCalledWith(
        "Error while importing bookmarks",
        expect.any(Error),
      );
      expect(document.location.reload).not.toHaveBeenCalled();
    });
  });
});
