# Test data fixtures

This folder and json data it contains are solely aimed at being used for tests:

- unit tests (`*Test.elm`)
- api server tests (`server.spec.js`)

Notes:

- EcoInvent processes use a fixed `0.42` value for individual impact details; `ecs`, as a non-reversible aggregate, still holds the actual value;
- Process comments all have `<stripped for tests>` as their value, as they're huge and never subject of testing.
