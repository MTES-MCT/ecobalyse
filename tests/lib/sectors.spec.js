const {
  ALL_SCOPES,
  GENERIC_SECTORS,
  LEGACY_SCOPES,
  applyGenericSectorsToOpenApi,
  getEnabledGenericSectorEntries,
  getEnabledGenericSectors,
  isGenericSectorEnabled,
  parseGenericSectorFromUrl,
  parseScopeFromUrl,
} = require("../../lib/sectors");

describe("lib.sectors", () => {
  describe("ALL_SECTORS", () => {
    test("should list legacy and generic sectors", () => {
      expect(ALL_SCOPES).toEqual(["apparel", "food", "food2", "object", "textile", "veli"]);
      expect(LEGACY_SCOPES).toEqual(["food", "textile"]);
      expect(GENERIC_SECTORS).toEqual(["apparel", "food2", "object", "veli"]);
    });
  });

  describe("parseSectorFromUrl", () => {
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

  describe("parseGenericSectorFromUrl", () => {
    test.each([
      ["/apparel/countries", "apparel"],
      ["/food2/countries", "food2"],
      ["/object/simulator", "object"],
      ["/veli/processes/assembly", "veli"],
      ["/food2/simulator?x=1", "food2"],
      ["/generic/scopes", null],
      ["/textile/countries", null],
      ["/food/countries", null],
      ["/", null],
    ])("%s → %s", (url, expected) => {
      expect(parseGenericSectorFromUrl(url)).toBe(expected);
    });
  });

  describe("isGenericSectorEnabled / getEnabledGenericSectors", () => {
    test("should respect ENABLE_XXX_SECTION flags", () => {
      const env = {
        ENABLE_FOOD2_SECTION: "True",
        ENABLE_OBJECTS_SECTION: "False",
        ENABLE_VELI_SECTION: "True",
      };
      expect(isGenericSectorEnabled("food2", env)).toBe(true);
      expect(isGenericSectorEnabled("object", env)).toBe(false);
      expect(isGenericSectorEnabled("veli", env)).toBe(true);
      expect(getEnabledGenericSectors(env)).toEqual(["food2", "veli"]);
    });

    test("should treat unset flags as disabled", () => {
      expect(getEnabledGenericSectors({})).toEqual([]);
      expect(isGenericSectorEnabled("food2", {})).toBe(false);
    });

    test("should treat unexpected flag values as disabled", () => {
      const env = {
        ENABLE_FOOD2_SECTION: "false",
        ENABLE_OBJECTS_SECTION: "true",
        ENABLE_VELI_SECTION: "1",
      };
      expect(isGenericSectorEnabled("food2", env)).toBe(false);
      expect(isGenericSectorEnabled("object", env)).toBe(false);
      expect(isGenericSectorEnabled("veli", env)).toBe(false);
      expect(getEnabledGenericSectors(env)).toEqual([]);
    });
  });

  describe("getEnabledGenericSectorEntries", () => {
    test("should return id/name entries for enabled sectors", () => {
      expect(
        getEnabledGenericSectorEntries({
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

  describe("applyGenericSectorsToOpenApi", () => {
    const baseDoc = () => ({
      paths: {
        "/generic/scopes": { get: { tags: ["Générique"] } },
        "/{scope}/countries": { get: { tags: ["Générique"] } },
        "/textile/countries": { get: { tags: ["Textile"] } },
      },
    });

    test("should keep generic paths when at least one sector is enabled", () => {
      const doc = baseDoc();
      const pathsBefore = { ...doc.paths };
      applyGenericSectorsToOpenApi(doc, {
        ENABLE_FOOD2_SECTION: "True",
      });
      expect(doc.paths).toEqual(pathsBefore);
    });

    test("should strip generic paths when no generic sector is enabled", () => {
      const doc = baseDoc();
      applyGenericSectorsToOpenApi(doc, {});
      expect(doc.paths).toEqual({
        "/textile/countries": { get: { tags: ["Textile"] } },
      });
    });
  });
});
