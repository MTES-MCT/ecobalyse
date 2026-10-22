require("dotenv").config();
const fs = require("fs");
const path = require("path");
const { Elm } = require("./check-db-app");
const {
  getComponentConfigAsString,
  getDetailedProcessesAsString,
  getProcessesAsString,
} = require("./lib");

const fixtureRoot = "tests/fixtures";
const fixtureFiles = {
  countries: "countries.json",
  definitions: "impacts.json",
  food2Components: "food2/components.json",
  food2Examples: "food2/examples.json",
  food2ProductCategories: "food2/categories.json",
  foodIngredients: "food/ingredients.json",
  foodProductExamples: "food/examples.json",
  objectComponents: "object/components.json",
  objectExamples: "object/examples.json",
  objectProductCategories: "object/categories.json",
  processes: "processes.json",
  textileComponents: "textile/components.json",
  textileMaterials: "textile/materials.json",
  textileProductExamples: "textile/examples.json",
  textileProducts: "textile/products.json",
  transports: "transports.json",
  veliComponents: "veli/components.json",
  veliExamples: "veli/examples.json",
  veliProductCategories: "veli/categories.json",
};

function parseArgs(argv) {
  const unexpected = argv.filter((arg) => arg !== "--fixtures");
  if (unexpected.length > 0) {
    throw new Error(`Unexpected argument: ${unexpected.join(" ")}`);
  } else {
    return { checkFixtures: argv.includes("--fixtures") };
  }
}

function readFixtureFile(relativePath) {
  return fs.readFileSync(path.join(fixtureRoot, relativePath), "utf8");
}

function readFixtureFiles() {
  return {
    componentConfigJson: readFixtureFile("components/config.json"),
    files: Object.fromEntries(
      Object.entries(fixtureFiles).map(([fieldName, relativePath]) => [
        fieldName,
        readFixtureFile(relativePath),
      ]),
    ),
  };
}

const { checkFixtures } = parseArgs(process.argv.slice(2));
const elmApp = Elm.CheckDb.init({
  flags: {
    componentConfigJson: getComponentConfigAsString(),
    detailedProcessesJson: getDetailedProcessesAsString(),
    fixtureDb: checkFixtures ? readFixtureFiles() : null,
    nonDetailedProcessesJson: getProcessesAsString(),
  },
});

elmApp.ports.logAndExit.subscribe(({ message, status }) => {
  if (status > 0) {
    console.error(`🚨 ERROR: ${message}`);
  } else {
    console.info(message);
  }
  process.exit(status);
});
