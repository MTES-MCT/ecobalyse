require("dotenv").config();
const fs = require("fs");
const { Elm } = require("./compute-aggregated-app");


const elmApp = Elm.ComputeAggregated.init({
	"flags": {
		"definitionsString": fs.readFileSync("public/data/impacts.json", "utf-8"),
		"textileProcessesString": fs.readFileSync("public/data/textile/processes_impacts.json", "utf-8"),
		"foodProcessesString": fs.readFileSync("public/data/food/processes_impacts.json", "utf-8")
	}
});

elmApp.ports.export.subscribe(({ textileProcesses, foodProcesses }) => {
	try {
	  fs.writeFileSync('public/data/textile/processes_impacts.json', JSON.stringify(textileProcesses, null, 2));
	  fs.writeFileSync('public/data/food/processes_impacts.json', JSON.stringify(foodProcesses, null, 2));
		console.log("EXPORTED!");
	} catch (err) {
	  console.error(err);
	}
});
