const lib = require("../../lib");

describe("lib.index", () => {
  describe("filterLegacyFood1Paths", () => {
    test("should filter out food1 api and keep food2 ones", () => {
      const paths = {
        "/food": "x",
        "/food/countries": "x",
        "/food2": "x",
        "/food2/simulator": "x",
        "/textile": "x",
        "/textile/simulator": "x",
      };
      const filteredPaths = lib.filterLegacyFood1Paths(paths);
      expect(filteredPaths).toEqual({
        "/food2": "x",
        "/food2/simulator": "x",
        "/textile": "x",
        "/textile/simulator": "x",
      });
    });
  });
});
