# Test data fixtures

This folder and json data it contains are solely aimed at being used for tests:

- Unit tests (`*Test.elm`)
- API server tests (`server.spec.js`)

Notes:

- These JSON files are maintained by hand. There's no script for automating extraction or synchronization. It's highly possible that a resource exists in `text/fixtures` and not in `public/data`, or the other way around.
- EcoInvent processes use a fixed `0.42` value for individual impact details (`acd`, `cch`, etc.); `ecs`, as a non-reversible aggregate, still holds the production value when the process exists in `public/data`.
- Process comments all have `<stripped for tests>` as their value, as they're huge and never subject of testing.
