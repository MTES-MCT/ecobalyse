# Dependency solver for Elm, made in WebAssembly

This repo holds a dependency solver for the elm ecosystem compiled to a WebAssembly module.
The wasm module is published on npm, so you can easily use it in your JS projects with:

```js
let wasm = require("elm-solve-deps-wasm");
wasm.init();
let use_test = false; // solve for normal dependencies, not test dependencies
let additional_constraints = {}; // no additional package needed
let solution = wasm.solve_deps(
  elm_json_config, // the elm.json that we have to solve
  use_test,
  additional_constraints,
  fetchElmJson, // user defined (cf example-offline/dependency-provider-offline.js)
  listAvailableVersions // user defined (cf example-offline/dependency-provider-offline.js)
);
```

## Shrinking the .wasm size

Shrinking the generated WebAssembly package to the smallest size possible will benefit everyone using it as a dependency, so here is an attempt at doing it.
Most of the info required to [shrink the wasm size is available in the rustwasm reference book][shrink-wasm].
Here is a summary of the different techniques we use here.

- Compile with link time optimization (`lto`). In theory, this gives LLVM more opportunities to inline and prune functions.
- Use `opt-level = "z"` to optimize for size instead of for speed.
- Use the [`wee_alloc` allocator][wee_alloc] which is optimized for size instead of the default allocator, optimized for speed.
- Replace panic logic by abort with `panic = "abort"` and with [`wasm-snip --snip-rust-panicking-code`][wasm-snip].
- Use [`wasm-opt -Oz -o output.wasm input.wasm`][wasm-opt] on the output of wasm-pack. Remark that it's better to use the latest one from the binaryen project instead of the one shipped with wasm-pack automatically, so we add `wasm-opt = false` to wasm-pack config.
- Profile the generated wasm with [`twiggy`][twiggy] to find optimization opportunities. This requires adding `debug = true` to the release compilation profile, and `-g` to `wasm-opt`.

With the above tricks we start with a `.wasm` file weighing 470kb and end with a 251kb file!
Most of it comes from the `wasm-opt` tool.
Here is the detail of what each step brings:

- Initial `--release` size: 479kb.
- When using `wee_alloc`: 470kb.
- When also adding `wasm-opt -Oz`: 366kb.
- When also adding `lto = true` and `opt-level = "z"`: 276kb.
- When also adding `wasm-snip --snip-rust-panicking-code`: 271kb.
- When adding `debug = true` and using twiggy, I found out that there was a non-negligeable part of the wasm binary dedicated to formatting f64 numbers. But in fact, this never happens in our use case, so we can snipe it!
- When also adding `wasm-snip -p "core::fmt::float::<impl core::fmt::Display for f64>::fmt::.*"`: 251kb.

So in summary, the steps to get the most shrinked wasm module are the following:

```sh
wasm-pack build --target nodejs
wasm-snip --snip-rust-panicking-code -p "core::fmt::float::<impl core::fmt::Display for f64>::fmt::.*" -o snipped.wasm pkg/elm_solve_deps_wasm_bg.wasm
wasm-opt -Oz -o output.wasm snipped.wasm
cp output.wasm pkg/elm_solve_deps_wasm_bg.wasm
```

All that being said, if you don't want to bother installing `wasm-snip` and the latest `wasm-opt`, you can simply call:
```sh
wasm-pack build --profiling --target nodejs
```
and let the provided wasm-opt do its job, with a generated `.wasm` of size 276kb.

[shrink-wasm]: https://rustwasm.github.io/docs/book/reference/code-size.html
[wee_alloc]: https://github.com/rustwasm/wee_alloc
[wasm-snip]: https://github.com/rustwasm/wasm-snip
[wasm-opt]: https://rustwasm.github.io/docs/book/reference/code-size.html#use-the-wasm-opt-tool
[twiggy]: https://rustwasm.github.io/twiggy/index.html
