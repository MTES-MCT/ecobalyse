find-elm-dependencies
=====================

> Find elm dependencies of a given entry file.


## Installation

```bash
$ npm i find-elm-dependencies -S
```

## Usage

```js
var findAllDependencies = require('find-elm-dependencies').findAllDependencies;

findAllDependencies('./path/to/Main.elm')
  .then(function(dependencies) {
    console.log(dependencies);
  });

```


This was extracted from https://github.com/rtfeldman/node-elm-compiler
