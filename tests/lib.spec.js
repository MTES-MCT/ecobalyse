const fs = require("fs");
const lib = require("../lib");

describe("Lib", () => {
  it("should throw if provided with an invalid data dir", () => {
    expect(() => lib.getDataFiles("foo")).toThrow(/not found in foo/);
  });
});
