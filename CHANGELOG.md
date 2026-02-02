# Changelog


## [8.4.0](https://github.com/MTES-MCT/ecobalyse/compare/v8.3.0..v8.4.0) (2026-02-02)



### 🚀 Features

- *(object,veli)* Implement use stage ([#1710](https://github.com/MTES-MCT/ecobalyse/issues/1710))
- *(explorer)* Add countries to object/veli explorers ([#1724](https://github.com/MTES-MCT/ecobalyse/issues/1724))
- Add ctcpa packaging selection ([#1697](https://github.com/MTES-MCT/ecobalyse/issues/1697))
- Add elm auto-formatting on git pre-commit ([#1736](https://github.com/MTES-MCT/ecobalyse/issues/1736))
- Introduce mass per unit for packagings ([#1718](https://github.com/MTES-MCT/ecobalyse/issues/1718))
- Render ecs for guests in processes explorer ([#1748](https://github.com/MTES-MCT/ecobalyse/issues/1748))

### 🪲 Bug Fixes

- *(ui)* Fix incomplete comparator chart legend when exported ([#1704](https://github.com/MTES-MCT/ecobalyse/issues/1704))
- Detailed impacts bug on object/veli ([#1709](https://github.com/MTES-MCT/ecobalyse/issues/1709))
- *(bo,ui)* Constrain comment cell height in processes admin ([#1712](https://github.com/MTES-MCT/ecobalyse/issues/1712))
- Preserve transformations ordering ([#1700](https://github.com/MTES-MCT/ecobalyse/issues/1700))
- *(object,ui)* Align impacts in object simulator details ([#1720](https://github.com/MTES-MCT/ecobalyse/issues/1720))
- *(object,veli)* Distinguish material & transform stage impacts in comparator ([#1734](https://github.com/MTES-MCT/ecobalyse/issues/1734))
- Add missing `/` to shareable url ([#1741](https://github.com/MTES-MCT/ecobalyse/issues/1741))

### 🚜 Refactor

- Use "stage" instead of "step" in the codebase ([#1738](https://github.com/MTES-MCT/ecobalyse/issues/1738))

### 📚 Documentation

- API is not versionned anymore ([#1742](https://github.com/MTES-MCT/ecobalyse/issues/1742))

### ⚙️ Miscellaneous Tasks

- Change default electric mix to India’s ([#1702](https://github.com/MTES-MCT/ecobalyse/issues/1702))
- Data update and add cff process ([#1708](https://github.com/MTES-MCT/ecobalyse/issues/1708))
- Update veli examples ([#1716](https://github.com/MTES-MCT/ecobalyse/issues/1716))
- Upgrade node dependencies, 2026-01 ([#1737](https://github.com/MTES-MCT/ecobalyse/issues/1737))
- Change terms agreement ([#1627](https://github.com/MTES-MCT/ecobalyse/issues/1627))
- Add privacy policy as Markdown ([#1747](https://github.com/MTES-MCT/ecobalyse/issues/1747))
- Remove versioning from frontend ([#1743](https://github.com/MTES-MCT/ecobalyse/issues/1743))


## [8.3.0](https://github.com/MTES-MCT/ecobalyse/compare/v8.2.0..v8.3.0) (2026-01-09)



### 🚀 Features

- *(admin,ui)* Render comment column in component admin ([#1639](https://github.com/MTES-MCT/ecobalyse/issues/1639))
- Add packaging from ctcpa ([#1615](https://github.com/MTES-MCT/ecobalyse/issues/1615))
- *(bo)* Add the token usage state to the users table ([#1633](https://github.com/MTES-MCT/ecobalyse/issues/1633))
- *(explorer)* Make explorer datasets searchable ([#1663](https://github.com/MTES-MCT/ecobalyse/issues/1663))
- *(explorer)* Freeze table header position to top when scrolling ([#1677](https://github.com/MTES-MCT/ecobalyse/issues/1677))
- Add new packaging processes ([#1685](https://github.com/MTES-MCT/ecobalyse/issues/1685))
- Unselect all in comparator ([#1695](https://github.com/MTES-MCT/ecobalyse/issues/1695))

### 🪲 Bug Fixes

- *(admin,ui)* Prevent unscrollable ui state ([#1636](https://github.com/MTES-MCT/ecobalyse/issues/1636))
- *(explorer)* Sort string columns alphabetically ([#1643](https://github.com/MTES-MCT/ecobalyse/issues/1643))
- *(ui)* Fix losing session data when navigating different versions ([#1694](https://github.com/MTES-MCT/ecobalyse/issues/1694))
- Revert bookmarks local storage update ([#1699](https://github.com/MTES-MCT/ecobalyse/issues/1699))

### ⚙️ Miscellaneous Tasks

- Cache elm deps ([#1635](https://github.com/MTES-MCT/ecobalyse/issues/1635))
- Serialize the JournalEntries values as string ([#1634](https://github.com/MTES-MCT/ecobalyse/issues/1634))
- Upgrade node dependencies, 2025-12-15 ([#1644](https://github.com/MTES-MCT/ecobalyse/issues/1644))
- Remove pef score ([#1628](https://github.com/MTES-MCT/ecobalyse/issues/1628))
- Remove obsolete suffix and cleanup ([#1651](https://github.com/MTES-MCT/ecobalyse/issues/1651))
- Update components ([#1641](https://github.com/MTES-MCT/ecobalyse/issues/1641))
- Update list of Veli examples ([#1661](https://github.com/MTES-MCT/ecobalyse/issues/1661))
- Update components from staging db ([#1666](https://github.com/MTES-MCT/ecobalyse/issues/1666))
- Update components from staging db ([#1667](https://github.com/MTES-MCT/ecobalyse/issues/1667))
- Update list of Object examples ([#1662](https://github.com/MTES-MCT/ecobalyse/issues/1662))
- Upgrade elm-review ([#1686](https://github.com/MTES-MCT/ecobalyse/issues/1686))
- Upgrade dependencies, 2026-01-05 ([#1687](https://github.com/MTES-MCT/ecobalyse/issues/1687))
- *(security)* Upgrade qs package ([#1688](https://github.com/MTES-MCT/ecobalyse/issues/1688))
- Various data updates : flax, elasthane and wool ([#1696](https://github.com/MTES-MCT/ecobalyse/issues/1696))
- Remove unused and obsolete npm dependencies ([#1698](https://github.com/MTES-MCT/ecobalyse/issues/1698))


## [8.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v8.1.0..v8.2.0) (2025-12-10)



### 🚀 Features

- Reorder bookmarks in comparison modal ([#1550](https://github.com/MTES-MCT/ecobalyse/issues/1550))
- *(bo)* Add component published status ([#1556](https://github.com/MTES-MCT/ecobalyse/issues/1556))
- *(bo)* Add SIREN to the users table ([#1577](https://github.com/MTES-MCT/ecobalyse/issues/1577))
- *(object)* Implement transports ([#1580](https://github.com/MTES-MCT/ecobalyse/issues/1580))
- Dump published components ([#1572](https://github.com/MTES-MCT/ecobalyse/issues/1572))

### 🪲 Bug Fixes

- Replace “score d’impact” by “coût environnemental” in the comparison tool legend ([#1545](https://github.com/MTES-MCT/ecobalyse/issues/1545))
- *(object)* Do not apply transport to assembly for a single item ([#1610](https://github.com/MTES-MCT/ecobalyse/issues/1610))

### ⚙️ Miscellaneous Tasks

- Rewrite v7 calls to a dedicated application ([#1474](https://github.com/MTES-MCT/ecobalyse/issues/1474))
- Sort ingredients.json and materials.json by id ([#1546](https://github.com/MTES-MCT/ecobalyse/issues/1546))
- Add veli object scope to transport processes ([#1559](https://github.com/MTES-MCT/ecobalyse/issues/1559))
- Stop reformatting the json files generated by ecobalyse-data ([#1542](https://github.com/MTES-MCT/ecobalyse/issues/1542))
- Stabilize process ids ([#1562](https://github.com/MTES-MCT/ecobalyse/issues/1562))
- Correct custom source ([#1567](https://github.com/MTES-MCT/ecobalyse/issues/1567))
- Add new object processes ([#1570](https://github.com/MTES-MCT/ecobalyse/issues/1570))
- Disable npm postinstall scripts ([#1586](https://github.com/MTES-MCT/ecobalyse/issues/1586))
- Add dependabot cooldown to improve security ([#1593](https://github.com/MTES-MCT/ecobalyse/issues/1593))
- Run transcrypt explicitly ([#1595](https://github.com/MTES-MCT/ecobalyse/issues/1595))
- Fix dependabot config ([#1594](https://github.com/MTES-MCT/ecobalyse/issues/1594))
- New export delete duplicate object processes ([#1587](https://github.com/MTES-MCT/ecobalyse/issues/1587))
- Add the “use” category to fuels ([#1581](https://github.com/MTES-MCT/ecobalyse/issues/1581))
- Convert wood processes to m3 ([#1576](https://github.com/MTES-MCT/ecobalyse/issues/1576))
- Unify transport processes ([#1588](https://github.com/MTES-MCT/ecobalyse/issues/1588))
- Correct locations for created activities ([#1603](https://github.com/MTES-MCT/ecobalyse/issues/1603))
- Add contrails to air freight ([#1607](https://github.com/MTES-MCT/ecobalyse/issues/1607))
- Hide ground beef and beef with bone ([#1626](https://github.com/MTES-MCT/ecobalyse/issues/1626))


## [8.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v8.0.0..v8.1.0) (2025-11-14)



### 🚀 Features

- Add metal incineration process ([#1461](https://github.com/MTES-MCT/ecobalyse/issues/1461))
- Add vehicle processes ([#1419](https://github.com/MTES-MCT/ecobalyse/issues/1419))
- *(object)* Handle product end of life collection strategies ([#1477](https://github.com/MTES-MCT/ecobalyse/issues/1477))
- *(component)* Load component life cycle configuration over HTTP/JSON ([#1482](https://github.com/MTES-MCT/ecobalyse/issues/1482))
- Replace Posthog with Plausible. ([#1504](https://github.com/MTES-MCT/ecobalyse/issues/1504))
- *(object)* Compute impacts against localized energy mixes ([#1511](https://github.com/MTES-MCT/ecobalyse/issues/1511))
- Allow renaming bookmarks ([#1506](https://github.com/MTES-MCT/ecobalyse/issues/1506))

### 🪲 Bug Fixes

- Use consistent json field naming. ([#1503](https://github.com/MTES-MCT/ecobalyse/issues/1503))
- Resynchronize the processes files with the ecobalyse-data repository ([#1505](https://github.com/MTES-MCT/ecobalyse/issues/1505))
- *(explorer)* Render empty distances as N/A in transport tables ([#1515](https://github.com/MTES-MCT/ecobalyse/issues/1515))
- Change the unit displayed in the comparator from µPts to Pts ([#1522](https://github.com/MTES-MCT/ecobalyse/issues/1522))
- *(openapi)* Add missing properties and schema ([#1536](https://github.com/MTES-MCT/ecobalyse/issues/1536))

### ⚙️ Miscellaneous Tasks

- Traduire le template d'issue en français ([#1465](https://github.com/MTES-MCT/ecobalyse/issues/1465))
- Add Sentry integration to the backend ([#1445](https://github.com/MTES-MCT/ecobalyse/issues/1445))
- Replace deprecated passlib ([#1469](https://github.com/MTES-MCT/ecobalyse/issues/1469))
- Remove obsolete `elements_json` field ([#1481](https://github.com/MTES-MCT/ecobalyse/issues/1481))
- Add location and rename sourceId->activityName ([#1507](https://github.com/MTES-MCT/ecobalyse/issues/1507))


## [8.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v7.2.0..v8.0.0) (2025-10-21)



### 🚀 Features

- End of life processes according to material type ([#1273](https://github.com/MTES-MCT/ecobalyse/issues/1273))
- *(object)* Implement basic end of life lifecycle stage ([#1444](https://github.com/MTES-MCT/ecobalyse/issues/1444))
- *(textile,data,api)* [**breaking**] Use UUIDs for material identifiers. ([#1285](https://github.com/MTES-MCT/ecobalyse/issues/1285))

### 🪲 Bug Fixes

- *(auth)* Require manual login confirmation ([#1398](https://github.com/MTES-MCT/ecobalyse/issues/1398))
- Correct wrong impacts and hide ARM-x86/64 diff ([#1415](https://github.com/MTES-MCT/ecobalyse/issues/1415))
- Validate version number param ([#1426](https://github.com/MTES-MCT/ecobalyse/issues/1426))
- Missing paraffin processes ([#1428](https://github.com/MTES-MCT/ecobalyse/issues/1428))
- *(ui)* Fix styling issue in textile layout ([#1443](https://github.com/MTES-MCT/ecobalyse/issues/1443))

### 🚜 Refactor

- Add elements model to the DB ([#1341](https://github.com/MTES-MCT/ecobalyse/issues/1341))

### ⚙️ Miscellaneous Tasks

- Add self hosting ([#1324](https://github.com/MTES-MCT/ecobalyse/issues/1324))
- Add back pg docker-compose for dev ([#1409](https://github.com/MTES-MCT/ecobalyse/issues/1409))
- Remove matomo tracking ([#1410](https://github.com/MTES-MCT/ecobalyse/issues/1410))
- Add countries (1/2) ([#1401](https://github.com/MTES-MCT/ecobalyse/issues/1401))
- Pin python version to 3.12.x to avoid psycopg-binary incompatibility ([#1425](https://github.com/MTES-MCT/ecobalyse/issues/1425))
- Transport data (2/2) ([#1404](https://github.com/MTES-MCT/ecobalyse/issues/1404))
- Upgrade node dependencies, 2025-10-15 ([#1451](https://github.com/MTES-MCT/ecobalyse/issues/1451))
- Add command to add multiple users at once ([#1459](https://github.com/MTES-MCT/ecobalyse/issues/1459))
- Add command to update processes from fixtures ([#1453](https://github.com/MTES-MCT/ecobalyse/issues/1453))
- Reintroduce matomo tracking. ([#1463](https://github.com/MTES-MCT/ecobalyse/issues/1463))


## [7.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v7.1.0..v7.2.0) (2025-09-25)



### 🚀 Features

- *(ui)* Update textile CTA links to regulatory version, add banner ([#1372](https://github.com/MTES-MCT/ecobalyse/issues/1372))
- *(object,ui)* Add support for component comments ([#1371](https://github.com/MTES-MCT/ecobalyse/issues/1371))
- *(object)* Improve json results serialization for debugging ([#1385](https://github.com/MTES-MCT/ecobalyse/issues/1385))

### 🪲 Bug Fixes

- *(object)* Apply transforms preserving material unit ([#1352](https://github.com/MTES-MCT/ecobalyse/issues/1352))
- *(api)* Fix openapi docs for country code. ([#1346](https://github.com/MTES-MCT/ecobalyse/issues/1346))
- Fixed food API examples (food "Carton" and "Cuisson") ([#1379](https://github.com/MTES-MCT/ecobalyse/issues/1379))
- Fixed mass validation message ([#1380](https://github.com/MTES-MCT/ecobalyse/issues/1380))
- *(api)* Fix JSON number reformatting ([#1383](https://github.com/MTES-MCT/ecobalyse/issues/1383))
- *(api)* Expose server fqdn and version to urls in responses ([#1381](https://github.com/MTES-MCT/ecobalyse/issues/1381))
- *(food,ui)* Expose ingredient process technical name ([#1386](https://github.com/MTES-MCT/ecobalyse/issues/1386))
- Don’t patch storage key for new auth system ([#1395](https://github.com/MTES-MCT/ecobalyse/issues/1395))
- *(ui)* Fix links to regulatory version ([#1397](https://github.com/MTES-MCT/ecobalyse/issues/1397))

### ⚙️ Miscellaneous Tasks

- Force food and objects section on CI build ([#1373](https://github.com/MTES-MCT/ecobalyse/issues/1373))
- Upgrade nodejs dependencies, 2025-09 ([#1382](https://github.com/MTES-MCT/ecobalyse/issues/1382))
- Don’t deploy prereleases ([#1394](https://github.com/MTES-MCT/ecobalyse/issues/1394))
- Add versions stats to scalingo cli ([#1384](https://github.com/MTES-MCT/ecobalyse/issues/1384))
- *(ui)* Revamp homepage layout and contents ([#1396](https://github.com/MTES-MCT/ecobalyse/issues/1396))


## [7.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v7.0.0..v7.1.0) (2025-09-08)



### 🚀 Features

- Implement Agribalyse 3.2 ([#1201](https://github.com/MTES-MCT/ecobalyse/issues/1201))
- *(bo)* Add API to list processes ([#1167](https://github.com/MTES-MCT/ecobalyse/issues/1167))
- *(bo)* Add processes admin ui ([#1306](https://github.com/MTES-MCT/ecobalyse/issues/1306))
- *(bo)* Allow searching process source, scopes and categories. ([#1321](https://github.com/MTES-MCT/ecobalyse/issues/1321))
- *(bo)* Allow exporting selected components. ([#1339](https://github.com/MTES-MCT/ecobalyse/issues/1339))
- *(object)* Add durability slider ([#1343](https://github.com/MTES-MCT/ecobalyse/issues/1343))

### 🪲 Bug Fixes

- Patch old versions selector to hide unreleased versions ([#1297](https://github.com/MTES-MCT/ecobalyse/issues/1297))
- Corrected oil and seed/nuts densities ([#1294](https://github.com/MTES-MCT/ecobalyse/issues/1294))
- Remove creosote (or related flows) and acetamiprid ([#1279](https://github.com/MTES-MCT/ecobalyse/issues/1279))
- Fixed scenarios ([#1316](https://github.com/MTES-MCT/ecobalyse/issues/1316))
- *(ui)* Fix api request examples in the share tab. ([#1348](https://github.com/MTES-MCT/ecobalyse/issues/1348))

### ⚙️ Miscellaneous Tasks

- Improve token error feedback ([#1291](https://github.com/MTES-MCT/ecobalyse/issues/1291))
- List and parse scalingo logs ([#1293](https://github.com/MTES-MCT/ecobalyse/issues/1293))
- Upgrade posthog deps ([#1301](https://github.com/MTES-MCT/ecobalyse/issues/1301))
- Npm dependencies upgrades, 2025-08 ([#1317](https://github.com/MTES-MCT/ecobalyse/issues/1317))
- Fix food ids and densities  ([#1323](https://github.com/MTES-MCT/ecobalyse/issues/1323))
- Restored last ingredient ids identity between v7.0.0 and next version ([#1330](https://github.com/MTES-MCT/ecobalyse/issues/1330))
- Add board processes ([#1331](https://github.com/MTES-MCT/ecobalyse/issues/1331))
- Fixed cocoa butter ([#1340](https://github.com/MTES-MCT/ecobalyse/issues/1340))
- Less eggs for now ([#1344](https://github.com/MTES-MCT/ecobalyse/issues/1344))
- Add object scope to veli processes ([#1347](https://github.com/MTES-MCT/ecobalyse/issues/1347))
- Update components list for Object ([#1349](https://github.com/MTES-MCT/ecobalyse/issues/1349))
- Create product examples for object ([#1350](https://github.com/MTES-MCT/ecobalyse/issues/1350))


## [7.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v6.1.1..v7.0.0) (2025-07-29)



### 🚀 Features

- *(sec)* Allow configuring rate limiting ([#1214](https://github.com/MTES-MCT/ecobalyse/issues/1214))
- *(ui)* Improve error ux on expired magic link ([#1225](https://github.com/MTES-MCT/ecobalyse/issues/1225))
- Add sawing process ([#1179](https://github.com/MTES-MCT/ecobalyse/issues/1179))
- Add veli processes ([#1194](https://github.com/MTES-MCT/ecobalyse/issues/1194))
- Improve KPI tracking with Posthog ([#1222](https://github.com/MTES-MCT/ecobalyse/issues/1222))
- *(textile)* [**breaking**] Remove the traceability parameter. ([#1237](https://github.com/MTES-MCT/ecobalyse/issues/1237))
- Add pretreatment dyeing average aquatic pollution scenario ([#1232](https://github.com/MTES-MCT/ecobalyse/issues/1232))
- Allow configuring version polling interval ([#1283](https://github.com/MTES-MCT/ecobalyse/issues/1283))
- *(bo)* Add user accounts admin ([#1266](https://github.com/MTES-MCT/ecobalyse/issues/1266))

### 🪲 Bug Fixes

- JSON parsing in versions ([#1212](https://github.com/MTES-MCT/ecobalyse/issues/1212))
- *(ui)* Don't scrolltop on explorer modal closed ([#1218](https://github.com/MTES-MCT/ecobalyse/issues/1218))
- Remove displayName duplicates ([#1249](https://github.com/MTES-MCT/ecobalyse/issues/1249))
- Fix analytics initialization procedure. ([#1252](https://github.com/MTES-MCT/ecobalyse/issues/1252))
- Fix Sentry express instrumentation ([#1254](https://github.com/MTES-MCT/ecobalyse/issues/1254))
- Fix api requests logging ([#1258](https://github.com/MTES-MCT/ecobalyse/issues/1258))
- Update CSP for posthog requirements ([#1259](https://github.com/MTES-MCT/ecobalyse/issues/1259))
- *(api)* Filter food api transform processes ([#1275](https://github.com/MTES-MCT/ecobalyse/issues/1275))
- *(api)* Fix textile api product field docs ([#1278](https://github.com/MTES-MCT/ecobalyse/issues/1278))
- *(textile)* [**breaking**] Use low voltage FR elec at the utilization step, medium voltage otherwise ([#1276](https://github.com/MTES-MCT/ecobalyse/issues/1276))
- Cache password verification to improve perfs ([#1284](https://github.com/MTES-MCT/ecobalyse/issues/1284))
- *(textile)* [**breaking**] Apply bleaching pretreatments energy mix impacts ([#1282](https://github.com/MTES-MCT/ecobalyse/issues/1282))
- *(textile)* Ensure examples use default product category trims ([#1287](https://github.com/MTES-MCT/ecobalyse/issues/1287))
- *(textile)* [**breaking**] Limit printing surface ratio to 80% max ([#1277](https://github.com/MTES-MCT/ecobalyse/issues/1277))

### 🚜 Refactor

- Let invalid cooking process be detected as a compilation error ([#1289](https://github.com/MTES-MCT/ecobalyse/issues/1289))

### ⚙️ Miscellaneous Tasks

- Wtu m3 eq ([#1229](https://github.com/MTES-MCT/ecobalyse/issues/1229))
- Update default trims following feedback ([#1236](https://github.com/MTES-MCT/ecobalyse/issues/1236))
- Upgrade node.js and Elm deps, 2025-07 ([#1256](https://github.com/MTES-MCT/ecobalyse/issues/1256))
- Improve general CSP configuration ([#1262](https://github.com/MTES-MCT/ecobalyse/issues/1262))
- New pasta and soups ([#1221](https://github.com/MTES-MCT/ecobalyse/issues/1221))
- Add mention in the API about the persistence of ids ([#1267](https://github.com/MTES-MCT/ecobalyse/issues/1267))
- Restored the `oilseed-feed` ([#1255](https://github.com/MTES-MCT/ecobalyse/issues/1255))
- Change elec name ([#1288](https://github.com/MTES-MCT/ecobalyse/issues/1288))


## [6.1.1](https://github.com/MTES-MCT/ecobalyse/compare/v6.1.0..v6.1.1) (2025-07-02)



### 🪲 Bug Fixes

- Add uv to scalingo when updating version ([#1210](https://github.com/MTES-MCT/ecobalyse/issues/1210))


## [6.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v6.0.0..v6.1.0) (2025-07-02)



### 🚀 Features

- *(ui)* Add an alert about old user accounts deletion ([#1205](https://github.com/MTES-MCT/ecobalyse/issues/1205))
- *(ui)* Improve alert on existing user account ([#1208](https://github.com/MTES-MCT/ecobalyse/issues/1208))
- *(ui)* Exclude draft and pre-releases from version dropdown. ([#1206](https://github.com/MTES-MCT/ecobalyse/issues/1206))

### 🪲 Bug Fixes

- Add missing `uv run` ([#1204](https://github.com/MTES-MCT/ecobalyse/issues/1204))
- *(backend)* Versions url rewriting ([#1209](https://github.com/MTES-MCT/ecobalyse/issues/1209))


## [6.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v5.0.1..v6.0.0) (2025-07-02)



### 🚀 Features

- *(bo)* Allow duplicating components ([#1064](https://github.com/MTES-MCT/ecobalyse/issues/1064))
- *(bo)* Add a button to export components json db ([#1067](https://github.com/MTES-MCT/ecobalyse/issues/1067))
- *(bo)* Add an individual component export button ([#1071](https://github.com/MTES-MCT/ecobalyse/issues/1071))
- Add missing meat ingredients ([#960](https://github.com/MTES-MCT/ecobalyse/issues/960))
- Add object processes ([#1088](https://github.com/MTES-MCT/ecobalyse/issues/1088))
- *(backend)* [**breaking**] Introduce new auth system ([#1090](https://github.com/MTES-MCT/ecobalyse/issues/1090))
- Add plastic extrusion ([#1123](https://github.com/MTES-MCT/ecobalyse/issues/1123))
- Add success notification on api token copied. ([#1145](https://github.com/MTES-MCT/ecobalyse/issues/1145))
- Display land occupation explorer ([#1125](https://github.com/MTES-MCT/ecobalyse/issues/1125))
- *(bo)* Allow editing component scopes ([#1118](https://github.com/MTES-MCT/ecobalyse/issues/1118))
- Textile component in object ([#1157](https://github.com/MTES-MCT/ecobalyse/issues/1157))
- *(ui)* Update the notification system to use DSFR ([#1164](https://github.com/MTES-MCT/ecobalyse/issues/1164))
- Add journaling of actions ([#1148](https://github.com/MTES-MCT/ecobalyse/issues/1148))
- Add new user organization type. ([#1178](https://github.com/MTES-MCT/ecobalyse/issues/1178))
- *(textile,ui)* Add link to product category explorer ([#1182](https://github.com/MTES-MCT/ecobalyse/issues/1182))
- Add link to privacy policy page. ([#1181](https://github.com/MTES-MCT/ecobalyse/issues/1181))
- *(object)* Restrict available transforms by material constraints ([#1180](https://github.com/MTES-MCT/ecobalyse/issues/1180))
- *(veli)* Enable veli explorer ([#1191](https://github.com/MTES-MCT/ecobalyse/issues/1191))
- *(bo,ui)* Introduce back-office sections ([#1195](https://github.com/MTES-MCT/ecobalyse/issues/1195))
- Display cropGroup and Scenario in Ingredient Explorer ([#1185](https://github.com/MTES-MCT/ecobalyse/issues/1185))

### 🪲 Bug Fixes

- Default to empty string on BACKEND_API_URL not set ([#1068](https://github.com/MTES-MCT/ecobalyse/issues/1068))
- Properly decode json processes on login ([#1083](https://github.com/MTES-MCT/ecobalyse/issues/1083))
- Use static backend url ([#1135](https://github.com/MTES-MCT/ecobalyse/issues/1135))
- *(textile)* Update skirt category default repair cost ([#1138](https://github.com/MTES-MCT/ecobalyse/issues/1138))
- *(textile)* Siwtch to default price on product category change. ([#1137](https://github.com/MTES-MCT/ecobalyse/issues/1137))
- Handle reusing outdated magic links. ([#1141](https://github.com/MTES-MCT/ecobalyse/issues/1141))
- Negative impacts on lentils ([#1127](https://github.com/MTES-MCT/ecobalyse/issues/1127))
- Remove negative LDU by better balancing Transformation to arable land ([#1144](https://github.com/MTES-MCT/ecobalyse/issues/1144))
- *(textile)* Exclude trims weight before the Making step ([#1139](https://github.com/MTES-MCT/ecobalyse/issues/1139))
- Force recomputation of land occupations ([#1132](https://github.com/MTES-MCT/ecobalyse/issues/1132))
- Improve e2e tests reliability wrt notifications ([#1176](https://github.com/MTES-MCT/ecobalyse/issues/1176))
- *(textile)* Update docs link for ennobling. ([#1177](https://github.com/MTES-MCT/ecobalyse/issues/1177))
- 500 error on journal history ([#1184](https://github.com/MTES-MCT/ecobalyse/issues/1184))
- *(ui)* Prevent scrolling on explorer modal opened ([#1187](https://github.com/MTES-MCT/ecobalyse/issues/1187))
- *(api)* Fix typo in printing api docs ([#1190](https://github.com/MTES-MCT/ecobalyse/issues/1190))
- *(ui)* Fix explorer barcharts width ([#1193](https://github.com/MTES-MCT/ecobalyse/issues/1193))
- *(textile)* Compute printing impacts from surface ([#1119](https://github.com/MTES-MCT/ecobalyse/issues/1119))
- *(veli)* Hide or show veli section depending on env ([#1200](https://github.com/MTES-MCT/ecobalyse/issues/1200))
- *(food,textile,ui)* Fix page scroll issues ([#1198](https://github.com/MTES-MCT/ecobalyse/issues/1198))
- *(textile,ui)* Exclude empty components from available choices ([#1202](https://github.com/MTES-MCT/ecobalyse/issues/1202))
- *(textile)* Fix toxicity impacts computation for printing ([#1203](https://github.com/MTES-MCT/ecobalyse/issues/1203))

### 🚜 Refactor

- Merge processes in a single file for cross-domain reusability ([#1072](https://github.com/MTES-MCT/ecobalyse/issues/1072))
- Generalize uuid parsing result errors ([#1107](https://github.com/MTES-MCT/ecobalyse/issues/1107))
- Improve activities to create ([#1150](https://github.com/MTES-MCT/ecobalyse/issues/1150))
- Handle empty responses from the backend api ([#1189](https://github.com/MTES-MCT/ecobalyse/issues/1189))
- *(bo,ui)* Restrict component to set a single scope ([#1196](https://github.com/MTES-MCT/ecobalyse/issues/1196))

### ⚙️ Miscellaneous Tasks

- Upgrade node dependencies, 2025-05 ([#1065](https://github.com/MTES-MCT/ecobalyse/issues/1065))
- Update ecobalyse data sync ([#1086](https://github.com/MTES-MCT/ecobalyse/issues/1086))
- Test versions ([#1076](https://github.com/MTES-MCT/ecobalyse/issues/1076))
- Cleanup object ([#1089](https://github.com/MTES-MCT/ecobalyse/issues/1089))
- Replace elec process medium voltage by low voltage ([#1121](https://github.com/MTES-MCT/ecobalyse/issues/1121))
- Use uv instead of pipenv for `score_history` ([#1130](https://github.com/MTES-MCT/ecobalyse/issues/1130))
- Fix `scalingo` deploy ([#1131](https://github.com/MTES-MCT/ecobalyse/issues/1131))
- Upgade node dependencies, 2025-06 ([#1140](https://github.com/MTES-MCT/ecobalyse/issues/1140))
- Improve playwright test config ([#1142](https://github.com/MTES-MCT/ecobalyse/issues/1142))
- *(textile)* Update upcycled tshirt example. ([#1136](https://github.com/MTES-MCT/ecobalyse/issues/1136))
- Reduce sentry tracesSampleRate ([#1147](https://github.com/MTES-MCT/ecobalyse/issues/1147))
- *(api,food)* Remove deprecated GET /food endpoint documentation ([#1175](https://github.com/MTES-MCT/ecobalyse/issues/1175))


## [5.0.1](https://github.com/MTES-MCT/ecobalyse/compare/v5.0.0..v5.0.1) (2025-04-29)



### 🪲 Bug Fixes

- *(food,ui)* Render ingredient technical process name tooltip ([#1059](https://github.com/MTES-MCT/ecobalyse/issues/1059))


## [5.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v4.0.1..v5.0.0) (2025-04-28)



### 🚀 Features

- *(object)* Add plastic transformation process ([#949](https://github.com/MTES-MCT/ecobalyse/issues/949))
- Allow customize component element final mass ([#959](https://github.com/MTES-MCT/ecobalyse/issues/959))
- *(object,ui)* Allow adding component element transforms ([#967](https://github.com/MTES-MCT/ecobalyse/issues/967))
- *(object,ui)* Allow updating a component element material. ([#969](https://github.com/MTES-MCT/ecobalyse/issues/969))
- *(object,ui)* Allow adding a new element to a component ([#979](https://github.com/MTES-MCT/ecobalyse/issues/979))
- *(object,ui)* Allow set a custom component name ([#981](https://github.com/MTES-MCT/ecobalyse/issues/981))
- Store and render app version along bookmarks ([#989](https://github.com/MTES-MCT/ecobalyse/issues/989))
- *(object,ui)* Allow multiple component instances ([#1001](https://github.com/MTES-MCT/ecobalyse/issues/1001))
- *(object)* Render lifecycle stage impacts data ([#1008](https://github.com/MTES-MCT/ecobalyse/issues/1008))
- Minimalistic component back-office ([#1016](https://github.com/MTES-MCT/ecobalyse/issues/1016))
- *(back-office)* Allow admins to update components ([#1034](https://github.com/MTES-MCT/ecobalyse/issues/1034))

### 🪲 Bug Fixes

- Explicit strategies and htc/htn fixes ([#952](https://github.com/MTES-MCT/ecobalyse/issues/952))
- Memory leak in node 20.16 and 20.17 ([#958](https://github.com/MTES-MCT/ecobalyse/issues/958))
- *(security)* Upgrade django to 5.1.7. ([#966](https://github.com/MTES-MCT/ecobalyse/issues/966))
- Re-allow overriding spinning country. ([#917](https://github.com/MTES-MCT/ecobalyse/issues/917))
- *(food,ui)* Fix food transform processes list not scoped ([#990](https://github.com/MTES-MCT/ecobalyse/issues/990))
- *(object,ui)* Fix string representation of custom component items ([#996](https://github.com/MTES-MCT/ecobalyse/issues/996))
- *(api)* Improve API docs and JSON data validation ([#1021](https://github.com/MTES-MCT/ecobalyse/issues/1021))

### 🚜 Refactor

- Read changelog from local file ([#964](https://github.com/MTES-MCT/ecobalyse/issues/964))
- Decouple ingredient/material id from process id ([#1022](https://github.com/MTES-MCT/ecobalyse/issues/1022))

### ⚙️ Miscellaneous Tasks

- *(food,textile,api)* [**breaking**] Remove deprecated API endpoints. ([#951](https://github.com/MTES-MCT/ecobalyse/issues/951))
- Rename ingredients ([#957](https://github.com/MTES-MCT/ecobalyse/issues/957))
- Upgrade node dependencies, 2025-03 ([#965](https://github.com/MTES-MCT/ecobalyse/issues/965))
- Data JSON export refactor ([#968](https://github.com/MTES-MCT/ecobalyse/issues/968))
- Add issue template ([#972](https://github.com/MTES-MCT/ecobalyse/issues/972))
- Rename bug report template file ([#973](https://github.com/MTES-MCT/ecobalyse/issues/973))
- Upgrade nodejs and python dependencies, 2025-03-31 ([#987](https://github.com/MTES-MCT/ecobalyse/issues/987))
- Upgrade django to 5.1.8 ([#1007](https://github.com/MTES-MCT/ecobalyse/issues/1007))
- Impacts from brightway switch ([#993](https://github.com/MTES-MCT/ecobalyse/issues/993))
- Replace plastic component ([#1017](https://github.com/MTES-MCT/ecobalyse/issues/1017))
- Update process model to require sourceId ([#1039](https://github.com/MTES-MCT/ecobalyse/issues/1039))
- Supress long-term impacts (new export from ecobalyse-data#63) ([#1010](https://github.com/MTES-MCT/ecobalyse/issues/1010))
- Create local test component data ([#1045](https://github.com/MTES-MCT/ecobalyse/issues/1045))
- Lower Uranium FRU (new export from ecobalyse-data#71) ([#1018](https://github.com/MTES-MCT/ecobalyse/issues/1018))
- Hide some ingredients ([#1040](https://github.com/MTES-MCT/ecobalyse/issues/1040))
- Update home page ([#1041](https://github.com/MTES-MCT/ecobalyse/issues/1041))


## [4.0.1](https://github.com/MTES-MCT/ecobalyse/compare/v4.0.0..v4.0.1) (2025-03-04)



### ⚙️ Miscellaneous Tasks

- Deprecate textile simulator API GET endpoints. ([#954](https://github.com/MTES-MCT/ecobalyse/issues/954))


## [4.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v3.1.0..v4.0.0) (2025-03-04)



### 🚀 Features

- Add pre-treatments and update bleaching process ([#898](https://github.com/MTES-MCT/ecobalyse/issues/898))
- *(textile,ui)* Apply default trims on product category change ([#910](https://github.com/MTES-MCT/ecobalyse/issues/910))
- Add link to docs in trims section. ([#911](https://github.com/MTES-MCT/ecobalyse/issues/911))
- Update finishing ([#906](https://github.com/MTES-MCT/ecobalyse/issues/906))
- *(textile)* Add pre-treatments at the ennobling step. ([#916](https://github.com/MTES-MCT/ecobalyse/issues/916))
- Update aquatic pollution and pre-treatments computations ([#928](https://github.com/MTES-MCT/ecobalyse/issues/928))
- [**breaking**] Replace dyeing medium parameter with dyeing process type. ([#941](https://github.com/MTES-MCT/ecobalyse/issues/941))
- *(food)* Add transport cooling column to ingredients explorer. ([#950](https://github.com/MTES-MCT/ecobalyse/issues/950))

### 🪲 Bug Fixes

- Include trims impacts to score without durability. ([#912](https://github.com/MTES-MCT/ecobalyse/issues/912))
- *(security)* Upgrade sentry libs to v8.49.0 ([#918](https://github.com/MTES-MCT/ecobalyse/issues/918))
- Remove the sourceId from the explorer ([#947](https://github.com/MTES-MCT/ecobalyse/issues/947))

### 📚 Documentation

- Add FAQ entry about security & self-hosting. ([#919](https://github.com/MTES-MCT/ecobalyse/issues/919))

### ⚙️ Miscellaneous Tasks

- *(data)* Update fast fashion examples nb of references. ([#908](https://github.com/MTES-MCT/ecobalyse/issues/908))
- For bleaching set etf to 0 ([#914](https://github.com/MTES-MCT/ecobalyse/issues/914))
- Check ecobalyse-data sync for PR ([#915](https://github.com/MTES-MCT/ecobalyse/issues/915))
- Sync ecobalyse-data after bw update ([#920](https://github.com/MTES-MCT/ecobalyse/issues/920))
- Doubts on the lamb, hide it for now ([#927](https://github.com/MTES-MCT/ecobalyse/issues/927))
- Upgrade dependencies, 2025, Feb 12. ([#938](https://github.com/MTES-MCT/ecobalyse/issues/938))
- *(textile)* Remove obsolete waste for material ([#940](https://github.com/MTES-MCT/ecobalyse/issues/940))
- Use new deployment stack `scalingo-22` ([#939](https://github.com/MTES-MCT/ecobalyse/issues/939))
- WFLDB export from simapro ([#942](https://github.com/MTES-MCT/ecobalyse/issues/942))
- Sync from ecobalyse-data#48 ([#944](https://github.com/MTES-MCT/ecobalyse/issues/944))
- Update wool "nouvelle filière" with new impacts ([#943](https://github.com/MTES-MCT/ecobalyse/issues/943))
- Convert to camelCase json keys ([#946](https://github.com/MTES-MCT/ecobalyse/issues/946))
- Enable all verticals in review apps ([#953](https://github.com/MTES-MCT/ecobalyse/issues/953))
- Update ingredient name in score history ([#948](https://github.com/MTES-MCT/ecobalyse/issues/948))


## [3.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v3.0.0..v3.1.0) (2025-01-23)



### 🚀 Features

- Show heat, elec, waste, density in process explorer. ([#901](https://github.com/MTES-MCT/ecobalyse/issues/901))
- Handle component process transforms ([#897](https://github.com/MTES-MCT/ecobalyse/issues/897))
- Render component transforms ([#907](https://github.com/MTES-MCT/ecobalyse/issues/907))

### 🪲 Bug Fixes

- Avoid empty process aliases. ([#899](https://github.com/MTES-MCT/ecobalyse/issues/899))
- *(security)* Upgrade django to 5.1.5. ([#900](https://github.com/MTES-MCT/ecobalyse/issues/900))
- Hide link to food from the homepage. ([#904](https://github.com/MTES-MCT/ecobalyse/issues/904))
- Restrict selectable components to scoped ones. ([#905](https://github.com/MTES-MCT/ecobalyse/issues/905))

### 🚜 Refactor

- Improve YAML gh action legibility. ([#896](https://github.com/MTES-MCT/ecobalyse/issues/896))
- Merge component and process dbs in-memory. ([#903](https://github.com/MTES-MCT/ecobalyse/issues/903))

### ⚙️ Miscellaneous Tasks

- Add python build libs to .gitignore. ([#895](https://github.com/MTES-MCT/ecobalyse/issues/895))
- Update data files ([#889](https://github.com/MTES-MCT/ecobalyse/issues/889))
- Rely on process UUID instead of alias in code. ([#902](https://github.com/MTES-MCT/ecobalyse/issues/902))


## [3.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.7.0..v3.0.0) (2025-01-13)



### 🚀 Features

- Generalize density, electricity, heat and waste process fields ([#855](https://github.com/MTES-MCT/ecobalyse/issues/855))
- *(data)* Ensure consistent nullable alias field in all processes files. ([#862](https://github.com/MTES-MCT/ecobalyse/issues/862))
- Add betagouv logo. ([#848](https://github.com/MTES-MCT/ecobalyse/issues/848))
- *(data)* Unified, cross-domain processes file format. ([#866](https://github.com/MTES-MCT/ecobalyse/issues/866))
- *(data)* Validate processes files against a JSON schema. ([#869](https://github.com/MTES-MCT/ecobalyse/issues/869))
- *(data,textile)* Add trim process and components data. ([#824](https://github.com/MTES-MCT/ecobalyse/issues/824))
- *(textile)* Implement trims. ([#873](https://github.com/MTES-MCT/ecobalyse/issues/873))
- *(data,ui)* Add trims to more textile examples, render them in explorer ([#876](https://github.com/MTES-MCT/ecobalyse/issues/876))
- Allow expanding trim details. ([#877](https://github.com/MTES-MCT/ecobalyse/issues/877))
- Allow staff to access detailed impacts from explorer. ([#878](https://github.com/MTES-MCT/ecobalyse/issues/878))

### 🪲 Bug Fixes

- *(food)* [**breaking**] Food processes identifiers are now UUIDs ([#844](https://github.com/MTES-MCT/ecobalyse/issues/844))
- *(data)* [**breaking**] Update textile process ids to use UUID format ([#858](https://github.com/MTES-MCT/ecobalyse/issues/858))
- Data pipeline with new UUIDs ([#857](https://github.com/MTES-MCT/ecobalyse/issues/857))
- Fix api error with old versions ([#851](https://github.com/MTES-MCT/ecobalyse/issues/851))
- Broken homepage after upgrading highcharts ([#863](https://github.com/MTES-MCT/ecobalyse/issues/863))
- *(dev)* Fix npm ci error with `transcrypt` ([#870](https://github.com/MTES-MCT/ecobalyse/issues/870))
- Correct data on trims ([#879](https://github.com/MTES-MCT/ecobalyse/issues/879))
- Warn on session data decoding error. ([#884](https://github.com/MTES-MCT/ecobalyse/issues/884))
- *(textile)* Apply durability to trims impacts. ([#886](https://github.com/MTES-MCT/ecobalyse/issues/886))
- Update PEF score label. ([#887](https://github.com/MTES-MCT/ecobalyse/issues/887))
- Add missing env and allow workflow dispatch for release creation ([#892](https://github.com/MTES-MCT/ecobalyse/issues/892))

### 🚜 Refactor

- Move textile step_usage field to categories. ([#850](https://github.com/MTES-MCT/ecobalyse/issues/850))
- *(data)* Move textile process "correctif" to comment ([#852](https://github.com/MTES-MCT/ecobalyse/issues/852))
- Add encrypted detailed impacts files to the source code ([#840](https://github.com/MTES-MCT/ecobalyse/issues/840))
- Abstract components. ([#872](https://github.com/MTES-MCT/ecobalyse/issues/872))
- Order json keys ([#871](https://github.com/MTES-MCT/ecobalyse/issues/871))

### 📚 Documentation

- Fix openapi food examples ([#867](https://github.com/MTES-MCT/ecobalyse/issues/867))

### ⚙️ Miscellaneous Tasks

- Increase API test timeout ([#853](https://github.com/MTES-MCT/ecobalyse/issues/853))
- *(data)* Remove system_description process field. ([#859](https://github.com/MTES-MCT/ecobalyse/issues/859))
- Upgrade dependencies, December 2024. ([#860](https://github.com/MTES-MCT/ecobalyse/issues/860))
- Remove obsolete/unused info textile process field. ([#861](https://github.com/MTES-MCT/ecobalyse/issues/861))
- *(data)* Merge PastoEco in a single file to speedup imports and fixed linking to AGB ([#833](https://github.com/MTES-MCT/ecobalyse/issues/833))
- Fix score_history workflow for transcrypt ([#864](https://github.com/MTES-MCT/ecobalyse/issues/864))
- Standardize number formatting across codebase ([#804](https://github.com/MTES-MCT/ecobalyse/issues/804))
- Standardize tkm unit ([#868](https://github.com/MTES-MCT/ecobalyse/issues/868))
- Remove obsolete pre-commit command. ([#874](https://github.com/MTES-MCT/ecobalyse/issues/874))
- Update trim api parameter ordering. ([#875](https://github.com/MTES-MCT/ecobalyse/issues/875))
- Remove data directory, now in `ecobalyse-data` repo ([#888](https://github.com/MTES-MCT/ecobalyse/issues/888))
- Update crypto-related docs. ([#890](https://github.com/MTES-MCT/ecobalyse/issues/890))
- *(security)* Upgrade django to >=5.1.4. ([#885](https://github.com/MTES-MCT/ecobalyse/issues/885))
- Readd score_history ([#891](https://github.com/MTES-MCT/ecobalyse/issues/891))


## [2.7.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.6.0..v2.7.0) (2024-12-05)



### 🚀 Features

- *(objects)* Introduce components for objects and veli ([#825](https://github.com/MTES-MCT/ecobalyse/issues/825))
- *(textile)* Update number of references index thresholds. ([#839](https://github.com/MTES-MCT/ecobalyse/issues/839))
- Introduce objects/veli components db and explorer ([#841](https://github.com/MTES-MCT/ecobalyse/issues/841))

### 🚜 Refactor

- Move weaving elec_pppm to textile wellknown. ([#843](https://github.com/MTES-MCT/ecobalyse/issues/843))

### ⚙️ Miscellaneous Tasks

- *(data)* New ingredients ([#814](https://github.com/MTES-MCT/ecobalyse/issues/814))
- *(data)* Add irrigation to the Ecoinvent organic cotton ([#832](https://github.com/MTES-MCT/ecobalyse/issues/832))


## [2.6.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.5.0..v2.6.0) (2024-11-20)



### 🚀 Features

- Add API FAQ page. ([#829](https://github.com/MTES-MCT/ecobalyse/issues/829))
- Intégration Laine woolmark ([#831](https://github.com/MTES-MCT/ecobalyse/issues/831))

### ⚙️ Miscellaneous Tasks

- Upgrade dependencies, Nov. 2024. ([#830](https://github.com/MTES-MCT/ecobalyse/issues/830))
- *(data)* Fixed typo paysane→paysanne ([#836](https://github.com/MTES-MCT/ecobalyse/issues/836))


## [2.5.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.4.0..v2.5.0) (2024-11-07)



### 🚀 Features

- Add bookmarks for objects ([#781](https://github.com/MTES-MCT/ecobalyse/issues/781))
- Add object explorer pages. ([#803](https://github.com/MTES-MCT/ecobalyse/issues/803))
- Distinguish Objects from Veli. ([#813](https://github.com/MTES-MCT/ecobalyse/issues/813))
- Display score without durability ([#815](https://github.com/MTES-MCT/ecobalyse/issues/815))
- Textile export ([#808](https://github.com/MTES-MCT/ecobalyse/issues/808))
- Object export ([#812](https://github.com/MTES-MCT/ecobalyse/issues/812))

### 🪲 Bug Fixes

- Create object encrypted file for versions ([#800](https://github.com/MTES-MCT/ecobalyse/issues/800))
- Improve object simulator. ([#799](https://github.com/MTES-MCT/ecobalyse/issues/799))
- Fix encoded display name field. ([#820](https://github.com/MTES-MCT/ecobalyse/issues/820))

### 🚜 Refactor

- Aggregate in python ([#794](https://github.com/MTES-MCT/ecobalyse/issues/794))
- Turn food process category into a list ([#795](https://github.com/MTES-MCT/ecobalyse/issues/795))
- Aggregate in python ([#807](https://github.com/MTES-MCT/ecobalyse/issues/807))

### ⚙️ Miscellaneous Tasks

- Upgrade dependencies to their latest version, Oct. 2024. ([#801](https://github.com/MTES-MCT/ecobalyse/issues/801))
- Add tolerance to tests comparison ([#810](https://github.com/MTES-MCT/ecobalyse/issues/810))
- *(data)* New export ([#819](https://github.com/MTES-MCT/ecobalyse/issues/819))

### ◀️ Revert

- "refactor: aggregate in python" ([#806](https://github.com/MTES-MCT/ecobalyse/issues/806))


## [2.4.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.3.0..v2.4.0) (2024-10-10)



### 🚀 Features

- Introduce first version of object interface ([#756](https://github.com/MTES-MCT/ecobalyse/issues/756))

### 🪲 Bug Fixes

- Sync food ([#759](https://github.com/MTES-MCT/ecobalyse/issues/759))
- Don't hide version information on staging ([#778](https://github.com/MTES-MCT/ecobalyse/issues/778))
- Reset physical durablility in regulatory mode ([#786](https://github.com/MTES-MCT/ecobalyse/issues/786))
- *(api,food)* Nullable fields weren't nullable anymore. ([#789](https://github.com/MTES-MCT/ecobalyse/issues/789))

### 🚜 Refactor

- Small textile explorer improvements ([#773](https://github.com/MTES-MCT/ecobalyse/issues/773))

### ⚙️ Miscellaneous Tasks

- Don't download draft releases ([#771](https://github.com/MTES-MCT/ecobalyse/issues/771))
- Remove `airTransportRatio` from examples ([#785](https://github.com/MTES-MCT/ecobalyse/issues/785))
- Cleanup package-lock.json. ([#787](https://github.com/MTES-MCT/ecobalyse/issues/787))
- Use builtin python action cache for pipenv ([#796](https://github.com/MTES-MCT/ecobalyse/issues/796))
- Improve changelog by using `git-cliff` ([#768](https://github.com/MTES-MCT/ecobalyse/issues/768))


## [2.3.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.2.0..v2.3.0) (2024-09-25)



### 🚀 Features

- DisplayName in the textile explorer, reordered columns ([#737](https://github.com/MTES-MCT/ecobalyse/issues/737))
- Add link to changelog in app footer. ([#748](https://github.com/MTES-MCT/ecobalyse/issues/748))
- AirTransportRatio should depend on durability ([#757](https://github.com/MTES-MCT/ecobalyse/issues/757))

### 🪲 Bug Fixes

- Encode physicalDurability parameter. ([#751](https://github.com/MTES-MCT/ecobalyse/issues/751))
- Check db integrity after building it ([#753](https://github.com/MTES-MCT/ecobalyse/issues/753))
- Fix github CI python build setup. ([#762](https://github.com/MTES-MCT/ecobalyse/issues/762))
- Stricter validation of POST json body passed to the textile API. ([#760](https://github.com/MTES-MCT/ecobalyse/issues/760))
- *(textile)* Distribution step had no inland road transports added. ([#761](https://github.com/MTES-MCT/ecobalyse/issues/761))
- Decode and validate all optionals. ([#764](https://github.com/MTES-MCT/ecobalyse/issues/764))
- Check uniqueness of JSON db primary keys at build time. ([#766](https://github.com/MTES-MCT/ecobalyse/issues/766))
- Update export outside of EU probability. ([#765](https://github.com/MTES-MCT/ecobalyse/issues/765))
- *(api)* Handle ingredient plane transport in food POST api. ([#769](https://github.com/MTES-MCT/ecobalyse/issues/769))

### 🚜 Refactor

- Removed duplicate identifier column in the food explorer ([#738](https://github.com/MTES-MCT/ecobalyse/issues/738))
- Sort most record properties and constructors. ([#736](https://github.com/MTES-MCT/ecobalyse/issues/736))
- Remove obsolete gitbook markdown parsing code. ([#744](https://github.com/MTES-MCT/ecobalyse/issues/744))
- Express all percentages as splits. ([#770](https://github.com/MTES-MCT/ecobalyse/issues/770))

### ⚙️ Miscellaneous Tasks

- *(data)* Removed recycled viscose (unsafe) ([#750](https://github.com/MTES-MCT/ecobalyse/issues/750))
- Upgrade deps (2024-09-12) ([#746](https://github.com/MTES-MCT/ecobalyse/issues/746))
- Render food api docs conditionally from env. ([#755](https://github.com/MTES-MCT/ecobalyse/issues/755))
- Filter sentry errors by env ([#752](https://github.com/MTES-MCT/ecobalyse/issues/752))
- Add PR template ([#767](https://github.com/MTES-MCT/ecobalyse/issues/767))
- Change waste ratio to input mass ([#711](https://github.com/MTES-MCT/ecobalyse/issues/711))


## [2.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.1.1..v2.2.0) (2024-09-12)



### 🚀 Features

- Add app version to openapi docs in the root endpoint. ([#726](https://github.com/MTES-MCT/ecobalyse/issues/726))
- Render app version details in the changelog. ([#725](https://github.com/MTES-MCT/ecobalyse/issues/725))
- Add holistic durability in exploratory mode ([#721](https://github.com/MTES-MCT/ecobalyse/issues/721))

### 🪲 Bug Fixes

- Use fabric processes to compute fabric waste ([#712](https://github.com/MTES-MCT/ecobalyse/issues/712))
- Don't add disabled step impacts to lifecycle totals. ([#719](https://github.com/MTES-MCT/ecobalyse/issues/719))
- Accept custom making complexity for upcycled garments. ([#723](https://github.com/MTES-MCT/ecobalyse/issues/723))
- Make scalingo not segfaulting. ([#728](https://github.com/MTES-MCT/ecobalyse/issues/728))
- Ensure express app is properly monitored by Sentry. ([#729](https://github.com/MTES-MCT/ecobalyse/issues/729))
- *(ci)* Check for ecobalyse-private when extracting the branch name ([#733](https://github.com/MTES-MCT/ecobalyse/issues/733))

### ⚙️ Miscellaneous Tasks

- Upgrade dependencies to their latest stable versions. ([#714](https://github.com/MTES-MCT/ecobalyse/issues/714))
- Security upgrades 2024-09-05 ([#730](https://github.com/MTES-MCT/ecobalyse/issues/730))
- *(data)* New impacts recycled cotton ([#718](https://github.com/MTES-MCT/ecobalyse/issues/718))
- *(data)* Ingredients ([#676](https://github.com/MTES-MCT/ecobalyse/issues/676))
- Optimize scalingo build ([#734](https://github.com/MTES-MCT/ecobalyse/issues/734))


## [2.1.1](https://github.com/MTES-MCT/ecobalyse/compare/v2.1.0..v2.1.1) (2024-09-02)



### 🪲 Bug Fixes

- *(ui)* Hide unreleased entry in production version selector. ([#715](https://github.com/MTES-MCT/ecobalyse/issues/715))


## [2.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.0.0..v2.1.0) (2024-09-02)



### 🚀 Features

- Serve multiple app versions ([#627](https://github.com/MTES-MCT/ecobalyse/issues/627))
- Add a button to access material/ingredient details ([#703](https://github.com/MTES-MCT/ecobalyse/issues/703))
- Add a version selector widget. ([#700](https://github.com/MTES-MCT/ecobalyse/issues/700))
- Allow downloading explorer data as CSV. ([#705](https://github.com/MTES-MCT/ecobalyse/issues/705))
- Version selector redirect to current location hash. ([#709](https://github.com/MTES-MCT/ecobalyse/issues/709))
- *(api,textile)* Make all country params optional. ([#713](https://github.com/MTES-MCT/ecobalyse/issues/713))
- Implement upcycling. ([#710](https://github.com/MTES-MCT/ecobalyse/issues/710))

### 🪲 Bug Fixes

- Add missing run command for score history ([#697](https://github.com/MTES-MCT/ecobalyse/issues/697))
- Avoid scrolling to top when using the explorer. ([#702](https://github.com/MTES-MCT/ecobalyse/issues/702))
- Add github token to worklows ([#704](https://github.com/MTES-MCT/ecobalyse/issues/704))
- Broken comparator charts on desynced cache data. ([#706](https://github.com/MTES-MCT/ecobalyse/issues/706))

### 🚜 Refactor

- Use python instead of bash to get data branch ([#685](https://github.com/MTES-MCT/ecobalyse/issues/685))
- Use python to patch files ([#701](https://github.com/MTES-MCT/ecobalyse/issues/701))

### ⚙️ Miscellaneous Tasks

- Serve version file with relative path ([#693](https://github.com/MTES-MCT/ecobalyse/issues/693))
- Upgrade Django to >=5.0.8. ([#695](https://github.com/MTES-MCT/ecobalyse/issues/695))


## [2.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.2..v2.0.0) (2024-07-30)



### 🚀 Features

- *(textile,api,ui,data)* [**breaking**] Update durability index computation ([#673](https://github.com/MTES-MCT/ecobalyse/issues/673))

### 🪲 Bug Fixes

- Update pull examples data ([#690](https://github.com/MTES-MCT/ecobalyse/issues/690))
- *(food)* Correct default origin for ingredients ([#683](https://github.com/MTES-MCT/ecobalyse/issues/683))

### 📚 Documentation

- Update readme ecobalyse private ([#687](https://github.com/MTES-MCT/ecobalyse/issues/687))

### ⚙️ Miscellaneous Tasks

- *(data,food)* Added Organic tomatos ([#665](https://github.com/MTES-MCT/ecobalyse/issues/665))
- *(ui)* Rename learning tab to exploratory tab. ([#684](https://github.com/MTES-MCT/ecobalyse/issues/684))
- Keep track of data-dir hash ([#686](https://github.com/MTES-MCT/ecobalyse/issues/686))
- Rename business services ([#692](https://github.com/MTES-MCT/ecobalyse/issues/692))


## [1.3.2](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.1..v1.3.2) (2024-07-23)



### 🪲 Bug Fixes

- Data-dir is needed before build ([#681](https://github.com/MTES-MCT/ecobalyse/issues/681))


## [1.3.1](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.0..v1.3.1) (2024-07-23)



### 🪲 Bug Fixes

- Add ecobalyse-private to release please ([#679](https://github.com/MTES-MCT/ecobalyse/issues/679))


## [1.3.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.2.0..v1.3.0) (2024-07-23)



### 🚀 Features

- *(food,ui)* Render agribalyse process name in ingredient selector. ([#659](https://github.com/MTES-MCT/ecobalyse/issues/659))
- Display current version in the footer ([#677](https://github.com/MTES-MCT/ecobalyse/issues/677))

### 🪲 Bug Fixes

- *(api)* Fix invalid openapi format ([#666](https://github.com/MTES-MCT/ecobalyse/issues/666))
- *(api)* Fix material shares sum rounding precision error. ([#670](https://github.com/MTES-MCT/ecobalyse/issues/670))
- Add missing condition in `release-please` workflow ([#671](https://github.com/MTES-MCT/ecobalyse/issues/671))

### 🚜 Refactor

- Remove `processes_impacts` from public repo ([#658](https://github.com/MTES-MCT/ecobalyse/issues/658))

### ⚙️ Miscellaneous Tasks

- Updated brightway, fixed some versions for jupyter, fixed the random issue with ground-beef-organic ([#628](https://github.com/MTES-MCT/ecobalyse/issues/628))
- Remove obsolete adjustable ecotox weighting feat. ([#663](https://github.com/MTES-MCT/ecobalyse/issues/663))
- *(ui)* Rename advanced tab to learning tab. ([#667](https://github.com/MTES-MCT/ecobalyse/issues/667))
- *(data,food)* Mask some ingredients for now ([#669](https://github.com/MTES-MCT/ecobalyse/issues/669))
- Provide a way to synchronise a branch of `ecobalyse-private` with a PR ([#672](https://github.com/MTES-MCT/ecobalyse/issues/672))


## [1.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.1.1..v1.2.0) (2024-07-10)



### 🚀 Features

- Add a link to the new product category gform. ([#626](https://github.com/MTES-MCT/ecobalyse/issues/626))
- Clarify ingredients names (bio, conv) and origin (France, EU, Hors-EU) ([#653](https://github.com/MTES-MCT/ecobalyse/issues/653))


## [1.1.1](https://github.com/MTES-MCT/ecobalyse/compare/v1.1.0..v1.1.1) (2024-07-10)



### 🪲 Bug Fixes

- *(ui)* Round Dtex number in the web UI. ([#649](https://github.com/MTES-MCT/ecobalyse/issues/649))
- *(api,ui)* Use custom waste/complexity and product defaults. ([#648](https://github.com/MTES-MCT/ecobalyse/issues/648))
- Rename organic cotton. ([#647](https://github.com/MTES-MCT/ecobalyse/issues/647))
- Avoid building detailed impacts in production. ([#656](https://github.com/MTES-MCT/ecobalyse/issues/656))

### 🚜 Refactor

- Don't use Django anymore to serve the files ([#646](https://github.com/MTES-MCT/ecobalyse/issues/646))

### 🎨 Styling

- Fixed ruff warnings ([#644](https://github.com/MTES-MCT/ecobalyse/issues/644))

### 🧪 Testing

- Use pytest instead of Django builtin ([#654](https://github.com/MTES-MCT/ecobalyse/issues/654))

### ⚙️ Miscellaneous Tasks

- Bump braces from 3.0.2 to 3.0.3 ([#618](https://github.com/MTES-MCT/ecobalyse/issues/618))
- Connect to PG using tunnel ([#643](https://github.com/MTES-MCT/ecobalyse/issues/643))
- Use psycopg2 binary package ([#655](https://github.com/MTES-MCT/ecobalyse/issues/655))


## [1.1.0](https://github.com/MTES-MCT/ecobalyse/compare/1.0.0..v1.1.0) (2024-06-28)



### 🚀 Features

- Store history of scores for example products ([#608](https://github.com/MTES-MCT/ecobalyse/issues/608))
- Show the source of processes/ingredients/materials in the explorer ([#630](https://github.com/MTES-MCT/ecobalyse/issues/630))

### 🪲 Bug Fixes

- Remove fake details ([#622](https://github.com/MTES-MCT/ecobalyse/issues/622))
- Fix fading UI activation status bug. ([#638](https://github.com/MTES-MCT/ecobalyse/issues/638))
- Don't export legacy fake details ([#642](https://github.com/MTES-MCT/ecobalyse/issues/642))
- YarnSize API param wasn't parsed when provided as float. ([#641](https://github.com/MTES-MCT/ecobalyse/issues/641))

### 📚 Documentation

- Enhance README ([#612](https://github.com/MTES-MCT/ecobalyse/issues/612))

### ⚙️ Miscellaneous Tasks

- Add semantic-pr to check PR titles ([#636](https://github.com/MTES-MCT/ecobalyse/issues/636))
- Dont't format `*.md` files ([#639](https://github.com/MTES-MCT/ecobalyse/issues/639))
- Automate release creation ([#632](https://github.com/MTES-MCT/ecobalyse/issues/632))
- Update Pipfile.lock ([#640](https://github.com/MTES-MCT/ecobalyse/issues/640))
- Removed Azadirachtine both on Brightway and SimaPro ([#619](https://github.com/MTES-MCT/ecobalyse/issues/619))


## 1.0.0 (2024-06-20)


### Fixup

- Simplify the previous PR fix-mass-computation-before-spinning ([#388](https://github.com/MTES-MCT/ecobalyse/issues/388))

### GitBook

- [#55] Mise en forme tableau d'étapes

### WIP

- Typing all the amounts with proper units

### WiP

- New country list including processes.

<!-- generated by git-cliff -->
