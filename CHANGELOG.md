# Changelog

## [2.3.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.2.0...v2.3.0) (2024-09-25)


### Features

* add link to changelog in app footer. ([#748](https://github.com/MTES-MCT/ecobalyse/issues/748)) ([efe88f5](https://github.com/MTES-MCT/ecobalyse/commit/efe88f57d4f61e74e84f62c5334a89d36fd767ee))
* airTransportRatio should depend on durability ([#757](https://github.com/MTES-MCT/ecobalyse/issues/757)) ([a0761d1](https://github.com/MTES-MCT/ecobalyse/commit/a0761d169469fddff7b9158f21de26d96a98ae0f))
* displayName in the textile explorer, reordered columns ([#737](https://github.com/MTES-MCT/ecobalyse/issues/737)) ([65d0ed5](https://github.com/MTES-MCT/ecobalyse/commit/65d0ed547566c193c5617147a35604e26b0bbe6d))


### Bug Fixes

* **api:** handle ingredient plane transport in food POST api. ([#769](https://github.com/MTES-MCT/ecobalyse/issues/769)) ([62587e2](https://github.com/MTES-MCT/ecobalyse/commit/62587e23593e459d66726b2221932092393790e5))
* check db integrity after building it ([#753](https://github.com/MTES-MCT/ecobalyse/issues/753)) ([5b41ef6](https://github.com/MTES-MCT/ecobalyse/commit/5b41ef6a6e1d4e799ed2abe7f21a321a87f9ae83))
* check uniqueness of JSON db primary keys at build time. ([#766](https://github.com/MTES-MCT/ecobalyse/issues/766)) ([0927954](https://github.com/MTES-MCT/ecobalyse/commit/0927954dfe472557f0e7c2e5e4aa24d1ce8572c2))
* decode and validate all optionals. ([#764](https://github.com/MTES-MCT/ecobalyse/issues/764)) ([87a7c6a](https://github.com/MTES-MCT/ecobalyse/commit/87a7c6af3e6edc12c2daa36192ad7f18fdefc444))
* encode physicalDurability parameter. ([#751](https://github.com/MTES-MCT/ecobalyse/issues/751)) ([f6750b8](https://github.com/MTES-MCT/ecobalyse/commit/f6750b8aea6dc0a4500a23465bfdbc0f0b627743))
* fix github CI python build setup. ([#762](https://github.com/MTES-MCT/ecobalyse/issues/762)) ([ea2cd9f](https://github.com/MTES-MCT/ecobalyse/commit/ea2cd9ff566129081ccf37caef25377717933c9d))
* fixed brightway explorer notebook error (wrong key) ([#745](https://github.com/MTES-MCT/ecobalyse/issues/745)) ([bc436c2](https://github.com/MTES-MCT/ecobalyse/commit/bc436c2d1520efb9de269cdadccf6587d1904468))
* in brightway explorer: improve display of compartment categories, if any ([#754](https://github.com/MTES-MCT/ecobalyse/issues/754)) ([757d5a6](https://github.com/MTES-MCT/ecobalyse/commit/757d5a6b50363995011e23bd5719adedb44d296f))
* stricter validation of POST json body passed to the textile API. ([#760](https://github.com/MTES-MCT/ecobalyse/issues/760)) ([a85bd8a](https://github.com/MTES-MCT/ecobalyse/commit/a85bd8aa506ce87b9b1310b6a4a933a591ce442e))
* **textile:** distribution step had no inland road transports added. ([#761](https://github.com/MTES-MCT/ecobalyse/issues/761)) ([d789d7d](https://github.com/MTES-MCT/ecobalyse/commit/d789d7d63a3dede6a4c2b07d43f6f43b9328a519))
* Update export outside of EU probability. ([#765](https://github.com/MTES-MCT/ecobalyse/issues/765)) ([c3fd9f2](https://github.com/MTES-MCT/ecobalyse/commit/c3fd9f2d5d0cc01232b31f9aa1ef657b33796292))

## [2.2.0](https://github.com/MTES-MCT/ecobalyse/compare/v2.1.1...v2.2.0) (2024-09-12)


### Features

* add app version to openapi docs in the root endpoint. ([#726](https://github.com/MTES-MCT/ecobalyse/issues/726)) ([5959c34](https://github.com/MTES-MCT/ecobalyse/commit/5959c3483600a2668390f6f0dd8a2778218436c0))
* add holistic durability in exploratory mode ([#721](https://github.com/MTES-MCT/ecobalyse/issues/721)) ([774faf3](https://github.com/MTES-MCT/ecobalyse/commit/774faf3ad553687e154d4f46bf1227ccd0571710))
* render app version details in the changelog. ([#725](https://github.com/MTES-MCT/ecobalyse/issues/725)) ([8f6ea50](https://github.com/MTES-MCT/ecobalyse/commit/8f6ea50aa1d11c37a0afc54e0de68a69cffbb1bb))


### Bug Fixes

* accept custom making complexity for upcycled garments. ([#723](https://github.com/MTES-MCT/ecobalyse/issues/723)) ([8f61547](https://github.com/MTES-MCT/ecobalyse/commit/8f61547f942b3fefd2129550125e9e7c0591cbaa))
* **ci:** check for ecobalyse-private when extracting the branch name ([#733](https://github.com/MTES-MCT/ecobalyse/issues/733)) ([23ae8a5](https://github.com/MTES-MCT/ecobalyse/commit/23ae8a564854ab6cdb4f38bc62f04a04a47ca3c4))
* don't add disabled step impacts to lifecycle totals. ([#719](https://github.com/MTES-MCT/ecobalyse/issues/719)) ([b6a7e1c](https://github.com/MTES-MCT/ecobalyse/commit/b6a7e1c4ff190acef8d0af0ee0f02b93b19ee32d))
* ensure express app is properly monitored by Sentry. ([#729](https://github.com/MTES-MCT/ecobalyse/issues/729)) ([84a39aa](https://github.com/MTES-MCT/ecobalyse/commit/84a39aa69a8771294195787401cd0e9e11403d1f))
* make scalingo not segfaulting. ([#728](https://github.com/MTES-MCT/ecobalyse/issues/728)) ([1de5140](https://github.com/MTES-MCT/ecobalyse/commit/1de5140c7e75bae20bd6afb58a0180d389dd3254))
* use fabric processes to compute fabric waste ([#712](https://github.com/MTES-MCT/ecobalyse/issues/712)) ([1cce55b](https://github.com/MTES-MCT/ecobalyse/commit/1cce55b229cc9e14de72037d381d06f2255fe0bd))

## [2.1.1](https://github.com/MTES-MCT/ecobalyse/compare/v2.1.0...v2.1.1) (2024-09-02)


### Bug Fixes

* **ui:** Hide unreleased entry in production version selector. ([#715](https://github.com/MTES-MCT/ecobalyse/issues/715)) ([78e4e8e](https://github.com/MTES-MCT/ecobalyse/commit/78e4e8e567b71677e70aaf5c1f3f09aea612fb32))

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
