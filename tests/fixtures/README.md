# Test data fixtures

This folder and json data it contains are solely aimed at being used for tests:

- unit tests (`*Test./elm`)
- api server tests (`server.spec.js`)

Processes whose source is Ecoinvent keep every detailed impact, including `ecs`, set to `0.42`, so we never leak EcoInvent IP. Every other source keeps its real detailed impacts. Two fixture-only processes have no production impacts and stay at `0.42`: the fake assembly process and the European wood sawing process. Process comments are replaced with `<stripped for tests>`. Unit and API score expectations follow this mix.
