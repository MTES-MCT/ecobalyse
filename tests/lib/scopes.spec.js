const {
  ALL_SCOPES,
  GENERIC_SCOPES,
  LEGACY_SCOPES,
  applyGenericScopesToOpenApi,
  getEnabledGenericScopeEntries,
  getEnabledGenericScopes,
  isGenericScopeEnabled,
  parseGenericScopeFromUrl,
  parseScopeFromUrl,
} = require("../../lib/scopes");

describe("lib.scopes", () => {
  describe("ALL_SCOPES", () => {
    test("should list legacy and generic scopes", () => {
      expect(ALL_SCOPES).toEqual(["food", "food2", "object", "textile", "veli"]);
      expect(LEGACY_SCOPES).toEqual(["food", "textile"]);
      expect(GENERIC_SCOPES).toEqual(["food2", "object", "veli"]);
    });
  });

  describe("parseScopeFromUrl", () => {
    test.each([
      ["/food/countries", "food"],
      ["/food2/countries", "food2"],
      ["/textile/countries", "textile"],
      ["/object/simulator", "object"],
      ["/veli/processes/assembly", "veli"],
      ["/generic/scopes", null],
      ["/", null],
    ])("%s → %s", (url, expected) => {
      expect(parseScopeFromUrl(url)).toBe(expected);
    });
  });

  describe("parseGenericScopeFromUrl", () => {
    test.each([
      ["/food2/countries", "food2"],
      ["/object/simulator", "object"],
      ["/veli/processes/assembly", "veli"],
      ["/food2/simulator?x=1", "food2"],
      ["/generic/scopes", null],
      ["/textile/countries", null],
      ["/food/countries", null],
      ["/", null],
    ])("%s → %s", (url, expected) => {
      expect(parseGenericScopeFromUrl(url)).toBe(expected);
    });
  });

  describe("isGenericScopeEnabled / getEnabledGenericScopes", () => {
    test("should respect ENABLE_XXX_SECTION flags", () => {
      const env = {
        ENABLE_FOOD2_SECTION: "True",
        ENABLE_OBJECTS_SECTION: "False",
        ENABLE_VELI_SECTION: "True",
      };
      expect(isGenericScopeEnabled("food2", env)).toBe(true);
      expect(isGenericScopeEnabled("object", env)).toBe(false);
      expect(isGenericScopeEnabled("veli", env)).toBe(true);
      expect(getEnabledGenericScopes(env)).toEqual(["food2", "veli"]);
    });

    test("should treat unset flags as disabled", () => {
      expect(getEnabledGenericScopes({})).toEqual([]);
      expect(isGenericScopeEnabled("food2", {})).toBe(false);
    });

    test("should treat unexpected flag values as disabled", () => {
      const env = {
        ENABLE_FOOD2_SECTION: "false",
        ENABLE_OBJECTS_SECTION: "true",
        ENABLE_VELI_SECTION: "1",
      };
      expect(isGenericScopeEnabled("food2", env)).toBe(false);
      expect(isGenericScopeEnabled("object", env)).toBe(false);
      expect(isGenericScopeEnabled("veli", env)).toBe(false);
      expect(getEnabledGenericScopes(env)).toEqual([]);
    });
  });

  describe("getEnabledGenericScopeEntries", () => {
    test("should return id/name entries for enabled scopes", () => {
      expect(
        getEnabledGenericScopeEntries({
          ENABLE_FOOD2_SECTION: "True",
          ENABLE_OBJECTS_SECTION: "False",
          ENABLE_VELI_SECTION: "True",
        }),
      ).toEqual([
        { id: "food2", name: "Alimentaire BÉTA" },
        { id: "veli", name: "Véhicules" },
      ]);
    });
  });

  describe("applyGenericScopesToOpenApi", () => {
    const baseDoc = () => ({
      paths: {
        "/generic/scopes": { get: { tags: ["Générique"] } },
        "/{scope}/countries": { get: { tags: ["Générique"] } },
        "/textile/countries": { get: { tags: ["Textile"] } },
      },
    });

    test("should keep generic paths when at least one scope is enabled", () => {
      const doc = baseDoc();
      const pathsBefore = { ...doc.paths };
      applyGenericScopesToOpenApi(doc, {
        ENABLE_FOOD2_SECTION: "True",
      });
      expect(doc.paths).toEqual(pathsBefore);
    });

    test("should strip generic paths when no generic scope is enabled", () => {
      const doc = baseDoc();
      applyGenericScopesToOpenApi(doc, {});
      expect(doc.paths).toEqual({
        "/textile/countries": { get: { tags: ["Textile"] } },
      });
    });
  });
});
