const lib = require("../lib");

describe("Lib module", () => {
  describe("getDataFiles", () => {
    it("should throw if no data directory is provided", () => {
      expect(() => lib.getDataFiles()).toThrow(/must be provided/);
    });

    it("should throw if provided with an invalid data dir", () => {
      expect(() => lib.getDataFiles("foo")).toThrow(/not found in foo/);
    });
  });
});
