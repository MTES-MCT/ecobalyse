# Changelog

## [2.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.0.0...v2.1.0) (2024-08-30)


### Features

* add a button to access material/ingredient details ([#703](https://github.com/MTES-MCT/ecobalyse/issues/703)) ([e6fa6fe](https://github.com/MTES-MCT/ecobalyse/commit/e6fa6fe1f58183c15d28d7c08949cd566391b980))
* add a version selector widget. ([#700](https://github.com/MTES-MCT/ecobalyse/issues/700)) ([a4ac751](https://github.com/MTES-MCT/ecobalyse/commit/a4ac75194530bad42bc673502f0413a19c4da80a))
* allow downloading explorer data as CSV. ([#705](https://github.com/MTES-MCT/ecobalyse/issues/705)) ([b0ce426](https://github.com/MTES-MCT/ecobalyse/commit/b0ce426d374744fb416188e17dcfdfb0a505b521))
* **api,textile:** make all country params optional. ([#713](https://github.com/MTES-MCT/ecobalyse/issues/713)) ([9c6724b](https://github.com/MTES-MCT/ecobalyse/commit/9c6724b7fcf2ebb5352f6c385fe80cc371957dd8))
* implement upcycling. ([#710](https://github.com/MTES-MCT/ecobalyse/issues/710)) ([b8b20ee](https://github.com/MTES-MCT/ecobalyse/commit/b8b20ee5f0b911eca035e10b7325ffd65adfb133))
* serve multiple app versions ([#627](https://github.com/MTES-MCT/ecobalyse/issues/627)) ([dcbbfaa](https://github.com/MTES-MCT/ecobalyse/commit/dcbbfaa1fae97daa45a342f1cb037f888a499d9f))
* version selector redirect to current location hash. ([#709](https://github.com/MTES-MCT/ecobalyse/issues/709)) ([4493fb8](https://github.com/MTES-MCT/ecobalyse/commit/4493fb87f500441c3a0c728c13973ebba2c18e65))


### Bug Fixes

* add github token to worklows ([#704](https://github.com/MTES-MCT/ecobalyse/issues/704)) ([053d920](https://github.com/MTES-MCT/ecobalyse/commit/053d92085c6f20f328be0d7bea41ba2d2bfaf581))
* add missing run command for score history ([#697](https://github.com/MTES-MCT/ecobalyse/issues/697)) ([82207dc](https://github.com/MTES-MCT/ecobalyse/commit/82207dce85e67e19f8abaf6bd8e31ef407c493d1))
* avoid scrolling to top when using the explorer. ([#702](https://github.com/MTES-MCT/ecobalyse/issues/702)) ([bc4332f](https://github.com/MTES-MCT/ecobalyse/commit/bc4332ffad9dfda4ae7f56b20afa78d779c1078f))
* broken comparator charts on desynced cache data. ([#706](https://github.com/MTES-MCT/ecobalyse/issues/706)) ([9445b71](https://github.com/MTES-MCT/ecobalyse/commit/9445b7107311bcace6761f5a2d039c1b0dc103c0))

## [2.0.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.2...v2.0.0) (2024-07-30)


### ⚠ BREAKING CHANGES

* **textile,api,ui,data:** update durability index computation ([#673](https://github.com/MTES-MCT/ecobalyse/issues/673))

### Features

* Brightway explorer download buttons ([#688](https://github.com/MTES-MCT/ecobalyse/issues/688)) ([d4cf712](https://github.com/MTES-MCT/ecobalyse/commit/d4cf712e52438c8b61abe362779a15daebfc3e24))
* download and upload buttons above the list of activities ([#689](https://github.com/MTES-MCT/ecobalyse/issues/689)) ([d27fa51](https://github.com/MTES-MCT/ecobalyse/commit/d27fa51c415f7af14d60cae8e7d1c7c459464553))
* **textile,api,ui,data:** update durability index computation ([#673](https://github.com/MTES-MCT/ecobalyse/issues/673)) ([a915613](https://github.com/MTES-MCT/ecobalyse/commit/a915613cbb3d600775f5001023e0e5e61dbb467b))


### Bug Fixes

* **food:** correct default origin for ingredients ([#683](https://github.com/MTES-MCT/ecobalyse/issues/683)) ([8b1ce73](https://github.com/MTES-MCT/ecobalyse/commit/8b1ce7363c280d1fc298bcd3aee644f1b6f4ea42))
* update pull examples data ([#690](https://github.com/MTES-MCT/ecobalyse/issues/690)) ([bfbef62](https://github.com/MTES-MCT/ecobalyse/commit/bfbef62fa63a36119c9930678ed766a317c0ee2a))

## [1.3.2](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.1...v1.3.2) (2024-07-23)


### Bug Fixes

* data-dir is needed before build ([#681](https://github.com/MTES-MCT/ecobalyse/issues/681)) ([4407c91](https://github.com/MTES-MCT/ecobalyse/commit/4407c91f2a45661f6e9cd73a3d9bee238ceb864e))

## [1.3.1](https://github.com/MTES-MCT/ecobalyse/compare/v1.3.0...v1.3.1) (2024-07-23)


### Bug Fixes

* add ecobalyse-private to release please ([#679](https://github.com/MTES-MCT/ecobalyse/issues/679)) ([1c8d9c0](https://github.com/MTES-MCT/ecobalyse/commit/1c8d9c0b9cbdb3490650abf7800e8279457d6d9d))

## [1.3.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.2.0...v1.3.0) (2024-07-23)


### Features

* Allow to switch to a different DB while navigating ([#674](https://github.com/MTES-MCT/ecobalyse/issues/674)) ([6672e4f](https://github.com/MTES-MCT/ecobalyse/commit/6672e4f2adf9f2ffce0859b3c00b2b3385047332))
* display current version in the footer ([#677](https://github.com/MTES-MCT/ecobalyse/issues/677)) ([90178b1](https://github.com/MTES-MCT/ecobalyse/commit/90178b19fdccb5230170781e72e58d6374db264a))
* **food,ui:** render agribalyse process name in ingredient selector. ([#659](https://github.com/MTES-MCT/ecobalyse/issues/659)) ([d6c732f](https://github.com/MTES-MCT/ecobalyse/commit/d6c732f7a1081fb75e749c466c1b2e69de1fbbbf))


### Bug Fixes

* add missing condition in `release-please` workflow ([#671](https://github.com/MTES-MCT/ecobalyse/issues/671)) ([be4e18f](https://github.com/MTES-MCT/ecobalyse/commit/be4e18f43e320e3bd1e740306ea551a438617d0a))
* **api:** Fix invalid openapi format ([#666](https://github.com/MTES-MCT/ecobalyse/issues/666)) ([9e8f170](https://github.com/MTES-MCT/ecobalyse/commit/9e8f17014891846acdff2d6cfaffd41fc5ed4ccc))
* **api:** Fix material shares sum rounding precision error. ([#670](https://github.com/MTES-MCT/ecobalyse/issues/670)) ([f0f8358](https://github.com/MTES-MCT/ecobalyse/commit/f0f8358802d6180d6c43a5fe7374f1271bd82193))

## [1.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.1.1...v1.2.0) (2024-07-10)


### Features

* add a link to the new product category gform. ([#626](https://github.com/MTES-MCT/ecobalyse/issues/626)) ([036864c](https://github.com/MTES-MCT/ecobalyse/commit/036864c105af216e935404109dc659a49fa33391))
* clarify ingredients names (bio, conv) and origin (France, EU, Hors-EU) ([#653](https://github.com/MTES-MCT/ecobalyse/issues/653)) ([cae1776](https://github.com/MTES-MCT/ecobalyse/commit/cae177697645ad151439c3ef7a0e069018a53893))

## [1.1.1](https://github.com/MTES-MCT/ecobalyse/compare/v1.1.0...v1.1.1) (2024-07-10)


### Bug Fixes

* **api,ui:** Use custom waste/complexity and product defaults. ([#648](https://github.com/MTES-MCT/ecobalyse/issues/648)) ([fd9e465](https://github.com/MTES-MCT/ecobalyse/commit/fd9e4658470c2243baf53abfff3eec09066bba9d))
* avoid building detailed impacts in production. ([#656](https://github.com/MTES-MCT/ecobalyse/issues/656)) ([3b5d79b](https://github.com/MTES-MCT/ecobalyse/commit/3b5d79beaca1a77087202731f4fc28e08a6d7a72))
* Rename organic cotton. ([#647](https://github.com/MTES-MCT/ecobalyse/issues/647)) ([5549065](https://github.com/MTES-MCT/ecobalyse/commit/554906580cac60f21f66e09671681fa08482a514))
* **ui:** Round Dtex number in the web UI. ([#649](https://github.com/MTES-MCT/ecobalyse/issues/649)) ([9ad4597](https://github.com/MTES-MCT/ecobalyse/commit/9ad459794888fd9d883e2f34971f4bc286a76076))

## [1.1.0](https://github.com/MTES-MCT/ecobalyse/compare/v1.0.0...v1.1.0) (2024-06-27)


### Features

* show the source of processes/ingredients/materials in the explorer ([#630](https://github.com/MTES-MCT/ecobalyse/issues/630)) ([40fb9ca](https://github.com/MTES-MCT/ecobalyse/commit/40fb9cac7cd9ea3027b876bff7433960add8ecac))
* store history of scores for example products ([#608](https://github.com/MTES-MCT/ecobalyse/issues/608)) ([999d1e7](https://github.com/MTES-MCT/ecobalyse/commit/999d1e72f4b3ccc496a1f5b2458abfcfb5654b67))


### Bug Fixes

* don't export legacy fake details ([#642](https://github.com/MTES-MCT/ecobalyse/issues/642)) ([79027b5](https://github.com/MTES-MCT/ecobalyse/commit/79027b51553c1680486fa3e4429caea999f44508))
* fix fading UI activation status bug. ([#638](https://github.com/MTES-MCT/ecobalyse/issues/638)) ([1fa37b7](https://github.com/MTES-MCT/ecobalyse/commit/1fa37b7a5b7a0919d2e2a405cfe52166425c2140))
* remove fake details ([#622](https://github.com/MTES-MCT/ecobalyse/issues/622)) ([8bb07e4](https://github.com/MTES-MCT/ecobalyse/commit/8bb07e47e95c208733f0c9c5f848cedc41a8bb83))
* yarnSize API param wasn't parsed when provided as float. ([#641](https://github.com/MTES-MCT/ecobalyse/issues/641)) ([76ce131](https://github.com/MTES-MCT/ecobalyse/commit/76ce1311dd55d4fe844b920166755f8e708486da))
