#!/usr/bin/env node

var findAllDependencies = require('../index.js').findAllDependencies;

var entry = process.argv[2];

findAllDependencies(entry)
  .then(function(dependencies) {
    console.log(dependencies);
  });
