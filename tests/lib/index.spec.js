const lib = require("../../lib");

describe("lib.index", () => {
  describe("mergeDetailedImpacts", () => {
    const baseProcesses = [
      { id: "a", displayName: "A", impacts: { ecs: 1 } },
      { id: "b", displayName: "B", impacts: { ecs: 2 } },
    ];

    test("should override base impacts with detailed ones matched by id", () => {
      const detailedImpacts = [{ id: "a", impacts: { ecs: 1, cch: 42 } }];
      expect(lib.mergeDetailedImpacts(baseProcesses, detailedImpacts)).toEqual([
        { id: "a", displayName: "A", impacts: { ecs: 1, cch: 42 } },
        { id: "b", displayName: "B", impacts: { ecs: 2 } },
      ]);
    });

    test("should keep base processes untouched when no detailed impacts are provided", () => {
      expect(lib.mergeDetailedImpacts(baseProcesses, [])).toEqual(baseProcesses);
    });

    test("should ignore detailed impacts referencing unknown ids", () => {
      const detailedImpacts = [{ id: "z", impacts: { ecs: 99 } }];
      expect(lib.mergeDetailedImpacts(baseProcesses, detailedImpacts)).toEqual(baseProcesses);
    });
  });

  describe("filterLegacyFood1Paths", () => {
    test("should filter out food1 api and keep food2 ones", () => {
      const paths = {
        "/food": {},
        "/food/countries": {},
        "/food2": {},
        "/food2/simulator": {},
        "/textile": {},
        "/textile/simulator": {},
      };
      const filteredPaths = lib.filterLegacyFood1Paths(paths);
      expect(filteredPaths).toEqual({
        "/food2": {},
        "/food2/simulator": {},
        "/textile": {},
        "/textile/simulator": {},
      });
    });
  });
});
