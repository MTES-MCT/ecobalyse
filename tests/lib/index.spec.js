const lib = require("../../lib");

describe("lib.index", () => {
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
